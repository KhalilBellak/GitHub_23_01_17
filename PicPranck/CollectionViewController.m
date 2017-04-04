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

@interface CollectionViewController ()
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;

@end

@implementation CollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
//    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] initWithTitle:@"Custom" style:UIBarButtonItemStylePlain target:self action:@selector(backToCustom)];
//    
//    self.navigationItem.leftBarButtonItem=barButton;
    
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2)];
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PicPranckCollectionViewCell class] forCellWithReuseIdentifier:[self getCellIdentifier]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionViewHeader"];
}
-(IBAction)backToCustom
{
    [self.tabBarController setSelectedIndex:0];
}

-(void)viewWillAppear:(BOOL)animated
{
    //    self.handle = [[FIRAuth auth]
    //                   addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
    //                       // ...
    //                   }];
    //Refresh collection view
    
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
- (IBAction)goToCustomTab:(id)sender
{
     [self.tabBarController setSelectedIndex:0];
}

- (IBAction)selectElements:(id)sender
{
    
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
    cell.imageViewInCell.indexOfViewInCollectionView=indexPath.row;
    cell.imageViewInCell.delegate=self;
    //Get image for preview
    [cell.activityIndic startAnimating];
    
    id idImage=[self getPreviewImageForCellAtIndexPath:indexPath];
    //Set it in imageView of Cell
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^
                   {
                       UIImage *image=[UIImage imageWithData:idImage];
                       PicPranckImage *ppImg=[[PicPranckImage alloc] initWithImage:image];
                       UIImage *imageToUse=[ppImg imageByScalingProportionallyToSize:cell.imageViewInCell.frame.size];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [cell.imageViewInCell setContentMode:UIViewContentModeScaleAspectFit];
                           [PicPranckImageServices setImage:imageToUse forImageView:cell.imageViewInCell];
                           [cell.activityIndic stopAnimating];
                       });
                       
                       
                   });
    
    
//    UIImage *image=[UIImage imageWithData:idImage];
//    PicPranckImage *ppImg=[[PicPranckImage alloc] initWithImage:image];
//    UIImage *imageToUse=[ppImg imageByScalingProportionallyToSize:cell.imageViewInCell.frame.size];
//    [cell.imageViewInCell setContentMode:UIViewContentModeScaleAspectFit];
//    [PicPranckImageServices setImage:imageToUse forImageView:cell.imageViewInCell];
//    [cell.activityIndic stopAnimating];
    
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
//-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
//                                            UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionViewHeader" forIndexPath:indexPath];
//    if (kind == UICollectionElementKindSectionHeader)
//    {
//        [self updateSectionHeader:headerView forIndexPath:indexPath];
//    }
//    NSLog(@"header frame: (w,h)=(%f,%f)",headerView.frame.size.width,headerView.frame.size.height);
//    return headerView;
//}
//
//- (void)updateSectionHeader:(UICollectionReusableView *)header forIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *text = [NSString stringWithFormat:@"HEADER"];
//    if([self isKindOfClass:[PicPranckCollectionViewController class]])
//        text=@"My PickPranks";
//    else
//        text=@"Images";
//    
//    NSAttributedString *AttrText=[PicPranckCustomViewsServices getAttributedStringWithString:text withFontSize:15];
//    
//    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(self.collectionView.frame.origin.x,self.collectionView.frame.origin.y,self.collectionView.frame.size.width, header.frame.size.height)];
//    //label.center=self.collectionView.center;
//    
//    [label setAttributedText:AttrText];
//    [header addSubview:label];
//    //header.label.text = text;
//}
#pragma mark <PicPranckImageViewDelegate>
-(void)cellTaped:(PicPranckImageView *)sender
{
    [PicPranckCustomViewsServices createPreviewInCollectionViewController:self WithIndex:sender.indexOfViewInCollectionView];
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
@end
