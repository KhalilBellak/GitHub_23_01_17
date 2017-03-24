//
//  CollectionViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PicPranckImageView.h"
#import "PicPranckButton.h"

@import Firebase;

@interface CollectionViewController : UICollectionViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,PicPranckImageViewDelegate,PicPranckButtonDelegate>

-(id)getPreviewImageForCellAtIndexPath:(NSIndexPath *)indexPath;
-(NSString *)getCellIdentifier;
@end


