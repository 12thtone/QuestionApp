//
//  UserQuestionTableViewController.h
//  QuestionApp
//
//  Created by Matt Maher on 2/18/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface UserQuestionTableViewController : PFQueryTableViewController

@property (nonatomic, strong) PFUser *user;

@end
