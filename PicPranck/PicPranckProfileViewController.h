//
//  PicPranckProfileViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 18/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckProfileViewController : UITableViewController <UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
//@property (strong, nonatomic) IBOutlet UITableView *profileTableView;
@property (strong, nonatomic) IBOutlet UIView *backGroungView;

@end
