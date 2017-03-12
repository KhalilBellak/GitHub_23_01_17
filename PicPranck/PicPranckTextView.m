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
    UIColor *pWhiteColor=[UIColor whiteColor];
    
    if([text length]>0)
    {
        NSNumber *stroke=[[NSNumber alloc] init];
        stroke=[NSNumber numberWithFloat:-7.0];
        NSDictionary *typingAttributes = @{
                                           NSFontAttributeName: [UIFont fontWithName:@"Impact" size:22.0f],
                                           NSForegroundColorAttributeName : pWhiteColor,
                                           NSKernAttributeName : @(1.3f),
                                           NSStrokeColorAttributeName : [UIColor blackColor],
                                           NSStrokeWidthAttributeName :stroke
                                           };
        NSMutableAttributedString *attributedText=[[NSMutableAttributedString alloc] initWithString:text attributes:typingAttributes];

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
    //self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    [self.layer setBorderWidth:2.0f];
    [self.layer setBorderColor:[[PicPranckImageServices getGlobalTintWithLighterFactor:-100] CGColor]];
    
    
    
    //Make UITextView as a subview of UIImageView (for print and auto-resize issues)
    iImageView.layer.cornerRadius = self.frame.size.height/10;
    iImageView.clipsToBounds = YES;
    CGRect newFrame = CGRectMake(0,0,iImageView.frame.size.width,iImageView.frame.size.height);
    self.frame = newFrame;
    //self.layer=iImageView.layer;
    self.gestureView.frame=newFrame;
    
    self.layer.cornerRadius = self.frame.size.height/10;
    self.clipsToBounds = YES;
    
    iImageView.autoresizesSubviews = YES;
    //iImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
