//
//  ViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "ViewController.h"
#import "PicPranckTextView.h"
@interface ViewController ()//TEST OF BRANCH

@end
#pragma mark -
@implementation ViewController
#pragma mark View Controller methods
- (void)viewDidLoad {
    [super viewDidLoad];
    //Get global tint
    globalTint= [self.view tintColor];
    // Do any additional setup after loading the view, typically from a nib.
    listOfTextViews=[[NSMutableArray alloc] init];
    listOfGestureViews=[[NSMutableArray alloc] init];
    NSArray *listOfImageViews=[[NSArray alloc] initWithObjects:imageViewArea1,imageViewArea2,imageViewArea3,nil];
    for(UIImageView *currImageView in listOfImageViews)
    {
        //Initialization of PicPranckTextViews (text, layout ....)
        NSInteger iIndex=[listOfImageViews indexOfObject:currImageView];
        [currImageView.layer setBorderColor:[globalTint CGColor]];
        NSString *text=@"Hidden Picture";
        if(1==iIndex)
            text=@"Visible Picture";
        PicPranckTextView *currTextView=[[PicPranckTextView alloc] init];
        [currTextView initWithDelegate:self ImageView:currImageView AndText:text];

        //Add gesture Recognizers
        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
        UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTwice:)];
        tapOnce.cancelsTouchesInView=NO;
        tapTwice.cancelsTouchesInView=NO;
        tapOnce.numberOfTouchesRequired = 1;
        tapTwice.numberOfTapsRequired = 2;
        [tapOnce requireGestureRecognizerToFail:tapTwice];
        //Remove all gesture recognizers
        for (UIGestureRecognizer *recognizer in currTextView.gestureView.gestureRecognizers)
            [self.view removeGestureRecognizer:recognizer];
        [currTextView.gestureView addGestureRecognizer:tapOnce];
        [currTextView.gestureView addGestureRecognizer:tapTwice];
        
        [listOfTextViews addObject:currTextView];
        //TEST: put UIImageVIew in UITextView
        CGRect newFrame = CGRectMake(0,0,currImageView.frame.size.width,currImageView.frame.size.height);
        currTextView.frame = newFrame;

        [currImageView addSubview:currTextView];
        
        //[self.view addSubview:currTextView];
        [self.view addSubview:currTextView.gestureView];
        [self.view bringSubviewToFront:currTextView.gestureView];
        [listOfGestureViews addObject:currTextView.gestureView];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([[segue identifier] isEqualToString:@"chooseAppButtonSegue"])
     {
         UIImageView *imageViewContainer=[[UIImageView alloc] init];
         [self.view sendSubviewToBack:imageViewContainer];
         [imageViewContainer setBackgroundColor:[UIColor blackColor]];
         imageViewContainer.clipsToBounds=YES;
         
         NSInteger maxWidth=0,totalHeight=0,maxWidthBis=0,totalHeightBis=0;
         //CGFloat ratio=1.1;
         PicPranckTextView *firstTextView=[listOfTextViews objectAtIndex:0];
         CGFloat x=firstTextView.imageView.frame.origin.x;
         CGFloat y=firstTextView.imageView.frame.origin.y;
//       CGFloat w=firstTextView.imageView.frame.size.width;
//       CGFloat h=firstTextView.imageView.frame.size.height;
//       CGFloat Xoffset=0.5*(ratio-1)*w;
//       CGFloat Yoffset=3*0.5*(ratio-1)*h;
         
         for(PicPranckTextView *currTextView in listOfTextViews)
         {
             UIImageView *currImageView=currTextView.imageView;
             //CGRect newFrame = CGRectMake(Xoffset,Yoffset+totalHeight,currImageView.frame.size.width,currImageView.frame.size.height);
             CGRect newFrame = CGRectMake(0,totalHeight,currImageView.frame.size.width,currImageView.frame.size.height);
             currImageView.frame = newFrame;
             [imageViewContainer addSubview:currImageView];
             totalHeight+=currImageView.frame.size.height;
             if(0==maxWidth || maxWidth<currImageView.frame.size.width)
                 maxWidth=currImageView.frame.size.width;
         }
         //CGSize size = CGSizeMake(ratio*maxWidth,ratio*totalHeight);
         CGSize size = CGSizeMake(maxWidth,totalHeight);
         //CGRect newFrame=CGRectMake(x-Xoffset,y-Yoffset,size.width,size.height);
         CGRect newFrame=CGRectMake(x,y,size.width,size.height);
         imageViewContainer.frame=newFrame;
         
         [self.view addSubview:imageViewContainer];
         
         //Get Image with text
         CGFloat screenScale=[UIScreen mainScreen].scale;
         UIGraphicsBeginImageContextWithOptions(imageViewContainer.bounds.size, NO, 5*screenScale);
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
         [imageViewContainer.layer renderInContext:context];
         UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
//         NSLog(@"-------------------------------");
//         NSLog(@"Generated from UIImageVIewContainer:");
//         NSLog(@"finalImage.size.width: %f" , finalImage.size.width);
//         NSLog(@"finalImage.size.height:%f" , finalImage.size.height);
//         NSLog(@"screenScale:%f" , screenScale);
//         NSLog(@"-------------------------------");
//
         UIImageWriteToSavedPhotosAlbum(finalImage,nil,nil,nil);

     }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Camera and Galery Actions

