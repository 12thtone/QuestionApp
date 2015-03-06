//
//  LoginViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *login;
@property (weak, nonatomic) IBOutlet UIButton *needAccount;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassword;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationItem setTitle:@""];
    
    [self.login addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    self.login.layer.borderWidth = 1;
    self.login.layer.borderColor = [UIColor purpleColor].CGColor;
    self.login.layer.cornerRadius = 8;
    self.login.layer.masksToBounds = YES;
    
    //[self.needAccount addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
    self.needAccount.layer.borderWidth = 1;
    self.needAccount.layer.borderColor = [UIColor purpleColor].CGColor;
    self.needAccount.layer.cornerRadius = 8;
    self.needAccount.layer.masksToBounds = YES;
    
    //[self.forgotPassword addTarget:self action:@selector(newPassword:) forControlEvents:UIControlEventTouchUpInside];
    self.forgotPassword.layer.borderWidth = 1;
    self.forgotPassword.layer.borderColor = [UIColor purpleColor].CGColor;
    self.forgotPassword.layer.cornerRadius = 8;
    self.forgotPassword.layer.masksToBounds = YES;
    
}


- (void)login:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"We need a username and password."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

@end
