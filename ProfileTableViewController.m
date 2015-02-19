//
//  ProfileTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/9/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Parse/Parse.h>
#import "AllTabbersTableViewController.h"
#import "UserJokeTableViewController.h"

@interface ProfileTableViewController ()
- (IBAction)closeProfile:(id)sender;
- (IBAction)keepTabs:(id)sender;
- (IBAction)viewUserQuestions:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *usernameProfile;
@property (weak, nonatomic) IBOutlet UITextView *descriptionProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UILabel *totalTabbers;
//@property (weak, nonatomic) IBOutlet UIButton *tabbersLabel;
//@property (weak, nonatomic) IBOutlet UILabel *tabbersLabel;
@property (weak, nonatomic) PFUser *user;
@property (strong, nonatomic) NSMutableArray *theTabbers;

@end

@implementation ProfileTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.user = [[PFUser alloc] init];
    
    if (self.userProfile) {
        self.user = [self.userProfile objectForKey:@"author"];
        
    } else if (self.userProfileAnswer) {
        self.user = [self.userProfileAnswer objectForKey:@"answerAuthor"];
        //NSLog(@"Fresh from the AnswerTVC %@", self.userProfileAnswer);
    } else if (self.userFromTabList) {
        self.user = self.userFromTabList;
    } else {
        self.user = self.userFromFullAnswerList;
    }
    
    [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *pictureFile = [self.user objectForKey:@"picture"];
        
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error){
                
                [self.imageProfile setImage:[UIImage imageWithData:data]];
                self.descriptionProfile.text = [self.user objectForKey:@"description"];
                self.usernameProfile.text = [self.user objectForKey:@"username"];
            }
            else {
                NSLog(@"no data!");
            }
        }];
    }];
    
    [self tabbersQuery];
    /*
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listTabbers:)];
    [tap setNumberOfTapsRequired:1];
    tap.enabled = YES;
    [self.tabbersLabel addGestureRecognizer:tap];
    */
    /*
    NSString *totalTabberString = [NSString stringWithFormat:@"%lu", (unsigned long)self.theTabbers.count];
    
    self.totalTabbers.text = totalTabberString;
    */
    //[user fetchIfNeeded];
    /*
    PFFile *pictureFile = [user objectForKey:@"picture"];
    
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            
            [self.imageProfile setImage:[UIImage imageWithData:data]];
            self.descriptionProfile.text = [user objectForKey:@"description"];
            self.usernameProfile.text = [user objectForKey:@"username"];
        }
        else {
            NSLog(@"no data!");
        }
    }];*/
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self tabbersQuery];
}

- (void)setTabData:(NSMutableArray *)tabData {
    [self tabbersQuery];
    self.theTabbers = tabData;
    NSLog(@"%lu", (unsigned long)tabData.count);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeProfile:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)keepTabs:(id)sender {
    
    NSMutableArray *tabbersList = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
    
    [query whereKey:@"tabReceiver" equalTo:self.user];
    [query whereKey:@"tabMaker" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFUser *aUser in objects) {
            [tabbersList addObject:aUser];
        }
            NSString *alreadyString = [NSString stringWithFormat:@"You're already keeping tabs on %@", [self.user username]];
        
        //NSLog(@"%lu", (unsigned long)tabbersList.count);
        //NSLog(@"%@", tabbersList);
        
            if (tabbersList.count == 0) {
                [self saveTabs];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                    message:alreadyString
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
    }];
    
    ////////////////////////
    /*
    PFObject *newTab = [PFObject objectWithClassName:@"Tab"];
    newTab[@"tabMaker"] = [PFUser currentUser];
    newTab[@"tabReceiver"] = self.user;
    
    NSString *userString = [NSString stringWithFormat:@"You're keeping tabs on %@", [self.user username]];
    
    [newTab saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Tabs!"
                                                                message:userString
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:[error.userInfo objectForKey:@"error"]
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
     */
}

- (IBAction)viewUserQuestions:(id)sender {
}

- (void)saveTabs {
    PFObject *newTab = [PFObject objectWithClassName:@"Tab"];
    newTab[@"tabMaker"] = [PFUser currentUser];
    newTab[@"tabReceiver"] = self.user;
    
    NSString *userString = [NSString stringWithFormat:@"You're keeping tabs on %@", [self.user username]];
    
    [newTab saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Tabs!"
                                                                message:userString
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

- (NSArray *)tabbersQuery {
    NSMutableArray *tabberArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
    
    [query whereKey:@"tabReceiver" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFUser *tabber in objects) {
            [tabberArray addObject:tabber];
            
            self.theTabbers = [tabberArray copy];
        }
        
        NSString *totalTabberString = [NSString stringWithFormat:@"%lu", (unsigned long)self.theTabbers.count];
        self.totalTabbers.text = totalTabberString;
        
        UIButton *tabButtonTextSet = (UIButton *)[self.view viewWithTag:101];
        
        if (self.theTabbers.count == 1) {
            [tabButtonTextSet setTitle:@"Tabber" forState:UIControlStateNormal];
        } else {
            [tabButtonTextSet setTitle:@"Tabbers" forState:UIControlStateNormal];
        }
    }];
    
    //NSLog(@"%lu", (unsigned long)self.theTabbers.count);
    
    //[self loadView];
    
    return tabberArray;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"viewTabbers"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        AllTabbersTableViewController *allTabbersTableViewController = (AllTabbersTableViewController * )navigationController.topViewController;
        allTabbersTableViewController.user = self.user;
        
        //AllTabbersTableViewController.user = self.user;
    }
    
    if ([segue.identifier isEqualToString:@"viewUserQuestions"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        UserJokeTableViewController *userQuestionTableViewController = (UserJokeTableViewController * )navigationController.topViewController;
        userQuestionTableViewController.user = self.user;
        
        //AllTabbersTableViewController.user = self.user;
    }
}

@end
