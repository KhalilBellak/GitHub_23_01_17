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
        //Make UITextView as a subview of UIImageView (for print and auto-resize issues)
        CGRect newFrame = CGRectMake(0,0,currImageView.frame.size.width,currImageView.frame.size.height);
        currTextView.frame = newFrame;
        currImageView.autoresizesSubviews = YES;
        currTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [currImageView addSubview:currTextView];
        //Add gestureView to view to catch gestures
        [self.view addSubview:currTextView.gestureView];
        [self.view bringSubviewToFront:currTextView.gestureView];
        [listOfGestureViews addObject:currTextView.gestureView];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"chooseAppButtonSegue"])
    {
        //Dispatch because picture can take time to generate and we should display all aavailable apps
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(void){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self generateImageToSend];
            });
        });
        
        
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
    imagePicker.allowsEditing = NO;
    [imagePicker setDelegate:self];
    
    [picker presentViewController:imagePicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)iPicker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    NSString *key=@"UIImagePickerControllerOriginalImage";
    //if(UIImagePickerControllerSourceTypePhotoLibrary==iPicker.sourceType)
    //    key=@"UIImagePickerControllerEditedImage";
    image=[info objectForKey:key];
    [self setImage:image forTextView:tapedTextView];
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}
-(void)setImage:(UIImage *)iImage forTextView:(PicPranckTextView *)pPTextView
{
    
    [self setImage:iImage forImageView:pPTextView.imageView];
    [pPTextView.layer setBorderWidth:0.0f];
    [self.view bringSubviewToFront:pPTextView];
    [self.view bringSubviewToFront:pPTextView.gestureView];
    if(!pPTextView.edited)
        [pPTextView setText:@""];
}
-(void)setImage:(UIImage *)iImage forImageView:(UIImageView *)iImageView
{
    iImageView.backgroundColor = [UIColor blackColor];
    [iImageView setContentMode:UIViewContentModeScaleAspectFit];
    [iImageView setImage:iImage];
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
    //TODO:move view while keyboard appears
    
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

#pragma mark Generate Image To Send
-(void)generateImageToSend
{
    //TODO: handle cases when no image selected (need to resize them)
    //TODO: create new PicPrankTextViews to put in imageViewContainer
    //Create clones of UIImageViews and UITextViews
    NSMutableArray *listOfTextViewsClones=[[NSMutableArray alloc] init];
    NSMutableArray *listOfImageViewsClones=[[NSMutableArray alloc] init];
    //Clone UIImageViews
    NSInteger maxWidth=0,maxHeight=0,totalHeight=0;
    //PicPranckTextView *firstTextView=[listOfTextViews objectAtIndex:0];
    CGFloat x=0.0,y=0.0,oldHeight=0.0,oldWidth=0.0;
    UIImage *blackImage=nil;
    for(PicPranckTextView *currTextView in listOfTextViews)
    {
        UIImageView *currImageView=currTextView.imageView;
        UIImage *currImage=currImageView.image;
        if(0==[listOfTextViews indexOfObject:currTextView])
        {
            x=currTextView.imageView.frame.origin.x;
            y=currTextView.imageView.frame.origin.y;
            oldHeight=currTextView.imageView.frame.size.height;
            oldWidth=currTextView.imageView.frame.size.width;
        }
        //Create a black image
        if(!currImage)
        {
            if(!blackImage)
            {
                CGSize imageSize = CGSizeMake(300,300);
                UIColor *fillColor = [UIColor blackColor];
                UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                [fillColor setFill];
                CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
                blackImage= UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                currImage=blackImage;
            }
            [self setImage:blackImage forTextView:currTextView];
        }
        if(0==maxWidth || maxWidth<currImage.size.width)
            maxWidth=currImage.size.width;
        if(0==maxHeight || maxHeight<currImage.size.height)
            maxHeight=currImage.size.height;
        //Clone UIImage View and Text View
        UIImageView *imageViewClone=[[UIImageView alloc] init];
        imageViewClone.frame=currImageView.frame;
        imageViewClone.image=currImageView.image;
        [self setImage:currImage forImageView:imageViewClone];
        PicPranckTextView *textViewClone=[[PicPranckTextView alloc] init];
        //[textViewClone initWithDelegate:self ImageView:imageViewClone AndText:currTextView.text];
        [PicPranckTextView copyTextView:currTextView inOtherTextView:textViewClone withImageView:imageViewClone];
        [textViewClone.layer setBorderWidth:0.0f];
        imageViewClone.autoresizesSubviews = YES;
        textViewClone.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imageViewClone addSubview:textViewClone];
        [imageViewClone bringSubviewToFront:textViewClone];
        //Keep in array
        [listOfTextViewsClones addObject:textViewClone];
        [listOfImageViewsClones addObject:imageViewClone];
        
    }
    //TODO: send image to AppViewController
    
    
    //Creation of UIImageView which will contain all UIImageViews for later print
    UIImageView *imageViewContainer=[[UIImageView alloc] init];
    [self.view sendSubviewToBack:imageViewContainer];
    [imageViewContainer setBackgroundColor:[UIColor blackColor]];
    imageViewContainer.clipsToBounds=YES;
    //Automatic Resize of imageViewContainer subviews
    //imageViewContainer.autoresizesSubviews = YES;
    //Put all views in imageViewContainer and reframe if necessary
    for(PicPranckTextView *currTextView in listOfTextViewsClones)
    {
        UIImageView *currImageView=currTextView.imageView;
        UIImage *currImage=currImageView.image;
        //TODO: ratio for font size not accurate
        CGFloat ratio=0.0;
        if(0<currImageView.frame.size.width)
            ratio=currImage.size.width/currImageView.frame.size.width;
        //             CGRect newFrameImageView = CGRectMake(0.5*(maxWidth-currImage.size.width),totalHeight+0.5*(maxHeight-currImage.size.height),currImage.size.width,currImage.size.height);
        CGRect newFrameImageView = CGRectMake(0.5*(maxWidth-currImage.size.width),totalHeight,currImage.size.width,currImage.size.height);
        currImageView.frame = newFrameImageView;
        CGFloat oldFontSize=currTextView.font.pointSize;
        [currTextView setFont:[UIFont fontWithName:@"Impact" size:ratio*oldFontSize]];
        //currImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imageViewContainer addSubview:currImageView];
        totalHeight+=currImage.size.height;
    }
    
    
    CGSize size = CGSizeMake(maxWidth,totalHeight);
    CGRect newFrame=CGRectMake(x,y,size.width,size.height);
    imageViewContainer.frame=newFrame;
    
    
    //[self.view addSubview:imageViewContainer];
    
    //Get Image with text
    CGFloat screenScale=[UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(imageViewContainer.bounds.size, NO, screenScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [imageViewContainer.layer renderInContext:context];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(finalImage,nil,nil,nil);
    
    //Back to old frame
    CGRect oldFrame=CGRectMake(x,y,oldWidth,oldHeight);
    imageViewContainer.frame=oldFrame;
}
@end
