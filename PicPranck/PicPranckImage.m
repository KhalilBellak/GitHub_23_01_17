//
//  PicPranckImage.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckImage.h"

@implementation PicPranckImage
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
    return [newImage croppedImageWithRect: CGRectMake ((newImage.size.width - width) / 2, (newImage.size.height - height) / 2, width, height)];
}

-(CGImageRef)CGImageWithCorrectOrientation
{
    if (self.imageOrientation == UIImageOrientationDown) {
        //retaining because caller expects to own the reference
        CGImageRetain([self CGImage]);
        return [self CGImage];
    }
    
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 180 * M_PI/180);
    }
    
    [self drawAtPoint:CGPointMake(0, 0)];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return cgImage;
    //retaining because caller expects to own the reference
    //CGImageRetain([self CGImage]);
    //return [self CGImage];
//    //if (self.imageOrientation == UIImageOrientationDown)
//    CGFloat angle=0.0;
//    
//    if (self.imageOrientation==_originalImageOrientation)
//    {
//        //retaining because caller expects to own the reference
//        CGImageRetain([self CGImage]);
//        return [self CGImage];
//    }
//    
//    UIGraphicsBeginImageContext(self.size);
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    if (self.imageOrientation == UIImageOrientationUp)
//    {
//        angle=90*M_PI/180;
//    }
//    else
//    {
//    if (self.imageOrientation == UIImageOrientationRight)
//    {
//        if(_originalImageOrientation==UIImageOrientationUp)
//            angle=90 * M_PI/180;
//        else if(_originalImageOrientation==UIImageOrientationDown)
//            angle=-90 * M_PI/180;
//        else if(_originalImageOrientation==UIImageOrientationLeft)
//            angle=M_PI/180;
//    }
//    else if (self.imageOrientation == UIImageOrientationLeft)
//    {
//        if(_originalImageOrientation==UIImageOrientationUp)
//            angle=-90 * M_PI/180;
//        else if(_originalImageOrientation==UIImageOrientationDown)
//            angle=90 * M_PI/180;
//        else if(_originalImageOrientation==UIImageOrientationRight)
//            angle=M_PI;
//    }
//    else if (self.imageOrientation == UIImageOrientationUp)
//    {
//        if(_originalImageOrientation==UIImageOrientationDown)
//            angle=M_PI;
//        else if(_originalImageOrientation==UIImageOrientationRight)
//            angle=-90 * M_PI/180;
//        else if(_originalImageOrientation==UIImageOrientationLeft)
//            angle=90*M_PI/180;
//    }
//    else if (self.imageOrientation == UIImageOrientationDown)
//    {
//        if(_originalImageOrientation==UIImageOrientationUp)
//            angle=M_PI;
//        else if(_originalImageOrientation==UIImageOrientationRight)
//            angle=90 * M_PI/180;
//        else if(_originalImageOrientation==UIImageOrientationLeft)
//            angle=-90*M_PI/180;
//    }
//    }
//    CGContextRotateCTM (context,angle);
//    [self drawAtPoint:CGPointMake(0, 0)];
//    
//    CGImageRef cgImage = CGBitmapContextCreateImage(context);
//    UIGraphicsEndImageContext();
//    
//    return cgImage;
}

-(PicPranckImage*)resizedImageWithMinimumSize:(CGSize)size
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
}

-(PicPranckImage*)drawImageInBounds:(CGRect)bounds
{
    CGFloat angle=0.0;
    switch(_originalImageOrientation)
    {
        case UIImageOrientationRight:
            angle=90*M_PI/180;
            break;
        case UIImageOrientationLeft:
            angle=-90*M_PI/180;
            break;
        case UIImageOrientationDown:
            angle=M_PI;
            break;
        default:
            angle=0;
            break;
    }
    //Get size of rotated image
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width, bounds.size.height)];
    //[rotatedViewBox setBackgroundColor:[UIColor redColor]];
    CGAffineTransform t = CGAffineTransformMakeRotation(angle);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    //Create the context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Move origin of context to center
    CGContextTranslateCTM(context, rotatedSize.width/2, rotatedSize.height/2);
    //Now easy to rotate
    CGContextRotateCTM (context,angle);
    //Move back the origin and draw image
    [self drawInRect: CGRectMake(-bounds.size.width / 2, -bounds.size.height / 2, bounds.size.width, bounds.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
    //Return the PicPranckImage
    PicPranckImage *ppResizedImage=[[PicPranckImage alloc] initWithImage:image ];
    
    return ppResizedImage;
}

-(UIImage*)croppedImageWithRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height);
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self drawInRect:drawRect];
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return subImage;
}

-(UIImage *) resizableImageWithCapInsets2: (UIEdgeInsets) inset
{
    if ([self respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        return [self resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        float left = (self.size.width-2)/2;//The middle points rarely vary anyway
        float top = (self.size.height-2)/2;
        return [self stretchableImageWithLeftCapWidth:left topCapHeight:top];
    }
}
@end
