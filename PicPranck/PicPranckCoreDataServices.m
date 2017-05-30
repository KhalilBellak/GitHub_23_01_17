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
#import "ImageOfAreaDetails+CoreDataClass.h"
#import "Bridge+CoreDataClass.h"
//View controller
//#import "PicPranckCollectionViewController.h"
#import "ViewController.h"
#import "TabBarViewController.h"
#import "PicPranckProfileViewController.h"
//Services
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckEncryptionServices.h"
//PicPranck objects
#import "PicPranckImageView.h"
#import "PicPranckImage.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCollectionViewFlowLayout.h"
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
        
        TabBarViewController *tabBarVC=[PicPranckCoreDataServices getTabBarVCFromVC:viewController];
        if(moc && tabBarVC)
            tabBarVC.allPicPrancksRemovedMode=NO;
    }
    return moc;
}

#pragma mark Uploading Images
+(void)uploadImages:(NSArray *)listOfImages withViewController: (ViewController *)viewController
{
    bool forceRest=FALSE;
    
    TabBarViewController *tabBarVC=[PicPranckCoreDataServices getTabBarVCFromVC:viewController];
    
    if([PicPranckEncryptionServices isFirebaseMode])
    {
        NSInteger nbOfSavedPP=[PicPranckEncryptionServices getNumberOfUserPicPranks:NO];
        
        NSInteger countOfSavedPP=[PicPranckEncryptionServices getCountOfUserPicPranks];
        
        [PicPranckEncryptionServices createStorageForImages:listOfImages withNumberOfPicPranks:countOfSavedPP fromViewController:viewController];
        //Let user know that save was successful
        [viewController showMessagePrompt:@"PickPranck saved !"];
        //Increment nb of saved PP in database
        [PicPranckEncryptionServices setNumberOfUserPicPranks:++nbOfSavedPP forceUpdateInDB:YES];
        if(tabBarVC)
            tabBarVC.allPicPrancksRemovedMode=NO;
        return;

    }
    if([PicPranckCoreDataServices areAllPicPrancksDeletedMode:viewController])
    {
        forceRest=tabBarVC.allPicPrancksRemovedMode;
        if(tabBarVC)
            tabBarVC.allPicPrancksRemovedMode=NO;
    }
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:forceRest fromViewController:viewController];
    if(managedObjCtx)
    {
        UIImage *imageToUse;
        //Create a saved image object
        SavedImage *newSavedImage =[NSEntityDescription insertNewObjectForEntityForName:@"SavedImage" inManagedObjectContext:managedObjCtx];
        ImageOfAreaDetails *newImageOfAreaDetails =[NSEntityDescription insertNewObjectForEntityForName:@"ImageOfAreaDetails" inManagedObjectContext:managedObjCtx];
        Bridge *bridge =[NSEntityDescription insertNewObjectForEntityForName:@"Bridge" inManagedObjectContext:managedObjCtx];
        for(UIImage *currImage in listOfImages)
        {
            NSInteger iIndex=[listOfImages indexOfObject:currImage];
            NSData *imageData = UIImageJPEGRepresentation(currImage,1.0);
            //Create Image area object
            ImageOfArea *newImageOfArea =[NSEntityDescription insertNewObjectForEntityForName:@"ImageOfArea" inManagedObjectContext:managedObjCtx];
            //Create thumbnail
            if(1==iIndex)
            {
                PicPranckImage *ppImg=[[PicPranckImage alloc] initWithImage:currImage];
                imageToUse=[ppImg imageByScalingProportionallyToSize:[PicPranckCollectionViewFlowLayout getCellSize]];
                NSData *thumbnailData = UIImageJPEGRepresentation(currImage,1.0);
                [newImageOfAreaDetails setThumbnail:thumbnailData];
            }
            //Set Attributes
            [newImageOfArea setPosition:iIndex];
            [newImageOfArea setDataImage:imageData];
            //Set Relationships
            [newImageOfArea setOwner:bridge];
        }
        
        NSDate *localDate = [NSDate date];
        [newSavedImage setDateOfCreation:localDate];
        [bridge setDateOfCreation:localDate];
        
        [newSavedImage setNewPicPranck:YES];
        
        [newImageOfAreaDetails setOwner:newSavedImage];
        
        NSError *err=[[NSError alloc] init];
        bool saved=[managedObjCtx save:&err];
        if(saved)
        {
            [viewController showMessagePrompt:@"PickPranck saved !"];
            count++;
            newSavedCount++;
        }
        else if(err)
            [viewController showMessagePrompt:err.localizedDescription];
        
        [managedObjCtx reset];
        
    }
}

