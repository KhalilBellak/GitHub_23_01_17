//
//  PicPranckImageView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckImageView.h"

#define X_OFFSET_FROM_CENTER_OF_SCREEN 20
#define Y_OFFSET_FROM_BOTTOM_OF_SCREEN 60
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 30
#define WIDTH_PREVIEW 200
#define HEIGHT_PREVIEW 400
@implementation PicPranckImageView

-(id)initFromViewController:(PicPranckViewController *)iViewController withManagedObject:(NSManagedObject *)iManagedObject andFrame:(CGRect)frame
{
    if(!iManagedObject || !iViewController)
        return nil;
    //Initialize attributes
    _managedObject=iManagedObject;
    _viewController=iViewController;
    //Init self
    self=[self init];
    //Gesture Recognizers
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
    tapOnce.numberOfTouchesRequired = 1;
    //tapOnce.cancelsTouchesInView=NO;
    [self addGestureRecognizer:tapOnce];
    self.userInteractionEnabled = YES;
    //Set Image
    id idImage=[_managedObject valueForKey:@"visibleImage"];
    UIImage *image=[UIImage imageWithData:idImage];
    [self setContentMode:UIViewContentModeScaleAspectFit];
    [self setImage:[self rotate:image withOrientation:UIImageOrientationRight]];
    
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor blackColor]];
    
    [_managedObject setValue:@(false) forKey:@"newPicPranck"];
    
    [_viewController.collectionView addSubview:self];
    [_viewController.collectionView bringSubviewToFront:self];
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark Gesture Recognizers
-(void) handleTapOnce: (UITapGestureRecognizer *)sender
{
    if(UIGestureRecognizerStateEnded==sender.state)
    {
        CGRect frame = [UIScreen mainScreen].bounds;
        //Take into consideration the tab bar
        CGRect newFrame=CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-_viewController.tabBarController.tabBar.frame.size.height);
        //Image View which will contain preview
        if(!_imageViewForPreview)
        {
            CGRect previewFrame=CGRectMake((newFrame.size.width-WIDTH_PREVIEW)/2, Y_OFFSET_FROM_BOTTOM_OF_SCREEN, WIDTH_PREVIEW, HEIGHT_PREVIEW);
            _imageViewForPreview=[[UIImageView alloc] initWithFrame:previewFrame];
            CGFloat totalHeight=0.0;
            CGFloat heightChildImageView=previewFrame.size.height/3;
            for(int i=0;i<3;i++)
            {
                id idImage=nil;
                switch(i) {
                    case 0:
                        idImage=[_managedObject valueForKey:@"upperImage"];
                        break;
                    case 1:
                        idImage=[_managedObject valueForKey:@"visibleImage"];
                        break;
                    default:
                        idImage=[_managedObject valueForKey:@"lowerImage"];
                        break;
                
                }
                UIImage *image=[UIImage imageWithData:idImage];
                //Set frame of child UIImageVIew
                CGRect childFrame=CGRectMake(0, totalHeight, previewFrame.size.width, heightChildImageView);
                totalHeight+=heightChildImageView;
                UIImageView *childImageView=[[UIImageView alloc] init];
                [childImageView setFrame:childFrame];
                [childImageView setBackgroundColor:[UIColor blackColor]];
                [childImageView setContentMode:UIViewContentModeScaleAspectFit];
                [childImageView setImage:[self rotate:image withOrientation:UIImageOrientationRight]];
                [_imageViewForPreview addSubview:childImageView];
            }
            
        }
        //View of screen's size and semi-transparent
        if(!_coverView)
        {
            _coverView=[[UIView alloc] initWithFrame:newFrame];
            _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
            //Add button close
            CGRect closeFrame=CGRectMake(newFrame.size.width/2+X_OFFSET_FROM_CENTER_OF_SCREEN, newFrame.size.height- Y_OFFSET_FROM_BOTTOM_OF_SCREEN, BUTTON_WIDTH, BUTTON_HEIGHT);
            [self addButtonInView:_coverView withFrame:closeFrame text:@"Close" andSelector:@selector(closePreview:)];
            //Add button Use
            CGRect useFrame=CGRectMake(newFrame.size.width/2-(BUTTON_WIDTH+ X_OFFSET_FROM_CENTER_OF_SCREEN), newFrame.size.height- Y_OFFSET_FROM_BOTTOM_OF_SCREEN, BUTTON_WIDTH, BUTTON_HEIGHT);
            [self addButtonInView:_coverView withFrame:useFrame text:@"Use" andSelector:@selector(useImage:)];
        }
        //Add preview UIImageView to cover view
        [_coverView addSubview:_imageViewForPreview];
        [_coverView bringSubviewToFront:_imageViewForPreview];
        //Make cover view pop up
        _coverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        [_viewController.view addSubview:_coverView];
        [UIView animateWithDuration:0.3/1.5 animations:^{
            _coverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                _coverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    _coverView.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
        
    }
}
#pragma mark Buttons on Cover View
-(void)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame text:(NSString *)text andSelector:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:iFrame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [iView addSubview:button];
}
-(IBAction)closePreview:(id)sender
{
    [_coverView removeFromSuperview];
}
-(IBAction)useImage:(id)sender
{
    
}
#pragma mark Method for Image manipulations
static inline double radians (double degrees) {return degrees * M_PI/180;}
-(UIImage *)rotate:(UIImage *) src  withOrientation:(UIImageOrientation) orientation
{
    //Calculate the size of the rotated view's containing box for our drawing space
    CGFloat nbDegrees=0.0;
    switch(orientation)
    {
        case UIImageOrientationRight:
            nbDegrees=90;
            break;
        case UIImageOrientationLeft:
            nbDegrees=-90;
            break;
        default:
            nbDegrees=0;
            break;
    }
    
    //Get size of rotated image
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,src.size.width, src.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(nbDegrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Move origin of context to center
    CGContextTranslateCTM(context, rotatedSize.width/2, rotatedSize.height/2);
    //Now easy to rotate
    CGContextRotateCTM (context, radians(nbDegrees));
    //CGContextScaleCTM(context, 1.0, -1.0);
    //Move back the origin and draw image
    CGContextDrawImage(context, CGRectMake(-src.size.width / 2, -src.size.height / 2, src.size.width, src.size.height), [src CGImage]);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end