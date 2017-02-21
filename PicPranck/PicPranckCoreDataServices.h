//
//  PicPranckCoreDataServices.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewController;
@class PicPranckViewController;

@interface PicPranckCoreDataServices : NSObject

+(void)uploadImages:(NSArray *)listOfImages withViewController: (ViewController *)viewController;
+(void)addThumbnailInPicPranckGallery:(PicPranckViewController *)ppViewController;
@end
