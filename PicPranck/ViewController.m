//
//  ViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import "AppDelegate.h"
#import "ViewController.h"
#import "PicPranckTextView.h"
#import <objc/runtime.h>
#import "PicPranckActivityItemProvider.h"
#import "PicPranckViewController.h"
#import <CoreData/CoreData.h>
#import "SavedImage+CoreDataClass.h"
#import "ImageOfArea+CoreDataClass.h"

#define USE_ACTIVITY_VIEW_CONTROLLER 1
@interface ViewController ()//TEST OF BRANCH

@end
#pragma mark -
@implementation ViewController

#pragma mark View Controller methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Bring save button front
    [self.view bringSubviewToFront:saveButton];
    //Dictionary for size for every application
    dicOfSizes= [[NSMutableDictionary alloc] init];
    [dicOfSizes setValue:[NSValue valueWithCGSize:CGSizeMake(1000, 1000)]
                  forKey:@"WhatsApp"];
    [dicOfSizes setValue:[NSValue valueWithCGSize:CGSizeMake(300, 1000)]
                  forKey:@"Facebook"];
    [dicOfSizes setValue:[NSValue valueWithCGSize:CGSizeMake(300, 400)]
                  forKey:@"iMessage"];
    
    activityType=@"";
    //Get global tint
    globalTint= [self.view tintColor];
 
    // Do any additional setup after loading the view, typically from a nib.
    listOfTextViews=[[NSMutableArray alloc] init];
    listOfGestureViews=[[NSMutableArray alloc] init];
    [self initializeAreas:YES];

    //Add self as observer of Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}
