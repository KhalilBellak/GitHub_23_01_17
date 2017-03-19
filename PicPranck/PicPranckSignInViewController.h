//
//  PicPranckSignInViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckSignInViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UIButton *forgotPassButton;

- (IBAction)didTapEmailLogin:(id)sender;
- (IBAction)didCreateAccount:(id)sender;
- (IBAction)didRequestPasswordReset:(id)sender;

@property BOOL hasSegued;
@end
