//
//  MyJokesTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 3/14/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "MyJokesTableViewController.h"
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import "ResponseTableViewController.h"
#import "DataSource.h"
#import "MyJokesTableViewCell.h"

@interface MyJokesTableViewController () <UIAlertViewDelegate>

@property (strong, nonatomic)PFObject *postToDelete;

- (IBAction)exitUserQuestions:(UIBarButtonItem *)sender;

@end

@implementation MyJokesTableViewController

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
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    self.tabBarController.tabBar.alpha = 0.9;
    [self.tabBarController.tabBar setBarTintColor:[UIColor purpleColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.canDisplayBannerAds = YES;
    
    [self loadObjects];
}

#pragma mark - PFQuery

- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    PFUser *currentUser = [PFUser currentUser];
    
    [query whereKey:@"author" equalTo:currentUser];
    [query orderByDescending:@"createdAt"];
    
    return query;
}

#pragma mark - PFQueryTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    MyJokesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyJokesTVC" forIndexPath:indexPath];
    
    PFUser *user = [PFUser currentUser];
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
    NSDate *date = [[self.objects objectAtIndex:indexPath.row] createdAt];
    
    [cell.deleteButton addTarget:self action:@selector(confirmDelete:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.statusLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"status"];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.jokeTitleLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"questionTitle"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"meToResponses"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        ResponseTableViewController *answerTableViewController = (ResponseTableViewController *)segue.destinationViewController;
        answerTableViewController.joke = object;
    }
}

- (IBAction)exitUserQuestions:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delete

- (void)confirmDelete:(id)sender {
    
    UITableViewCell *tappedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *tapIndexPath = [self.tableView indexPathForCell:tappedCell];
    self.postToDelete = [self.objects objectAtIndex:tapIndexPath.row];
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                          message:@"Are you sure you want to delete this joke?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
    [deleteAlert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        [self.postToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Deleted"
                                                                    message:@"Everyone's looking forward to your next joke!"
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
}

@end