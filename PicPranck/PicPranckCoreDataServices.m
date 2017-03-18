//
//  PicPranckCoreDataServices.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "AppDelegate.h"
//Core Data
#import <CoreData/CoreData.h>
#import "SavedImage+CoreDataClass.h"
#import "ImageOfArea+CoreDataClass.h"
//View controller
#import "PicPranckCollectionViewController.h"
#import "ViewController.h"
#import "TabBarViewController.h"
#import "PicPranckProfileViewController.h"
//Services
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
//PicPranck objects
#import "PicPranckImageView.h"
#import "PicPranckImage.h"
#import "PicPranckCollectionViewCell.h"
//Extensions
#import "UIViewController+Alerts.h"

#define X_OFFSET 5
#define Y_OFFSET 5
#define NB_OF_IMG_BY_ROW 3

//@interface PicPranckCoreDataServices
//
//@end

// ClassA.m
static int count = 0;
static int newSavedCount=0;
@implementation PicPranckCoreDataServices

+(int) initCount
{
    return count;
}
+(int) initNewSavedCount
{
    return newSavedCount;
}
+(NSManagedObjectContext *)managedObjectContext:(bool)forceReset fromViewController:(UIViewController *)viewController
{
    static NSManagedObjectContext *moc=nil;
    if(forceReset)
        moc=nil;
    if(!moc)
    {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        moc=[appDelegate managedObjectContext];
        if(moc && viewController)
        {
            if([viewController.tabBarController isKindOfClass:[TabBarViewController class]])
            {
                TabBarViewController *tabBarVC=(TabBarViewController *)viewController.tabBarController;
                tabBarVC.allPicPrancksRemovedMode=NO;
            }
        }
    }
    return moc;
}

