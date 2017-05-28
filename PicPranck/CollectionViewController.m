//
//  CollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "CollectionViewController.h"
#import "PicPranckViewController.h"
#import "PicPranckCollectionViewController.h"
#import "PicPranckImage.h"
#import "AppDelegate.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckCollectionViewCell.h"
#import "ImageOfArea+CoreDataClass.h"
#import "PicPranckCollectionViewFlowLayout.h"
#import "ViewController.h"

//TODO: initialize fetchedResultsController in view init and use all mechanisms of update
static int collectionViewMode = 0;
@interface CollectionViewController ()
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;

@end

@implementation CollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Collection View "settings"
    [self.collectionView setAllowsMultipleSelection:YES];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    
    //Collection View background
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PicPranckCollectionViewCell class] forCellWithReuseIdentifier:[self getCellIdentifier]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionViewHeader"];
    
    _selectedIndices=[[NSMutableArray alloc] init];
}
-(IBAction)backToCustom
{
    [self.tabBarController setSelectedIndex:0];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goToCustomTab:(id)sender
{
     [self.tabBarController setSelectedIndex:0];
}

- (IBAction)selectElements:(id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UINavigationItem *navigVC=self.navigationItem;
        UITabBarController *tabBarVC=self.tabBarController;
        
        UIBarButtonItem *button=(UIBarButtonItem *)sender;
        if(0==button.tag)
        {
            //Replace Select by Delete (in red)
            [button setImage:[UIImage imageNamed:@"cancelButton"] ];
            //Replace custom button icon with trash button
            if(!_trashButton)
            {
                _trashButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trashButtonNavigationBar"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteSelectedElements:)];
                UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, -20.0, 0.0, 0.0);
                [_trashButton setImageInsets:titleInsets];
            }
            
            UIImageView *titleView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedElements"]];
            [navigVC setTitleView:titleView];
            _trashButton.customView.frame=navigVC.leftBarButtonItem.customView.bounds;
            [navigVC setLeftBarButtonItem:_trashButton];
            [_trashButton setEnabled:NO];
            //Hide tab bar
            [tabBarVC.tabBar setHidden:YES];
            button.tag=1;
        }
        else if(1==button.tag)
            [self backToInitialStateFromBarButtonItem:button];
    }
}
-(void)backToInitialStateFromBarButtonItem:(UIBarButtonItem *)barButton
{
    UINavigationItem *navigVC=self.navigationItem;
    UITabBarController *tabBarVC=self.tabBarController;
    //Put back select button
    [barButton setImage:[UIImage imageNamed:@"selectButton"] ];
    //[barButton setTitle:@"Select"];
    [barButton setTintColor:self.collectionView.tintColor];
    [navigVC setTitleView:nil];
    //Put back custom button
    [navigVC setLeftBarButtonItem:_buttonCustomView];
    //show tab bar
    [tabBarVC.tabBar setHidden:NO];
    //Deselect all items
    for(id row in _selectedIndices)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[row integerValue] inSection:0];
        UICollectionViewCell *cell=[self.collectionView cellForItemAtIndexPath:indexPath];
        if([cell isKindOfClass:[PicPranckCollectionViewCell class]])
        {
            PicPranckCollectionViewCell *ppCell=(PicPranckCollectionViewCell *)cell;
            if(ppCell.imageViewInCell)
                [ppCell.imageViewInCell.layer setBorderWidth:0];
        }
    }
    [_selectedIndices removeAllObjects];
    
    if(_trashButton)
        [_trashButton setEnabled:NO];
    barButton.tag=0;
}
-(void)deleteSelectedElements:(id)sender
{
    //To be implemented by subclass
    
}
#pragma mark <UICollectionViewDataSource>


-(id)getPreviewImageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    //To be implemented by subclasses
    return nil;
}
-(NSString *)getCellIdentifier
{
    //To be implemented by subclasses
    return nil;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PicPranckCollectionViewCell *cell =(PicPranckCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:[self getCellIdentifier] forIndexPath:indexPath];
    //cell.imageViewInCell.indexOfViewInCollectionView=indexPath.row;
    cell.imageViewInCell.delegate=self;
    //Get image for preview
    [cell.activityIndic startAnimating];
    
    id idImage=[self getPreviewImageForCellAtIndexPath:indexPath];
    UIImage *image=[UIImage imageWithData:idImage];

    [cell.imageViewInCell setContentMode:UIViewContentModeScaleAspectFit];
    [PicPranckImageServices setImage:image forImageView:cell.imageViewInCell];
    [cell.activityIndic stopAnimating];
    return cell;
}


