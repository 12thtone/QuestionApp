//
//  QuestionTableViewCell.h
//  QuestionApp
//
//  Created by Matt Maher on 2/14/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end
