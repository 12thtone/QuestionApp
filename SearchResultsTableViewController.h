//
//  SearchResultsTableViewController.h
//  QuestionApp
//
//  Created by Matt Maher on 2/18/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UISearchController *searchController;

@end