+(TabBarViewController *)getTabBarVCFromVC:(UIViewController *)vc {
    TabBarViewController *result=nil;
    if(vc && [vc.tabBarController isKindOfClass:[TabBarViewController class]]) {
            result=(TabBarViewController *)vc.tabBarController;
    }
    return result;
}

//+(void)addThumbnailInImageView:(UIImageView *)imgView withIndex:(NSInteger)index
//{
//    if(!imgView)
//        imgView=[[UIImageView alloc] init];
//    SavedImage *currManObj=[PicPranckCoreDataServices retrieveDataAtIndex:index];
//    //Find core data element with right index
//    if(currManObj)
//    {
//        //Put right image in Image View
//        //Take the middle one
//        NSInteger position=1;
//        NSPredicate *myPredicate = [NSPredicate predicateWithFormat:@"position == %@", @(position)];
//        
//        NSObject *chosenImgOfAreaDetails = [currManObj.imageOfAreaDetails filteredSetUsingPredicate:myPredicate].anyObject;
//        id idImage=nil;
//        if([chosenImgOfAreaDetails isKindOfClass:[ImageOfAreaDetails class]])
//        {
//            ImageOfAreaDetails *imgOfAreaDetails=(ImageOfAreaDetails *) chosenImgOfAreaDetails;
//            
//            idImage=[imgOfAreaDetails.imageOfAreaWithData dataImage];
//        }
//        //Set image for thumbnail
//        UIImage *image=[UIImage imageWithData:idImage];
//        PicPranckImage *ppImg=[[PicPranckImage alloc] initWithImage:image];
//        [imgView setContentMode:UIViewContentModeScaleAspectFit];
//        [PicPranckImageServices setImage:[ppImg imageByScalingProportionallyToSize:imgView.frame.size] forImageView:imgView];
//    }
//    
//}
#pragma mark Retrieve methods
+(id)retrieveDataAtIndex:(NSInteger)index withType:(NSString *)type
{
    NSArray *results=[PicPranckCoreDataServices retrieveAllSavedImagesWithType:type];
    //Inserting thumbnails of created PickPrancks
    for(id currManObj in results)
    {
        //Find core data element with right index
        if(index==[results indexOfObject:currManObj])
            return currManObj;
    }
    return nil;
}
+(NSArray *)retrieveAllSavedImagesWithType:(NSString *)type
{
    
    //NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO withViewController:nil];
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO fromViewController:nil];
    //Fetch request
    
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:type];
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
    Bridge *bridge=[PicPranckCoreDataServices retrieveDataAtIndex:index withType:@"Bridge"];
    if(bridge)
    {
        //Sort the set
        NSSortDescriptor *sortDsc=[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSArray *arrayDsc=[[NSArray alloc] initWithObjects:sortDsc, nil];
        
        //Bridge *savedImg=[PicPranckCoreDataServices retrieveDataAtIndex:index withType:@"Bridge"];
        
        NSArray *sortedArray=[bridge.imagesOfArea sortedArrayUsingDescriptors:arrayDsc];
        for(ImageOfArea *imgOfArea in sortedArray)
        {
//            id idImage=[imgOfAreaDetails.bridge.imageOfArea dataImage];
//            UIImage *image=[UIImage imageWithData:idImage];
            [arrayOfImgs addObject:imgOfArea.dataImage];
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
+(void)removeAllImages:(UIViewController *)sender {
    
    //In case we already performed a flush
    if([PicPranckCoreDataServices areAllPicPrancksDeletedMode:sender]) {
        [sender showMessagePrompt:@"PicPranks were already deleted !"];
        return;
    }
    
    //If Firebase mode instead of CoreData
    if([PicPranckEncryptionServices isFirebaseMode]) {
        [PicPranckEncryptionServices removeAllPicPrancks:sender];
        return;
    }
    
    NSManagedObjectContext *managedObjectContext=[PicPranckCoreDataServices managedObjectContext:NO
                                                                              fromViewController:sender];
    // retrieve the store URL
    NSURL * storeURL = [[managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    
    // lock the current context
    //[managedObjectContext lock];
    
    //Perform Delete
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
                    TabBarViewController *tabBarVC=[PicPranckCoreDataServices getTabBarVCFromVC:ppProfileVC];
                    if(tabBarVC)
                        tabBarVC.allPicPrancksRemovedMode=YES;
                }
                
            }
        }
    }];
    
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
        NSArray *results=[PicPranckCoreDataServices retrieveAllSavedImagesWithType:@"SavedImage"];
        count=(int)[results count];
    }
    return (NSInteger)count ;
}
+(NSInteger)getNumberOfNewSavedPicPrancks
{
    return (NSInteger)newSavedCount ;
}
@end
