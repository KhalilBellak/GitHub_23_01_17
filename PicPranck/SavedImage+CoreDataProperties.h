//
//  SavedImage+CoreDataProperties.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "SavedImage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SavedImage (CoreDataProperties)

+ (NSFetchRequest<SavedImage *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateOfCreation;
@property (nonatomic) BOOL newPicPranck;
@property (nullable, nonatomic, retain) NSSet<ImageOfArea *> *imageChildren;

@end

@interface SavedImage (CoreDataGeneratedAccessors)

- (void)addImageChildrenObject:(ImageOfArea *)value;
- (void)removeImageChildrenObject:(ImageOfArea *)value;
- (void)addImageChildren:(NSSet<ImageOfArea *> *)values;
- (void)removeImageChildren:(NSSet<ImageOfArea *> *)values;

@end

NS_ASSUME_NONNULL_END
