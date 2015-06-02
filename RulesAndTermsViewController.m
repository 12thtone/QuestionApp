//
//  RulesAndTermsViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 3/27/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "RulesAndTermsViewController.h"

@interface RulesAndTermsViewController ()

- (IBAction)cancelPressed:(UIBarButtonItem *)sender;

@end

@implementation RulesAndTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
