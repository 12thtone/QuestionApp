//
//  AllTabbersTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/16/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AllTabbersTableViewController.h"
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import "ProfileTableViewController.h"
#import "DataSource.h"
#import "AllTabbersTableViewCell.h"

@interface AllTabbersTableViewController () 

- (IBAction)exitTabberList:(UIBarButtonItem *)sender;

@end

@implementation AllTabbersTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Tab"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Tab";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 2;
    }
    return self;
}

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

# pragma mark - PFQuery

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query whereKey:@"tabReceiver" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    
    return query;
}

#pragma mark - PFQueryTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    AllTabbersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allTabbersTVCell" forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *date = [[self.objects objectAtIndex:indexPath.row] createdAt];
    
    PFUser *user = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"tabMaker"];
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSString *username = user.username;
        cell.usernameLabel.text = username;
        cell.fullNameLabel.text = [user objectForKey:@"realName"];
        
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
    
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    
    return cell;
}

- (IBAction)exitTabberList:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"viewNewTabberProfile"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFUser *user = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"tabMaker"];
        
        NSLog(@"%@", user);
                
        ProfileTableViewController *profileTableViewController = segue.destinationViewController;
        profileTableViewController.userFromTabList = user;
        profileTableViewController.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}

@end
