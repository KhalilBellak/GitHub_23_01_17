//
//  PicPranckFirebaseCollectionViewController
//  PicPranck
//
//  Created by El Khalil Bellakrid on 02/05/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckFirebaseCollectionViewController.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckEncryptionServices.h"
#import "UIViewController+Alerts.h"

@import Firebase;
@import FirebaseStorage;
@import FirebaseDatabase;
@import FirebaseStorageUI;

@interface PicPranckFirebaseCollectionViewController ()

@end

@implementation PicPranckFirebaseCollectionViewController
static NSString * const reuseIdentifier = @"Cell";
@synthesize storage=_storage;
@synthesize dicoNSURLOfAvailablePickPranks=_dicoNSURLOfAvailablePickPranks;
//@synthesize listOfKeys=_listOfKeys;
@synthesize availablePPRef=_availablePPRef;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nbOfItems=0;
    _dicoNSURLOfAvailablePickPranks=[[NSMutableDictionary alloc] init];
//    _listOfKeys=[[NSMutableArray alloc] init];
    //Firebase Storage
    _storage=[FIRStorage storageWithURL:@"gs://picpranck.appspot.com"];
    FIRStorageReference *storageRef = [_storage reference];
    //User's id
    NSString *userID=[FIRAuth auth].currentUser.uid;
    //Path to storage
    NSString *pathToStorage=[NSString stringWithFormat:@"usersPicPrancks/%@",userID];
    _availablePPRef = [storageRef child:pathToStorage];
    
    //Firebase Database
    //Path to Database
    NSString *pathToDB=[NSString stringWithFormat:@"usersPicPrancks/%@/PicPrancks",userID];
    self.firebaseRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *availablePP=[self.firebaseRef child:pathToDB];
    self.dataSource = [self.collectionView bindToQuery:availablePP//self.firebaseRef
                                          populateCell:^UICollectionViewCell *(UICollectionView *collectionView,
                                                                               NSIndexPath *indexPath,
                                                                               FIRDataSnapshot *object) {
                                              return [self populateCell:collectionView atIndexPath:indexPath withFIRObject:object];
                                          }];
    //self.dataSource=[self.collectionView reu]
    //self.dataSource
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
    [super viewWillAppear:animated];
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
    cell.pictureName=object.value;
    //NSString *pictureName=object.value;
    
    NSString *extension=@"png";
    
    //NSString *pathToPreview=[NSString stringWithFormat:@"PicPranck_%ld",(long)indexPath.row];
    
    NSString *pathToPreview=object.value;
    NSMutableArray *arrayOfURLs=[[NSMutableArray alloc] init];
    
    //Create local directory to cache images
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathToCacheDirectory=[NSString stringWithFormat:@"%@/%@", documentsDirectory,pathToPreview];
    NSString *pathToCachedImagePreview=[NSString stringWithFormat:@"%@/%@/image_1.png", documentsDirectory,pathToPreview];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCacheDirectory isDirectory:nil])
    {
        //If not, create it
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath: pathToCacheDirectory
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];

    }
    else if([[NSFileManager defaultManager] fileExistsAtPath:pathToCachedImagePreview isDirectory:nil])
    {
        //If already cached set preview in cell
        NSArray *arrayOfNSURL=[_dicoNSURLOfAvailablePickPranks objectForKey:pathToPreview];
        if(arrayOfNSURL && 1<[arrayOfNSURL count])
        {
            NSData *data=[NSData dataWithContentsOfURL:[arrayOfNSURL objectAtIndex:1]];
            UIImage *imagePreview=[[UIImage alloc] initWithData:data];
            [cell.imageViewInCell setImage:imagePreview];
            if(imagePreview)
                [cell.activityIndic stopAnimating];
            cell.imageViewInCell.delegate=self;
            return cell;
        }
    }
    
    //QOS_CLASS_USER_INITIATED
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^
                   {
                       for(int i=1;i<=3;i++)
                       {
                           
                           //Get a path to picture of type nameOfPicture/nameOfPicture_i.extension
                           NSString *currRelativeImagePath=[NSString stringWithFormat: @"image_%d.%@",i-1,extension];
                           NSString *currImagePath=[NSString stringWithFormat:@"%@/%@", pathToPreview,currRelativeImagePath];
                           //UIImage *placeholderImage=[UIImage imageNamed:@"simple_fuck_no_back.png"];
                           FIRStorageReference *element = [self.availablePPRef child:currImagePath];
                           
                           // Create local filesystem URL
                           //With document directory
                           NSString *local=[NSString stringWithFormat:@"%@/%@",pathToCacheDirectory,currRelativeImagePath];
                           NSURL *localURL=[NSURL fileURLWithPath:local];
                           
                           NSNumber *isAFile;
                           NSError *err;
                           NSData *cachedData=[NSData dataWithContentsOfURL:localURL];
                           [localURL getResourceValue:&isAFile
                                               forKey:NSURLFileResourceTypeKey error:&err];
                           
                           // Download to the local filesystem
                           if(0>=isAFile && !cachedData)
                           {
                               [element dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
                                   if (error != nil) {
                                       //[self showMessagePrompt:error.description];
                                       // Uh-oh, an error occurred!
                                   } else {
                                       
                                       NSData *decryptedData =[PicPranckEncryptionServices decryptImage:data];
                                       [decryptedData writeToURL:localURL  atomically:YES];

                                       //Set thumbnail
                                       if(2==i)
                                       {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [cell.imageViewInCell setImage:[UIImage imageWithData:decryptedData]];
                                               [cell.activityIndic stopAnimating];
                                           });
                                           
                                       }
                                   }
                               }];

                           }
                           else if(2==i && cachedData)
                           {
                               //Set thumbnail
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [cell.imageViewInCell setImage:[UIImage imageWithData:cachedData]];
                                   [cell.activityIndic stopAnimating];
                               });
                           }
                           [arrayOfURLs addObject:localURL];
                       }
                       if(3==[arrayOfURLs count])
                       {
                           [_dicoNSURLOfAvailablePickPranks setValue:arrayOfURLs forKey:pathToPreview];
//                           if(indexPath.row<=[_listOfKeys count])
//                               [_listOfKeys insertObject:pathToPreview atIndex:indexPath.row];
//                           else
//                               [_listOfKeys addObject:pathToPreview];
                           
                       }
                       
                   });
    cell.imageViewInCell.delegate=self;
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
-(void)deleteSelectedElements:(id)sender
{
    //Sort
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self"
                                                                ascending: YES];
    [self.selectedIndices sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    //Array of PPs Name to delete
    NSMutableArray *folderNamesToDelete=[[NSMutableArray alloc] init];
    for(id row in self.selectedIndices)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[row integerValue] inSection:0];
        PicPranckCollectionViewCell *currCell=(PicPranckCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [folderNamesToDelete addObject:currCell.pictureName];
    }
    [PicPranckEncryptionServices removePicPrancks:self withNames:folderNamesToDelete];
    [self.selectedIndices removeAllObjects];
    [self backToInitialStateFromBarButtonItem:self.selectButton];
    
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
