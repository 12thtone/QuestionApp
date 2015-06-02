//
//  TabsTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/16/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "TabsTableViewController.h"
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>
#import "ResponseTableViewController.h"
#import "ProfileTableViewController.h"
#import "DataSource.h"
#import "TabsTableViewCell.h"

@interface TabsTableViewController () <MFMailComposeViewControllerDelegate>

- (IBAction)jokeType:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *jokeTypeControl;

@property (nonatomic, assign) BOOL gotOne;
@property (nonatomic, assign) BOOL finishMy;

@property (nonatomic, strong) PFObject *messageData;

@end

@implementation TabsTableViewController

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
        self.objectsPerPage = 20;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    self.tabBarController.tabBar.alpha = 0.9;
    [self.tabBarController.tabBar setBarTintColor:[UIColor purpleColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.canDisplayBannerAds = YES;
}

#pragma mark - PFQuery

- (PFQuery *)queryForTable {
    
    if (self.gotOne == YES) {
        PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
        
        [query whereKey:@"tabMaker" equalTo:[PFUser currentUser]];
        [query includeKey:@"tabReceiver"];
        
        PFQuery *queryQ = [PFQuery queryWithClassName:@"Question"];
        
        [queryQ whereKey:@"status" equalTo:@"Got One for Ya"];
        [queryQ whereKey:@"author" matchesKey:@"tabReceiver" inQuery:query];
        [queryQ orderByDescending:@"createdAt"];
        
        return queryQ;
        
    } else if (self.finishMy == YES) {
        PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
        
        [query whereKey:@"tabMaker" equalTo:[PFUser currentUser]];
        [query includeKey:@"tabReceiver"];
        
        PFQuery *queryQ = [PFQuery queryWithClassName:@"Question"];
        
        [queryQ whereKey:@"status" equalTo:@"Finish My Joke"];
        [queryQ whereKey:@"author" matchesKey:@"tabReceiver" inQuery:query];
        [queryQ orderByDescending:@"createdAt"];
        
        return queryQ;
        
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
        
        [query whereKey:@"tabMaker" equalTo:[PFUser currentUser]];
        [query includeKey:@"tabReceiver"];

        PFQuery *queryQ = [PFQuery queryWithClassName:@"Question"];
        [queryQ whereKey:@"author" matchesKey:@"tabReceiver" inQuery:query];
        [queryQ orderByDescending:@"createdAt"];
        
        return queryQ;
    }
    
}

#pragma mark - PFQueryTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    TabsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TabsTVCell" forIndexPath:indexPath];
    
    PFUser *user = [self.objects objectAtIndex:indexPath.row][@"author"];
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        cell.usernameLabel.text = [object objectForKey:@"username"];
        
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
    NSDate *date = [[self.objects objectAtIndex:indexPath.row] createdAt];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTapped:)];
    [tap setNumberOfTapsRequired:1];
    [cell.usernameLabel addGestureRecognizer:tap];
    
    [cell.upVoteButton addTarget:self action:@selector(saveVote:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareButton addTarget:self action:@selector(shareOrReport:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    if ([segue.identifier isEqualToString:@"showTabResponses"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        ResponseTableViewController *answerTableViewController = (ResponseTableViewController *)segue.destinationViewController;
        answerTableViewController.joke = object;
    }
}

- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFUser *user = [self.objects objectAtIndex:tapIndexPath.row];
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfile = user;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

- (IBAction)exitUserQuestions:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
                                                                message:@"Thanks for your UpVote!"
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

- (void)shareOrReport:(id)sender {
    
    UITableViewCell *tappedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForCell:tappedCell];
    
    self.messageData = [self.objects objectAtIndex:tapIndexPath.row];
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:nil
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Share", @"Report a Violation", nil];
    [deleteAlert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        NSString *messageBody = [NSString stringWithFormat:@"%@ found a joke for you on Jokadoo!\n\n%@ wrote the following:\n\n%@\n\nTo view this joke, and tons more like it, download Jokadoo!\n\nhttp://www.12thtone.com", [[PFUser currentUser] username], [[[self.messageData objectForKey:@"author"] fetchIfNeeded] objectForKey:@"username"], [self.messageData objectForKey:@"questionText"]];
        
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
    
    if (buttonIndex == 2) {
        [self reportViolation];
    }
}

- (void)reportViolation {
    MFMailComposeViewController *violationReport = [[MFMailComposeViewController alloc] init];
    violationReport.mailComposeDelegate = self;
    
    NSLog(@"%@", self.messageData);
    
    NSString *emailBody = [NSString stringWithFormat:@"Reporting User: %@ \n\nViolating User: %@ \n\nPost Number: %@ \n\nAdditional Details: \n\nWe will review your report within 24 hours. Rule violations are taken very seriously.\n\nThank you very much for helping to make Jokadoo a better place!", [[PFUser currentUser] username], [[self.messageData objectForKey:@"author"] username], [[self.messageData objectForKey:@"author"] objectId]];
    
    [violationReport setSubject:@"Jokadoo Violation - URGENT"];
    [violationReport setMessageBody:emailBody isHTML:NO];
    [violationReport setToRecipients:[NSArray arrayWithObjects:@"contact@12thtone.com",nil]];
    
    [self presentViewController:violationReport animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)jokeType:(id)sender {
    switch (self.jokeTypeControl.selectedSegmentIndex)
    {
            
        case 0:
            if (self.objects == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Tabs, Yet"
                                                                    message:@"Keep Tabs on Some Funny Users."
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                break;
            } else {
                self.gotOne = NO;
                self.finishMy = NO;
                [self loadObjects];
                break;
            }
        case 1:
            if (self.objects == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Tabs, Yet"
                                                                    message:@"Keep Tabs on Some Funny Users."
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                break;
            } else {
                self.gotOne = YES;
                self.finishMy = NO;
                [self loadObjects];
                break;
            }
        case 2:
            if (self.objects == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Tabs, Yet"
                                                                    message:@"Keep Tabs on Some Funny Users."
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                break;
            } else {
                self.finishMy = YES;
                self.gotOne = NO;
                [self loadObjects];
                break;
            }
        default:
            break;
    }
    
}

@end