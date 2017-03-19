//
//  ViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicPranckTextView.h"
#import "PicPranckImage.h"
#import "PicPranckImageView.h"
//#import "PicPranckDocumentInteractionController.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UIDocumentInteractionControllerDelegate>
{
    
    //UIView *viewToMoveForKeyBoardAppearance;
    NSMutableArray *listOfGestureViews;
    
    PicPranckTextView *tapedTextView;
    UIColor *globalTint;
    
    UIImagePickerController *picker;
    
    PicPranckTextView *textView1;
    IBOutlet PicPranckImageView *imageViewArea1;
    
    IBOutlet UIImageView *imageViewArea2;
    PicPranckTextView *textView2;
    
    IBOutlet UIImageView *imageViewArea3;
    PicPranckTextView *textView3;
    
    //Buttons
    IBOutlet UIButton *buttonSend;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *resetButton;
    IBOutlet UIStackView *areasStackView;
    IBOutlet UIView *viewToMoveForKeyBoardAppearance;
    
    IBOutlet UIStackView *buttonsStackView;
}

@property NSMutableArray *listOfTextViews;

//@property PicPranckImage *ppImage;
@property UIImage *ppImage;
@property NSString *activityType;

@property UIDocumentInteractionController *documentInteractionController;
@property UIActivityViewController * activityViewController;

- (IBAction)reset:(id)sender;
- (IBAction)performSave:(id)sender;
- (IBAction)buttonSendClicked:(id)sender;
-(void)generateImageToSendWithActivityType:(NSString *)iActivityType;
//-(UIImage *)getImage;
-(UIImage *)getImageOfAreaOfIndex:(NSInteger)index;
//-(void)setImagesWithImages:(NSMutableArray *)listOfImages;
@end

