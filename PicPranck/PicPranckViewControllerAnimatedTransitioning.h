//
//  PicPranckViewControllerAnimatedTransitioning.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 26/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckViewControllerAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property BOOL forModalView;
@property UITabBarController *tabBarController;
@property NSInteger index;
@property id<UIViewControllerContextTransitioning>transitionContext;
-(id)initWithtabBarController: (UITabBarController *)iTabBarController andIndex:(NSInteger)iIndex;

@end
