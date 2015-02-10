//
//  AddQuestionViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AddQuestionViewController.h"
//#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "QuestionTableViewController.h"

@interface AddQuestionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *textField;
- (IBAction)savePressed:(UIBarButtonItem *)sender;
- (IBAction)cancelPressed:(UIBarButtonItem *)sender;

@end

@implementation AddQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    }
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveQuestion
{
    
    PFObject *newQuestion = [PFObject objectWithClassName:@"Question"];
    newQuestion[@"questionTitle"] = self.titleField.text;
    newQuestion[@"questionText"] = self.textField.text;
    newQuestion[@"author"] = [PFUser currentUser];
    
    [newQuestion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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