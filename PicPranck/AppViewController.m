
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
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL =[NSURL URLWithString:@"https://www.facebook.com/FacebookDevelopers"];
    NSInteger width=self.view.frame.size.width;
    NSInteger height=self.view.frame.size.height;
    FBSDKSendButton *button = [[FBSDKSendButton alloc] initWithFrame:CGRectMake((0.5*width)-100,(0.5*height)+10, 100, 30)];
    button.shareContent = content;
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    //[[UIImage imageNamed:@"image.png"] drawInRect:self.view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:_imageToSend];
    //[_imageView setContentMode:UIViewContentModeCenter];
    //_imageView.contentMode = UIViewContentMode.ScaleAspectFit;
    

}

@end
