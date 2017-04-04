//
//  PicPranckCollectionViewCell.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PicPranckImageView;

@interface PicPranckCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet PicPranckImageView *imageViewInCell;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndic;
@end
