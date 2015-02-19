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

@interface AddResponseViewController ()

@property (weak, nonatomic) IBOutlet UILabel *jokeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) NSString *response;
//- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;

@end

@implementation AddResponseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
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
/*
- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/
- (void)saveAnswer
{
    NSNumber *voteCount = [NSNumber numberWithInt:1];
    
    PFObject *newResponse = [PFObject objectWithClassName:@"Answer"];
    newResponse[@"answerText"] = self.response;
    newResponse[@"vote"] = voteCount;
    newResponse[@"answerQuestion"] = self.joke;
    newResponse[@"answerAuthor"] = [PFUser currentUser];
    
    //NSLog(@"%@", self.question);
    
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
    
    //PFObject *newAnswer = [PFObject objectWithClassName:@"Question"];
    //PFObject *newAnswer = [self.question objectForKey:@"answers"];
    /*
    PFObject *currentQuestion = [PFObject objectWithClassName:@"Question"];
    PFRelation *relation = [newAnswer relationForKey:@"questionsAnswer"];
    [relation addObject:newAnswer];
    [currentQuestion saveInBackground];
    */
    //newAnswer[@"questionsAnswer"] = self.answerTextView.text;
    /////////////////////////////////
    /*
    [self.question addObject:@[self.answer] forKey:@"answers"];
    //[self.question saveInBackground];
    
    [self.question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //NSLog(@"%@", self.answer);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:[error.userInfo objectForKey:@"error"]
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
    */
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
