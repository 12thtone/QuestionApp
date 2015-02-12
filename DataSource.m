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
    
    // Create a query
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    [query orderByDescending:@"createdAt"];
    /*
     // Follow relationship
     if ([PFUser currentUser]) {
     [query whereKey:@"author" equalTo:[PFUser currentUser]];
     }
     else {
     // I added this so that when there is no currentUser, the query will not return any data
     // Without this, when a user signs up and is logged in automatically, they briefly see a table with data
     // before loadObjects is called and the table is refreshed.
     // There are other ways to get an empty query, of course. With the below, I know that there
     // is no such column with the value in the database.
     [query whereKey:@"nonexistent" equalTo:@"doesn't exist"];
     }*/
    
    return query;
}

@end
