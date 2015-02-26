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
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor redColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Light" size:18], NSFontAttributeName, nil]];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Add a Joke", nil)];
    
    self.statusString = @"Got One for Ya";
}

- (IBAction)savePressed:(UIBarButtonItem *)sender {
    
    NSString *title = [self.titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([title length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"We'll need at least a title."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        [self saveQuestion];
        [self dismissViewControllerAnimated:YES completion:nil];
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
    NSNumber *voteCount = [NSNumber numberWithInt:1];
    
    PFObject *newJoke = [PFObject objectWithClassName:@"Question"];
    newJoke[@"questionTitle"] = self.titleField.text;
    newJoke[@"questionText"] = self.textField.text;
    newJoke[@"voteQuestion"] = voteCount;
    newJoke[@"status"] = self.statusString;
    newJoke[@"author"] = [PFUser currentUser];
    
    [newJoke saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
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

@end