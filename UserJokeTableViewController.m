//
//  UserQuestionTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/18/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "UserJokeTableViewController.h"
#import <Parse/Parse.h>
#import "ResponseTableViewController.h"
#import "DataSource.h"
#import "UserJokeTableViewCell.h"

@interface UserJokeTableViewController ()
@property (weak, nonatomic) PFUser *tappedUser;
//@property (strong, nonatomic) NSMutableArray *questionObject;
@property (strong, nonatomic) NSMutableArray *theQuestions;
@property (strong, nonatomic) NSMutableArray *theVotes;
@property (strong, nonatomic) NSMutableArray *theObjects;
@property (strong, nonatomic) NSMutableArray *theAuthors;
- (IBAction)exitUserQuestions:(UIBarButtonItem *)sender;

@end

@implementation UserJokeTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Question"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Question";
        
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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [[DataSource sharedInstance] queryForTable:self.parseClassName];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self queryForTable];
    [self questionQuery];
    //[self loadObjects];
}

- (NSArray *)questionQuery {
    NSMutableArray *questionArray = [[NSMutableArray alloc] init];
    NSMutableArray *voteArray = [[NSMutableArray alloc] init];
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    NSMutableArray *authorArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    
    [query whereKey:@"author" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            [questionArray addObject:[object objectForKey:@"questionTitle"]];
            [voteArray addObject:[object objectForKey:@"voteQuestion"]];
            [authorArray addObject:[object objectForKey:@"author"]];
            [objectArray addObject:object];
            
            self.theQuestions = [questionArray copy];
            self.theVotes = [voteArray copy];
            self.theObjects = [objectArray copy];
            self.theAuthors = [authorArray copy];
        }
        NSLog(@"%@", self.theAuthors);
    }];
    
    return objectArray;
}

#pragma mark - PFQueryTableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.theObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    UserJokeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserQuestionTVCell" forIndexPath:indexPath];
    
    //PFUser *user = [self.user objectForKey:@"author"];
    PFUser *user = self.user;
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSString *username = user.username;
        cell.usernameLabel.text = username;
        
        PFFile *pictureFile = [user objectForKey:@"picture"];
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error){
                
                [cell.userImage setImage:[UIImage imageWithData:data]];
            }
            else {
                NSLog(@"no data!");
            }
        }];
    }];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *date = [[self.theObjects objectAtIndex:indexPath.row] createdAt];
    /*
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTapped:)];
    [tap setNumberOfTapsRequired:1];
    [cell.usernameLabel addGestureRecognizer:tap];
    */
    UITapGestureRecognizer *voteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveVote:)];
    [voteTap setNumberOfTapsRequired:1];
    voteTap.enabled = YES;
    [cell.voteLabel addGestureRecognizer:voteTap];
    
    cell.statusLabel.text = [[self.theObjects objectAtIndex:indexPath.row] objectForKey:@"status"];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.questionTitleLabel.text = [[self.theObjects objectAtIndex:indexPath.row] objectForKey:@"questionTitle"];
    cell.voteLabel.text = [NSString stringWithFormat:@"%@", [[self.theObjects objectAtIndex:indexPath.row] objectForKey:@"voteQuestion"]];
    
    if ([cell.voteLabel.text  isEqual:@"1"]) {
        cell.voteVotesLabel.text = @"Vote";
    } else {
        cell.voteVotesLabel.text = @"Votes";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showUserAnswers"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.theObjects objectAtIndex:indexPath.row];
        
        //NSLog(@"sdfbsdfbsdfb%@", [object objectId]);
        
        ResponseTableViewController *answerTableViewController = (ResponseTableViewController *)segue.destinationViewController;
        answerTableViewController.question = object;
    }
}
/*
- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    //NSLog(@"%@", sender);
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    PFObject *object = [self.objects objectAtIndex:tapIndexPath.row];
    
    //NSLog(@"OBJECTS QQQ: %@", self.objects[0]);
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfile = object;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}
*/
#pragma mark - Votes

- (void)saveVote:(UITapGestureRecognizer *)sender {
    
    //NSLog(@"self.questionObject: %@", self.questionObject);
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    //NSLog(@"%@", [[self.questionObject objectForKey:@"voteQuestion"] objectAtIndex:tapIndexPath.row]);
    //NSLog(@"%@", self.questionObject);
    
    PFObject *newVote = [self.theObjects objectAtIndex:tapIndexPath.row];
    //NSLog(@"%@", newVote);
    //PFObject *newVote = [self.questionObject objectAtIndex:tapIndexPath.row];
    [newVote incrementKey:@"voteQuestion" byAmount:[NSNumber numberWithInt:1]];
    //[newVote saveInBackground];
    
    //NSLog(@"VOTE: %@", newVote);
    
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

- (IBAction)exitUserQuestions:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end