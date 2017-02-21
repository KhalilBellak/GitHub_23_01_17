//
//  PicPranckCoreDataServices.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "PicPranckCoreDataServices.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "PicPranckViewController.h"
#import "PicPranckImageView.h"
#import "SavedImage+CoreDataClass.h"
#import "ImageOfArea+CoreDataClass.h"

#define X_OFFSET 5
#define Y_OFFSET 5
#define NB_OF_IMG_BY_ROW 3

@implementation PicPranckCoreDataServices

#pragma mark Uploading Images
+(void)uploadImages:(NSArray *)listOfImages withViewController: (ViewController *)viewController
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
            
            [viewController presentViewController:alertController animated:YES completion:nil];
        }
    }
}
+(void)addThumbnailInPicPranckGallery:(PicPranckViewController *)ppViewController
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext=appDelegate.managedObjectContext;
    //Fetch request
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"SavedImage"];
    req.fetchBatchSize=10;
    req.fetchLimit=30;
    //Predicate
    //NSPredicate *predicate =[NSPredicate predicateWithFormat:@"newPicPranck == true"];
    //[req setPredicate:predicate];
    //Sort results by date
    NSSortDescriptor *sortDesc=[[NSSortDescriptor alloc] initWithKey:@"dateOfCreation" ascending:YES];
    [req setSortDescriptors:[[NSArray alloc] initWithObjects:sortDesc,nil] ];
    //Getting the images
    NSError *err=[[NSError alloc] init];
    NSArray *results=[managedObjectContext executeFetchRequest:req error:&err];
    //Inserting thumbnails of created PickPrancks
    CGRect collViewFrame=ppViewController.collectionView.frame;
    CGFloat width=(collViewFrame.size.width-(NB_OF_IMG_BY_ROW+1)*X_OFFSET)/NB_OF_IMG_BY_ROW;
    CGFloat xOffset=X_OFFSET,yOffset=Y_OFFSET;
    for(SavedImage *currManObj in results)
    {
        if(currManObj.newPicPranck)
        {
            CGRect frame=CGRectMake(xOffset, yOffset, width, width);
            PicPranckImageView *ppImgView=[[PicPranckImageView alloc] initFromViewController:ppViewController withManagedObject:currManObj andFrame:frame];
        }
        xOffset+=(width+X_OFFSET);
        if(collViewFrame.size.width+collViewFrame.origin.x< xOffset+width)
        {
            xOffset=X_OFFSET;
            yOffset+=width+Y_OFFSET;
        }
    }
}
@end
