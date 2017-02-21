//
//  PicPranckImage.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckImage.h"
#import "PicPranckImageServices.h"

@implementation PicPranckImage

@synthesize originalImageOrientation=_originalImageOrientation;

-(instancetype)initWithImage:(UIImage *)iImage
{
    _originalImageOrientation=iImage.imageOrientation;
    return [super initWithCGImage:[iImage CGImage]];
}
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            targetSize.height *= 2.0f;
            targetSize.width *= 2.0f;
        }
    }
    
    NSUInteger width = targetSize.width;
    NSUInteger height = targetSize.height;
    PicPranckImage *newImage = [self resizedImageWithMinimumSize: CGSizeMake (width, height)];
    return [PicPranckImageServices croppedImage:newImage  withRect:CGRectMake ((newImage.size.width - width) / 2, (newImage.size.height - height) / 2, width, height)
        ];
}

-(PicPranckImage*)resizedImageWithMinimumSize:(CGSize)size
{
    CGImageRef imgRef = [PicPranckImageServices CGImageWithCorrectOrientationFromImage:self];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [PicPranckImageServices drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio)) inPicPranckImage:self];
}

@end
