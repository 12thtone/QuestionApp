//
//  ViolationViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 3/14/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "ViolationViewController.h"

@interface ViolationViewController ()
@property (weak, nonatomic) IBOutlet UIButton *sendViolationButton;
@property (weak, nonatomic) IBOutlet UITextField *violatorField;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;

@end

@implementation ViolationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.sendViolationButton addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
    self.sendViolationButton.layer.borderWidth = 1;
    self.sendViolationButton.layer.borderColor = [UIColor purpleColor].CGColor;
    self.sendViolationButton.layer.cornerRadius = 8;
    self.sendViolationButton.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)report {
    NSString *tpw = @"http://www.12thtone.com/jokadoo_contact.html";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tpw]];
}

@end
