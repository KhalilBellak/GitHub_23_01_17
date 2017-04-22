//
//  PicPranckCollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckCollectionViewController.h"
#import "PicPranckViewController.h"
#import "ViewController.h"

#import "AppDelegate.h"

#import "PicPranckImage.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCollectionViewFlowLayout.h"

#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"

#import "ImageOfArea+CoreDataClass.h"
#import "ImageOfAreaDetails+CoreDataClass.h"
#import "SavedImage+CoreDataClass.h"
#import "Bridge+CoreDataClass.h"



//TODO: initialize fetchedResultsController in view init and use all mechanisms of update

@interface PicPranckCollectionViewController ()
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

@implementation PicPranckCollectionViewController
@synthesize shouldReloadCollectionView=_shouldReloadCollectionView;
@synthesize fetchedResultsController=_fetchedResultsController;
static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    _shouldReloadCollectionView=YES;
    [self performFetch];
}

-(void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    //Refresh collection view
    if([PicPranckCoreDataServices areAllPicPrancksDeletedMode:self])
    {
        _fetchedResultsController=nil;
        [self fetchedResultsController];
        [self performFetch];
        [self.collectionView reloadData];
        NSLog(@"NUMBER OF FETCHED OBJECTS:%lu",[_fetchedResultsController.fetchedObjects count]);
    }

}
-(void)viewWillDisappear:(BOOL)animated
{
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO fromViewController:self];
    [managedObjCtx reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}
-(NSString *)getCellIdentifier
{
    return reuseIdentifier;
}
-(id)getPreviewImageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    SavedImage *savedImg = [_fetchedResultsController objectAtIndexPath:indexPath];
    //Sort the set
    if(savedImg)
        return savedImg.imageOfAreaDetails.thumbnail;
    return nil;
}


#pragma mark <NSFetchedResultsControllerDelegate>

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
        return _fetchedResultsController;

    return [self initializeFRC];
    
}
-(NSFetchedResultsController *)initializeFRC
{
    
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:[PicPranckCoreDataServices areAllPicPrancksDeletedMode:self] fromViewController:self];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SavedImage" inManagedObjectContext:managedObjCtx];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"dateOfCreation" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];

    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjCtx sectionNameKeyPath:nil
                                                   cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [[NSBlockOperation alloc] init];
}
-(void)deleteSelectedElements:(id)sender
{
    NSLog(@"deleteSelectedElements");
    NSMutableArray *arrayOfIdxPaths=[[NSMutableArray alloc] init];
    //Sort
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self"
                                                               ascending: YES];
    [self.selectedIndices sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
     NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:[PicPranckCoreDataServices areAllPicPrancksDeletedMode:self] fromViewController:self];
    for(id row in self.selectedIndices)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForItem:[row integerValue] inSection:0];
        [arrayOfIdxPaths addObject:indexPath];
        NSLog(@"row:%ld",(long)indexPath.row);
        NSLog(@"section:%ld",(long)indexPath.section);
        Bridge *bridge=[PicPranckCoreDataServices retrieveDataAtIndex:indexPath.row withType:@"Bridge"];
        SavedImage *savedImage=[PicPranckCoreDataServices retrieveDataAtIndex:indexPath.row withType:@"SavedImage"];
        [managedObjCtx deleteObject:bridge];
        [managedObjCtx deleteObject:savedImage];
    }
    [self.selectedIndices removeAllObjects];
    [self backToInitialStateFromBarButtonItem:self.selectButton];
    NSError *err;
    [managedObjCtx save:&err];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0)
            {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0)
                    self.shouldReloadCollectionView = YES;
                else
                {
                    [self.blockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            }
            else
                self.shouldReloadCollectionView = YES;
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1)
                self.shouldReloadCollectionView = YES;
            else
            {
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.shouldReloadCollectionView)
        [self.collectionView reloadData];
    else
    {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:nil];
    }
}

@end
