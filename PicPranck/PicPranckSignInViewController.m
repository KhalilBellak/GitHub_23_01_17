//
//  PicPranckSignInViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckSignInViewController.h"
#import "PicPranckEmailSignInViewController.h"
#import "UIViewController+Alerts.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import Firebase;
@import FirebaseAuth;

#define SPACING_TO_FB_LOGIN 60
typedef enum : NSUInteger {
    AuthEmail,
    AuthAnonymous,
    AuthFacebook,
} AuthProvider;

@interface PicPranckSignInViewController ()

@end

@implementation PicPranckSignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hasSegued=NO;
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2)];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    [PicPranckCustomViewsServices setLogInButtonsDesign:_logInButton withText:@"Log In"];
    [PicPranckCustomViewsServices setLogInButtonsDesign:_signUpButton withText:@"Sign Up"];
    [PicPranckCustomViewsServices setLogInButtonsDesign:_forgotPassButton withText:@"Forgot Password ?"];
    
    //Customize fields
    _emailTextField.placeholder=@"Email";
    _passwordTextField.placeholder=@"Password";
    UIToolbar *customKeyboard=[self getCustomizedKeyboard];
    _emailTextField.inputAccessoryView=customKeyboard;
    _passwordTextField.inputAccessoryView=customKeyboard;
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    CGPoint center=CGPointMake(_forgotPassButton.center.x,_forgotPassButton.center.y+SPACING_TO_FB_LOGIN);
    loginButton.center = center;
    [self.view addSubview:loginButton];
    
    UIView *gestureView=[[UIView alloc] init];
    gestureView.frame=loginButton.frame;
    [self.view addSubview:gestureView];
    [self.view bringSubviewToFront:gestureView];
    UITapGestureRecognizer *tapGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [tapGR setNumberOfTapsRequired:1];
    [gestureView addGestureRecognizer:tapGR];
    gestureView.tag=0;
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
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //Prevent from rotating
    return UIInterfaceOrientationMaskPortrait;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
                                              [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
                                              // [END signin_credential]
                                          }];
                                      }];
        }
    }];
}
- (void)showAuthPicker: (NSArray<NSNumber *>*) providers
{
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)didTap:(id)sender
{
    if([sender isKindOfClass:[UITapGestureRecognizer class]])
    {
        //UITapGestureRecognizer *tapGest=(UITapGestureRecognizer *)sender;
        //UIView *gestureView=tapGest.view;
        NSMutableArray *providers = [@[@(AuthFacebook)] mutableCopy];
        // Remove any existing providers. Note that this is not a complete list of
        // providers, so always check the documentation for a complete reference:
        // https://firebase.google.com/docs/auth
        //TODO: To uncomment when finishing testing
        
        for (id<FIRUserInfo> userInfo in [FIRAuth auth].currentUser.providerData) {
            if ([userInfo.providerID isEqualToString:FIRFacebookAuthProviderID]) {
                [providers removeObject:@(AuthFacebook)];
                //TODO: WARNING TO REMOVE AFTER FINISHING TESTS
                FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                [loginManager logOut];
                NSError *signOutError;
                BOOL status = [[FIRAuth auth] signOut:&signOutError];
                if (!status) {
                    NSLog(@"Error signing out: %@", signOutError);
                }
                [providers addObject:@(AuthFacebook)];
            }
        }
        [self showAuthPicker:providers];
//        if(0==gestureView.tag)
//        {
//            [self showAuthPicker:providers];
//            gestureView.tag=1;
//        }
//        else
//        {
//            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//            [loginManager logOut];
//            gestureView.tag=0;
//            NSError *signOutError;
//            BOOL status = [[FIRAuth auth] signOut:&signOutError];
//            if (!status) {
//                NSLog(@"Error signing out: %@", signOutError);
//                return;
//            }
//        }
    }
}
#pragma mark Handling Email Sign In
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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
- (IBAction)didCreateAccount:(id)sender
{
    //[self performSegueWithIdentifier:@"signUp" sender:self];
    PicPranckEmailSignInViewController *ppEmailVC=[self.storyboard instantiateViewControllerWithIdentifier:@"EmailSignUpViewController"];
    ppEmailVC.modalPresentationStyle=UIModalPresentationFormSheet;
    ppEmailVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ppEmailVC animated:YES completion:nil];
}
@end
