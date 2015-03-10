//
//  AddAnswerViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AddResponseViewController.h"
#import <Parse/Parse.h>
#import "ResponseTableViewController.h"
#import "Reachability.h"

@interface AddResponseViewController ()

@property (weak, nonatomic) IBOutlet UILabel *jokeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) NSString *response;

- (IBAction)save:(UIBarButtonItem *)sender;

@end

@implementation AddResponseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    self.jokeTitleLabel.text = [self.joke objectForKey:@"questionTitle"];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    
    self.response = [self.responseTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([self.response length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"We're hoping for an answer."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        [self saveAnswer];
    }
}

- (void)saveAnswer
{
    NSNumber *voteCount = [NSNumber numberWithInt:1];
    
    PFObject *newResponse = [PFObject objectWithClassName:@"Answer"];
    newResponse[@"answerText"] = self.response;
    newResponse[@"vote"] = voteCount;
    newResponse[@"answerQuestion"] = self.joke;
    newResponse[@"answerAuthor"] = [PFUser currentUser];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                            message:@"There's a problem with the internet connection. We'll get your response up ASAP!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [newResponse saveEventually];
    } else {
        
        [newResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
}

@end
