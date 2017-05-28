//
//  PicPranckSignInViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

//View controllers
#import "PicPranckSignInViewController.h"
#import "PicPranckEmailSignInViewController.h"
#import "UIViewController+Alerts.h"
//Services
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckEncryptionServices.h"
//Other Frameworks
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import Firebase;
@import FirebaseAuth;

typedef enum : NSUInteger {
    AuthEmail,
    AuthAnonymous,
    AuthFacebook,
} AuthProvider;

@interface PicPranckSignInViewController ()
@property BOOL hasSegued;
@end

#pragma mark -
@implementation PicPranckSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hasSegued=NO;
    
    //BackGround
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    //UIImage *imgBackground=[UIImage imageNamed:@"backGroundImage"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];

    //Customize text fields
    //[self customizeTextFields];
    
//    //Customize facebook button
//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    CGPoint center=CGPointMake(_facebookButton.center.x,_facebookButton.center.y);
//    loginButton.center = center;
//    [self.view addSubview:loginButton];
//    
//    
//    UIView *gestureView=[[UIView alloc] init];
//    gestureView.frame=loginButton.frame;
//    [self.view addSubview:gestureView];
//    [self.view bringSubviewToFront:gestureView];
//    UITapGestureRecognizer *tapGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
//    [tapGR setNumberOfTapsRequired:1];
//    [gestureView addGestureRecognizer:tapGR];
//    gestureView.tag=0;
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

#pragma Layout and appearance

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //Prevent from rotating
    return UIInterfaceOrientationMaskPortrait;
}

-(void)switchMode {

    [_facebookButton setHidden:[_containerEmailLogInView isHidden]];
    [_emailButton setHidden:[_containerEmailLogInView isHidden]];
    
    [_containerEmailLogInView setHidden:![_containerEmailLogInView isHidden]];
    
    if(![_containerEmailLogInView isHidden])
    {
        [self customizeTextFields];
        [self.view bringSubviewToFront:_containerEmailLogInView];
        [self.view sendSubviewToBack:_facebookButton];
        [self.view sendSubviewToBack:_emailButton];
    }
    else
    {
        [self.view sendSubviewToBack:_containerEmailLogInView];
        [self.view bringSubviewToFront:_facebookButton];
        [self.view bringSubviewToFront:_emailButton];
    }
}

- (IBAction)backToMainLogInView:(id)sender {
    [self switchMode];
}

-(void)customizeTextFields{
    UIToolbar *customKeyboard=[self getCustomizedKeyboard];
    
    _emailTextField.placeholder=@"Email";
    _emailTextField.inputAccessoryView=customKeyboard;
    
    _passwordTextField.placeholder=@"Password";
    _passwordTextField.inputAccessoryView=customKeyboard;
}

-(UIToolbar *)getCustomizedKeyboard{
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

-(void)doneButtonPressed{
    if(_emailTextField.isEditing)
        [_emailTextField endEditing:YES];
    else if(_passwordTextField.isEditing)
        [_passwordTextField endEditing:YES];
}

#pragma Firebase Authentification

- (void)firebaseLoginWithCredential:(FIRAuthCredential *)credential {
    [self showSpinner:^{
        if ([FIRAuth auth].currentUser) {
            // [START link_credential]
            [[FIRAuth auth]
             .currentUser linkWithCredential:credential
             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                 // [START_EXCLUDE]
                 [self hideSpinner:^{
                     if (error) {
                         [self showMessagePrompt:error.localizedDescription];
                         return;
                     }
                     [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
                     //[self.view reloadInputViews];
                 }];
                 // [END_EXCLUDE]
             }];
            // [END link_credential]
        } else {
            // [START signin_credential]
            [[FIRAuth auth] signInWithCredential:credential
                                      completion:^(FIRUser *user, NSError *error) {
                                          // [START_EXCLUDE]
                                          [self hideSpinner:^{
                                              // [END_EXCLUDE]
                                              if (error) {
                                                  // [START_EXCLUDE]
                                                  [self showMessagePrompt:error.localizedDescription];
                                                  // [END_EXCLUDE]
                                                  return;
                                              }
                                              [PicPranckEncryptionServices getOrCreateSaltyKey:user];
                                              [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
                                              // [END signin_credential]
                                          }];
                                      }];
        }
    }];
}

- (void)showAuthPicker: (NSArray<NSNumber *>*) providers {
    for (NSNumber *provider in providers) {
        switch (provider.unsignedIntegerValue) {
            case AuthEmail:
            {
               [self performSegueWithIdentifier:@"email" sender:nil];
            }
                break;
            case AuthFacebook: {
                
                FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                [loginManager
                 logInWithReadPermissions:@[ @"public_profile", @"email" ]
                 fromViewController:self
                 handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                     if (error) {
                         [self showMessagePrompt:error.localizedDescription];
                     } else if (result.isCancelled) {
                         NSLog(@"FBLogin cancelled");
                     } else {
                         // [START headless_facebook_auth]
                         FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                                          credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                                          .tokenString];
                         // [END headless_facebook_auth]
                         [self firebaseLoginWithCredential:credential];
                     }
                 }];
                
            }
                break;
                
            case AuthAnonymous: {
                    [self showSpinner:^{
                        // [START firebase_auth_anonymous]
                        [[FIRAuth auth]
                         signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                             // [START_EXCLUDE]
                             [self hideSpinner:^{
                                 if (error) {
                                     [self showMessagePrompt:error.localizedDescription];
                                     return;
                                 }
                             }];
                             // [END_EXCLUDE]
                         }];
                        // [END firebase_auth_anonymous]
                    }];
            }
                break;
        }
    }
}

