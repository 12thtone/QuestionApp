//
//  ForgotPasswordViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/19/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import <Parse/Parse.h>

@interface ForgotPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UIButton *submitEmail;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.submitEmail addTarget:self action:@selector(submitEmail:) forControlEvents:UIControlEventTouchUpInside];
    self.submitEmail.layer.borderWidth = 1;
    self.submitEmail.layer.borderColor = [UIColor purpleColor].CGColor;
    self.submitEmail.layer.cornerRadius = 8;
    self.submitEmail.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)submitEmail:(id)sender {
    
    if (self.userEmail.text.length == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Please enter your email address."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        
        NSString *email = [self.userEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [PFUser requestPasswordResetForEmailInBackground:email];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check Your Email"
                                                            message:@"We sent you a link to reset your password. You'll be Jokinit soon!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
