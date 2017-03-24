//
//  AvailablePicPranckCollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "AvailablePicPranckCollectionViewController.h"
#import "PicPranckCollectionViewCell.h"
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
    // Do any additional setup after loading the view.
    
//    [availablePP observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
//        [self updateCells:snapshot];
//    }];
}
-(void)updateCells:(FIRDataSnapshot *)snapshot
{
    [self.collectionView reloadData];
}
//-(void)viewDidAppear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(contentSizeCategoryChanged:)
//                                                 name:UIContentSizeCategoryDidChangeNotification
//                                               object:nil];
//}
//- (void)contentSizeCategoryChanged:(NSNotification *)notification
//{
//    [self.collectionView reloadData];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>
-(UICollectionViewCell *)populateCell:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath withFIRObject:(FIRDataSnapshot *)object
{
    PicPranckCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                  forIndexPath:indexPath];

    NSString *pictureName=object.value;
    
    NSString *extension=@"png";
    
    NSLog(@"object value: %@",object.value);
    NSLog(@"object key: %@",object.key);

    NSString *pathToPreview=[NSString stringWithFormat:@"%@/",pictureName];
    NSMutableArray *arrayOfURLs=[[NSMutableArray alloc] init];
    for(int i=1;i<=3;i++)
    {
        
        //Get a path to picture of type nameOfPicture/nameOfPicture_i.extension
        NSString *currRelativeImagePath=[NSString stringWithFormat: @"%@%@%@%@%@",pictureName,@"_",[@(i) stringValue],@".",extension];
        NSString *currImagePath=[NSString stringWithFormat:@"%@%@", pathToPreview,currRelativeImagePath];
        UIImage *placeholderImage;
        FIRStorageReference *element = [self.availablePPRef child:currImagePath];
        //Set thumbnail
        if(2==i)
            [cell.imageViewInCell sd_setImageWithStorageReference:element placeholderImage:placeholderImage];
        
        // Create local filesystem URL
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *local=[NSString stringWithFormat:@"%@/%@",documentsDirectory,currRelativeImagePath];
        NSURL *localURL=[NSURL fileURLWithPath:local];
        NSLog(@"Is a file URL:%d ",[localURL isFileURL]);
        NSNumber *isAFile;
        NSError *err;
        [localURL getResourceValue:&isAFile
                            forKey:NSURLFileResourceTypeKey error:&err];
        if(err)
        {
            NSLog(@"ERROR WHILE CALLINF GETRESOURCEVALUE:");
            NSLog(@"%@",err.description);
        }
        else if(0<isAFile)
        {
            NSLog(@"IS ALREADY A FILE");
             [arrayOfURLs addObject:localURL];
        }
        // Download to the local filesystem
        if(0>=isAFile)
        {
            FIRStorageDownloadTask *downloadTask = [element writeToFile:localURL completion:^(NSURL *URL, NSError *error){
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    NSLog(@"downloadTask KO");
                    NSLog(@"ERROR= %@",error.description);
                } else {
                    // Local file URL for "images/island.jpg" is returned
                    NSLog(@"downloadTask Succeeded");
                    [arrayOfURLs addObject:URL];
                }
            }];
        }
    }
    if(0<[arrayOfURLs count])
    {
        [_dicoNSURLOfAvailablePickPranks setValue:arrayOfURLs forKey:pictureName];
        [_listOfKeys insertObject:pictureName atIndex:indexPath.row];
    }
    cell.imageViewInCell.delegate=self;
    cell.imageViewInCell.indexOfViewInCollectionView=indexPath.row;
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    FIRDatabaseReference *nbAvailablePP=[self.firebaseRef child:@"nbOfAvailablePickPranks"];
//    [nbAvailablePP observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
//        self.nbOfItems=[snapshot.value integerValue];
//    }];
//    return self.nbOfItems;
//}
//-(id)getPreviewImageForCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    FIRStorageReference *storageRef = [_storage reference];
//    FIRStorageReference *availablePPRef = [storageRef child:@"availablePicPrancks"];
//    FIRStorageReference *dickFace = [availablePPRef child:@"dickFace/dickFace_2"];
//    // Placeholder image
//    //FIRDataSnapshot
//    UIImage *placeholderImage;
//    UIImageView *imageView=[[UIImageView alloc] init];
//    // Load the image using SDWebImage
//    [imageView sd_setImageWithStorageReference:dickFace placeholderImage:placeholderImage];
//    
//    return placeholderImage;
//}
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
