//
//  PicPranckImage.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckImage : UIImage
@property (nonatomic) UIImageOrientation originalImageOrientation;

-(UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
-(instancetype)initWithImage:(UIImage *)iImage;

@end
