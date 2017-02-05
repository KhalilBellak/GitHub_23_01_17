//
//  ViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicPranckTextView.h"
@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>
{
    NSMutableArray *listOfTextViews;
    NSMutableArray *listOfGestureViews;
    
    PicPranckTextView *tapedTextView;
    UIColor *globalTint;
    
    UIImagePickerController *picker;
    UIImage *image;
    
    PicPranckTextView *textView1;
    IBOutlet UIImageView *imageViewArea1;
    

    IBOutlet UIImageView *imageViewArea2;
    PicPranckTextView *textView2;
    
    IBOutlet UIImageView *imageViewArea3;
    PicPranckTextView *textView3;

}

@end

