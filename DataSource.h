//
//  DataSource.h
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseUI/ParseUI.h>

@interface DataSource : NSObject

+ (instancetype) sharedInstance;

- (PFQuery *)queryForTable:(NSString *)className;

- (BOOL)emailNotificationAllowed:(BOOL)yesOrNo;

@end
