//
//  ImageOfArea+CoreDataProperties.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 05/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ImageOfArea+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ImageOfArea (CoreDataProperties)

+ (NSFetchRequest<ImageOfArea *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *dataImage;
@property (nullable, nonatomic, retain) ImageOfAreaDetails *owner;

@end

NS_ASSUME_NONNULL_END
