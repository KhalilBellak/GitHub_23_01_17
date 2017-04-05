//
//  ImageOfArea+CoreDataProperties.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 05/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ImageOfArea+CoreDataProperties.h"

@implementation ImageOfArea (CoreDataProperties)

+ (NSFetchRequest<ImageOfArea *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ImageOfArea"];
}

@dynamic dataImage;
@dynamic owner;

@end
