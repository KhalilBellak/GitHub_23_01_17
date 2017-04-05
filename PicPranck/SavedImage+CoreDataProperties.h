//
//  SavedImage+CoreDataProperties.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 05/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "SavedImage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SavedImage (CoreDataProperties)

+ (NSFetchRequest<SavedImage *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateOfCreation;
@property (nonatomic) BOOL newPicPranck;
@property (nullable, nonatomic, retain) NSSet<ImageOfAreaDetails *> *imageOfAreaDetails;

@end

@interface SavedImage (CoreDataGeneratedAccessors)

- (void)addImageOfAreaDetailsObject:(ImageOfAreaDetails *)value;
- (void)removeImageOfAreaDetailsObject:(ImageOfAreaDetails *)value;
- (void)addImageOfAreaDetails:(NSSet<ImageOfAreaDetails *> *)values;
- (void)removeImageOfAreaDetails:(NSSet<ImageOfAreaDetails *> *)values;

@end

NS_ASSUME_NONNULL_END
