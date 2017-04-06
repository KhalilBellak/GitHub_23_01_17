//
//  ImageOfAreaDetails+CoreDataProperties.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 06/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ImageOfAreaDetails+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ImageOfAreaDetails (CoreDataProperties)

+ (NSFetchRequest<ImageOfAreaDetails *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) SavedImage *owner;

@end

NS_ASSUME_NONNULL_END
