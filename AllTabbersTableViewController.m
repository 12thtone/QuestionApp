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
#import "AllTabbersTableViewCell.h"

@interface AllTabbersTableViewController () <UITableViewDataSource, UITableViewDelegate>

- (IBAction)exitTabberList:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSMutableArray *theTabbersList;

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
        self.objectsPerPage = 15;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    self.tabBarController.tabBar.alpha = 0.9;
    [self.tabBarController.tabBar setBarTintColor:[UIColor purpleColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    /*
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor purpleColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Light" size:18], NSFontAttributeName, nil]];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"All Tabbers", nil)];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.canDisplayBannerAds = YES;
    
    [self tabberQuery];
    [self loadObjects];
}

# pragma mark - PFQuery

- (NSArray *)tabberQuery {
    NSMutableArray *tabbersList = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
    
    [query whereKey:@"tabReceiver" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFUser *aUser in objects) {
            [tabbersList addObject:aUser];
            
            self.theTabbersList = [tabbersList copy];
        }
        [self.tableView reloadData];
    }];
    
    return tabbersList;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)self.theTabbersList.count);
    return [self.theTabbersList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AllTabbersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allTabbersTVCell" forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *date = [[self.theTabbersList objectAtIndex:indexPath.row] createdAt];
    
    PFUser *user = [[self.theTabbersList objectAtIndex:indexPath.row] objectForKey:@"tabMaker"];
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
        PFUser *user = [[self.theTabbersList objectAtIndex:indexPath.row] objectForKey:@"tabMaker"];
        
        NSLog(@"%@", user);
                
        ProfileTableViewController *profileTableViewController = segue.destinationViewController;
        profileTableViewController.userFromTabList = user;
        profileTableViewController.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}

@end
