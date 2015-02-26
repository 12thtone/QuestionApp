//
//  AllTabbersTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/16/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AllTabbersTableViewController.h"
#import <Parse/Parse.h>
#import "ProfileTableViewController.h"

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
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    self.tabBarController.tabBar.alpha = 0.9;
    [self.tabBarController.tabBar setBarTintColor:[UIColor purpleColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor purpleColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Light" size:18], NSFontAttributeName, nil]];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"All Tabbers", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tabberQuery];
    [self loadObjects];
}

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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PFUser *user = [[self.theTabbersList objectAtIndex:indexPath.row] objectForKey:@"tabMaker"];
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSString *username = user.username;
        cell.textLabel.text = username;
    }];
    
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
    }
}

@end
