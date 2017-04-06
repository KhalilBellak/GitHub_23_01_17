//
//  SavedImage+CoreDataProperties.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 06/04/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "SavedImage+CoreDataProperties.h"

@implementation SavedImage (CoreDataProperties)

+ (NSFetchRequest<SavedImage *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SavedImage"];
}

@dynamic dateOfCreation;
@dynamic newPicPranck;
@dynamic imageOfAreaDetails;

@end
