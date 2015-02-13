//
//  AnswerTableViewCell.h
//  QuestionApp
//
//  Created by Matt Maher on 2/12/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteLabel;

@end