//-(void)didTap:(id)sender
//{
//    if([sender isKindOfClass:[UITapGestureRecognizer class]])
//    {
//        NSMutableArray *providers = [@[@(AuthFacebook)] mutableCopy];
//        for (id<FIRUserInfo> userInfo in [FIRAuth auth].currentUser.providerData) {
//            if ([userInfo.providerID isEqualToString:FIRFacebookAuthProviderID]) {
//                [providers removeObject:@(AuthFacebook)];
//                //TODO: WARNING TO REMOVE AFTER FINISHING TESTS
//                FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//                [loginManager logOut];
//                NSError *signOutError;
//                BOOL status = [[FIRAuth auth] signOut:&signOutError];
//                if (!status) {
//                    NSLog(@"Error signing out: %@", signOutError);
//                }
//                [providers addObject:@(AuthFacebook)];
//            }
//        }
//        [self showAuthPicker:providers];
////        if(0==gestureView.tag)
////        {
////            [self showAuthPicker:providers];
////            gestureView.tag=1;
////        }
////        else
////        {
////            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
////            [loginManager logOut];
////            gestureView.tag=0;
////            NSError *signOutError;
////            BOOL status = [[FIRAuth auth] signOut:&signOutError];
////            if (!status) {
////                NSLog(@"Error signing out: %@", signOutError);
////                return;
////            }
////        }
//    }
//}

#pragma mark Handling Email Log In and Sign In

- (IBAction)logInWithEmail:(id)sender{
    [self switchMode];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (IBAction)didTapEmailLogin:(id)sender {
    [self showSpinner:^{
        // [START headless_email_auth]
        [[FIRAuth auth] signInWithEmail:_emailTextField.text
                               password:_passwordTextField.text
                             completion:^(FIRUser *user, NSError *error) {
                                 // [START_EXCLUDE]
                                 [self hideSpinner:^{
                                     if (error) {
                                         [self showMessagePrompt:error.localizedDescription];
                                         return;
                                     }
                                     [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
                                 }];
                                 // [END_EXCLUDE]
                             }];
        // [END headless_email_auth]
    }];
}

/** @fn requestPasswordReset
 @brief Requests a "password reset" email be sent.
 */
- (IBAction)didRequestPasswordReset:(id)sender {
    [self
     showTextInputPromptWithMessage:@"Email:"
     completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
         if (!userPressedOK || !userInput.length) {
             return;
         }
         
         [self showSpinner:^{
             // [START password_reset]
             [[FIRAuth auth]
              sendPasswordResetWithEmail:userInput
              completion:^(NSError *_Nullable error) {
                  // [START_EXCLUDE]
                  [self hideSpinner:^{
                      if (error) {
                          [self
                           showMessagePrompt:error
                           .localizedDescription];
                          return;
                      }
                      
                      [self showMessagePrompt:@"Sent"];
                  }];
                  // [END_EXCLUDE]
              }];
             // [END password_reset]
         }];
     }];
}

- (IBAction)didCreateAccount:(id)sender {
    
    PicPranckEmailSignInViewController *ppEmailVC=[self.storyboard instantiateViewControllerWithIdentifier:@"EmailSignUpViewController"];
    ppEmailVC.modalPresentationStyle=UIModalPresentationFormSheet;
    ppEmailVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ppEmailVC animated:YES completion:nil];
}

#pragma mark Handling Facebook Log In
- (IBAction)logInWithFacebook:(id)sender
{
    NSMutableArray *providers = [@[@(AuthFacebook)] mutableCopy];
    
//    for (id<FIRUserInfo> userInfo in [FIRAuth auth].currentUser.providerData)
//    {
//        if ([userInfo.providerID isEqualToString:FIRFacebookAuthProviderID])
//        {
//            [providers removeObject:@(AuthFacebook)];
//            //TODO: WARNING TO REMOVE AFTER FINISHING TESTS
//            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//            [loginManager logOut];
//            NSError *signOutError;
//            BOOL status = [[FIRAuth auth] signOut:&signOutError];
//            if (!status) {
//                NSLog(@"Error signing out: %@", signOutError);
//            }
//            [providers addObject:@(AuthFacebook)];
//        }
//    }
    [self showAuthPicker:providers];
}


@end
