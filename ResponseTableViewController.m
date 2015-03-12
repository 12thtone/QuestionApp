//
//  AnswerTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "ResponseTableViewController.h"
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import "AddResponseViewController.h"
#import "DataSource.h"
#import "ResponseTableViewCell.h"
#import "ProfileTableViewController.h"
#import "FullResponseTableViewController.h"

@interface ResponseTableViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *jokeTextView;

@end

@implementation ResponseTableViewController

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
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    self.tabBarController.tabBar.alpha = 0.9;
    [self.tabBarController.tabBar setBarTintColor:[UIColor purpleColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    CGRect frame = self.jokeTextView.frame;
    frame.size.height = self.jokeTextView.contentSize.height;
    self.jokeTextView.frame = frame;
    
    self.jokeTextView.text = [self.joke objectForKey:@"questionText"];
    [self.jokeTextView sizeToFit];
    
    
    [self.jokeTextView.textContainer setSize:self.jokeTextView.frame.size];
    [self.jokeTextView layoutIfNeeded];
    [self.jokeTextView setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.canDisplayBannerAds = YES;
    
    [self loadObjects];
}

#pragma mark - PFQuery

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query whereKey:@"answerQuestion" equalTo:self.joke];
    [query orderByDescending:@"vote"];
    
    return query;
}

#pragma mark - PFQueryTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    ResponseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResponseTVC" forIndexPath:indexPath];
        
    PFUser *user = [self.objects objectAtIndex:indexPath.row][@"answerAuthor"];
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTapped:)];
    [tap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [cell.usernameLabel addGestureRecognizer:tap];
    
    [cell.upVoteButton addTarget:self action:@selector(saveVote:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareButton addTarget:self action:@selector(shareJoke:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *date = [self.joke createdAt];
    
    cell.responseLabel.text = [self.objects objectAtIndex:indexPath.row][@"answerText"];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.voteLabel.text = [NSString stringWithFormat:@"%@", [self.objects objectAtIndex:indexPath.row][@"vote"]];
    
    if ([cell.voteLabel.text  isEqual:@"1"]) {
        cell.voteVotesLabel.text = @"Vote";
    } else {
        cell.voteVotesLabel.text = @"Votes";
    }

    return cell;
}

#pragma mark - Votes

- (void)saveVote:(id)sender {
    
    UITableViewCell *tappedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForCell:tappedCell];
    
    PFObject *newVote = [self.objects objectAtIndex:tapIndexPath.row];
    [newVote incrementKey:@"vote" byAmount:[NSNumber numberWithInt:1]];
        
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
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ found a joke response for you on Jokadoo!\n\n%@ wrote the following:\n\n%@\n\nTo view this joke, and tons more like it, download Jokadoo!\n\nhttp://www.12thtone.com", [[PFUser currentUser] username], [[[messageData objectForKey:@"answerAuthor"] fetchIfNeeded] objectForKey:@"username"], [messageData objectForKey:@"answerText"]];
    
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addResponse"]) {
        AddResponseViewController *addAnswerViewController = (AddResponseViewController *)segue.destinationViewController;
        addAnswerViewController.joke = self.joke;
    }
    
    if ([segue.identifier isEqualToString:@"showResponse"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        FullResponseTableViewController *fullAnswerTableViewController = (FullResponseTableViewController *)segue.destinationViewController;
        fullAnswerTableViewController.fullResponse = object;
        fullAnswerTableViewController.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}

- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint tapLocation = [sender locationInView:self.tableView];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    PFObject *object = [self.objects objectAtIndex:tapIndexPath.row];
        
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfileAnswer = object;
    profileVC.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

@end
