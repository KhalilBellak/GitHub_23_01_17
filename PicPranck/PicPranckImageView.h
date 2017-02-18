//
//  PicPranckImageView.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PicPranckViewController.h"

@interface PicPranckImageView : UIImageView
@property (strong,nonatomic) NSManagedObject *managedObject;
@property (strong,nonatomic) PicPranckViewController *viewController;
@property (strong,nonatomic) UIView *coverView;
@property (strong,nonatomic) UIImageView *imageViewForPreview;
@property (strong,nonatomic) NSMutableArray *listOfRotatedImgs;
-(id)initFromViewController:(PicPranckViewController *)iViewController withManagedObject:(NSManagedObject *)iManagedObject andFrame:(CGRect)frame;

@end
