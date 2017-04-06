//
//  PicPranckCollectionViewFlowLayout.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 15/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckCollectionViewFlowLayout : UICollectionViewFlowLayout
@property CGFloat cellSize;
@property NSInteger nbOfElements;
+(CGFloat)getHeaderHeight;
+(CGSize)getCellSize;
@end
