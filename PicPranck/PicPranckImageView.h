//
//  PicPranckImageView.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//#import "PicPranckCollectionViewController.h"
#import "SavedImage+CoreDataClass.h"
@class PicPranckImageView;
@protocol PicPranckImageViewDelegate < NSObject >

-(void)cellTaped:(PicPranckImageView *)sender; //withIndex:(NSInteger) index;

@end

@class PicPranckImageViewDelegate;
@interface PicPranckImageView : UIImageView
@property  NSInteger indexOfViewInCollectionView;
@property  UIView *layerView;
@property  SavedImage *managedObject;
//@property (nonatomic, assign) PicPranckImageViewDelegate *delegate;
@property (nonatomic, weak) id <PicPranckImageViewDelegate> delegate;
//@property  PicPranckCollectionViewController *viewController;
@property  UIView *coverView;
@property  UIImageView *imageViewForPreview;
@property  NSMutableArray *listOfImgs;
@end


