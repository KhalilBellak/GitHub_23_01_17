//
//  PicPranckImageView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "PicPranckImageView.h"
#import "PicPranckImageServices.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckEncryptionServices.h"
#import "ViewController.h"
#import "ImageOfArea+CoreDataClass.h"
#import "PicPranckFirebaseCollectionViewController.h"
#define X_OFFSET_FROM_CENTER_OF_SCREEN 20
#define Y_OFFSET_FROM_BOTTOM_OF_SCREEN 60
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 30
#define WIDTH_PREVIEW 200
#define HEIGHT_PREVIEW 400
#define DELETE_BUTTON_RELATIVE_RADIUS 8

//TODO: To delete later

@implementation PicPranckImageView
//@synthesize indexOfViewInCollectionView=_indexOfViewInCollectionView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark Gesture Recognizers

//-(void)deleteImageView: (UITapGestureRecognizer *)sender
//{
//    if ( sender.state == UIGestureRecognizerStateEnded )
//    {
//        //Delete image from data
//        [PicPranckCoreDataServices removeImages:_managedObject];
//        [_layerView removeFromSuperview];
//        [self removeFromSuperview];
//    }
//}
//-(void)setImage:(UIImage *)image
//{
//    if([self.delegate isKindOfClass:[PicPranckFirebaseCollectionViewController class]])
//    {
//        
//        NSData *imageData = UIImagePNGRepresentation(image);
//        UIImage *decryptedImage=[PicPranckEncryptionServices decryptImage:imageData];
//        [super setImage:decryptedImage];
//        return;
//    }
//    [super setImage:image];
//}
-(void)removeDeleteButton: (UITapGestureRecognizer *)sender
{
    if ( sender.state == UIGestureRecognizerStateEnded )
        [sender.view removeFromSuperview];
}

#pragma mark Buttons on Cover View
-(void)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame text:(NSString *)text andSelector:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:iFrame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [iView addSubview:button];
}


@end
