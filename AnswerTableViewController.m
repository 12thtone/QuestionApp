//
//  AnswerTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AnswerTableViewController.h"
#import <Parse/Parse.h>
#import "AddAnswerViewController.h"

@interface AnswerTableViewController ()
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) NSMutableArray *answerArray;
@property (weak, nonatomic) NSArray *theAnswers;

@end

@implementation AnswerTableViewController

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
    
    self.questionTextView.text = [self.question objectForKey:@"questionText"];
    
    //NSLog(@"To Go %@", self.question);
    
    //self.answerArray = [self.question objectForKey:@"answers"];
    //NSLog(@"Array: %@", self.answerArray);
    
    //NSLog(@"%@", self.question);
    /*
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    */
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
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [self.question createdAt];
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"answerAuthor" equalTo:self.question];
    [query fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            cell.textLabel.text = [objects objectForKey:@"answerText"];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    */
    /*
    PFObject *answers = [PFObject objectWithClassName:@"Answer"];
    [answers fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            cell.textLabel.text = [answers objectForKey:@"answerText"];
        }
    }];
    */
    PFObject *answers = [PFObject objectWithClassName:@"Answer"];
    [answers fetchIfNeeded];
    NSLog(@"%@", answers);
    cell.textLabel.text = [object objectForKey:@"answerText"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
    
    return cell;
}


#pragma mark - UITableViewDelegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addAnswer"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //PFObject *object = [self.objects objectAtIndex:indexPath.row];
        //NSLog(@"%@", self.question);
        AddAnswerViewController *addAnswerViewController = (AddAnswerViewController *)segue.destinationViewController;
        addAnswerViewController.question = self.question;
    }
}

@end
