//
//  AvailablePicPranckCollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "AvailablePicPranckCollectionViewController.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCustomViewsServices.h"
#import "UIViewController+Alerts.h"
@import Firebase;
@import FirebaseStorage;
@import FirebaseDatabase;
//@import FirebaseUI;
//@import FirebaseDatabaseUI;
@import FirebaseStorageUI;
//#import <FirebaseUI/FirebaseStorageUI/UIImageView+FirebaseStorage.h>

@interface AvailablePicPranckCollectionViewController ()

@end

@implementation AvailablePicPranckCollectionViewController
static NSString * const reuseIdentifier = @"CellFromAvailablePP";
@synthesize storage=_storage;
@synthesize dicoNSURLOfAvailablePickPranks=_dicoNSURLOfAvailablePickPranks;
@synthesize listOfKeys=_listOfKeys;
@synthesize availablePPRef=_availablePPRef;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nbOfItems=0;
    _dicoNSURLOfAvailablePickPranks=[[NSMutableDictionary alloc] init];
    _listOfKeys=[[NSMutableArray alloc] init];
    //Firebase Storage
    _storage=[FIRStorage storageWithURL:@"gs://picpranck.appspot.com"];
    FIRStorageReference *storageRef = [_storage reference];
    _availablePPRef = [storageRef child:@"availablePicPrancks"];
 
    //Firebase Database
    self.firebaseRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *availablePP=[self.firebaseRef child:@"availablePickPranks"];
    self.dataSource = [self.collectionView bindToQuery:availablePP//self.firebaseRef
                                          populateCell:^UICollectionViewCell *(UICollectionView *collectionView,
                                                                               NSIndexPath *indexPath,
                                                                               FIRDataSnapshot *object) {
                                              return [self populateCell:collectionView atIndexPath:indexPath withFIRObject:object];
                                          }];
    //self.dataSource=[self.collectionView reu]
    //self.dataSource

}
-(void)updateCells:(FIRDataSnapshot *)snapshot
{
    [self.collectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>
-(UICollectionViewCell *)populateCell:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath withFIRObject:(FIRDataSnapshot *)object
{
    PicPranckCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                  forIndexPath:indexPath];
    [cell.activityIndic startAnimating];
    
    NSString *pictureName=object.value;
    
    NSString *extension=@"png";

    NSString *pathToPreview=[NSString stringWithFormat:@"%@/",pictureName];
    NSMutableArray *arrayOfURLs=[[NSMutableArray alloc] init];
    
    //QOS_CLASS_USER_INITIATED
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^
                   {
                       for(int i=1;i<=3;i++)
                       {
                           
                           //Get a path to picture of type nameOfPicture/nameOfPicture_i.extension
                           NSString *currRelativeImagePath=[NSString stringWithFormat: @"%@%@%@%@%@",pictureName,@"_",[@(i) stringValue],@".",extension];
                           NSString *currImagePath=[NSString stringWithFormat:@"%@%@", pathToPreview,currRelativeImagePath];
                           UIImage *placeholderImage=[UIImage imageNamed:@"simple_fuck_no_back.png"];
                           FIRStorageReference *element = [self.availablePPRef child:currImagePath];
                           
                           // Create local filesystem URL
                           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                           NSString *documentsDirectory = [paths objectAtIndex:0];
                           NSString *local=[NSString stringWithFormat:@"%@/%@",documentsDirectory,currRelativeImagePath];
                           NSURL *localURL=[NSURL fileURLWithPath:local];
                           
                           NSNumber *isAFile;
                           NSError *err;
                           [localURL getResourceValue:&isAFile
                                               forKey:NSURLFileResourceTypeKey error:&err];
                           //if(err)
                           //    [self showMessagePrompt:err.description];
                           
                           // Download to the local filesystem
                           if(0>=isAFile)
                           {
                               FIRStorageDownloadTask *downloadTask = [element writeToFile:localURL completion:^(NSURL *URL, NSError *error)
                                                                       {
                                                                           if(error)
                                                                           {
                                                                               [self showMessagePrompt:error.description];
                                                                               return;
                                                                           }
                                                                       }];
                           }
                           [arrayOfURLs addObject:localURL];
                           
                           //Set thumbnail
                           if(2==i)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [cell.imageViewInCell sd_setImageWithStorageReference:element placeholderImage:placeholderImage];
                                   [cell.activityIndic stopAnimating];
                               });
                               
                           }
                       }
                       if(3==[arrayOfURLs count])
                       {
                           [_dicoNSURLOfAvailablePickPranks setValue:arrayOfURLs forKey:pictureName];
                           if(indexPath.row<=[_listOfKeys count])
                               [_listOfKeys insertObject:pictureName atIndex:indexPath.row];
                           else
                               [_listOfKeys addObject:pictureName];
                           
                       }
                       
                   });
    cell.imageViewInCell.delegate=self;
    //cell.imageViewInCell.indexOfViewInCollectionView=indexPath.row;
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSString *)getCellIdentifier
{
    //To be implemented by subclasses
    return reuseIdentifier;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
