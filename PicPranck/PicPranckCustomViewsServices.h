//
//  PicPranckCustomViewsServices.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PicPranckCollectionViewController;
@class PicPranckButton;
@interface PicPranckCustomViewsServices : NSObject

@property UIViewController *modalViewController;
//+(ViewController *)viewController;
+(PicPranckButton *)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame text:(NSString *)text andSelector:(SEL)action;
+(void)createPreviewInCollectionViewController:(PicPranckCollectionViewController *)vc WithIndex:(NSInteger) index;
@end
