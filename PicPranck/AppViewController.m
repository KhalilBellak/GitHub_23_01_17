
//
//  AppViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 30/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "AppViewController.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
@implementation AppViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //TODO: Position Add right content to FB share button
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL =[NSURL URLWithString:@"https://www.facebook.com/FacebookDevelopers"];
    NSInteger width=self.view.frame.size.width;
    NSInteger height=self.view.frame.size.height;
    FBSDKSendButton *button = [[FBSDKSendButton alloc] initWithFrame:CGRectMake((0.5*width)-100,(0.5*height)+10, 100, 30)];
    button.shareContent = content;
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    
    //TODO: Activities to allow
    //    [self generateImageToSend];
    //    NSMutableArray *activityItems= [NSMutableArray arrayWithObjects:image, nil];
    //    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    //    activityViewController.excludedActivityTypes = @[UIActivityTypeMail,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypePrint,                                                         UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToFacebook,                                                        UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,                                                         UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,                                                         UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,
    //                                                      @"com.apple.mobilenotes.SharingExtension"];
    // net.whatsapp.WhatsApp.ShareExtension
    // com.facebook.Messenger.ShareExtension
    // com.apple.UIKit.activity.Message
    //    [self presentViewController:activityViewController animated:YES completion:nil];
    

}

@end
