//
//  PicPranckTextView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 28/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
//PicPranck Objects
#import "PicPranckTextView.h"
//Services
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"

@implementation PicPranckTextView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        [super addGestureRecognizer:gestureRecognizer];
    }
}
-(void)initWithDelegate:(id<UITextViewDelegate> ) textViewDelegate ImageView:(UIImageView *)iImageView AndText:(NSString *)text
{
    
    self.delegate=textViewDelegate;
    self.imageView=iImageView;
    //self.imageView.contentMode=UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds=YES;
    //UIColor *pWhiteColor=[UIColor whiteColor];
    
    if([text length]>0)
    {
        NSAttributedString *attributedText=[PicPranckCustomViewsServices getAttributedStringWithString:text withFontSize:22.0f];
        [self setAttributedText:attributedText ];
    }

    //Gestures
    self.tapsAcquired=0;
    //gesture view
    if(!self.gestureView)
        self.gestureView=[[UIView alloc] init];
    [self.gestureView setBackgroundColor:[UIColor clearColor]];
    iImageView.userInteractionEnabled=YES;
    self.gestureView.userInteractionEnabled=YES;
    //Edition of text view
    self.editable=YES;
    self.edited=NO;
    [self setTextAlignment:NSTextAlignmentCenter];
    //Layout
    [self setBackgroundColor:[UIColor clearColor]];
    self.layer.masksToBounds=YES;
    self.clipsToBounds = YES;
    
    CGRect newFrame = CGRectMake(0,0,iImageView.frame.size.width,iImageView.frame.size.height);
    self.frame = newFrame;
    self.gestureView.frame=newFrame;
  
    iImageView.clipsToBounds = YES;
    iImageView.autoresizesSubviews = YES;
    [iImageView setBackgroundColor:[PicPranckImageServices getGlobalTintWithLighterFactor:-50]];
    iImageView.alpha=0.75;
    if(1==iImageView.tag)
        iImageView.alpha=1;
    //Make UITextView as a subview of UIImageView (for print and auto-resize issues)
    [iImageView addSubview:self];
    [iImageView addSubview:self.gestureView];
    [iImageView bringSubviewToFront:self.gestureView];
    
    
}
+(void)copyTextView:(PicPranckTextView *)textViewToCopy inOtherTextView:(PicPranckTextView *)targetTextView withImageView:(UIImageView *)iImageView
{
    if(textViewToCopy && targetTextView)
    {
        NSString *text = [NSString stringWithFormat:@"%@", textViewToCopy.text];
        [targetTextView initWithDelegate:textViewToCopy.delegate ImageView:iImageView AndText:text];
    }
}
@end
