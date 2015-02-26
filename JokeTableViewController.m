//
//  QuestionTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "JokeTableViewController.h"
#import <Parse/Parse.h>
#import "ResponseTableViewController.h"
#import "ProfileTableViewController.h"
#import "DataSource.h"
#import "JokeTableViewCell.h"

@interface JokeTableViewController ()

@property (weak, nonatomic) PFUser *tappedUser;
@property (strong, nonatomic) NSMutableArray *theObjects;
@property (strong, nonatomic) NSMutableArray *theAuthors;

@end

@implementation JokeTableViewController

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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    
    [self.tabBarController.tabBar setBarTintColor:[UIColor redColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor redColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Light" size:18], NSFontAttributeName, nil]];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"New Jokes", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self questionQuery];
    [self loadObjects];
}

#pragma mark - PFQuery

- (void)questionQuery {
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    NSMutableArray *authorArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            [authorArray addObject:[object objectForKey:@"author"]];
            [objectArray addObject:object];
            
            self.theObjects = [objectArray copy];
            self.theAuthors = [authorArray copy];
        }
        
        [self.tableView reloadData];
    }];
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
    
    JokeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JokeTVC" forIndexPath:indexPath];
    
    PFUser *user = [object objectForKey:@"author"];
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
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *date = [object createdAt];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTapped:)];
    [tap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [cell.usernameLabel addGestureRecognizer:tap];
    
    UITapGestureRecognizer *voteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveVote:)];
    [voteTap setNumberOfTapsRequired:1];
    voteTap.enabled = YES;
    [cell.voteLabel addGestureRecognizer:voteTap];
    
    cell.statusLabel.text = [object objectForKey:@"status"];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.jokeTitleLabel.text = [object objectForKey:@"questionTitle"];
    cell.voteLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"voteQuestion"]];
    
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
    
    if ([segue.identifier isEqualToString:@"showJoke"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        ResponseTableViewController *answerTableViewController = (ResponseTableViewController *)segue.destinationViewController;
        answerTableViewController.joke = object;
    }
}

- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFObject *object = [self.objects objectAtIndex:tapIndexPath.row];
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfile = object;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

#pragma mark - Votes

- (void)saveVote:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFObject *newVote = [self.theObjects objectAtIndex:tapIndexPath.row];
    
    [newVote incrementKey:@"voteQuestion" byAmount:[NSNumber numberWithInt:1]];
    
    [newVote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"+1"
                                                                message:@"Thanks for your vote!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [self loadObjects];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:[error.userInfo objectForKey:@"error"]
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

@end