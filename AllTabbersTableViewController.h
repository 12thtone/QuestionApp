//
//  AllTabbersTableViewController.h
//  QuestionApp
//
//  Created by Matt Maher on 2/16/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface AllTabbersTableViewController : PFQueryTableViewController

@property (nonatomic, strong) PFUser *user;

@end
