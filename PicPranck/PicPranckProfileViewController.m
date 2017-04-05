//
//  PicPranckProfileViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 18/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckProfileViewController.h"
#import "TabBarViewController.h"
#import "UIViewController+Alerts.h"

#import "PicPranckCustomViewsServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCoreDataServices.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "UIImageView+AFNetworking.h"

@import Firebase;
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface PicPranckProfileViewController ()

@end

@implementation PicPranckProfileViewController
static NSString * const reuseIdentifier = @"profileCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2)];
    [self.backGroungView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
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
#pragma mark <UITableViewDelegate>

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(1==indexPath.section)
    {
        if(indexPath.row==[tableView numberOfRowsInSection:1]-1)
            [self showMessagePrompt:@"Do you really want to Log out from PickPrank ?" withActionBlockOfType:@"Log out"];
        else if (indexPath.row==[tableView numberOfRowsInSection:1]-2)
            [self showMessagePrompt:@"Do you really want to delete all PickPranks ?" withActionBlockOfType:@"Remove all"];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
//#pragma mark <UITableViewDelegate>
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if(0==section || 1==section || 2==section)
//        return 2;
//    return 0;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//    
//    return cell;
//}

@end