#pragma mark <UICollectionViewDelegateFlowLayout>

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    //Prevent from scrolling over top and below bottom
//    CGFloat yMin=[UIScreen mainScreen].bounds.origin.y;
//    if (scrollView.contentOffset.y < yMin)
//    {
//        CGPoint originalCGP=self.collectionView.contentOffset;
//        if(scrollView.contentOffset.y < yMin)
//            originalCGP.y=yMin;
//        [self.collectionView setContentOffset:originalCGP animated:NO];
//    }
//}
- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([collectionViewLayout isKindOfClass:[PicPranckCollectionViewFlowLayout class]])
    {
        PicPranckCollectionViewFlowLayout *ppCollecViewLayout=(PicPranckCollectionViewFlowLayout *)collectionViewLayout;
        return ppCollecViewLayout.itemSize;
    }
    return CGSizeMake(120, 120);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width, [PicPranckCollectionViewFlowLayout getHeaderHeight]);
}

#pragma mark <PicPranckImageViewDelegate>
-(void)cellTaped:(PicPranckImageView *)sender //withIndex:(NSInteger)index
{
    NSInteger index=0;
    UIView *cell=[[sender superview] superview];
    PicPranckCollectionViewCell *ppCell;
    if([cell isKindOfClass:[PicPranckCollectionViewCell class]])
    {
        ppCell=(PicPranckCollectionViewCell *)cell;
        index=[[self.collectionView indexPathForCell:ppCell] row];
    }
    if(0==_selectButton.tag)
        [PicPranckCustomViewsServices createPreviewInCollectionViewController:self WithIndex:index];
    else if(1==_selectButton.tag)
    {
        CGFloat borderWidth=0;
        if(_trashButton && ![_trashButton isEnabled])
            [_trashButton setEnabled:YES];
        
        if([self elementIsAlreadySelectedAtIndex:index])
        {
            [_selectedIndices removeObject:@(index)];
            if(0==[_selectedIndices count])
               [_trashButton setEnabled:NO];
        }
        else
        {
            [_selectedIndices addObject:@(index)];
            borderWidth=4;
        }
        //Highlight Cell
        if(ppCell)
        {
            [ppCell.imageViewInCell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [ppCell.imageViewInCell.layer setBorderWidth:borderWidth];
        }
    }
}
#pragma mark <PicPranckButtonDelegate>
-(void)useImage:(PicPranckButton *)sender
{
    UITabBarController *tabBarController=self.tabBarController;
    NSArray *vcArray=[tabBarController viewControllers];
    for(UIViewController *currVc in vcArray)
    {
        if([currVc isKindOfClass:[ViewController class]])
        {
            NSInteger iIndex=[vcArray indexOfObject:currVc];
            ViewController *vc=(ViewController *)currVc;
            NSMutableArray *arrayOfImages=[[NSMutableArray alloc] init];
            NSArray *subViewsOfView=[sender.modalVC.view subviews];
            UIView *coverView=[subViewsOfView objectAtIndex:0];
            NSArray *subViewsOfCoverView=[coverView subviews];
            for(UIView *subView in subViewsOfCoverView)
            {
                if(![subView isKindOfClass:[UIButton class]])
                {
                    NSArray *subViewsOfContainerView=[subView subviews];
                    for(UIView *subViewOfCovecView in subViewsOfContainerView)
                    {
                        if([subViewOfCovecView isKindOfClass:[UIImageView class]])
                        {
                            UIImageView *imgSubView=(UIImageView *)subViewOfCovecView;
                            [arrayOfImages insertObject:imgSubView.image atIndex:imgSubView.tag];
                        }
                    }
                }
            }
            [PicPranckImageServices setImageAreasWithImages:arrayOfImages inViewController:vc];
            [sender removeFromSuperview];
            [sender.superview removeFromSuperview];
            //Disiss modal VC
            [sender.modalVC dismissViewControllerAnimated:YES completion:^{
                //Dismiss collection view VC
                //Animated transition to Main VC
                [UIView transitionFromView:sender.modalVC.view
                                    toView:vc.view
                                  duration:0.4
                                   options:UIViewAnimationOptionTransitionFlipFromTop
                                completion:^(BOOL finished) {
                                    if (finished) {
                                        [sender.modalVC.view removeFromSuperview];
                                        tabBarController.selectedIndex = iIndex;
                                    }
                                }];
                
            }];
            
            
            
            
        }
    }
}
-(void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)elementIsAlreadySelectedAtIndex:(NSInteger)index
{
    bool result=NO;
    for(id currId in _selectedIndices)
    {
        NSInteger iId=[currId integerValue];
        if(iId==index)
            result=YES;
    }
    return result;
}
+(NSInteger)getModeOfCollectionView
{
    return collectionViewMode ;
}
@end