#pragma mark Uploading Images
+(void)uploadImages:(NSArray *)listOfImages withViewController: (ViewController *)viewController
{
    bool forceRest=FALSE;
    
    if([PicPranckCoreDataServices areAllPicPrancksDeletedMode:viewController])
    {
        if([viewController.tabBarController isKindOfClass:[TabBarViewController class]])
        {
            TabBarViewController *tabBarVC=(TabBarViewController *)viewController.tabBarController;
            forceRest=tabBarVC.allPicPrancksRemovedMode;
            tabBarVC.allPicPrancksRemovedMode=NO;
        }
    }
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:forceRest fromViewController:viewController];
    if(managedObjCtx)
    {
        //Create a saved image object
        SavedImage *newSavedImage =[NSEntityDescription insertNewObjectForEntityForName:@"SavedImage" inManagedObjectContext:managedObjCtx];
        NSDate *localDate = [NSDate date];
        for(UIImage *currImage in listOfImages)
        {
            NSInteger iIndex=[listOfImages indexOfObject:currImage];
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
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Saving" message:@"PickPranck saved !" preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//            [alertController addAction:ok];
//            
//            [viewController presentViewController:alertController animated:YES completion:nil];
            [viewController showMessagePrompt:@"PickPranck saved !"];
            count++;
            newSavedCount++;
            
        }
    }
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
        PicPranckImage *ppImg=[[PicPranckImage alloc] initWithImage:image];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        [PicPranckImageServices setImage:[ppImg imageByScalingProportionallyToSize:imgView.frame.size] forImageView:imgView];
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
    
    //NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO withViewController:nil];
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO fromViewController:nil];
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
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO fromViewController:nil];
    if(managedObjCtx)
        [managedObjCtx deleteObject:objectToDelete];
    count--;
}
+(void)removeAllImages:(UIViewController *)sender
{
    if([PicPranckCoreDataServices areAllPicPrancksDeletedMode:sender])
    {
        [sender showMessagePrompt:@"PicPranks were already deleted !"];
        return;
    }
    NSManagedObjectContext *managedObjectContext=[PicPranckCoreDataServices managedObjectContext:NO fromViewController:sender];
    // retrieve the store URL
    NSURL * storeURL = [[managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    //[managedObjectContext lock];
    [managedObjectContext performBlock:^{
        NSError * error;
        [managedObjectContext reset];//to drop pending changes
        //delete the store from the current managedObjectContext
        if ([[managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
        {
            // remove the file containing the data
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
            //recreate the store like in the  appDelegate method
            [[managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
            if (error)
                [sender showMessagePrompt:error.localizedDescription];
            else
                [sender showMessagePrompt:@"PicPranks removed Successfully !"];
            //managedObjCtx.persistentStoreCoordinator=nil;
            //managedObjCtx=nil;
            
            //[managedObjCtx save:&error];
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            if(appDelegate)
            {
                [appDelegate resetPersistencyObjects];
                [appDelegate initializePersistentStoreCoordinator];
                [appDelegate initializeManagedObjectContext];
                //Let know tab bar controller that we removed all PicPrancks have been removed
                if([sender isKindOfClass:[PicPranckProfileViewController class]])
                {
                    PicPranckProfileViewController *ppProfileVC=(PicPranckProfileViewController *)sender;
                    if([ppProfileVC.tabBarController isKindOfClass:[TabBarViewController class]])
                    {
                        TabBarViewController *tabBarVC=(TabBarViewController *)ppProfileVC.tabBarController;
                        tabBarVC.allPicPrancksRemovedMode=YES;
                    }
                }
                
            }
        }
    }];
    
//    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO];
//    if(managedObjCtx)
//    {
//        NSPersistentStore *store =[managedObjCtx.persistentStoreCoordinator.persistentStores lastObject];
//        NSError *error;
//        NSURL *storeURL = store.URL;
//        NSPersistentStoreCoordinator *storeCoordinator =managedObjCtx.persistentStoreCoordinator;
//        [storeCoordinator removePersistentStore:store error:&error];
//        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
//        if (error)
//            [sender showMessagePrompt:error.localizedDescription];
//        else
//            [sender showMessagePrompt:@"PicPranks removed Successfully !"];
//        //managedObjCtx.persistentStoreCoordinator=nil;
//        //managedObjCtx=nil;
//        
//        //[managedObjCtx save:&error];
//        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//        if(appDelegate)
//        {
//            [appDelegate resetPersistencyObjects];
//            [appDelegate initializePersistentStoreCoordinator];
//            [appDelegate initializeManagedObjectContext];
//            //Let know tab bar controller that we removed all PicPrancks have been removed
//            if([sender isKindOfClass:[PicPranckProfileViewController class]])
//            {
//                PicPranckProfileViewController *ppProfileVC=(PicPranckProfileViewController *)sender;
//                if([ppProfileVC.tabBarController isKindOfClass:[TabBarViewController class]])
//                {
//                    TabBarViewController *tabBarVC=(TabBarViewController *)ppProfileVC.tabBarController;
//                    tabBarVC.allPicPrancksRemovedMode=YES;
//                }
//            }
//            
//        }
//    }
}
+(BOOL)areAllPicPrancksDeletedMode:(UIViewController *)sender
{
    //if([sender isKindOfClass:[PicPranckProfileViewController class]])
    //{
        //PicPranckProfileViewController *ppProfileVC=(PicPranckProfileViewController *)sender;
        if([sender.tabBarController isKindOfClass:[TabBarViewController class]])
        {
            TabBarViewController *tabBarVC=(TabBarViewController *)sender.tabBarController;
            return tabBarVC.allPicPrancksRemovedMode;
        }
    //}
    return FALSE;
}
#pragma mark Infos about Core Data
+(NSInteger)getNumberOfSavedPicPrancks
{
    if(0==count)
    {
        NSArray *results=[PicPranckCoreDataServices retrieveAllSavedImages];
        count=(int)[results count];
    }
    return (NSInteger)count ;
}
+(NSInteger)getNumberOfNewSavedPicPrancks
{
    return (NSInteger)newSavedCount ;
}
@end
