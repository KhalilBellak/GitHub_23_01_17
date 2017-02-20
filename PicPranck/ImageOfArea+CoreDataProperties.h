//
//  ImageOfArea+CoreDataProperties.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ImageOfArea+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ImageOfArea (CoreDataProperties)

+ (NSFetchRequest<ImageOfArea *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *dataImage;
@property (nonatomic) int16_t position;
@property (nullable, nonatomic, retain) SavedImage *parent;

@end

NS_ASSUME_NONNULL_END
