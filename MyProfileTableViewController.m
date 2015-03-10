//
//  MyProfileTableViewController.m
//  QuestionApp
//
//  Created by Matt Maher on 2/9/15.
//  Copyright (c) 2015 Matt Maher. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import "Reachability.h"
#import "SettingsTableViewController.h"

@interface MyProfileTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)camera:(UIBarButtonItem *)sender;
- (IBAction)saveButton:(UIBarButtonItem *)sender;
- (IBAction)imageLibrary:(id)sender;
- (IBAction)logout:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameProfile;
@property (weak, nonatomic) IBOutlet UITextView *textProfile;

@property (weak, nonatomic) UIImage *chosenImage;

@end

@implementation MyProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    self.tabBarController.tabBar.alpha = 0.9;
    [self.tabBarController.tabBar setBarTintColor:[UIColor purpleColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *tapDismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapDismissKeyboard];
    
    PFUser *currentUser = [PFUser currentUser];
    self.usernameProfile.text = currentUser.username;
    
    if (currentUser.description) {
        self.textProfile.text = [currentUser objectForKey:@"description"];
    }
    
    PFFile *pictureFile = [currentUser objectForKey:@"picture"];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error){
            [self.profileImage setImage:[UIImage imageWithData:data]];
            self.profileImage.layer.cornerRadius = 8.0;
            self.profileImage.layer.borderColor = [[UIColor grayColor] CGColor];
            self.profileImage.layer.borderWidth = 1.0;
            self.profileImage.layer.masksToBounds = YES;
        }
        else {
            NSLog(@"no data!");
            [self.profileImage setImage:[UIImage imageNamed:@"placeholder.png"]]; //Set Custom Image if there is no user picture.
            self.profileImage.layer.cornerRadius = 8.0;
            self.profileImage.layer.borderColor = [[UIColor grayColor] CGColor];
            self.profileImage.layer.borderWidth = 1.0;
            self.profileImage.layer.masksToBounds = YES;
            
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.textProfile resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    UITableViewCell *cell;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        cell = (UITableViewCell *) textField.superview.superview;
        
    } else {
        // Load resources for iOS 7 or later
        cell = (UITableViewCell *) textField.superview.superview.superview;
        // TextField -> UITableVieCellContentView -> (in iOS 7!)ScrollView -> Cell!
    }
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)saveButton:(UIBarButtonItem *)sender {
    if (self.chosenImage || self.textProfile) {
        
        [self saveProfile];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Let's try adding a picture and profile description."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)saveProfile
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                            message:@"There's a problem with the internet connection. Try again when there's a better signal."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        
        if (self.chosenImage) {
            NSString *profileString = self.textProfile.text;
            
            NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.0f);
            NSLog(@"MyImage size in bytes:%lu",(unsigned long)[imageData length]);
            PFFile *imageFile = [PFFile fileWithName:@"Profileimage.png" data:imageData];
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Profile Updated"
                                                                        message:@"Your changes have been saved."
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    
                    if (succeeded) {
                        
                        PFUser *user = [PFUser currentUser];
                        user[@"description"] = profileString;
                        user[@"picture"] = imageFile;
                        [user saveInBackground];
                    }
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                        message:[error.userInfo objectForKey:@"error"]
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        } else {
            NSString *profileString = self.textProfile.text;
            
            PFUser *user = [PFUser currentUser];
            user[@"description"] = profileString;
            [user saveInBackground];
        }
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"toSettings"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        
        SettingsTableViewController *settingsTableViewController = (SettingsTableViewController*) navigationController;
        settingsTableViewController.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}

#pragma mark - Images

- (IBAction)camera:(UIBarButtonItem *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                              message:@"This device has no camera."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)imageLibrary:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = self.chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)logout:(UIBarButtonItem *)sender {
    [PFUser logOut];
}

@end
