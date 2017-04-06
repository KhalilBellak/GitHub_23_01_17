//
//  PicPranckCollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckCollectionViewController.h"
#import "PicPranckViewController.h"
#import "PicPranckImage.h"
#import "AppDelegate.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckCollectionViewCell.h"
#import "ImageOfArea+CoreDataClass.h"
#import "ImageOfAreaDetails+CoreDataClass.h"
#import "PicPranckCollectionViewFlowLayout.h"
#import "ViewController.h"

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
//    self.handle = [[FIRAuth auth]
//                   addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
//                       // ...
//                   }];

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
    //self.fetchedResultsController=nil;
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:NO fromViewController:self];
    [managedObjCtx reset];
    //[[FIRAuth auth] removeAuthStateDidChangeListener:_handle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    {
        return savedImg.imageOfAreaDetails.thumbnail;
//        NSSortDescriptor *sortDsc=[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
//        NSArray *arrayDsc=[[NSArray alloc] initWithObjects:sortDsc, nil];
//        
//        NSArray *sortedArray=[savedImg.imageOfAreaDetails sortedArrayUsingDescriptors:arrayDsc];
//        if(1<[sortedArray count])
//        {
//            ImageOfAreaDetails *imgOfAreaDetails=[sortedArray objectAtIndex:1];
//            //return [imgOfAreaDetails.imageOfAreaWithData dataImage];
//            
//        }
    }
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
    // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
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
