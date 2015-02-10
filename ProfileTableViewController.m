//
//  ProfileTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/9/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Parse/Parse.h>

@interface ProfileTableViewController ()
- (IBAction)closeProfile:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *usernameProfile;
@property (weak, nonatomic) IBOutlet UITextView *descriptionProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;

@end

@implementation ProfileTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.usernameProfile.text = [self.userProfile objectForKey:@"questionTitle"];
    
    PFUser *user = [self.userProfile objectForKey:@"author"];
    [user fetchIfNeeded];
    PFFile *pictureFile = [user objectForKey:@"picture"];
    //PFObject *userDescription = [self.userProfile objectForKey:@"description"];
    
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            
            [self.imageProfile setImage:[UIImage imageWithData:data]];
            self.descriptionProfile.text = [user objectForKey:@"description"];
            self.usernameProfile.text = [user objectForKey:@"username"];
        }
        else {
            NSLog(@"no data!");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeProfile:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
