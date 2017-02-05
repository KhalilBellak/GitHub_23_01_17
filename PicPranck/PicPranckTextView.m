//
//  PicPranckTextView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 28/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckTextView.h"

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
    self.tapsAcquired=0;
    self.editable=YES;
    self.edited=NO;
    self.delegate=textViewDelegate;
    self.imageView=iImageView;
    
    //self.imageView=iImageView;
    
    UIColor *pColor=[UIColor whiteColor];
    if([text length]>0)
    {
        //TODO: fill text with white (not transparent)
        NSNumber *stroke=[[NSNumber alloc] init];
        stroke=[NSNumber numberWithFloat:7.0];
        NSDictionary *typingAttributes = @{
                                           NSFontAttributeName: [UIFont fontWithName:@"Impact" size:22.0f],
                                           NSForegroundColorAttributeName : pColor,
                                           NSKernAttributeName : @(1.3f),
                                           NSStrokeColorAttributeName : [UIColor blackColor],
                                           NSStrokeWidthAttributeName :stroke
                                           };
        NSAttributedString *attributedText=[[NSAttributedString alloc] initWithString:text attributes:typingAttributes];
        [self setAttributedText:attributedText ];
    }
    
   //LAYOUT
    self.frame=iImageView.frame;
    [self setBackgroundColor:[UIColor clearColor]];
    self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    //self.layer.borderWidth= 1.0f;
    [self.layer setBorderWidth:2.0f];
    //UIColor *borderColor=iImageView.layer.borderColor;
    [self.layer setBorderColor:iImageView.layer.borderColor];
    
    self.tapsAcquired=0;
    
    [self setTextAlignment:NSTextAlignmentCenter];
    //gesture view
    self.gestureView=[[UIView alloc] init];
    self.gestureView.frame=iImageView.frame;
    [self.gestureView setBackgroundColor:[UIColor clearColor]];
    
}
//-(BOOL)becomeFirstResponder
//{
//    if(2==self.tapsAcquired)
//    {
//        NSLog(@"becomeFirstResponder");
//        return [super becomeFirstResponder];
//    }
//    return NO;
//}
@end
