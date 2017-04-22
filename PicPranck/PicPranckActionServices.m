//
//  PicPranckActionServices.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckActionServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckImageView.h"
#import "ViewController.h"
#import "PicPranckCollectionViewController.h"
#import "PicPranckButton.h"

@implementation PicPranckActionServices

+(void)closePreview:(id)sender
{
    if([sender isKindOfClass:[PicPranckButton class]])
    {
        PicPranckButton *button=(PicPranckButton *)sender;
        [button.superview removeFromSuperview];
        [button.delegate dismissViewController];
        //[button.ppCollectionVC dismissViewControllerAnimated:YES completion:nil];
    }
}
+(void)useImage:(id)sender
{
    //Get Tab Bar Controller
    if([sender isKindOfClass:[PicPranckButton class]])
    {
        PicPranckButton *button=(PicPranckButton *)sender;
        [button.delegate useImage:button];
    }
}

+(void) handleTapOnce: (UITapGestureRecognizer *)sender
{
    if(UIGestureRecognizerStateEnded==sender.state)
    {
        if([sender.view isKindOfClass:[PicPranckImageView class]])
        {
            PicPranckImageView *imgView=(PicPranckImageView *)sender.view;
            [imgView.delegate cellTaped:imgView ];//withIndex:0];
        }
    }
}

@end
