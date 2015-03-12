//
//  QuestionTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "JokeTableViewController.h"
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import "ResponseTableViewController.h"
#import "ProfileTableViewController.h"
#import "DataSource.h"
#import "JokeTableViewCell.h"

@interface JokeTableViewController ()

@property (weak, nonatomic) PFUser *tappedUser;

- (IBAction)jokeType:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *jokeTypeControl;

@property (nonatomic, assign) BOOL gotOne;
@property (nonatomic, assign) BOOL finishMy;

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
        self.objectsPerPage = 5;
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
    self.tabBarController.tabBar.alpha = 0.9;
    [self.tabBarController.tabBar setBarTintColor:[UIColor purpleColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.canDisplayBannerAds = YES;
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationItem setTitle:@""];
    
    [self loadObjects];
}

#pragma mark - PFQuery

- (PFQuery *)queryForTable {
    
    if (self.gotOne == YES) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        
        [query whereKey:@"status" equalTo:@"Got One for Ya"];
        [query orderByDescending:@"createdAt"];
        
        return query;
    } else if (self.finishMy == YES) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        
        [query whereKey:@"status" equalTo:@"Finish My Joke"];
        [query orderByDescending:@"createdAt"];
        
        return query;
    } else {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        
        [query orderByDescending:@"createdAt"];
        
        return query;
    }
}

#pragma mark - PFQueryTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    JokeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JokeTVC" forIndexPath:indexPath];
    
        PFUser *user = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"author"];
        [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSString *username = user.username;
            cell.usernameLabel.text = username;
            
            PFFile *pictureFile = [user objectForKey:@"picture"];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error){
                    
                    [cell.userImage setImage:[UIImage imageWithData:data]];
                    cell.userImage.layer.cornerRadius = 8.0;
                    cell.userImage.layer.borderColor = [[UIColor grayColor] CGColor];
                    cell.userImage.layer.borderWidth = 1.0;
                    cell.userImage.layer.masksToBounds = YES;
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
        
        [cell.upVoteButton addTarget:self action:@selector(saveVote:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(shareJoke:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.statusLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"status"];
        cell.dateLabel.text = [dateFormatter stringFromDate:date];
        cell.jokeTitleLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"questionTitle"];
        cell.voteLabel.text = [NSString stringWithFormat:@"%@", [[self.objects objectAtIndex:indexPath.row] objectForKey:@"voteQuestion"]];
        
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
        NSLog(@"SEGUE: %@", object);
        ResponseTableViewController *answerTableViewController = (ResponseTableViewController *)segue.destinationViewController;
        answerTableViewController.joke = object;
    }
}

- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFObject *object = [self.objects objectAtIndex:tapIndexPath.row];
    NSLog(@"SEGUE: %@", object);
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfile = object;
    profileVC.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

#pragma mark - Votes

- (void)saveVote:(id)sender {
    
    UITableViewCell *tappedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForCell:tappedCell];
    
    PFObject *newVote = [self.objects objectAtIndex:tapIndexPath.row];
    
    [newVote incrementKey:@"voteQuestion" byAmount:[NSNumber numberWithInt:1]];
    
    [newVote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"+1"
                                                                message:@"Thanks for your vote!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [self loadObjects];
            ((UIButton *)sender).enabled = NO;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:[error.userInfo objectForKey:@"error"]
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

#pragma mark - Sharing

- (void)shareJoke:(id)sender {
    
    UITableViewCell *tappedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForCell:tappedCell];
    
    PFObject *messageData = [self.objects objectAtIndex:tapIndexPath.row];
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ found a joke for you on Jokadoo!\n\n%@ wrote the following:\n\n%@\n\nTo view this joke, and tons more like it, download Jokadoo!\n\nhttp://www.12thtone.com", [[PFUser currentUser] username], [[[messageData objectForKey:@"author"] fetchIfNeeded] objectForKey:@"username"], [messageData objectForKey:@"questionText"]];
    
    NSMutableArray *jokeToShare = [NSMutableArray array];
    [jokeToShare addObject:messageBody];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:jokeToShare applicationActivities:nil];
    
    if (!([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        activityVC.popoverPresentationController.sourceView = self.view;
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    if (UIActivityTypeMail) {
        [activityVC setValue:@"Jokadoo" forKey:@"subject"];
    }
}

- (IBAction)jokeType:(id)sender {
    switch (self.jokeTypeControl.selectedSegmentIndex)
    {
        case 0:
            self.gotOne = NO;
            self.finishMy = NO;
            [self loadObjects];
            break;
        case 1:
            self.gotOne = YES;
            self.finishMy = NO;
            [self loadObjects];
            break;
        case 2:
            self.finishMy = YES;
            self.gotOne = NO;
            [self loadObjects];
            break;
        default:
            break;
    }
}

@end