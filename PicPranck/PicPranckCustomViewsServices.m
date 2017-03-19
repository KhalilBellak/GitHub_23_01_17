//
//  PicPranckCustomViewsServices.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckCustomViewsServices.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckActionServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckViewControllerAnimatedTransitioning.h"
#import "PicPranckButton.h"
#import "ViewController.h"
#import "PicPranckCollectionViewController.h"
#import "PicPranckViewController.h"
#import "SavedImage+CoreDataClass.h"
#import "ImageOfArea+CoreDataClass.h"

#define X_OFFSET_FROM_CENTER_OF_SCREEN 20
#define Y_OFFSET_FROM_BOTTOM_OF_SCREEN 60
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 30
#define WIDTH_PREVIEW 400
#define HEIGHT_PREVIEW 1200
#define WIDTH_PREVIEW_RATIO 2
#define HEIGHT_PREVIEW_RATIO 1.33 //4/3
#define DELETE_BUTTON_RELATIVE_RADIUS 8

@implementation PicPranckCustomViewsServices

//+(ViewController *)viewController
//{
//    static ViewController *vc=nil;
//    if(!vc)
//        vc=[[ViewController alloc] init];
//    return vc;
//}
#pragma mark Preview creation
+(void)createPreviewInCollectionViewController:(PicPranckCollectionViewController *)vc WithIndex:(NSInteger) index
{
    SavedImage *managedObject=[PicPranckCoreDataServices retrieveDataAtIndex:index];
    if(!managedObject)
        return;
    //Get frame
    CGRect frame = [UIScreen mainScreen].bounds;
    //Take half width of screen and 3/4 of height of screen for preview
    CGFloat widthOfPreview=frame.size.width/WIDTH_PREVIEW_RATIO;
    CGFloat heightOfPreview=frame.size.height/HEIGHT_PREVIEW_RATIO;
    CGRect previewFrame=CGRectMake((frame.size.width-widthOfPreview)/2, (frame.size.height-heightOfPreview)/2, widthOfPreview, heightOfPreview);
    UIView *imageViewForPreview=[[UIView alloc] initWithFrame:previewFrame];
    
    //UIImageView *imageViewForPreview=[[UIImageView alloc] init];
    if(imageViewForPreview)
    {
        CGFloat totalHeight=0.0;
        CGFloat heightChildImageView=previewFrame.size.height/3;
        //Sort the set
        NSSortDescriptor *sortDsc=[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSArray *arrayDsc=[[NSArray alloc] initWithObjects:sortDsc, nil];
        
        NSArray *sortedArray=[managedObject.imageChildren sortedArrayUsingDescriptors:arrayDsc];
        
        for(ImageOfArea *imgOfArea in sortedArray)
        {
            id idImage=imgOfArea.dataImage;
            UIImage *image=[UIImage imageWithData:idImage];
            //Set frame of child UIImageVIew
            CGRect childFrame=CGRectMake(0, totalHeight, previewFrame.size.width, heightChildImageView);
            totalHeight+=heightChildImageView;
            UIImageView *childImageView=[[UIImageView alloc] init];
            childImageView.tag=[sortedArray indexOfObject:imgOfArea];
            [childImageView setFrame:childFrame];
            [childImageView setBackgroundColor:[UIColor blackColor]];
            [childImageView setContentMode:UIViewContentModeScaleAspectFit];
            //Keep rotated images
            [childImageView setImage:image];
            [imageViewForPreview addSubview:childImageView];
        }
    }
    
    //View of screen's size and semi-transparent
    UIView *coverView=[[UIView alloc] initWithFrame:frame];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    
    //Modal VC to display view
    PicPranckViewController *modalViewController=[[PicPranckViewController alloc] initModalView];
    [modalViewController.view addSubview:coverView];
    
    //Add button close
    CGRect closeFrame=CGRectMake(frame.size.width/2+X_OFFSET_FROM_CENTER_OF_SCREEN, frame.size.height- Y_OFFSET_FROM_BOTTOM_OF_SCREEN, BUTTON_WIDTH, BUTTON_HEIGHT);
    PicPranckButton *closeButton=[PicPranckCustomViewsServices addButtonInView:coverView withFrame:closeFrame text:@"Close" andSelector:@selector(closePreview:)];
    closeButton.tag=index;
    closeButton.modalVC=modalViewController;
    //closeButton.ppCollectionVC=vc;
    closeButton.delegate=vc;
    //Add button Use
    CGRect useFrame=CGRectMake(frame.size.width/2-(BUTTON_WIDTH+ X_OFFSET_FROM_CENTER_OF_SCREEN), frame.size.height- Y_OFFSET_FROM_BOTTOM_OF_SCREEN, BUTTON_WIDTH, BUTTON_HEIGHT);
    PicPranckButton *useButton=[PicPranckCustomViewsServices addButtonInView:coverView withFrame:useFrame text:@"Use" andSelector:@selector(useImage:)];
    useButton.tag=index;
    useButton.modalVC=modalViewController;
    //useButton.ppCollectionVC=vc;
    useButton.delegate=vc;
    //Add preview UIImageView to cover view
    [coverView addSubview:imageViewForPreview];
    [coverView bringSubviewToFront:imageViewForPreview];

    //Handle animation of modal presentation
    [vc presentViewController:modalViewController animated:YES completion:nil];
}
+(void)closePreview:(id)sender
{
    [PicPranckActionServices closePreview:sender];
}
+(void)useImage:(id)sender
{
    [PicPranckActionServices useImage:sender];
}
#pragma mark Buttons on Cover View
+(PicPranckButton *)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame text:(NSString *)text andSelector:(SEL)action
{
    PicPranckButton *button = [[PicPranckButton alloc] initWithFrame:iFrame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [iView addSubview:button];
    return button;
}
#pragma mark Design of buttons (border, background, attributed text....)
+(void)setViewDesign:(UIView *)view
{
    view.layer.cornerRadius = view.frame.size.height/10;
    [view.layer setBorderWidth:2.0f];
    [view.layer setBorderColor:[[PicPranckImageServices getGlobalTintWithLighterFactor:-100] CGColor]];
    [view setBackgroundColor:[PicPranckImageServices getGlobalTintWithLighterFactor:-50]];
}
+(void)setLogInButtonsDesign:(UIButton *)button withText:(NSString *)string
{
    [button setBackgroundColor:[UIColor clearColor]];
    CGFloat fontSize=18.0f;
    if([string isEqualToString:@"Forgot Password ?"])
        fontSize=15.0f;
    NSAttributedString *buttonTitle=[PicPranckCustomViewsServices getAttributedStringWithString:string withFontSize:fontSize];
    [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
}
+(NSAttributedString *)getAttributedStringWithString:(NSString *)string withFontSize:(CGFloat)size
{
    NSNumber *stroke=[[NSNumber alloc] init];
    stroke=[NSNumber numberWithFloat:-7.0];
    NSDictionary *typingAttributes = @{
                                       NSFontAttributeName: [UIFont fontWithName:@"Impact" size:size],
                                       NSForegroundColorAttributeName : [UIColor whiteColor],
                                       NSKernAttributeName : @(1.3f),
                                       NSStrokeColorAttributeName : [UIColor blackColor],
                                       NSStrokeWidthAttributeName :stroke
                                       };
    NSMutableAttributedString *attributedText=[[NSMutableAttributedString alloc] initWithString:string attributes:typingAttributes];
    return attributedText;
}
@end
