//
//  TabBarViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "TabBarViewController.h"
#import "PicPranckViewControllerAnimatedTransitioning.h"
@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate=self;
    // Do any additional setup after loading the view.
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor blackColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Impact" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor blackColor]
                                                        } forState:UIControlStateSelected];
    
    
    // doing this results in an easier to read unselected state then the default iOS 7 one
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Impact" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1]
                                                        } forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark <UITabBarControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    //NSLog(@"Selected Index: %@",self.selectedIndex);
    PicPranckViewControllerAnimatedTransitioning *vcAnimTrans=[[PicPranckViewControllerAnimatedTransitioning alloc]  initWithtabBarController:self andIndex:tabBarController.selectedIndex];
    return vcAnimTrans;
}
//-(id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
