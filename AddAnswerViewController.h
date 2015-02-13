//
//  AddAnswerViewController.h
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@class QuestionTableViewController;

@interface AddAnswerViewController : UIViewController

@property (nonatomic, strong) PFObject *question;

@end
