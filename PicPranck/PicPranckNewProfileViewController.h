//
//  PicPranckNewProfileViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 24/05/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PicPranckNewProfileViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
//@property (strong, nonatomic) IBOutlet UITableView *profileTableView;
@property (strong, nonatomic) IBOutlet UIView *backGroungView;
-(void)logOut;
-(void)removeAll;
+(NSString *)getTitle;
+(NSString *)getDescription;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)logOutAction:(id)sender;
- (IBAction)flushPicPranksAction:(id)sender;
- (IBAction)shareWithFBAction:(id)sender;
- (IBAction)shareWithEmail:(id)sender;

@end
