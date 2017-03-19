//
//  PicPranckEmailSignInViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckEmailSignInViewController : UIViewController 
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)submit:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelSignUp:(id)sender;

@end
