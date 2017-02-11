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
    //Dictionary for size for every application
    dicOfSizes= [[NSMutableDictionary alloc] init];
    [dicOfSizes setValue:[NSValue valueWithCGSize:CGSizeMake(1000, 1000)]
                  forKey:@"WhatsApp"];
    [dicOfSizes setValue:[NSValue valueWithCGSize:CGSizeMake(500, 500)]
                  forKey:@"Messenger"];
    
    applicationTarget=@"";
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
    //button for UIActivityControllerView
    CGFloat x=self.view.frame.size.width;
    CGFloat y=self.view.frame.size.height;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x-100, 0.5*y-10, 100, 30)];
    [button setTitle:@"Send" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(sendPicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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

-(void)sendPicture:(id)sender
{
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]])
    {
    NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:savePath atomically:YES];
    
    _documentInteractionController = [PicPranckDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
    _documentInteractionController.UTI = @"net.whatsapp.image";
    _documentInteractionController.delegate = self;
    
    [_documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated: YES]; 
    }
    
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    applicationTarget=application;
    if ([self isWhatsApplication:application])
    {
        NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/PicPranck.wai"];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:savePath atomically:YES];
        controller.URL = [NSURL fileURLWithPath:savePath];
        controller.UTI = @"net.whatsapp.image";
        
    }
    [self generateImageToSend];
}

- (BOOL)isWhatsApplication:(NSString *)application {
    if ([application rangeOfString:@"whats"].location == NSNotFound)
        return NO;
    else
        return YES;
}
-(void)generateImageToSend
{
    //TODO: handle cases when no image selected (need to resize them)
    //Create clones of UIImageViews and UITextViews
    NSString *keyForDico=[[NSString alloc] init];
    if (0<[applicationTarget rangeOfString:@"whats"].location)
        keyForDico=@"WhatsApp";
    CGSize sizesForApp=[[dicOfSizes objectForKey:keyForDico] CGSizeValue];
    
    NSMutableArray *listOfTextViewsClones=[[NSMutableArray alloc] init];
    NSMutableArray *listOfImageViewsClones=[[NSMutableArray alloc] init];
    NSMutableArray *listOfSizes=[[NSMutableArray alloc] init];
    //Clone UIImageViews
    NSInteger maxWidth=0,maxHeight=0,totalHeight=0;
    NSInteger averageWidth=0,averageHeight=0;
    //PicPranckTextView *firstTextView=[listOfTextViews objectAtIndex:0];
    CGFloat x=0.0,y=0.0;
    UIImage *blackImage=nil;
    for(PicPranckTextView *currTextView in listOfTextViews)
    {
        UIImageView *currImageView=currTextView.imageView;
        UIImage *currImage=currImageView.image;
        if(0==[listOfTextViews indexOfObject:currTextView])
        {
            x=currTextView.imageView.frame.origin.x;
            y=currTextView.imageView.frame.origin.y;
        }
        //Keep width and height for average computing
        if(currImage)
        {
            CGSize size= CGSizeMake(currImage.size.width, currImage.size.height);
            [listOfSizes addObject:[NSValue valueWithCGSize:size]];
        }
        //Create a black image
        else
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
    if(0<[listOfSizes count])
    {
        for(NSValue *currSize in listOfSizes)
        {
            CGSize currCGSize=[currSize CGSizeValue];
            averageWidth+=currCGSize.width;
            averageHeight+=currCGSize.height;
        }
        averageWidth*=(1/[listOfSizes count]);
        averageHeight*=(1/[listOfSizes count]);
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
            ratio=sizesForApp.width/currImageView.frame.size.width;
//        CGFloat xOffset=0.5*(maxWidth-currImage.size.width);
//        if(xOffset<0)
//            xOffset=0;
        CGRect newFrameImageView = CGRectMake(0,totalHeight,sizesForApp.width,sizesForApp.height);
        currImageView.frame = newFrameImageView;
        CGFloat oldFontSize=currTextView.font.pointSize;
        [currTextView setFont:[UIFont fontWithName:@"Impact" size:ratio*oldFontSize]];
        [imageViewContainer addSubview:currImageView];
        totalHeight+=sizesForApp.height;
    }
    //Add black square if whatsapp
    if (0<[applicationTarget rangeOfString:@"whats"].location)
    {
        CGSize imageSize = CGSizeMake(sizesForApp.width,sizesForApp.height);
        UIColor *fillColor = [UIColor blackColor];
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [fillColor setFill];
        CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
        UIImage *blackImage= UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *blackImageView=[[UIImageView alloc] init];
        CGRect frame=CGRectMake(0,totalHeight,sizesForApp.width,sizesForApp.height);
        blackImageView.frame=frame;
        [blackImageView setImage:blackImage];
        [imageViewContainer addSubview:blackImageView];
        totalHeight+=sizesForApp.height;
    }
    CGSize size = CGSizeMake(sizesForApp.width,totalHeight);
    CGRect newFrame=CGRectMake(x,y,size.width,size.height);
    imageViewContainer.frame=newFrame;
    
    //Get Image with text
    CGFloat screenScale=[UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(imageViewContainer.bounds.size, NO, screenScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [imageViewContainer.layer renderInContext:context];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(finalImage,nil,nil,nil);
    image=finalImage;
 
}
@end
