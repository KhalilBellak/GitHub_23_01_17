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
        [button.ppCollectionVC dismissViewControllerAnimated:YES completion:nil];
    }
}
+(void)useImage:(id)sender
{
    //Get Tab Bar Controller
    if([sender isKindOfClass:[PicPranckButton class]])
    {
        PicPranckButton *button=(PicPranckButton *)sender;
        UIViewController *vcRoot=[UIApplication sharedApplication].keyWindow.rootViewController;
        if([vcRoot isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tabBarController=(UITabBarController *)vcRoot;
            NSArray *vcArray=[tabBarController viewControllers];
            for(UIViewController *currVc in vcArray)
            {
                if([currVc isKindOfClass:[ViewController class]])
                {
                    NSInteger iIndex=[vcArray indexOfObject:currVc];
                    ViewController *vc=(ViewController *)currVc;
                    
                    [PicPranckImageServices setImageAreasWithImages:[PicPranckCoreDataServices retrieveImagesArrayFromDataAtIndex:button.tag] inViewController:vc];
                    [button.superview removeFromSuperview];
                    //Disiss modal VC
                    [button.modalVC dismissViewControllerAnimated:YES completion:^{
                        //Dismiss collection view VC
                        //Animated transition to Main VC
                        [UIView transitionFromView:button.modalVC.view
                                            toView:vc.view
                                          duration:0.4
                                           options:UIViewAnimationOptionTransitionFlipFromTop
                                        completion:^(BOOL finished) {
                                            if (finished) {
                                                [button.modalVC.view removeFromSuperview];
                                                tabBarController.selectedIndex = iIndex;
                                            }
                                        }];
                        
                    }];
                    
                    
                    
                    
                }
            }
        }
        else
        {
            [button.superview removeFromSuperview];
            [button.ppCollectionVC dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

+(void) handleTapOnce: (UITapGestureRecognizer *)sender
{
    if(UIGestureRecognizerStateEnded==sender.state)
    {
        if([sender.view isKindOfClass:[PicPranckImageView class]])
        {
            PicPranckImageView *imgView=(PicPranckImageView *)sender.view;
            //[button.superview removeFromSuperview];
            
            UIViewController *vcRoot=[UIApplication sharedApplication].keyWindow.rootViewController;
            if([vcRoot isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *tabVC=(UITabBarController *)vcRoot;
                NSArray *vcArray=[tabVC viewControllers];
                for(UIViewController *currVc in vcArray)
                {
                    if([currVc isKindOfClass:[PicPranckCollectionViewController class]])
                    {
                        PicPranckCollectionViewController *ppCollecVC=(PicPranckCollectionViewController *)currVc;
                        [PicPranckCustomViewsServices createPreviewInCollectionViewController:ppCollecVC WithIndex:imgView.indexOfViewInCollectionView];
                    }
                }
            }
            
        }
    }
}
@end
