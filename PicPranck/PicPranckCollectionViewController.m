//
//  PicPranckCollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckCollectionViewController.h"
#import "PicPranckViewController.h"
#import "PicPranckImageView.h"
#import "PicPranckImage.h"
#import "AppDelegate.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCollectionViewCell.h"
#import "ImageOfArea+CoreDataClass.h"

//TODO: initialize fetchedResultsController in view init and use all mechanisms of update

@interface PicPranckCollectionViewController ()

@end

@implementation PicPranckCollectionViewController

@synthesize fetchedResultsController=_fetchedResultsController;
static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    _shouldReloadCollectionView=YES;
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    //self.transitioningDelegate=
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2)];
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PicPranckCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
//    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    // Do any additional setup after loading the view.
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    //self.fetchedResultsController=nil;
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext];
    [managedObjCtx reset];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"INDEX OF CELL: %ld",indexPath.row);
    PicPranckCollectionViewCell *cell =(PicPranckCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // populate cell with image
    //[PicPranckCoreDataServices addThumbnailInImageView:cell.imageViewInCell withIndex:indexPath.row];
    cell.imageViewInCell.indexOfViewInCollectionView=indexPath.row;
    
    SavedImage *savedImg = [_fetchedResultsController objectAtIndexPath:indexPath];
    //Sort the set
    if(savedImg)
    {
        NSSortDescriptor *sortDsc=[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSArray *arrayDsc=[[NSArray alloc] initWithObjects:sortDsc, nil];
        NSArray *sortedArray=[savedImg.imageChildren sortedArrayUsingDescriptors:arrayDsc];
        if(1<[sortedArray count])
        {
            ImageOfArea *imgOfArea=[sortedArray objectAtIndex:1];
            id idImage=imgOfArea.dataImage;
            UIImage *image=[UIImage imageWithData:idImage];
            //[PicPranckImageServices setImage:image forImageView:cell.imageViewInCell];
            PicPranckImage *ppImg=[[PicPranckImage alloc] initWithImage:image];
            [cell.imageViewInCell setContentMode:UIViewContentModeScaleAspectFit];
            [PicPranckImageServices setImage:[ppImg imageByScalingProportionallyToSize:cell.imageViewInCell.frame.size] forImageView:cell.imageViewInCell];
        }
    }
    return cell;
}




#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
//-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
#pragma mark <NSFetchedResultsControllerDelegate>

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
        return _fetchedResultsController;

    return [self initializeFRC];
    
}
-(NSFetchedResultsController *)initializeFRC
{
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SavedImage" inManagedObjectContext:managedObjCtx];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"dateOfCreation" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    //    //Fetch request
    //    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"SavedImage"];
    //    //Sort results by date
    //    NSSortDescriptor *sortDesc=[[NSSortDescriptor alloc] initWithKey:@"dateOfCreation" ascending:YES];
    //    [req setSortDescriptors:[[NSArray alloc] initWithObjects:sortDesc,nil] ];
    
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Prevent from scrolling over top and below bottom
    CGFloat yMin=[UIScreen mainScreen].bounds.origin.y;
    if (scrollView.contentOffset.y < yMin)
    {
        CGPoint originalCGP=self.collectionView.contentOffset;
        if(scrollView.contentOffset.y < yMin)
            originalCGP.y=yMin;
        [self.collectionView setContentOffset:originalCGP animated:NO];
    }
}
@end
