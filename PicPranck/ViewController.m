//
//  ViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//Framework search paths
///Users/Khalil/Desktop/Developer/FacebookSDKs-iOS-4.19.0 $(inherited)
#import <objc/runtime.h>
#import "AppDelegate.h"
//View Controllers
#import "ViewController.h"
#import "PicPranckViewController.h"
//PicPranck Objects
#import "PicPranckTextView.h"
#import "PicPranckActivityItemProvider.h"
//Services
#import "PicPranckImageServices.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckCustomViewsServices.h"
//Pods
//#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory.h>

#define MAXIMUM_DATA_SIZE 250000
#define USE_ACTIVITY_VIEW_CONTROLLER 1
@interface ViewController ()
@end

#pragma mark -
@implementation ViewController

#pragma mark Synthetizing
@synthesize listOfTextViews=_listOfTextViews;
@synthesize  activityViewController=_activityViewController;
@synthesize documentInteractionController=_documentInteractionController;
@synthesize activityType=_activityType;
//@synthesize ppImage=_ppImage;

#pragma mark View Controller methods

- (void)viewDidLoad {
    [super viewDidLoad];
    //Set background image for main view
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
//    //Set background image for stack view (containing areas)
//    UIImage *imgStackView=[[UIImage alloc] initWithContentsOfFile:@"blue_pastel_light.jpeg"];
//    [areasStackView setBackgroundColor:[UIColor colorWithPatternImage:imgStackView]];
    //Set background image for areaStack view
    
    [viewToMoveForKeyBoardAppearance bringSubviewToFront:areasStackView];
    
    [self setButtons];
    
    _activityType=@"";
    //Get global tint
    [self.view setTintColor:[PicPranckImageServices getGlobalTintWithLighterFactor:0]];
    globalTint= [self.view tintColor];
    // Do any additional setup after loading the view, typically from a nib.
    _listOfTextViews=[[NSMutableArray alloc] init];
    listOfGestureViews=[[NSMutableArray alloc] init];
    [self initializeAreas:YES];

    //Add self as observer of Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}
-(void)setButtons
{
    [self setButton:@"Reset"];
    [self setButton:@"Save"];
    [self setButton:@"Send"];
    [self.view bringSubviewToFront:buttonsStackView];
}
-(void)setButton:(NSString *)nameOfButton
{
    UIButton *button=resetButton;
    //NIKFontAwesomeIcon icon=NIKFontAwesomeIconEraser;
    //NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory textlessButtonIconFactory];
    //factory.size=0.5*button.frame.size.height;
    ////factory.colors = @[[UIColor redColor], [UIColor darkGrayColor]];
    //factory.strokeColor = [UIColor blackColor];
    //factory.strokeWidth = 1.0;
    //factory.square=YES;
    if([nameOfButton isEqualToString:@"Send"])
    {
        //icon=NIKFontAwesomeIconUpload;//NIKFontAwesomeIconSendO
        button=buttonSend;
    }
    else if([nameOfButton isEqualToString:@"Save"])
    {
        //icon=NIKFontAwesomeIconSave;
        button=saveButton;
    }
    
    button.clipsToBounds = YES;
    [button setTitle:@"" forState:UIControlStateNormal];
    //[PicPranckCustomViewsServices setViewDesign:button];
    //[button setImage:[factory createImageForIcon:icon] forState:UIControlStateNormal];
    [buttonsStackView bringSubviewToFront:button];
}
-(void) initializeAreas:(BOOL)firstInitialization
{
    
    NSArray *listOfImageViews=[[NSArray alloc] initWithObjects:imageViewArea1,imageViewArea2,imageViewArea3,nil];
    if(!firstInitialization && ([listOfImageViews count]!=[_listOfTextViews count]))
        return;
    for(UIImageView *currImageView in listOfImageViews)
    {
        currImageView.clipsToBounds=YES;
        currImageView.contentMode=UIViewContentModeScaleAspectFit;
        //Initialization of PicPranckTextViews (text, layout ....)
        NSInteger iIndex=[listOfImageViews indexOfObject:currImageView];
        currImageView.tag=iIndex;
//        [currImageView.layer setBorderColor:[[PicPranckImageServices getGlobalTintWithLighterFactor:-40] CGColor]];
        
        NSString *text=@"HIDDEN PICTURE";
        if(1==iIndex)
            text=@"VISIBLE PICTURE";
        PicPranckTextView *currTextView=nil;
        //When hitting reset button should set images to nil and background to clear
        currImageView.image=nil;
        
        //[currImageView setBackgroundColor:[UIColor clearColor]];
        //Create or get the text view
        if(firstInitialization)
            currTextView=[[PicPranckTextView alloc] init];
        else
            currTextView=[_listOfTextViews objectAtIndex:iIndex];
        
        [currTextView initWithDelegate:self ImageView:currImageView AndText:text];
        if(firstInitialization)
        {
            currTextView.edited=NO;
            //Add gesture Recognizers
            UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
            UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTwice:)];
            tapOnce.cancelsTouchesInView=NO;
            tapTwice.cancelsTouchesInView=NO;
            tapOnce.numberOfTouchesRequired = 1;
            tapTwice.numberOfTapsRequired = 2;
            [tapOnce requireGestureRecognizerToFail:tapTwice];

            [currTextView.gestureView addGestureRecognizer:tapOnce];
            [currTextView.gestureView addGestureRecognizer:tapTwice];
            [_listOfTextViews addObject:currTextView];
        }
        [listOfGestureViews addObject:currTextView.gestureView];
        [areasStackView bringSubviewToFront:currImageView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"View to move for keyboord (w,h)=(%f,%f)",viewToMoveForKeyBoardAppearance.frame.size.width,viewToMoveForKeyBoardAppearance.frame.size.height);
//    NSLog(@"View to move for keyboord (x,y)=(%f,%f)",viewToMoveForKeyBoardAppearance.frame.origin.x,viewToMoveForKeyBoardAppearance.frame.origin.y);
//    NSLog(@"Stack View (w,h)=(%f,%f)",areasStackView.frame.size.width,areasStackView.frame.size.height);
//    NSLog(@"Stack View (x,y)=(%f,%f)",areasStackView.frame.origin.x,areasStackView.frame.origin.y);
//    
    
    //[areasStackView setBackgroundColor:[UIColor redColor]];
    //NSLog(@"%@",[self recursiveDescription]);
//    UIView *testView=[[UIView alloc] initWithFrame:areasStackView.frame];
//    [testView.layer setBorderColor:[[UIColor redColor] CGColor]];
//    [testView.layer setBorderWidth:2];
//    [self.view addSubview:testView];
//    [self.view bringSubviewToFront:testView];
    

    
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSArray *listOfImageViews=[[NSArray alloc] initWithObjects:imageViewArea1,imageViewArea2,imageViewArea3,nil];
    if([listOfImageViews count]!=[_listOfTextViews count])
        return;
    //Update Text view and gesture views frames
    for(UIImageView *currImageView in listOfImageViews)
    {
        PicPranckTextView *currTextView=[_listOfTextViews objectAtIndex:[listOfImageViews indexOfObject:currImageView]];
        CGRect newFrame = CGRectMake(0,0,currImageView.frame.size.width,currImageView.frame.size.height);
        currTextView.frame=newFrame;
        currTextView.gestureView.frame=newFrame;
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    //Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
#pragma mark Camera and Galery Actions
-(void)imagePickerController:(UIImagePickerController *)iPicker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *key=@"UIImagePickerControllerOriginalImage";
    //Get image from UIImagePickerController
    UIImage *imageFromPicker=[info objectForKey:key];
    
    NSData *imgData = UIImageJPEGRepresentation(imageFromPicker, 0); //1 it represents the quality of the image.
    NSInteger dataSize=[imgData length];
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)dataSize);
    //Set it in the right image view
    [PicPranckImageServices setImage:imageFromPicker forPicPranckTextView:tapedTextView inViewController:self];
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}
#pragma mark Action for Gesture Recognizers
-(void) handleTapOnce: (UITapGestureRecognizer *)sender
{
    NSInteger iIndex=[listOfGestureViews indexOfObject:sender.view];
    tapedTextView=[_listOfTextViews objectAtIndex:iIndex];
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
    tapedTextView=[_listOfTextViews objectAtIndex:iIndex];
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
    [self moveViewVertically:viewToMoveForKeyBoardAppearance withTapedTextView:tapedTextView andKeyBoardFrame:keyboardFrame];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self moveViewVertically:viewToMoveForKeyBoardAppearance toPosition:0];
}
-(void)moveViewVertically:(UIView *)iView withTapedTextView:(PicPranckTextView *) iTapedTextView andKeyBoardFrame:(CGRect) keyBoardFrame
{
    CGFloat yDown=iTapedTextView.imageView.frame.origin.y+iTapedTextView.imageView.frame.size.height;
    CGFloat yKeyboard=keyBoardFrame.origin.y-keyBoardFrame.size.height;
    CGFloat dY=yDown-yKeyboard;
    if(0<dY)
        [self moveViewVertically:iView toPosition:iView.frame.origin.y-dY];
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
#pragma mark Sharing methods
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
//    _activityType=application;
//    if ([self isWhatsApplication:application])
//    {
//        NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/PicPranck.png"];
//        [UIImageJPEGRepresentation(_ppImage, 1.0) writeToFile:savePath atomically:YES];
//        controller.URL = [NSURL fileURLWithPath:savePath];
//        controller.UTI = @"net.whatsapp.image";
//        
//    }
//    [PicPranckImageServices generateImageToSend:self];
}
- (BOOL)isWhatsApplication:(NSString *)application {
    if ([application rangeOfString:@"whats"].location == NSNotFound)
        return NO;
    else
        return YES;
}
-(void)generateImageToSendWithActivityType:(NSString *)iActivityType
{
    _activityType=iActivityType;
    [PicPranckImageServices generateImageToSend:self];
}
-(UIImage *)getImageOfAreaOfIndex:(NSInteger)index
{
    UIImage *result=nil;
    if(2<index)
        return result;
    id textView=[_listOfTextViews objectAtIndex:index];
    if([textView isKindOfClass:[PicPranckTextView class]])
    {
        PicPranckTextView *ppTextView=(PicPranckTextView *)textView;
        result=ppTextView.imageView.image;
    }
    return result;
}

#pragma mark IBActions
- (IBAction)reset:(id)sender
{
    [self initializeAreas:NO];
}
- (IBAction)buttonSendClicked:(id)sender
{
    [PicPranckImageServices sendPicture:self];
}
-(IBAction)gotoLibrary:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.view setFrame:CGRectMake(0, 80, 450, 350)];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.allowsEditing = NO;
    [imagePicker setDelegate:self];
    
    [picker presentViewController:imagePicker animated:YES completion:nil];
}
- (IBAction)performSave:(id)sender
{
    NSArray *listOfImages=[[NSArray alloc] initWithObjects:imageViewArea1.image,imageViewArea2.image,imageViewArea3.image, nil];
    [PicPranckCoreDataServices uploadImages:listOfImages withViewController:self];
}

@end
