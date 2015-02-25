//
//  SignupViewController.h
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameSignupField;
@property (weak, nonatomic) IBOutlet UITextField *usernameSignupField;
@property (weak, nonatomic) IBOutlet UITextField *passwordSignupField;
@property (weak, nonatomic) IBOutlet UITextField *emailSignupField;

- (IBAction)createAccount:(id)sender;

@end
