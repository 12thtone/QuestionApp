//
//  ProfileTableViewController.h
//  QuestionApp
//
//  Created by Matt Maher on 2/9/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface ProfileTableViewController : UITableViewController

@property (nonatomic, strong) PFObject *userProfile;

@end
