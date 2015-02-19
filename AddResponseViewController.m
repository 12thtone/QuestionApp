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

@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;
@property (weak, nonatomic) NSString *answer;
//- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;

@end

@implementation AddResponseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.questionTitleLabel.text = [self.question objectForKey:@"questionTitle"];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    
    self.answer = [self.answerTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([self.answer length] == 0) {
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
    
    PFObject *newAnswer = [PFObject objectWithClassName:@"Answer"];
    newAnswer[@"answerText"] = self.answer;
    newAnswer[@"vote"] = voteCount;
    newAnswer[@"answerQuestion"] = self.question;
    newAnswer[@"answerAuthor"] = [PFUser currentUser];
    
    //NSLog(@"%@", self.question);
    
    [newAnswer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