-(void) initializeAreas:(BOOL)firstInitialization
{
    NSArray *listOfImageViews=[[NSArray alloc] initWithObjects:imageViewArea1,imageViewArea2,imageViewArea3,nil];
    if(!firstInitialization && ([listOfImageViews count]!=[listOfTextViews count]))
        return;
    for(UIImageView *currImageView in listOfImageViews)
    {
        //Initialization of PicPranckTextViews (text, layout ....)
        NSInteger iIndex=[listOfImageViews indexOfObject:currImageView];
        [currImageView.layer setBorderColor:[globalTint CGColor]];
        NSString *text=@"Hidden Picture";
        if(1==iIndex)
            text=@"Visible Picture";
        PicPranckTextView *currTextView=nil;
        //When hitting reset button should set images to nil and background to clear
        currImageView.image=nil;
        [currImageView setBackgroundColor:[UIColor clearColor]];
        //Create or get the text view
        if(firstInitialization)
            currTextView=[[PicPranckTextView alloc] init];
        else
            currTextView=[listOfTextViews objectAtIndex:iIndex];
        
        [currTextView initWithDelegate:self ImageView:currImageView AndText:text];
        
        if(firstInitialization)
        {
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
        }
        
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
-(void)viewWillDisappear:(BOOL)animated
{
    //Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
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
    UIImage *imageFromPicker=[info objectForKey:key];
    NSLog(@"Size of imageFromPicker : (%f,%f)",imageFromPicker.size.width,imageFromPicker.size.height);
    //TO CHECKw
//    if(image)
//    {
//        CGImageRelease([image CGImage]);
//    }
    image=[[PicPranckImage alloc] initWithImage:imageFromPicker];
    UIImage *resImage=[image imageByScalingProportionallyToSize:tapedTextView.imageView.frame.size];
    NSLog(@"Size of image : (%f,%f)",resImage.size.width,resImage.size.height);
    [self setImage:resImage forTextView:tapedTextView];
    UIImageWriteToSavedPhotosAlbum(resImage,nil,nil,nil);
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
-(void)setImagesWithImages:(NSMutableArray *)listOfImages
{
    for(int i=0;i<3;i++)
    {
        PicPranckTextView *textViewToSet=[listOfTextViews objectAtIndex:i];
        UIImage *curImage=[listOfImages objectAtIndex:i];
        [textViewToSet setText:@""];
        [self setImage:curImage forTextView:textViewToSet];
    }
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
        //Add Done button to keyboard
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
//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//    //TODO:move view while keyboard appears
//    
//    
//}
//-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    return TRUE;
//}
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


- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [self moveViewVertically:self.view withTapedTextView:tapedTextView andKeyBoardFrame:keyboardFrame];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self moveViewVertically:self.view toPosition:0];
}
-(void)moveViewVertically:(UIView *)iView withTapedTextView:(PicPranckTextView *) iTapedTextView andKeyBoardFrame:(CGRect) keyBoardFrame
{
    CGFloat yDown=iTapedTextView.imageView.frame.origin.y+iTapedTextView.imageView.frame.size.height;
    CGFloat yKeyboard=keyBoardFrame.origin.y-keyBoardFrame.size.height;
    CGFloat dY=yDown-yKeyboard;
    if(0<dY)
        [self moveViewVertically:self.view toPosition:self.view.frame.origin.y-dY];
}
-(void)moveViewVertically:(UIView *)iView toPosition:(CGFloat)y
{
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^
     {
         CGRect frame = iView.frame;
         frame.origin.y=y;
         iView.frame = frame;
     }
                     completion:nil];
}
#pragma mark Generate Image To Send

-(void)sendPicture:(id)sender
{
    if(USE_ACTIVITY_VIEW_CONTROLLER)
    {
        PicPranckActivityItemProvider *message = [[PicPranckActivityItemProvider alloc] initWithPlaceholderItem:image];
        message.viewController=self;
        NSMutableArray *activityItems=[[NSMutableArray alloc] init];
        [activityItems addObject:message];
            _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            _activityViewController.excludedActivityTypes = @[UIActivityTypeMail,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypePrint,                                                         UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToFacebook,                                                        UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,                                                         UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,                                                         UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,
                                                              @"com.apple.mobilenotes.SharingExtension"];
            [self presentViewController:_activityViewController animated:YES completion:nil];
    }
    else
    {
        if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]])
        {
            NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.png"];
            
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:savePath atomically:YES];
            
            _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
            _documentInteractionController.UTI = @"net.whatsapp.image";
            _documentInteractionController.delegate = self;
            
            [_documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated: YES];
        }
    }
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    activityType=application;
    if ([self isWhatsApplication:application])
    {
        NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/PicPranck.png"];
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
-(void)generateImageToSendWithActivityType:(NSString *)iActivityType
{
    activityType=iActivityType;
    [self generateImageToSend];
}
-(void)generateImageToSend
{
    //TODO: handle cases when no image selected (need to resize them)
    //Create clones of UIImageViews and UITextViews
    CGSize sizesForApp=[[dicOfSizes objectForKey:activityType] CGSizeValue];
    
    NSMutableArray *listOfTextViewsClones=[[NSMutableArray alloc] init];
    NSMutableArray *listOfImageViewsClones=[[NSMutableArray alloc] init];
    NSMutableArray *listOfSizes=[[NSMutableArray alloc] init];
    //Clone UIImageViews
    NSInteger maxWidth=0,maxHeight=0,totalHeight=0;
    NSInteger averageWidth=0,averageHeight=0;
    
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
    
    //Put all views in imageViewContainer and reframe if necessary
    for(PicPranckTextView *currTextView in listOfTextViewsClones)
    {
        UIImageView *currImageView=currTextView.imageView;
        //TODO: ratio for font size not accurate
        CGFloat ratio=0.0;
        if(0<currImageView.frame.size.width)
            ratio=sizesForApp.width/currImageView.frame.size.width;

        CGRect newFrameImageView = CGRectMake(0,totalHeight,sizesForApp.width,sizesForApp.height);
        currImageView.frame = newFrameImageView;
        CGFloat oldFontSize=currTextView.font.pointSize;
        [currTextView setFont:[UIFont fontWithName:@"Impact" size:ratio*oldFontSize]];
        [imageViewContainer addSubview:currImageView];
        totalHeight+=sizesForApp.height;
    }
    //Add black square if whatsapp

    if([activityType isEqualToString:@"WhatsApp"])
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
    //UIImageWriteToSavedPhotosAlbum(finalImage,nil,nil,nil);
    image=finalImage;
 
}
#pragma mark Reset
- (IBAction)reset:(id)sender
{
    [self initializeAreas:NO];
}

#pragma mark Uploading Images
- (IBAction)performSave:(id)sender
{
    NSArray *listOfImages=[[NSArray alloc] initWithObjects:imageViewArea1.image,imageViewArea2.image,imageViewArea3.image, nil];
    [self uploadImages:listOfImages];
}
-(void)uploadImages:(NSArray *)listOfImages
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext=appDelegate.managedObjectContext;
    if(managedObjectContext)
    {
        //Create a saved image object
        SavedImage *newSavedImage =[NSEntityDescription insertNewObjectForEntityForName:@"SavedImage" inManagedObjectContext:managedObjectContext];
        NSDate *localDate = [NSDate date];
        for(UIImage *currImage in listOfImages)
        {
            NSInteger iIndex=[listOfImages indexOfObject:currImage];
             NSLog(@"Size of currImage : (%f,%f)",currImage.size.width,currImage.size.height);
            NSData *imageData = UIImageJPEGRepresentation(currImage,1.0);
            //Create Image area object
            ImageOfArea *newImageOfArea =[NSEntityDescription insertNewObjectForEntityForName:@"ImageOfArea" inManagedObjectContext:managedObjectContext];
            [newImageOfArea setParent:newSavedImage];
            [newImageOfArea setPosition:iIndex];
            [newImageOfArea setDataImage:imageData];
            [newSavedImage addImageChildrenObject:newImageOfArea];
        }
        [newSavedImage setDateOfCreation:localDate];
        [newSavedImage setNewPicPranck:YES];
        NSError *err=[[NSError alloc] init];
        bool saved=[managedObjectContext save:&err];
        if(saved)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Saving" message:@"PickPranck saved !" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}
- (IBAction)buttonSendClicked:(id)sender {
    [self sendPicture:sender];
}
-(UIImage *)getImage
{
    return image;
}
@end
