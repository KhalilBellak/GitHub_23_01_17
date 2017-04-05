//
//  ImageOfAreaDetails+CoreDataProperties.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 05/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ImageOfAreaDetails+CoreDataProperties.h"

@implementation ImageOfAreaDetails (CoreDataProperties)

+ (NSFetchRequest<ImageOfAreaDetails *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ImageOfAreaDetails"];
}

@dynamic position;
@dynamic owner;
@dynamic imageOfAreaWithData;

@end
