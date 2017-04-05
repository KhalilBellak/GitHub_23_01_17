//
//  ImageOfAreaDetails+CoreDataProperties.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 05/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ImageOfAreaDetails+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ImageOfAreaDetails (CoreDataProperties)

+ (NSFetchRequest<ImageOfAreaDetails *> *)fetchRequest;

@property (nonatomic) int16_t position;
@property (nullable, nonatomic, retain) SavedImage *owner;
@property (nullable, nonatomic, retain) ImageOfArea *imageOfAreaWithData;

@end

NS_ASSUME_NONNULL_END
