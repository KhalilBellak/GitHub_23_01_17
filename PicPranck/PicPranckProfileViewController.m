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
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "UIImageView+AFNetworking.h"

@import Firebase;

@interface PicPranckProfileViewController ()

@end

@implementation PicPranckProfileViewController
static NSString * const reuseIdentifier = @"profileCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.backGroungView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    //To avoid having additional rows on last section
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
    //[cell setBackgroundColor:[UIColor blackColor]];
    
    if(1==indexPath.section || 2==indexPath.section)
    {
        
        NSString *rowTitle=@"Remove All created PicPranks";
        if(1==indexPath.section && 1==indexPath.row)
            rowTitle=@"Log out";
        else if(2==indexPath.section)
        {
            if(0==indexPath.row)
                rowTitle=@"Share with Facebook";
            else if(1==indexPath.row)
                rowTitle=@"Share with Email";
        }
        NSAttributedString * sectionTitleAttrString=[PicPranckCustomViewsServices getAttributedStringWithString:rowTitle withFontSize:12.0];
        UILabel *viewWithTitle=[[UILabel alloc] initWithFrame:cell.contentView.frame];
        [viewWithTitle setAttributedText:sectionTitleAttrString];
        [cell.contentView addSubview:viewWithTitle];
    }
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
    else if(2==indexPath.section)
    {
        NSLog(@"Nb Of rows: %ldl",(long)[tableView numberOfRowsInSection:2]);
        NSLog(@"Index of row: %ldl",(long)indexPath.row);
        if(1==indexPath.row)
        {
            if([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailVC=[[MFMailComposeViewController alloc] init];
                [mailVC setMailComposeDelegate:self];
                // Configure the fields of the interface.
                //[mailVC setToRecipients:@[@"address@example.com"]];
                [mailVC setSubject:[PicPranckProfileViewController getTitle]];
                [mailVC setMessageBody:[PicPranckProfileViewController getDescription] isHTML:YES];
                
                // Present the view controller modally.
                [self presentViewController:mailVC animated:YES completion:nil];
            }
            else
                [self showMessagePrompt:@"Mail services are not available !"];
        }
        else if(0==indexPath.row)
        {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentTitle=[PicPranckProfileViewController getTitle];
            content.contentDescription=[PicPranckProfileViewController getDescription];
            content.contentURL = [NSURL URLWithString:@"http://pickprank-app.com/"];
            [FBSDKMessageDialog showWithContent:content delegate:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
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
+(NSString *)getTitle
{
    return @"Let the troll inside you take over! ";
}
+(NSString *)getDescription
{
    NSString *string1=@"Hello !";
    NSString *string2=@"Here is my application to create customizable PickPranks: ";
    NSString *string3=@"http://pickprank-app.com/";
    NSString *desc=[NSString stringWithFormat:@"%@\r%@\r%@",string1,string2,string3];
    return desc;
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
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    //[view setBackgroundColor:[UIColor blackColor]];
    
    if(1==section || 2==section)
    {
        
        NSString *sectionTitle=@"Manage Profile";
        if(2==section)
            sectionTitle=@"Share with friends";
        
        NSAttributedString * sectionTitleAttrString=[PicPranckCustomViewsServices getAttributedStringWithString:sectionTitle withFontSize:15.0];
        UILabel *viewWithTitle=[[UILabel alloc] initWithFrame:view.frame];
        [viewWithTitle setAttributedText:sectionTitleAttrString];
        
        [view addSubview:viewWithTitle];
    }
}
@end
