//
//  PicPranckButton.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 25/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PicPranckButton;
@protocol PicPranckButtonDelegate < NSObject >
-(void)useImage:(PicPranckButton *)sender;
-(void)dismissViewController;
@end

@interface PicPranckButton : UIButton
@property (weak,nonatomic)UIViewController *modalVC;
@property (nonatomic, weak) id <PicPranckButtonDelegate> delegate;
@end
