//
//  QuestionTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "QuestionTableViewController.h"
#import <Parse/Parse.h>
#import "AnswerTableViewController.h"
#import "ProfileTableViewController.h"

@interface QuestionTableViewController ()
- (IBAction)logout:(id)sender;
- (IBAction)tapProfile:(UITapGestureRecognizer *)sender;

@property (weak, nonatomic) UIImageView *userImage;

@end

@implementation QuestionTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *questionLabel = (UILabel *)[self.view viewWithTag:101];
    UILabel *usernameLabel = (UILabel *)[self.view viewWithTag:102];
    UILabel *dateLabel = (UILabel *)[self.view viewWithTag:103];
    self.userImage = (UIImageView *)[self.view viewWithTag:104];
    /*
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [object createdAt];
    
    PFUser *user = [object objectForKey:@"author"];
    [user fetchIfNeeded];
    PFFile *pictureFile = [user objectForKey:@"picture"];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            [self.userImage setImage:[UIImage imageWithData:data]];
            questionLabel.text = [object objectForKey:@"questionTitle"];
            usernameLabel.text = [user objectForKey:@"username"];
            dateLabel.text = [dateFormatter stringFromDate:date];
        }
        else {
            NSLog(@"no data!");
        }
    }];
    */
    
    PFUser *user = [object objectForKey:@"author"];
    [user fetchIfNeeded];
    PFFile *pictureFile = [user objectForKey:@"picture"];
    
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
            NSDate *date = [object createdAt];
            
            [self.userImage setImage:[UIImage imageWithData:data]];
            questionLabel.text = [object objectForKey:@"questionTitle"];
            usernameLabel.text = [user objectForKey:@"username"];
            dateLabel.text = [dateFormatter stringFromDate:date];
        }
        else {
            NSLog(@"no data!");
        }
    }];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showQuestion"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        AnswerTableViewController *answerTableViewController = (AnswerTableViewController *)segue.destinationViewController;
        answerTableViewController.question = object;
    }
}

- (void) tapProfile:(UITapGestureRecognizer *)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userProfile = object;
    [self presentViewController:profileVC animated:YES completion:nil];
}

- (IBAction)logout:(UIBarButtonItem *)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (IBAction)seeProfile:(id)sender {
}

@end