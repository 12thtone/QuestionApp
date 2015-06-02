//
//  AddQuestionViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AddJokeViewController.h"
#import <Parse/Parse.h>
#import "JokeTableViewController.h"
#import "Reachability.h"
#import "DataSource.h"

@interface AddJokeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) NSString *statusString;
@property (weak, nonatomic) IBOutlet UISegmentedControl *jokeStatusSegment;

- (IBAction)savePressed:(UIBarButtonItem *)sender;
- (IBAction)cancelPressed:(UIBarButtonItem *)sender;
- (IBAction)indexChanged:(id)sender;

@end

@implementation AddJokeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeue-Light" size:22],NSFontAttributeName, [UIColor purpleColor], NSForegroundColorAttributeName, nil]];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Add a Joke", nil)];
    
    self.statusString = @"Got One for Ya";
}

- (IBAction)savePressed:(UIBarButtonItem *)sender {
    
    NSString *title = [self.titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *body = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([title length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"We'll need at least a title."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        
        if ([[DataSource sharedInstance] filterForProfanity:title] == NO && [[DataSource sharedInstance] filterForProfanity:body] == NO) {
            [self saveQuestion];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                                message:@"We found a banned word."
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
    
    
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)indexChanged:(id)sender {
    switch (self.jokeStatusSegment.selectedSegmentIndex)
    {
        case 0:
            self.statusString = @"Got One for Ya";
            break;
        case 1:
            self.statusString = @"Finish My Joke";
            break;
        default:
            break;
    }
}

- (void)saveQuestion
{
    NSString *jokeString = [NSString stringWithFormat:@"\n%@\n", self.textField.text];
    
    NSNumber *voteCount = [NSNumber numberWithInt:1];
    
    PFObject *newJoke = [PFObject objectWithClassName:@"Question"];
    newJoke[@"questionTitle"] = self.titleField.text;
    newJoke[@"questionText"] = jokeString;
    newJoke[@"voteQuestion"] = voteCount;
    newJoke[@"status"] = self.statusString;
    newJoke[@"author"] = [PFUser currentUser];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                            message:@"There's a problem with the internet connection. We'll get your joke up ASAP!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [newJoke saveEventually];
    } else {
        
        [newJoke saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end