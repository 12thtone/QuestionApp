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

- (BOOL)emailNotificationAllowed:(BOOL)yesOrNo {
    return yesOrNo;
}

- (PFQuery *)queryForTable:(NSString *)className {
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}

-(BOOL)filterForProfanity:(NSString *)text {
    
    NSArray *listOfProfaneWords = @[@"ballsack", @"bastard", @"bitch", @"blowjob", @"blow job",	@"boner", @"buttplug", @"clitoris", @"cock", @"cunt", @"damn", @"dick", @"dildo", @"dyke", @"fag", @"fellatio", @"felch", @"fuck", @"f u c k", @"fudgepacker", @"fudge packer", @"Goddamn", @"God damn", @"homo", @"jizz", @"labia", @"muff", @"nigger", @"nigga", @"penis", @"pussy",	@"queer", @"scrotum", @"sex", @"shit", @"slut", @"smegma", @"twat", @"vagina", @"whore"];
    
    NSArray *testText = [NSArray arrayWithObject:text];
    
    for (NSInteger i = 0; i <= [listOfProfaneWords count] - 1; i++) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", listOfProfaneWords[i]];
        NSArray *results = [testText filteredArrayUsingPredicate:predicate];
        NSLog(@"%@", results);
        
        if ([results count] != 0) {
            
            return YES;
        }
    }
    
    return NO;
}

@end
