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
@property (nonatomic, strong) PFObject *userProfileAnswer;
@property (nonatomic, strong) PFUser *userFromTabList;
@property (nonatomic, strong) PFUser *userFromFullAnswerList;


@end
