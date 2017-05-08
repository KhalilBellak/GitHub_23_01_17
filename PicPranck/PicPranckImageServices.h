//
//  PicPranckImageServices.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ViewController;
@class PicPranckTextView;
@class PicPranckImage;

@interface PicPranckImageServices : NSObject

+ (NSMutableDictionary *)dicOfSizes;

+(UIImage *)generateImageToSend:(ViewController *)viewController;
+(void)sendPicture:(ViewController *)viewController;

+(void)setImage:(UIImage *)iImage forPicPranckTextView:(PicPranckTextView *)pPTextView inViewController: (ViewController *)viewController;
+(void)setImage:(UIImage *)iImage forImageView:(UIImageView *)iImageView;
+(void)setImageAreasWithImages:(NSMutableArray *)listOfImages inViewController: (ViewController *)viewController;

+(PicPranckImage*)drawImageInBounds:(CGRect)bounds inPicPranckImage:(PicPranckImage *)ppImage;
+(UIImage *)croppedImage:(UIImage *)image withRect:(CGRect)rect;
+(CGImageRef)CGImageWithCorrectOrientationFromImage:(UIImage *)image;
+(UIImage *)rotate:(UIImage *) src  withOrientation:(UIImageOrientation) orientation;

+(UIImage *)getImageForBackgroundColoringWithSize:(CGSize)targetSize;
+(UIColor *)getGlobalTintWithLighterFactor:(NSInteger)factor;
@end
