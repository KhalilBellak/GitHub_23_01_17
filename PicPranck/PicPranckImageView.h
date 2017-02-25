//
//  PicPranckImageView.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PicPranckCollectionViewController.h"
#import "SavedImage+CoreDataClass.h"
@interface PicPranckImageView : UIImageView
@property  NSInteger indexOfViewInCollectionView;
@property  UIView *layerView;
@property  SavedImage *managedObject;
@property  PicPranckCollectionViewController *viewController;
@property  UIView *coverView;
@property  UIImageView *imageViewForPreview;
@property  NSMutableArray *listOfImgs;
-(id)initFromViewController:(PicPranckCollectionViewController *)iViewController withManagedObject:(SavedImage *)iManagedObject andFrame:(CGRect)frame;

@end
