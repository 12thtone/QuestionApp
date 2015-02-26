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
@property (weak, nonatomic) IBOutlet UILabel *jokesCount;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UILabel *totalTabbers;
@property (weak, nonatomic) IBOutlet UIButton *tabberButton;
@property (weak, nonatomic) IBOutlet UIButton *jokeButton;

@property (weak, nonatomic) PFUser *user;
@property (strong, nonatomic) NSMutableArray *theTabbers;
@property (strong, nonatomic) NSMutableArray *theJokes;

@end

@implementation ProfileTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    [self.tabBarController.tabBar setBarTintColor:[UIColor redColor]];
    
    if (self.userProfile) {
        self.user = [self.userProfile objectForKey:@"author"];
        
    } else if (self.userProfileAnswer) {
        self.user = [self.userProfileAnswer objectForKey:@"answerAuthor"];
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
    [self jokeQuery];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - PFQuery

- (void)tabbersQuery {
    NSMutableArray *tabberArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
    
    [query whereKey:@"tabReceiver" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *tabber in objects) {
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
}

- (void)jokeQuery {
    NSMutableArray *jokeArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    
    [query whereKey:@"author" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *joke in objects) {
            [jokeArray addObject:joke];
            
            self.theJokes = [jokeArray copy];
        }
        
        UIButton *jokeButtonTextSet = (UIButton *)[self.view viewWithTag:102];
        
        if (self.theJokes.count == 1) {
            [jokeButtonTextSet setTitle:@"Joke" forState:UIControlStateNormal];
        } else {
            [jokeButtonTextSet setTitle:@"Jokes" forState:UIControlStateNormal];
        }
        
        NSString *totalJokesString = [NSString stringWithFormat:@"%lu", (unsigned long)self.theJokes.count];
        self.jokesCount.text = totalJokesString;
        
    }];
}

- (void)untabDeleteQuery {
    NSMutableArray *untabArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
    
    [query whereKey:@"tabMaker" equalTo:[PFUser currentUser]];
    [query whereKey:@"tabReceiver" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *tabber in objects) {
            [untabArray addObject:tabber];
            
            [tabber deleteInBackground];
        }
        [self tabbersQuery];
    }];
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
        
        if (tabbersList.count == 0) {
            [self saveTabs];
        } else {
            [self deleteTabs];
        }
    }];
    
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
        [self tabbersQuery];
    }];
}

- (void)deleteTabs {
    
    NSString *userString = [NSString stringWithFormat:@"You're no longer keeping tabs on %@", [self.user username]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Untabbed"
                                                        message:userString
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [self untabDeleteQuery];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"viewTabbers"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        AllTabbersTableViewController *allTabbersTableViewController = (AllTabbersTableViewController * )navigationController.topViewController;
        allTabbersTableViewController.user = self.user;
    }
    
    if ([segue.identifier isEqualToString:@"viewUserQuestions"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        UserJokeTableViewController *userQuestionTableViewController = (UserJokeTableViewController * )navigationController.topViewController;
        userQuestionTableViewController.user = self.user;
    }
}

@end
