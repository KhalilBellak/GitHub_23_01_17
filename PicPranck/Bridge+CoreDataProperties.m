//
//  Bridge+CoreDataProperties.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 06/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Bridge+CoreDataProperties.h"

@implementation Bridge (CoreDataProperties)

+ (NSFetchRequest<Bridge *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Bridge"];
}

@dynamic dateOfCreation;
@dynamic imagesOfArea;

@end
