//
//  PicPranckCollectionViewCell.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckCollectionViewCell.h"
#import "PicPranckActionServices.h"
#import "PicPranckImageView.h"

@implementation PicPranckCollectionViewCell
- (PicPranckImageView *) imageViewInCell
{
    //self.layer.shouldRasterize = YES;
    //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    if (!_imageViewInCell) {
        _imageViewInCell = [[PicPranckImageView alloc] initWithFrame:self.contentView.bounds];
        //Gesture Recognizers
        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
        tapOnce.numberOfTouchesRequired = 1;
        tapOnce.cancelsTouchesInView=1;
        //tapOnce.cancelsTouchesInView=NO;
        [_imageViewInCell addGestureRecognizer:tapOnce];
        _imageViewInCell.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageViewInCell];
    }
    return _imageViewInCell;
}
-(void)handleTapOnce:(id)sender
{
    [PicPranckActionServices handleTapOnce:sender];
}
// Here we remove all the custom stuff that we added to our subclassed cell
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageViewInCell removeFromSuperview];
    self.imageViewInCell = nil;
}
@end
