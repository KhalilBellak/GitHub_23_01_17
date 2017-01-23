//
//  ViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImagePickerController *picker;
    UIImage *image;
    
    __strong IBOutlet UIImageView *imageViewArea1;
    __strong IBOutlet UIButton *buttonArea1;
}

- (IBAction)pressButtonArea:(id)sender forEvent:(UIEvent *)event;

@end

