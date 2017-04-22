//
//  PicPranckCollectionViewCell.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import "CollectionViewController.h"

#import "PicPranckCollectionViewCell.h"
#import "PicPranckActionServices.h"
#import "PicPranckImageServices.h"
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
        //self.acces
        [self.contentView addSubview:_imageViewInCell];
    }
    
    
    return _imageViewInCell;
}
-(UIActivityIndicatorView *)activityIndic
{
    if(!_activityIndic)
    {
        _activityIndic=[[UIActivityIndicatorView alloc] initWithFrame:self.contentView.bounds];
        [_activityIndic setBackgroundColor:[PicPranckImageServices getGlobalTintWithLighterFactor:-50]];
        _activityIndic.alpha=0.75;
        [self.contentView addSubview:_activityIndic];
        
         [_activityIndic startAnimating];
    }
    return _activityIndic;
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
//-(void)setSelected:(BOOL)selected
//{
//    [super setSelected:selected];
//    NSInteger collectionViewMode=[CollectionViewController getModeOfCollectionView];
//    [self.contentView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
//    if(selected && 1==collectionViewMode)
//        [self.contentView.layer setBorderWidth:2];
//    else
//        [self.contentView.layer setBorderWidth:0];
//    
//}
@end
