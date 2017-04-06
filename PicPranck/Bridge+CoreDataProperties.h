//
//  Bridge+CoreDataProperties.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 06/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Bridge+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Bridge (CoreDataProperties)

+ (NSFetchRequest<Bridge *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateOfCreation;
@property (nullable, nonatomic, retain) NSSet<ImageOfArea *> *imagesOfArea;

@end

@interface Bridge (CoreDataGeneratedAccessors)

- (void)addImagesOfAreaObject:(ImageOfArea *)value;
- (void)removeImagesOfAreaObject:(ImageOfArea *)value;
- (void)addImagesOfArea:(NSSet<ImageOfArea *> *)values;
- (void)removeImagesOfArea:(NSSet<ImageOfArea *> *)values;

@end

NS_ASSUME_NONNULL_END
