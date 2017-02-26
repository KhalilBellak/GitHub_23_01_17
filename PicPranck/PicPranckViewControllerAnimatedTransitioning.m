//
//  PicPranckViewControllerAnimatedTransitioning.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 26/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckViewControllerAnimatedTransitioning.h"

@implementation PicPranckViewControllerAnimatedTransitioning

-(id)initWithtabBarController:(UITabBarController *)iTabBarController andIndex:(NSInteger)iIndex
{
    self= [super init];
    self.tabBarController = iTabBarController;
    self.index=iIndex;
    return self;
}


-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSInteger lastIndex=self.index;
    self.transitionContext = transitionContext;
    
    UIView *containerView = transitionContext.containerView;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if(!fromViewController || !toViewController || !containerView) return;
    
    [containerView addSubview:toViewController.view];
    
    CGFloat viewWidth = toViewController.view.bounds.size.width;
    
    if (self.tabBarController.selectedIndex < lastIndex)
        viewWidth = -viewWidth;
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]  delay: 0.0  usingSpringWithDamping: 1.2 initialSpringVelocity: 2.5  options:UIViewAnimationOptionTransitionNone animations:^{
        toViewController.view.transform = CGAffineTransformIdentity;
        fromViewController.view.transform = CGAffineTransformMakeTranslation(-viewWidth, 0);
    } completion:^(BOOL finish){
        //[self.transitionContext completeTransition:[self.transitionContext transitionWasCancelled]];
        [self.transitionContext completeTransition:YES];
        //self.tabBarController.selectedIndex=lastIndex;
        fromViewController.view.transform = CGAffineTransformIdentity;
    }];
}
@end
