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
@property (strong, nonatomic) NSMutableArray *theObjects;
@property (strong, nonatomic) NSMutableArray *theAuthors;

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
    [self.questionTextView sizeToFit];
    [self.questionTextView.textContainer setSize:self.questionTextView.frame.size];
    [self.questionTextView layoutIfNeeded];
    [self.questionTextView setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self answerQuery];
    [self loadObjects];
}

- (NSArray *)answerQuery {
    NSMutableArray *answerArray = [[NSMutableArray alloc] init];
    NSMutableArray *voteArray = [[NSMutableArray alloc] init];
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    NSMutableArray *authorArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    
    [query whereKey:@"answerQuestion" equalTo:self.question];
    [query orderByDescending:@"vote"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //NSLog(@"BLOCK PRODUCT: %lu", (unsigned long)object.count);
        for (PFObject *object in objects) {
            //NSLog(@"BLOCK PRODUCT: %@", [objects objectForKey:@"answerText"]);
            [answerArray addObject:[object objectForKey:@"answerText"]];
            [voteArray addObject:[object objectForKey:@"vote"]];
            [authorArray addObject:[object objectForKey:@"answerAuthor"]];
            [objectArray addObject:object];
            NSLog(@"Answer ARRAY: %lu", (unsigned long)answerArray.count);
            
            self.theAnswers = [answerArray copy];
            self.theVotes = [voteArray copy];
            self.theObjects = [objectArray copy];
            self.theAuthors = [authorArray copy];
        }
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
    /*
    PFUser *author = [self.question objectForKey:@"author"];
    [author fetchIfNeeded];
    NSLog(@"%@", [author username]);
    */
        
    PFUser *user = [self.theAuthors objectAtIndex:indexPath.row];
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        cell.usernameLabel.text = [object objectForKey:@"username"];
    }];
    
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
    //cell.usernameLabel.text = [user username];
    //cell.usernameLabel.text = [[[self.theAuthors objectAtIndex:indexPath.row] fetchIfNeeded] objectForKey:@"username"];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.voteLabel.text = [NSString stringWithFormat:@"%@", [self.theVotes objectAtIndex:indexPath.row]];
    
    if ([cell.voteLabel.text  isEqual:@"1"]) {
        cell.voteVotesLabel.text = @"Vote";
    } else {
        cell.voteVotesLabel.text = @"Votes";
    }

    return cell;
}

#pragma mark - Votes

- (void)saveVote:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFObject *newVote = [self.theObjects objectAtIndex:tapIndexPath.row];
    [newVote incrementKey:@"vote" byAmount:[NSNumber numberWithInt:1]];
    //[newVote saveInBackground];
    
    NSLog(@"VOTE: %@", newVote);
    
    [newVote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"+1"
                                                                message:@"Thanks for your vote!"
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
    
    //PFObject *object1 = [self.objects objectAtIndex:tapIndexPath.row];
    PFObject *object = [self.theObjects objectAtIndex:tapIndexPath.row];
    
    NSLog(@"PROFILE: %@", object);
    
    //////////// Make a PFUser?
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfileAnswer = object;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

@end
