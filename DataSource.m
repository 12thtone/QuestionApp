//
//  DataSource.m
//  QuestionApp
//
//  Created by Matt Maher on 2/4/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "DataSource.h"
#import <Parse/Parse.h>

@interface DataSource ()

@end

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (PFQuery *)queryForTable:(NSString *)className {
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}

@end
