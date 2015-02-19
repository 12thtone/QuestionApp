//
//  SearchResultsTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/18/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "SearchResultsTableViewController.h"
//#import "QuestionTableViewController.h"
#import <Parse/Parse.h>

@interface SearchResultsTableViewController()

@end

@implementation SearchResultsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchController.searchBar setHidden:NO];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    //Note *note = [self.searchResults objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = note.noteTitle;
    //cell.detailTextLabel.text = note.noteTag;
    
    return cell;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*
    if ([[segue identifier]isEqualToString:@"fromSearchToRead"]) {
        [self.searchController.searchBar endEditing:YES];
        [self.searchController.searchBar setHidden:YES];
        self.readNoteVC = [segue destinationViewController];
        
    }
     */
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Note *selectedNote = [self.searchResults objectAtIndex:indexPath.row];
    //self.readNoteVC.selectedNote = selectedNote;
    
}

@end