-(IBAction)gotoLibrary:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.view setFrame:CGRectMake(0, 80, 450, 350)];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.allowsEditing = YES;
    [imagePicker setDelegate:self];
    
    [picker presentViewController:imagePicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)iPicker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    NSString *key=@"UIImagePickerControllerOriginalImage";
    if(UIImagePickerControllerSourceTypePhotoLibrary==iPicker.sourceType)
        key=@"UIImagePickerControllerEditedImage";
    image=[info objectForKey:key];
    tapedTextView.imageView.backgroundColor = [UIColor blackColor];
    [tapedTextView.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [tapedTextView.imageView setImage:image];
    [tapedTextView.layer setBorderWidth:0.0f];
    [self.view bringSubviewToFront:tapedTextView];
    [self.view bringSubviewToFront:tapedTextView.gestureView];
    if(!tapedTextView.edited)
        [tapedTextView setText:@""];
    
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}
#pragma mark Action for Gesture Recognizers
-(void) handleTapOnce: (UITapGestureRecognizer *)sender
{
    NSLog(@"SIMPLE TAP");
    NSInteger iIndex=[listOfGestureViews indexOfObject:sender.view];
    tapedTextView=[listOfTextViews objectAtIndex:iIndex];
    if(UIGestureRecognizerStateEnded==sender.state)
    {
        //tapedTextView=(PicPranckTextView *)sender.view;
        tapedTextView.tapsAcquired=1;
        picker=[[UIImagePickerController alloc] init];
        if(nil!=picker)
        {
            picker.delegate=self;
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:picker animated:YES completion:NULL];
            
            CGRect frame = picker.view.frame;
            int x = frame.size.width;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x-100, 10, 100, 30)];
            [button setTitle:@"Library" forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor clearColor]];
            [button addTarget:self action:@selector(gotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
            [picker.view addSubview:button];
        }
    }
}
-(void) handleTapTwice: (UITapGestureRecognizer *)sender
{
    NSLog(@"DOUBLE TAP");
    NSInteger iIndex=[listOfGestureViews indexOfObject:sender.view];
    tapedTextView=[listOfTextViews objectAtIndex:iIndex];
    if(UIGestureRecognizerStateEnded==sender.state)
    {
        //tapedTextView=(PicPranckTextView *)sender.view;
        tapedTextView.tapsAcquired=2;
        if(!tapedTextView.edited)
            [tapedTextView setText:@""];
        tapedTextView.edited=YES;
        //    //Add Done button to keyboard
        UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
        [keyboardToolbar sizeToFit];
        UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                          target:nil action:nil];
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                          target:self action:@selector(doneButtonPressed)];
        keyboardToolbar.items = @[flexBarButton, doneBarButton];
        tapedTextView.inputAccessoryView = keyboardToolbar;
        tapedTextView.editable=YES;
        [tapedTextView becomeFirstResponder];
    }
    
}

#pragma mark Text View Edition methods
-(void)doneButtonPressed
{
    [tapedTextView endEditing:YES];
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    UIColor *pWhiteColor=[UIColor whiteColor];
   [textView setTextColor:pWhiteColor];
    
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    textView.editable=NO;
    [textView endEditing:YES];
}
@end
