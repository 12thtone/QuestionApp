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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            
            //NSLog(@"%lu", (unsigned long)tabbersList.count);
            
            self.theTabbersList = [tabbersList copy];
            //NSLog(@"%lu", (unsigned long)self.theTabbersList.count);
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
        //NSString *question = [object objectForKey:@"questionTitle"];
        cell.textLabel.text = username;
        //cell.detailTextLabel.text = question;
    }];
    
    //NSLog(@"%@", [[[self.theTabbersList objectAtIndex:indexPath.row] objectForKey:@"tabReceiver"] username]);
    
    //cell.textLabel.text = [[self.theTabbersList objectAtIndex:indexPath.row] objectForKey:@"username"];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)exitTabberList:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"viewNewTabberProfile"]) {
        
        //UINavigationController *navigationController = segue.destinationViewController;
        //AllTabbersTableViewController *allTabbersTableViewController = (AllTabbersTableViewController * )navigationController.topViewController;
        
        //NSLog(@"%@", self.user);
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFUser *user = [[self.theTabbersList objectAtIndex:indexPath.row] objectForKey:@"tabMaker"];
        
        NSLog(@"%@", user);
                
        ProfileTableViewController *profileTableViewController = segue.destinationViewController;
        profileTableViewController.userFromTabList = user;
        
        //AllTabbersTableViewController.user = self.user;
    }
}

@end
