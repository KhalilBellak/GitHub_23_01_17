//
//  PicPranckCoreDataServices.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "PicPranckCollectionViewController.h"
#import "PicPranckImageView.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCollectionViewController.h"
#import "SavedImage+CoreDataClass.h"
#import "ImageOfArea+CoreDataClass.h"

#define X_OFFSET 5
#define Y_OFFSET 5
#define NB_OF_IMG_BY_ROW 3

//@interface PicPranckCoreDataServices
//
//@end

// ClassA.m
static int count = 0;
@implementation PicPranckCoreDataServices

+(int) initCount
{
    return count;
}
+(NSManagedObjectContext *)managedObjectContext
{
    static NSManagedObjectContext *moc=nil;
    if(!moc)
    {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        moc=appDelegate.managedObjectContext;
    }
    return moc;
}
//+(NSInteger)nbOfSavedPicPrancks
//{
//    static NSInteger count=0;
//    return count;
//}
#pragma mark Uploading Images
+(void)uploadImages:(NSArray *)listOfImages withViewController: (ViewController *)viewController
{
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext];
    if(managedObjCtx)
    {
        //Create a saved image object
        SavedImage *newSavedImage =[NSEntityDescription insertNewObjectForEntityForName:@"SavedImage" inManagedObjectContext:managedObjCtx];
        NSDate *localDate = [NSDate date];
        for(UIImage *currImage in listOfImages)
        {
            NSInteger iIndex=[listOfImages indexOfObject:currImage];
            NSLog(@"Size of currImage : (%f,%f)",currImage.size.width,currImage.size.height);
            NSData *imageData = UIImageJPEGRepresentation(currImage,1.0);
            //Create Image area object
            ImageOfArea *newImageOfArea =[NSEntityDescription insertNewObjectForEntityForName:@"ImageOfArea" inManagedObjectContext:managedObjCtx];
            [newImageOfArea setParent:newSavedImage];
            [newImageOfArea setPosition:iIndex];
            [newImageOfArea setDataImage:imageData];
            [newSavedImage addImageChildrenObject:newImageOfArea];
        }
        [newSavedImage setDateOfCreation:localDate];
        [newSavedImage setNewPicPranck:YES];
        NSError *err=[[NSError alloc] init];
        bool saved=[managedObjCtx save:&err];
        if(saved)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Saving" message:@"PickPranck saved !" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [viewController presentViewController:alertController animated:YES completion:nil];
            count++;
        }
    }
}
+(void)addThumbnailInPicPranckGallery:(PicPranckCollectionViewController *)ppViewController
{
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext];
    //Fetch request
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"SavedImage"];
    req.fetchBatchSize=10;
    req.fetchLimit=30;
    //Sort results by date
    NSSortDescriptor *sortDesc=[[NSSortDescriptor alloc] initWithKey:@"dateOfCreation" ascending:YES];
    [req setSortDescriptors:[[NSArray alloc] initWithObjects:sortDesc,nil] ];
    //Getting the images
    NSError *err=[[NSError alloc] init];
    NSArray *results=[managedObjCtx executeFetchRequest:req error:&err];
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
+(void)addThumbnailInPicPranckCollectionView:(PicPranckCollectionViewController *)collecViewController inCell:(PicPranckCollectionViewCell *)collecViewCell
{
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext];
    //Fetch request
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"SavedImage"];
    req.fetchBatchSize=10;
    req.fetchLimit=30;
    //Sort results by date
    NSSortDescriptor *sortDesc=[[NSSortDescriptor alloc] initWithKey:@"dateOfCreation" ascending:YES];
    [req setSortDescriptors:[[NSArray alloc] initWithObjects:sortDesc,nil] ];
    //Getting the images
    NSError *err=[[NSError alloc] init];
    NSArray *results=[managedObjCtx executeFetchRequest:req error:&err];
    //Inserting thumbnails of created PickPrancks
    for(SavedImage *currManObj in results)
    {
        if(currManObj.newPicPranck)
        {
            PicPranckImageView *ppImgView=[[PicPranckImageView alloc] initFromViewController:collecViewController withManagedObject:currManObj andFrame:collecViewCell.frame];
        }
    }
    //count++;
}

+(void)addThumbnailInImageView:(UIImageView *)imgView withIndex:(NSInteger)index
{
    if(!imgView)
        imgView=[[UIImageView alloc] init];
    SavedImage *currManObj=[PicPranckCoreDataServices retrieveDataAtIndex:index];
    //Find core data element with right index
    if(currManObj)
    {
        //Put right image in Image View
        //Take the middle one
        NSInteger position=1;
        NSPredicate *myPredicate = [NSPredicate predicateWithFormat:@"position == %@", @(position)];
        
        NSObject *chosenImgOfArea = [currManObj.imageChildren filteredSetUsingPredicate:myPredicate].anyObject;
        id idImage=nil;
        if([chosenImgOfArea isKindOfClass:[ImageOfArea class]])
        {
            ImageOfArea *imgOfArea=(ImageOfArea *) chosenImgOfArea;
            idImage=imgOfArea.dataImage;
        }
        //Set image for thumbnail
        UIImage *image=[UIImage imageWithData:idImage];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        [PicPranckImageServices setImage:image forImageView:imgView];
    }
    
}
#pragma mark Retrieve methods
+(SavedImage *)retrieveDataAtIndex:(NSInteger)index
{
    NSArray *results=[PicPranckCoreDataServices retrieveAllSavedImages];
    //Inserting thumbnails of created PickPrancks
    for(SavedImage *currManObj in results)
    {
        //Find core data element with right index
        if(index==[results indexOfObject:currManObj])
            return currManObj;
    }
    return nil;
}
+(NSArray *)retrieveAllSavedImages
{
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext];
    //Fetch request
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"SavedImage"];
    //Sort results by date
    NSSortDescriptor *sortDesc=[[NSSortDescriptor alloc] initWithKey:@"dateOfCreation" ascending:YES];
    [req setSortDescriptors:[[NSArray alloc] initWithObjects:sortDesc,nil] ];
    //Getting the images
    NSError *err=[[NSError alloc] init];
    NSArray *results=[managedObjCtx executeFetchRequest:req error:&err];
    return results;
}
+(NSMutableArray *)retrieveImagesArrayFromDataAtIndex:(NSInteger)index
{
    NSMutableArray *arrayOfImgs=[[NSMutableArray alloc] init];
    SavedImage *savedImg=[PicPranckCoreDataServices retrieveDataAtIndex:index];
    if(savedImg)
    {
        //Sort the set
        NSSortDescriptor *sortDsc=[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSArray *arrayDsc=[[NSArray alloc] initWithObjects:sortDsc, nil];
        NSArray *sortedArray=[savedImg.imageChildren sortedArrayUsingDescriptors:arrayDsc];
        for(ImageOfArea *imgOfArea in sortedArray)
        {
            id idImage=imgOfArea.dataImage;
            UIImage *image=[UIImage imageWithData:idImage];
            [arrayOfImgs addObject:image];
        }
        
    }
    return arrayOfImgs;
}
#pragma mark Remove Images
+(void)removeImages:(NSManagedObject *)objectToDelete
{
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext];
    if(managedObjCtx)
        [managedObjCtx deleteObject:objectToDelete];
    count--;
}
#pragma mark Infos about Core Data
+(NSInteger)getNumberOfSavedPicPrancks
{
    if(0==count)
    {
        NSArray *results=[PicPranckCoreDataServices retrieveAllSavedImages];
        count=[results count];
    }
    return (NSInteger)count ;
}
@end
