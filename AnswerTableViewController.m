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
@property (strong, nonatomic) NSMutableArray *theAnswers;
@property (strong, nonatomic) NSMutableArray *theVotes;

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
    //NSLog(@"iiiiiiii%lu", (unsigned long)self.theAnswers.count);
    [self loadObjects];
}

- (NSArray *)answerQuery {
    NSMutableArray *answerArray = [[NSMutableArray alloc] init];
    NSMutableArray *voteArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    
    [query whereKey:@"answerQuestion" equalTo:self.question];
    [query findObjectsInBackgroundWithBlock:^(NSArray *object, NSError *error) {
        //NSLog(@"BLOCK PRODUCT: %lu", (unsigned long)object.count);
        for (PFObject *objects in object) {
            //NSLog(@"BLOCK PRODUCT: %@", [objects objectForKey:@"answerText"]);
            [answerArray addObject:[objects objectForKey:@"answerText"]];
            [voteArray addObject:[objects objectForKey:@"vote"]];
            //NSLog(@"VOTE ARRAY: %@", voteArray[0]);
        }
        self.theAnswers = [answerArray copy];
        self.theVotes = [voteArray copy];
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
    return self.theAnswers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    AnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerTVC" forIndexPath:indexPath];
    
    PFUser *author = [self.question objectForKey:@"author"];
    [author fetchIfNeeded];
    NSLog(@"%@", [author username]);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTapped:)];
    [tap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [cell.usernameLabel addGestureRecognizer:tap];
    
    UITapGestureRecognizer *voteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveVote:)];
    [voteTap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [cell.voteLabel addGestureRecognizer:voteTap];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [self.question createdAt];
    
    cell.answerTextView.text = [self.theAnswers objectAtIndex:indexPath.row];
    cell.usernameLabel.text = [author username];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.voteLabel.text = [NSString stringWithFormat:@"%@", [self.theVotes objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - Votes

- (void)saveVote:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFObject *newVote = [self.objects objectAtIndex:tapIndexPath.row];
    
    [newVote incrementKey:@"vote" byAmount:[NSNumber numberWithInt:1]];
    
    [newVote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"+1"
                                                                message:@"Thanks for you vote!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:[error.userInfo objectForKey:@"error"]
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
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

- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFObject *object = [self.objects objectAtIndex:tapIndexPath.row];
    
    NSLog(@"OBJECTS: %@", self.objects[0]);
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfileAnswer = object;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

@end
