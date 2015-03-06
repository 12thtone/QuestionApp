//
//  ProfileTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/9/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import "AllTabbersTableViewController.h"
#import "UserJokeTableViewController.h"
#import <MessageUI/MessageUI.h>

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
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *keepTabsButton;

@property (weak, nonatomic) PFUser *user;
@property (strong, nonatomic) NSMutableArray *theTabbers;
@property (strong, nonatomic) NSMutableArray *theJokes;
@property (nonatomic, assign) NSInteger tabbersCount;

@end

@implementation ProfileTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imageProfile setImage:[UIImage imageNamed:@"placeholder.png"]];
    self.imageProfile.layer.cornerRadius = 8.0;
    self.imageProfile.layer.borderColor = [[UIColor grayColor] CGColor];
    self.imageProfile.layer.borderWidth = 1.0;
    self.imageProfile.layer.masksToBounds = YES;
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    [self.tabBarController.tabBar setBarTintColor:[UIColor redColor]];
    
    [self.descriptionProfile setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    [self.descriptionProfile setAlpha:0.7];
    
    if (self.userProfile) {
        self.user = [self.userProfile objectForKey:@"author"];
        
    } else if (self.userProfileAnswer) {
        self.user = [self.userProfileAnswer objectForKey:@"answerAuthor"];
    } else if (self.userFromTabList) {
        self.user = self.userFromTabList;
    } else {
        self.user = self.userFromFullAnswerList;
    }
    /*
    if ([[PFUser currentUser] username] == [self.user username]) {
        [self.keepTabsButton setHidden:YES];
    }
    */
    [self.keepTabsButton addTarget:self action:@selector(keepTabs:) forControlEvents:UIControlEventTouchUpInside];
    self.keepTabsButton.layer.borderWidth = 1;
    self.keepTabsButton.layer.borderColor = [UIColor purpleColor].CGColor;
    self.keepTabsButton.layer.cornerRadius = 8;
    self.keepTabsButton.layer.masksToBounds = YES;
    
    [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *pictureFile = [self.user objectForKey:@"picture"];
        
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error){
                
                [self.imageProfile setImage:[UIImage imageWithData:data]];
                self.imageProfile.layer.cornerRadius = 8.0;
                self.imageProfile.layer.borderColor = [[UIColor grayColor] CGColor];
                self.imageProfile.layer.borderWidth = 1.0;
                self.imageProfile.layer.masksToBounds = YES;
                
                self.descriptionProfile.text = [self.user objectForKey:@"description"];
                self.usernameProfile.text = [self.user objectForKey:@"username"];
                self.realNameLabel.text = [self.user objectForKey:@"realName"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMMM d, yyyy"];
                NSDate *date = [self.user createdAt];
                self.dateLabel.text = [dateFormatter stringFromDate:date];
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
        
    [self userTabbingQuery];
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
        
        self.tabbersCount = self.theTabbers.count;
        //NSString *totalTabberString = [NSString stringWithFormat:@"%lu", (unsigned long)self.theTabbers.count];
        NSString *totalTabberString = [NSString stringWithFormat:@"%lu", (unsigned long)self.self.tabbersCount];
        self.totalTabbers.text = totalTabberString;
    }];
}

- (void)userTabbingQuery {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tab"];
    
    [query whereKey:@"tabReceiver" equalTo:self.user];
    [query whereKey:@"tabMaker" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count == 0) {
            [self.keepTabsButton setTitle:@" Keep Tabs" forState:UIControlStateNormal];
            //self.keepTabsButton.imageView.image = [UIImage imageNamed:@"tag-plus-7@3x.png"];
            [self.keepTabsButton setImage:[UIImage imageNamed:@"tag-plus-7@3x.png"] forState:UIControlStateNormal];
        } else {
            [self.keepTabsButton setTitle:@" Untab" forState:UIControlStateNormal];
            //self.keepTabsButton.imageView.image = [UIImage imageNamed:@"tag-minus-7@3x.png"];
            [self.keepTabsButton setImage:[UIImage imageNamed:@"tag-minus-7@3x.png"] forState:UIControlStateNormal];
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
        
        //UIButton *jokeButtonTextSet = (UIButton *)[self.view viewWithTag:102];
        /*
        if (self.theJokes.count == 1) {
            [jokeButtonTextSet setTitle:@"Joke" forState:UIControlStateNormal];
        } else {
            [jokeButtonTextSet setTitle:@"Jokes" forState:UIControlStateNormal];
        }
        */
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
        //[self tabbersQuery];
        
        //NSInteger tabbersCount = self.theTabbers.count + 1;
        self.tabbersCount = self.tabbersCount - 1;
        NSString *totalTabberString = [NSString stringWithFormat:@"%lu", (unsigned long)self.tabbersCount];
        self.totalTabbers.text = totalTabberString;
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

- (void)keepTabs:(id)sender {
    
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
        
        [self.keepTabsButton setTitle:@" Untab" forState:UIControlStateNormal];
        [self.keepTabsButton setImage:[UIImage imageNamed:@"tag-minus-7@3x.png"] forState:UIControlStateNormal];
        
        self.tabbersCount = self.tabbersCount + 1;
        NSString *totalTabberString = [NSString stringWithFormat:@"%lu", (unsigned long)self.tabbersCount];
        self.totalTabbers.text = totalTabberString;
                
    }];
}

- (void)deleteTabs {
    
    NSString *userString = [NSString stringWithFormat:@"You're no longer keeping tabs on %@", [self.user username]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Untabbed"
                                                        message:userString
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    //self.keepTabsButton.imageView.image = [UIImage imageNamed:@"tag-plus-7@3x.png"];
    [self.keepTabsButton setTitle:@" Keep Tabs" forState:UIControlStateNormal];
    [self.keepTabsButton setImage:[UIImage imageNamed:@"tag-plus-7@3x.png"] forState:UIControlStateNormal];
    [self untabDeleteQuery];
    //[self removeInstallation];
    
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
