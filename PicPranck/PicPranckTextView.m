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
        //UITapGestureRecognizer *tapGestureRecognizer=(UITapGestureRecognizer *)gestureRecognizer;
        [super addGestureRecognizer:gestureRecognizer];
    }
}
-(void)initWithDelegate:(id<UITextViewDelegate> ) textViewDelegate ImageView:(UIImageView *)iImageView AndText:(NSString *)text
{
    //Initialization
    self.imageView=imageView;
    gestureView=[[UIView alloc]  init];
    //Layout
    [self setText:text];
    self.frame=iImageView.frame;
    self.delegate=textViewDelegate;
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.tapsAcquired=0;
    self.layer.frame=iImageView.frame;
    self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[[UIColor redColor]CGColor];
    self.layer.borderWidth= 1.0f;
    [self setTextAlignment:NSTextAlignmentCenter];
    
    
    [[self layer] setBorderWidth:2.0f];
    [[self layer] setBorderColor:[UIColor blueColor].CGColor];
}
//-(BOOL)canBecomeFirstResponder
//{
//    BOOL result=NO;
//    if(2==self.tapsAcquired)
//        result=YES;
//    return result;
//}
//-(void)removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//{
//
//}
//-(BOOL)becomeFirstResponder
//{
//    if(2==self.tapsAcquired)
//        return [super becomeFirstResponder];
//    else
//        return NO;
//}
@end
