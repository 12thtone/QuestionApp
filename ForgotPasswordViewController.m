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

- (IBAction)submitEmail:(id)sender;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitEmail:(id)sender {
    NSString *email = [self.userEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [PFUser requestPasswordResetForEmailInBackground:email];
}
@end
