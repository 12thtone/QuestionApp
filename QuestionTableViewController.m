//
//  QuestionTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "QuestionTableViewController.h"
#import <Parse/Parse.h>
#import "AnswerTableViewController.h"
#import "ProfileTableViewController.h"

@interface QuestionTableViewController ()
- (IBAction)logout:(id)sender;

@property (weak, nonatomic) UIButton *usernameButton;

@end

@implementation QuestionTableViewController

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
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    [self queryForTable];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.tableView reloadData];
    //[self loadObjects:0 clear:NO];
    [self queryForTable];
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self count];
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self.usernameButton addTarget:self action:@selector(tapProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *questionLabel = (UILabel *)[self.view viewWithTag:101];
    self.usernameButton = (UIButton *)[self.view viewWithTag:102];
    UILabel *dateLabel = (UILabel *)[self.view viewWithTag:103];
    /*
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [object createdAt];
    
    PFUser *user = [object objectForKey:@"author"];
    [user fetchIfNeeded];
    PFFile *pictureFile = [user objectForKey:@"picture"];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            [self.userImage setImage:[UIImage imageWithData:data]];
            questionLabel.text = [object objectForKey:@"questionTitle"];
            usernameLabel.text = [user objectForKey:@"username"];
            dateLabel.text = [dateFormatter stringFromDate:date];
        }
        else {
            NSLog(@"no data!");
        }
    }];
    */
    /*
    PFFile *pictureFile = [user objectForKey:@"picture"];
    
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            
            [self.userImage setImage:[UIImage imageWithData:data]];
            NSLog(@"%@", [user objectForKey:@"username"]);
        }
        else {
            NSLog(@"no data!");
        }
    }];
    */
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [object createdAt];
    
    PFUser *user = [object objectForKey:@"author"];
    [user fetchIfNeeded];
    
    questionLabel.text = [object objectForKey:@"questionTitle"];
    [self.usernameButton setTitle:[user objectForKey:@"username"] forState:UIControlStateNormal];
    dateLabel.text = [dateFormatter stringFromDate:date];
    
    return cell;
}

- (PFQuery *)queryForTable {
    
    // Create a query
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query orderByDescending:@"createdAt"];
    /*
    // Follow relationship
    if ([PFUser currentUser]) {
        [query whereKey:@"author" equalTo:[PFUser currentUser]];
    }
    else {
        // I added this so that when there is no currentUser, the query will not return any data
        // Without this, when a user signs up and is logged in automatically, they briefly see a table with data
        // before loadObjects is called and the table is refreshed.
        // There are other ways to get an empty query, of course. With the below, I know that there
        // is no such column with the value in the database.
        [query whereKey:@"nonexistent" equalTo:@"doesn't exist"];
    }*/
    
    return query;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showQuestion"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        NSLog(@"%@", object);
        
        AnswerTableViewController *answerTableViewController = (AnswerTableViewController *)segue.destinationViewController;
        answerTableViewController.question = object;
    }
}

- (void) tapProfile:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfile = object;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

- (IBAction)logout:(UIBarButtonItem *)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (IBAction)seeProfile:(id)sender {
}

@end