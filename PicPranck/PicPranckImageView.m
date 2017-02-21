//
//  PicPranckImageView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckImageView.h"
#import "PicPranckImageServices.h"
#import "ViewController.h"
#import "ImageOfArea+CoreDataClass.h"

#define X_OFFSET_FROM_CENTER_OF_SCREEN 20
#define Y_OFFSET_FROM_BOTTOM_OF_SCREEN 60
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 30
#define WIDTH_PREVIEW 200
#define HEIGHT_PREVIEW 400
@implementation PicPranckImageView

-(id)initFromViewController:(PicPranckViewController *)iViewController withManagedObject:(SavedImage *)iManagedObject andFrame:(CGRect)frame
{
    if(!iManagedObject || !iViewController)
        return nil;
    //Initialize attributes
    _managedObject=iManagedObject;
    _viewController=iViewController;
    _listOfImgs=[[NSMutableArray alloc] init];
    //Init self
    self=[self init];
    //Gesture Recognizers
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
    tapOnce.numberOfTouchesRequired = 1;
    //tapOnce.cancelsTouchesInView=NO;
    [self addGestureRecognizer:tapOnce];
    self.userInteractionEnabled = YES;
    //Set Image
    NSInteger position=1;
    NSPredicate *myPredicate = [NSPredicate predicateWithFormat:@"position == %@", @(position)];
    NSObject *chosenImgOfArea = [_managedObject.imageChildren filteredSetUsingPredicate:myPredicate].anyObject;
    id idImage=nil;
    if([chosenImgOfArea isKindOfClass:[ImageOfArea class]])
    {
        ImageOfArea *imgOfArea=(ImageOfArea *) chosenImgOfArea;
        idImage=imgOfArea.dataImage;
    }
    //Set image for thumbnail
    UIImage *image=[UIImage imageWithData:idImage];
    [self setContentMode:UIViewContentModeScaleAspectFit];
    [self setImage:image];
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor blackColor]];
    
    iManagedObject.newPicPranck=NO;
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
            //Sort the set
            NSSortDescriptor *sortDsc=[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
            NSArray *arrayDsc=[[NSArray alloc] initWithObjects:sortDsc, nil];
            NSArray *sortedArray=[_managedObject.imageChildren sortedArrayUsingDescriptors:arrayDsc];
            for(ImageOfArea *imgOfArea in sortedArray)
            //for(int i=0;i<3;i++)
            {
                id idImage=imgOfArea.dataImage;
                UIImage *image=[UIImage imageWithData:idImage];
                //Set frame of child UIImageVIew
                CGRect childFrame=CGRectMake(0, totalHeight, previewFrame.size.width, heightChildImageView);
                totalHeight+=heightChildImageView;
                UIImageView *childImageView=[[UIImageView alloc] init];
                [childImageView setFrame:childFrame];
                [childImageView setBackgroundColor:[UIColor blackColor]];
                [childImageView setContentMode:UIViewContentModeScaleAspectFit];
                //Keep rotated images
                [_listOfImgs addObject:image];
                [childImageView setImage:image];
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
    [_coverView removeFromSuperview];
    
    NSArray *vcArray=[_viewController.tabBarController viewControllers];
    for(UIViewController *currVc in vcArray)
    {
        if([currVc isKindOfClass:[ViewController class]])
        {
            ViewController *vc=(ViewController *)currVc;
            [PicPranckImageServices setImageAreasWithImages:_listOfImgs inViewController:vc];
            [_viewController.tabBarController setSelectedViewController:vc];
        }
    }
}
@end
