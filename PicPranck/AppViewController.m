
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
//    NSMutableArray *activityItems= [NSMutableArray arrayWithObjects:img, nil];
//    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypePrint,                                                         UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,                                                         UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,                                                         UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,                                                         UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop];
//    [self presentViewController:activityViewController animated:YES completion:nil];
    

}

@end
