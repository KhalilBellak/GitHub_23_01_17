//
//  TabBarViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View Controllers
#import "TabBarViewController.h"
//PicPranck Objects
#import "PicPranckViewControllerAnimatedTransitioning.h"
//Services
#import "PicPranckImageServices.h"
//Pods
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory.h>

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate=self;
    _allPicPrancksRemovedMode=NO;
    //NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    
    NSArray *listOfItems=self.tabBar.items;
    for(UITabBarItem *item in listOfItems)
    {
        NIKFontAwesomeIcon icon;
        switch ([listOfItems indexOfObject:item])
        {
            case 0:
                icon=NIKFontAwesomeIconEdit;
                break;
            case 1:
                icon=NIKFontAwesomeIconInbox;
                break;
            case 2:
                icon=NIKFontAwesomeIconPhoto;
                break;
            default:
                //icon=NIKFontAwesomeIconWrench;
                icon=NIKFontAwesomeIconUser;
                break;
        }
        //item.image=[factory createImageForIcon:icon];
        //item.selectedImage=[factory createImageForIcon:icon];
    }
    
    // Do any additional setup after loading the view.
    self.tabBar.barTintColor = [PicPranckImageServices getGlobalTintWithLighterFactor:30];
    self.tabBar.tintColor = [PicPranckImageServices getGlobalTintWithLighterFactor:-40];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Impact" size:10.0f],
                                                        NSForegroundColorAttributeName : [PicPranckImageServices getGlobalTintWithLighterFactor:-50]
                                                        } forState:UIControlStateSelected];
    
    
    // doing this results in an easier to read unselected state then the default iOS 7 one
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Impact" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor grayColor]
                                                        } forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIInterfaceOrientationMask)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController
{
    //Prevent from rotating
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark <UITabBarControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
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
