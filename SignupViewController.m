//
//  SignupViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>
#import "DataSource.h"

@interface SignupViewController ()

@property (nonatomic, strong) NSString *username;

@property (weak, nonatomic) IBOutlet UITextField *nameSignupField;
@property (weak, nonatomic) IBOutlet UITextField *usernameSignupField;
@property (weak, nonatomic) IBOutlet UITextField *passwordSignupField;
@property (weak, nonatomic) IBOutlet UITextField *emailSignupField;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = NO;
    
    [self.createAccount addTarget:self action:@selector(agreeToRules:) forControlEvents:UIControlEventTouchUpInside];
    self.createAccount.layer.borderWidth = 1;
    self.createAccount.layer.borderColor = [UIColor purpleColor].CGColor;
    self.createAccount.layer.cornerRadius = 8;
    self.createAccount.layer.masksToBounds = YES;
}

- (void)agreeToRules:(id)sender {
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Rules and Terms"
                                                           message:@"Please confirm that you have read and agree to abide by the Jokadoo Rules and Terms of Service."
                                                          delegate:self
                                                 cancelButtonTitle:@"Disagree"
                                                 otherButtonTitles:@"Agree", nil];
    [confirmAlert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self createNewAccount];
    }
}

- (void)createNewAccount {
    
    NSString *fullName = [self.nameSignupField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.username = [self.usernameSignupField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordSignupField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailSignupField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *needString = [NSString stringWithFormat:@"We need first and last name, username, password, and email."];
    NSString *takenString = [NSString stringWithFormat:@"%@ is already taken.", self.username];
    
    if ([fullName length] == 0 || [self.username length] == 0 || [password length] == 0 || [email length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:needString
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if (![self usernameQuery]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:takenString
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if ([[DataSource sharedInstance] filterForProfanity:fullName] == YES || [[DataSource sharedInstance] filterForProfanity:self.username] == YES) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                            message:@"We found a banned word."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"placeholder.png"]);
        PFFile *imageFile = [PFFile fileWithName:@"Profileimage.png" data:imageData];
        
        PFUser *newUser = [PFUser user];
        newUser[@"realName"] = fullName;
        newUser[@"picture"] = imageFile;
        newUser.username = self.username;
        newUser.password = password;
        newUser.email = email;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

#pragma mark - PFQuery

- (NSMutableArray *)usernameQuery {
    NSMutableArray *usernameArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"username" equalTo:self.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            [usernameArray addObject:[object objectForKey:@"answerText"]];
        }
    }];
    
    return usernameArray;
}

@end
