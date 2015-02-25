//
//  FullAnswerTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/18/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "FullResponseTableViewController.h"
#import <Parse/Parse.h>
#import "ProfileTableViewController.h"

@interface FullResponseTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteVotesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (strong, nonatomic) PFUser *fullResponseUser;

@end

@implementation FullResponseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *date = [self.fullResponse createdAt];
    
    [self.fullResponse fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *pictureFile = [self.fullResponse objectForKey:@"answerAuthor"][@"picture"];
        
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error){
                
                [self.userImage setImage:[UIImage imageWithData:data]];
                self.usernameLabel.text = [self.fullResponse objectForKey:@"answerAuthor"][@"username"];
            }
            else {
                NSLog(@"no data!");
            }
        }];
    }];
    
    if ([self.voteCountLabel.text isEqual:@"1"]) {
        self.voteVotesLabel.text = @"Vote";
    } else {
        self.voteVotesLabel.text = @"Votes";
    }
    
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    self.voteCountLabel.text = [NSString stringWithFormat:@"%@", [self.fullResponse objectForKey:@"vote"]];
    self.responseTextView.text = [self.fullResponse objectForKey:@"answerText"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileTapped:)];
    [tap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [self.usernameLabel addGestureRecognizer:tap];
    
    UITapGestureRecognizer *voteVotesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveVote:)];
    [voteVotesTap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [self.voteVotesLabel addGestureRecognizer:voteVotesTap];
    
    UITapGestureRecognizer *voteCountTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveVote:)];
    [voteCountTap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [self.voteCountLabel addGestureRecognizer:voteCountTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Navigation

- (void)userProfileTapped:(UITapGestureRecognizer *)sender {
    
    self.fullResponseUser = [self.fullResponse objectForKey:@"answerAuthor"];
    
    ProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    profileVC.userFromFullAnswerList = self.fullResponseUser;
    
    [self presentViewController:profileVC animated:YES completion:nil];
}

#pragma mark - Votes

- (void)saveVote:(UITapGestureRecognizer *)sender {
    
    //PFObject *newVote = self.fullAnswer objectForKey:@"objectId"];
    [self.fullResponse incrementKey:@"vote" byAmount:[NSNumber numberWithInt:1]];
    
    NSLog(@"VOTE: %@", self.fullResponse);
    
    [self.fullResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"+1"
                                                                message:@"Thanks for your vote!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:[error.userInfo objectForKey:@"error"]
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

@end
