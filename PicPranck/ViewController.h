//
//  ViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,
    UITextFieldDelegate,UITextViewDelegate>
{
    UIImagePickerController *picker;
    UIImage *image;
    
    //IBOutlet UITapGestureRecognizer *doubleTapArea1;
    UITextField *textField;
    UITextView *textView;
    IBOutlet UIImageView *imageViewArea1;
    IBOutlet UIButton *buttonArea1;
    
    IBOutlet UIButton *buttonArea2;
    IBOutlet UIImageView *imageViewArea2;
    
    
    IBOutlet UIButton *buttonArea3;
    IBOutlet UIImageView *imageViewArea3;
}

- (IBAction)pressButtonArea:(id)sender forEvent:(UIEvent *)event;
@end

