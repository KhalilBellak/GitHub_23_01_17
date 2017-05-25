//
//  PicPranckNewProfileViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 24/05/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckNewProfileViewController.h"

#import "PicPranckProfileViewController.h"
#import "TabBarViewController.h"
#import "UIViewController+Alerts.h"

#import "PicPranckCustomViewsServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCoreDataServices.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "UIImageView+AFNetworking.h"

@import Firebase;

@interface PicPranckNewProfileViewController ()

@end

@implementation PicPranckNewProfileViewController
static NSString * const reuseIdentifier = @"profileCell";
- (void)viewDidLoad {
    
    [super viewDidLoad];
    //Background
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.backGroungView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    UIImage *imgBackgroundDarker=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:YES];
    
    [self.scrollView setBackgroundColor:[UIColor colorWithPatternImage:imgBackgroundDarker]];
    //User's info
    [self setProfileNameAndPicture];
    
}
-(void)setProfileNameAndPicture
{
    [PicPranckCustomViewsServices setViewDesign:_profilePicture];
    
    _profilePicture.layer.cornerRadius = _profilePicture.frame.size.height/2;
    _profilePicture.clipsToBounds=YES;
    
    //Hide views
    [_userName setAlpha:0];
    //Add activity indicator
    UIActivityIndicatorView * activityIndic=[[UIActivityIndicatorView alloc] initWithFrame:_profilePicture.bounds];
    [activityIndic setBackgroundColor:[PicPranckImageServices getGlobalTintWithLighterFactor:-50]];
    [_profilePicture addSubview:activityIndic];
    [activityIndic startAnimating];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        //Set User's name and picture
        if ([FBSDKAccessToken currentAccessToken]) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    //Set User's name
                    NSString *nameOfLoginUser = [result valueForKey:@"name"];
                    NSAttributedString *userName;
                    if(0<[nameOfLoginUser length])
                        userName=[PicPranckCustomViewsServices getAttributedStringWithString:nameOfLoginUser withFontSize:19.0];
                    else
                        userName=[PicPranckCustomViewsServices getAttributedStringWithString:@"User Name" withFontSize:19.0];
                    
                    //Set Profile's picture
                    NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                    NSURL *url = [[NSURL alloc] initWithString:imageStringOfLoginUser];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_profilePicture setImageWithURL:url placeholderImage: nil];
                        [_userName setAttributedText:userName];
                        [_userName setAlpha:1];
                        [activityIndic stopAnimating];
                    });
                    
                }
            }];
        }
    });

}

-(void)viewWillAppear:(BOOL)animated
{
    
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

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)logOut
{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
    }
    [self performSegueWithIdentifier:@"logOut" sender:self];
}
-(void)removeAll
{
    
    [PicPranckCoreDataServices removeAllImages:self];
    //Let know other views that we've just wiped out all data (to re-initialize MOC)
    if([self.tabBarController isKindOfClass:[TabBarViewController class]])
    {
        TabBarViewController *tabBarVC=(TabBarViewController *)self.tabBarController;
        tabBarVC.allPicPrancksRemovedMode=YES;
    }
}
+(NSString *)getTitle
{
    return @"Let the troll inside you take over! ";
}
+(NSString *)getDescription
{
    NSString *string1=@"Hello !";
    NSString *string2=@"Here is my application to create customizable PickPranks: ";
    NSString *string3=@"http://pickprank-app.com/";
    NSString *desc=[NSString stringWithFormat:@"%@\r%@\r%@",string1,string2,string3];
    return desc;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logOutAction:(id)sender
{
    [self showMessagePrompt:@"Do you really want to Log out from PickPrank ?" withActionBlockOfType:@"Log out"];
}

- (IBAction)flushPicPranksAction:(id)sender
{
    [self showMessagePrompt:@"Do you really want to delete all PickPranks ?" withActionBlockOfType:@"Remove all"];
}
- (IBAction)shareWithFBAction:(id)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle=[PicPranckProfileViewController getTitle];
    content.contentDescription=[PicPranckProfileViewController getDescription];
    content.contentURL = [NSURL URLWithString:@"http://pickprank-app.com/"];
    [FBSDKMessageDialog showWithContent:content delegate:nil];
}

- (IBAction)shareWithEmail:(id)sender
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailVC=[[MFMailComposeViewController alloc] init];
        [mailVC setMailComposeDelegate:self];
        // Configure the fields of the interface.
        //[mailVC setToRecipients:@[@"address@example.com"]];
        [mailVC setSubject:[PicPranckProfileViewController getTitle]];
        [mailVC setMessageBody:[PicPranckProfileViewController getDescription] isHTML:YES];
        
        // Present the view controller modally.
        [self presentViewController:mailVC animated:YES completion:nil];
    }
    else
        [self showMessagePrompt:@"Mail services are not available !"];
}
@end
