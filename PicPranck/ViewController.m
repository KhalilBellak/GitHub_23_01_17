//
//  ViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(IBAction)pressButtonArea:(id)sender forEvent:(UIEvent *)event
{
    picker=[[UIImagePickerController alloc] init];
    if(nil!=picker)
    {
        picker.delegate=self;
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:picker animated:YES completion:NULL];
        //[picker takePicture];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    image=[info objectForKey:@"UIImagePickerControllerOriginalImage"    ];
    [imageViewArea1 setImage:image];
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if(nil!=segue)
//    {
//        if([segue.identifier containsString:@"area"])
//        {
//            UIViewController *vcDest=segue.destinationViewController;
//            pickpranckcamera
//        }
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
