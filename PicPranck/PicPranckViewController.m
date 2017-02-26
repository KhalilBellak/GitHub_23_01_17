//
//  PicPranckViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 14/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckViewController.h"
#import "PicPranckImageView.h"
#import "AppDelegate.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCollectionViewCell.h"

@interface PicPranckViewController ()

@end
#pragma mark -
@implementation PicPranckViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    //self.modalPresentationStyle = UIModalPresentationFormSheet;
    // Do any additional setup after loading the view.
}

#pragma mark - Navigation

/*// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
