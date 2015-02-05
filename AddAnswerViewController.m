//
//  AddAnswerViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "AddAnswerViewController.h"
#import <Parse/Parse.h>
#import "AnswerTableViewController.h"

@interface AddAnswerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;
@property (weak, nonatomic) NSString *answer;
//- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;

@end

@implementation AddAnswerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.questionTitleLabel.text = [self.question objectForKey:@"questionTitle"];
        
    // Check to see if note is not nil, which let's us know that the note
    // had already been saved.
    /*
     if (self.answer != nil) {
     self.titleTextField.text = [self.note objectForKey:@"title"];
     self.contentTextView.text = [self.note objectForKey:@"content"];
     }*/
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
    
    //PFObject *newAnswer = [PFObject objectWithClassName:@"Question"];
    //PFObject *newAnswer = [self.question objectForKey:@"answers"];
    /*
    PFObject *currentQuestion = [PFObject objectWithClassName:@"Question"];
    PFRelation *relation = [newAnswer relationForKey:@"questionsAnswer"];
    [relation addObject:newAnswer];
    [currentQuestion saveInBackground];
    */
    //newAnswer[@"questionsAnswer"] = self.answerTextView.text;
    
    [self.question addObject:@[self.answer] forKey:@"answers"];
    [self.question saveInBackground];
    
    [self.question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"%@", self.answer);
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
/*
 - (void)updateNote
 {
 
 PFQuery *query = [PFQuery queryWithClassName:@"Post"];
 
 // Retrieve the object by id
 [query getObjectInBackgroundWithId:[self.note objectId] block:^(PFObject *oldNote, NSError *error) {
 
 if (error) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
 message:[error.userInfo objectForKey:@"error"]
 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [alertView show];
 }
 else {
 oldNote[@"title"] = self.titleTextField.text;
 oldNote[@"content"] = self.contentTextView.text;
 
 [oldNote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
 if (succeeded) {
 [self.navigationController popViewControllerAnimated:YES];
 } else {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
 message:[error.userInfo objectForKey:@"error"]
 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [alertView show];
 }
 }];
 }
 
 }];
 
 }*/

@end
