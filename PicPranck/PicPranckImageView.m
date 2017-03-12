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
#import "ViewController.h"
#import "ImageOfArea+CoreDataClass.h"

#define X_OFFSET_FROM_CENTER_OF_SCREEN 20
#define Y_OFFSET_FROM_BOTTOM_OF_SCREEN 60
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 30
#define WIDTH_PREVIEW 200
#define HEIGHT_PREVIEW 400
#define DELETE_BUTTON_RELATIVE_RADIUS 8

//TODO: To delete later

@implementation PicPranckImageView
@synthesize indexOfViewInCollectionView=_indexOfViewInCollectionView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark Gesture Recognizers

-(void) longPress: (UILongPressGestureRecognizer *)sender
{
//    if ( sender.state == UIGestureRecognizerStateBegan)
//    {
//        //View to remove the delete button when clicking somewhere else than delete button
//        _layerView=[[UIView alloc] initWithFrame:self.viewController.view.frame];
//        [_layerView setBackgroundColor:[UIColor clearColor]];
//        [self.viewController.view addSubview:_layerView];
//        //Gesture recognizer for layerView
//        UITapGestureRecognizer *tapOnceForCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeDeleteButton:)];
//        tapOnceForCancel.numberOfTouchesRequired = 1;
//        [_layerView addGestureRecognizer:tapOnceForCancel];
//        //Creating delete button
//        CGFloat radius=self.frame.size.width/DELETE_BUTTON_RELATIVE_RADIUS;
//        CGRect frame=CGRectMake(self.frame.origin.x-radius,self.frame.origin.y-radius,2*radius,2*radius);
//        UIView *deleteButton = [[UIView alloc] initWithFrame:frame];
//        //deleteButton.alpha = 0.5;
//        deleteButton.layer.cornerRadius = radius;
//        deleteButton.backgroundColor = [UIColor blackColor];
//        [deleteButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
//        [deleteButton.layer setBorderWidth:1];
//        //Add label to delete button
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        [label setTextColor:[UIColor whiteColor]];
//        [label setBackgroundColor:[UIColor clearColor]];
//        [label setFont:[UIFont fontWithName: @"Impact" size: 10.0f*DELETE_BUTTON_RELATIVE_RADIUS/4]];
//        [label setText:@"X"];
//        [label setTextAlignment:NSTextAlignmentCenter];
//        [deleteButton addSubview:label];
//        [deleteButton bringSubviewToFront:label];
//        //Gesture recognizer for delete button
//        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteImageView:)];
//        tapOnce.numberOfTouchesRequired = 1;
//        [deleteButton addGestureRecognizer:tapOnce];
//        
//        [_layerView addSubview:deleteButton];
//        [_layerView bringSubviewToFront:deleteButton];
//    }
}

-(void)deleteImageView: (UITapGestureRecognizer *)sender
{
    if ( sender.state == UIGestureRecognizerStateEnded )
    {
        //Delete image from data
        [PicPranckCoreDataServices removeImages:_managedObject];
        [_layerView removeFromSuperview];
        [self removeFromSuperview];
    }
}
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
