//
//  AnswerTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AnswerTableViewController.h"
#import <Parse/Parse.h>
#import "AddAnswerViewController.h"
#import "DataSource.h"
#import "AnswerTableViewCell.h"
#import "ProfileTableViewController.h"

@interface AnswerTableViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
//@property (weak, nonatomic) NSMutableArray *answerArray;
@property (strong, nonatomic) NSMutableArray *theAnswers;

@end

@implementation AnswerTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Answer"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Answer";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.questionTextView.text = [self.question objectForKey:@"questionText"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self answerQuery];
    //self.theAnswers = [[DataSource sharedInstance] answerQuery:self.question].mutableCopy;
    //NSLog(@"iiiiiiii%lu", (unsigned long)self.theAnswers.count);
    [self loadObjects];
}

- (NSArray *)answerQuery {
    NSMutableArray *answerArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    
    [query whereKey:@"answerQuestion" equalTo:self.question];
    [query findObjectsInBackgroundWithBlock:^(NSArray *object, NSError *error) {
        //NSLog(@"BLOCK PRODUCT: %lu", (unsigned long)object.count);
        for (PFObject *objects in object) {
            //NSLog(@"BLOCK PRODUCT: %@", [objects objectForKey:@"answerText"]);
            [answerArray addObject:[objects objectForKey:@"answerText"]];
            //NSLog(@"ANSWER ARRAY: %@", answerArray);
        }
        self.theAnswers = [answerArray copy];
    }];
    
    return answerArray;
}

#pragma mark - PFQueryTableViewController

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"iiiiiiii%lu", (unsigned long)self.theAnswers.count);
    return self.theAnswers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    //static NSString *CellIdentifier = @"Cell";
    
    AnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerTVC" forIndexPath:indexPath];
    /*
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    */
    
    PFUser *author = [self.question objectForKey:@"author"];
    [author fetchIfNeeded];
    NSLog(@"%@", [author username]);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTapped:)];
    [tap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [cell.usernameLabel addGestureRecognizer:tap];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [self.question createdAt];
    
    //cell.textLabel.text = [self.theAnswers objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
    
    cell.answerTextView.text = [self.theAnswers objectAtIndex:indexPath.row];
    cell.usernameLabel.text = [author username];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    //cell.voteButton.text = [post valueForKey:@"title"];

    return cell;
}

- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    //UITableViewCell* tappedCell = [self.tableView cellForRowAtIndexPath:tapIndexPath];
    
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    PFObject *object = [self.objects objectAtIndex:tapIndexPath.row];
    
    NSLog(@"OBJECTS: %@", self.objects[0]);
    
    //PFUser *authorToGo = [self.objects objectForKey:@"author"];
    //[author fetchIfNeeded];
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfileAnswer = object;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addAnswer"]) {
        AddAnswerViewController *addAnswerViewController = (AddAnswerViewController *)segue.destinationViewController;
        addAnswerViewController.question = self.question;
    }
}

@end
