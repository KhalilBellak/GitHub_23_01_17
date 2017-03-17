//
//  PicPranckSignInViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckSignInViewController.h"
#import "UIViewController+Alerts.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#define SPACING_TO_FB_LOGIN 40
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
    // Do any additional setup after loading the view.
    if ([FBSDKAccessToken currentAccessToken])
    {
        //Segue directly to next view controller
    }
    _hasSegued=NO;
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2)];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    [PicPranckCustomViewsServices setButtonDesign:_logInButton];
    NSAttributedString *buttonTitle=[PicPranckCustomViewsServices getAttributedStringWithString:@"Log In"];
    [_logInButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    _emailTextField.placeholder=@"Email";
    _passwordTextField.placeholder=@"Password";
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    CGPoint center=CGPointMake(_logInButton.center.x, _logInButton.center.y+SPACING_TO_FB_LOGIN);
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
//    if(!_hasSegued)
//        [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
//    _hasSegued=YES;
}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    UITabBarController *barViewController=segue.destinationViewController;
//    UIViewController *vc=[barViewController.viewControllers objectAtIndex:0];
//    if([vc isKindOfClass:[UINavigationController class]])
//    {
//        UINavigationController *navVC=(UINavigationController *)vc;
//        UIViewController *targetVC=[navVC.viewControllers objectAtIndex:0];
//        
//    }
//}

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
        UITapGestureRecognizer *tapGest=(UITapGestureRecognizer *)sender;
        UIView *gestureView=tapGest.view;
        if(0==gestureView.tag)
        {
            NSMutableArray *providers = [@[@(AuthFacebook)] mutableCopy];
            // Remove any existing providers. Note that this is not a complete list of
            // providers, so always check the documentation for a complete reference:
            // https://firebase.google.com/docs/auth
            //TODO: To uncomment when finishing testing
         
                for (id<FIRUserInfo> userInfo in [FIRAuth auth].currentUser.providerData) {
                    if ([userInfo.providerID isEqualToString:FIRFacebookAuthProviderID]) {
                        [providers removeObject:@(AuthFacebook)];
                        NSError *signOutError;
                        BOOL status = [[FIRAuth auth] signOut:&signOutError];
                        if (!status) {
                            NSLog(@"Error signing out: %@", signOutError);
                            return;
                        }
                    }
                }
            [self showAuthPicker:providers];
            gestureView.tag=1;
        }
        else
        {
//            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//            [loginManager logOut];
            gestureView.tag=0;
            NSError *signOutError;
            BOOL status = [[FIRAuth auth] signOut:&signOutError];
            if (!status) {
                NSLog(@"Error signing out: %@", signOutError);
                return;
            }
        }
    }
}
@end
