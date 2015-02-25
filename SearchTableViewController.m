//
//  SearchTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/24/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "SearchTableViewController.h"
#import <Parse/Parse.h>
#import "ResponseTableViewController.h"
#import "ProfileTableViewController.h"
#import "DataSource.h"
#import "SearchTableViewCell.h"

@interface SearchTableViewController () <UISearchBarDelegate>

@property (weak, nonatomic) PFUser *tappedUser;

@property (strong, nonatomic) NSMutableArray *theUsers;

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) NSMutableArray *fixedResults;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchTableViewController

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
    
    self.searchBar.delegate = self;
    
    [[DataSource sharedInstance] queryForTable:self.parseClassName];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadObjects];
}

- (void)searchQuery {
    
    NSMutableArray *userArray = [[NSMutableArray alloc] init];
    
    NSString *searchString = self.searchBar.text;
    NSLog(@"%@", searchString);
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"description" matchesRegex:searchString modifiers:@"i"];
    
    PFQuery *query2 = [PFUser query];
    [query2 whereKey:@"realName" matchesRegex:searchString modifiers:@"i"];
    //[query orderByDescending:@"createdAt"];
    
    PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            NSLog(@"dfghdfgh: %@", object);
            [userArray addObject:object];
            NSLog(@"in for: %@", userArray);
            
        }
        
        self.theUsers = [userArray copy];
        NSLog(@"outside: %@", self.theUsers);
        [self.tableView reloadData];
        
    }];
    
}

#pragma mark - PFQueryTableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", (unsigned long)[self.theUsers count]);
    
    return [self.theUsers count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *date = [[self.theUsers objectAtIndex:indexPath.row] createdAt];
    
    PFFile *pictureFile = [[self.theUsers objectAtIndex:indexPath.row] objectForKey:@"picture"];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            
            [cell.userImage setImage:[UIImage imageWithData:data]];
        }
        else {
            NSLog(@"no data!");
        }
    }];
    
    cell.fullNameLabel.text = [[self.theUsers objectAtIndex:indexPath.row] objectForKey:@"realName"];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.usernameLabel.text = [[self.theUsers objectAtIndex:indexPath.row] username];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"searchToProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFUser *object = [self.theUsers objectAtIndex:indexPath.row];
        
        //NSLog(@"sdfbsdfbsdfb%@", [object objectId]);
        
        ProfileTableViewController *profileTableViewController = (ProfileTableViewController *)segue.destinationViewController;
        profileTableViewController.userFromTabList = object;
    }
}

#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self searchQuery];
}

@end