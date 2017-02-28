//
//  PicPranckCoreDataServices.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ViewController;
@class PicPranckCollectionViewController;
@class PicPranckCollectionViewCell;
@class SavedImage;
@class NSManagedObject;

@interface PicPranckCoreDataServices : NSObject

+(int) initCount;
+(int) initNewSavedCount;

+(NSManagedObjectContext *)managedObjectContext;
//+(NSInteger)nbOfSavedPicPrancks;

+(void)uploadImages:(NSArray *)listOfImages withViewController: (ViewController *)viewController;

+(void)addThumbnailInPicPranckGallery:(PicPranckCollectionViewController *)ppViewController;
+(void)addThumbnailInPicPranckCollectionView:(PicPranckCollectionViewController *)collecViewController inCell:(PicPranckCollectionViewCell *)collecViewCell;

+(void)addThumbnailInImageView:(UIImageView *)imgView withIndex:(NSInteger)index;

+(SavedImage *)retrieveDataAtIndex:(NSInteger)index;
+(NSMutableArray *)retrieveImagesArrayFromDataAtIndex:(NSInteger)index;
+(NSArray *)retrieveAllSavedImages;

+(void)removeImages:(NSManagedObject *)objectToDelete;
+(NSInteger)getNumberOfSavedPicPrancks;
+(NSInteger)getNumberOfNewSavedPicPrancks;
@end
