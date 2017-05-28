//
//  PicPranckEmailSignInViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckEmailSignInViewController.h"
#import "UIViewController+Alerts.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"

@import FirebaseAuth;

@interface PicPranckEmailSignInViewController ()

@end

@implementation PicPranckEmailSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    [PicPranckCustomViewsServices setLogInButtonsDesign:_cancelButton withText:@"Cancel"];
    [PicPranckCustomViewsServices setLogInButtonsDesign:_submitButton withText:@"Submit !"];
    
    //Customize fields
    _emailTextField.placeholder=@"Email";
    _passwordTextField.placeholder=@"Password";
    UIToolbar *customKeyboard=[self getCustomizedKeyboard];
    _emailTextField.inputAccessoryView=customKeyboard;
    _passwordTextField.inputAccessoryView=customKeyboard;
    
}
-(UIToolbar *)getCustomizedKeyboard
{
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(doneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    return keyboardToolbar;
}
-(void)doneButtonPressed
{
    if(_emailTextField.isEditing)
        [_emailTextField endEditing:YES];
    else if(_passwordTextField.isEditing)
        [_passwordTextField endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submit:(id)sender
{
        [self showSpinner:^{
                              // [START create_user]
                              [[FIRAuth auth]
                               createUserWithEmail:_emailTextField.text
                               password:_passwordTextField.text
                               completion:^(FIRUser *_Nullable user,
                                            NSError *_Nullable error) {
                                   // [START_EXCLUDE]
                                   [self hideSpinner:^{
                                       if (error) {
                                           [self
                                            showMessagePrompt:
                                            error
                                            .localizedDescription];
                                           return;
                                       }
                                       NSLog(@"%@ created", user.email);
                                       [self performSegueWithIdentifier:@"signUpSucceeded" sender:self];
                                   }];
                                   // [END_EXCLUDE]
                               }];
        }];
}
- (IBAction)cancelSignUp:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
