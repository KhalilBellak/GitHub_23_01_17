//
//  PicPranckViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 14/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckViewController.h"
#import "PicPranckImageView.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "SavedImage+CoreDataClass.h"
#import "ImageOfArea+CoreDataClass.h"

#define X_OFFSET 5
#define Y_OFFSET 5
#define NB_OF_IMG_BY_ROW 3

@interface PicPranckViewController ()

@end
#pragma mark -
@implementation PicPranckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext=appDelegate.managedObjectContext;
    //Fetch request
    NSFetchRequest *req=[[NSFetchRequest alloc] initWithEntityName:@"SavedImage"];
    req.fetchBatchSize=10;
    req.fetchLimit=30;
    //Predicate
    //NSPredicate *predicate =[NSPredicate predicateWithFormat:@"newPicPranck == true"];
    //[req setPredicate:predicate];
    //Sort results by date
    NSSortDescriptor *sortDesc=[[NSSortDescriptor alloc] initWithKey:@"dateOfCreation" ascending:YES];
    [req setSortDescriptors:[[NSArray alloc] initWithObjects:sortDesc,nil] ];
    //Getting the images
    NSError *err=[[NSError alloc] init];
    NSArray *results=[managedObjectContext executeFetchRequest:req error:&err];
    //Inserting thumbnails of created PickPrancks
    CGRect collViewFrame=_collectionView.frame;
    CGFloat width=(collViewFrame.size.width-(NB_OF_IMG_BY_ROW+1)*X_OFFSET)/NB_OF_IMG_BY_ROW;
    CGFloat xOffset=X_OFFSET,yOffset=Y_OFFSET;
    for(SavedImage *currManObj in results)
    {
        if(currManObj.newPicPranck)
        {
            CGRect frame=CGRectMake(xOffset, yOffset, width, width);
            PicPranckImageView *ppImgView=[[PicPranckImageView alloc] initFromViewController:self withManagedObject:currManObj andFrame:frame];
        }
        xOffset+=(width+X_OFFSET);
        if(collViewFrame.size.width+collViewFrame.origin.x< xOffset+width)
        {
            xOffset=X_OFFSET;
            yOffset+=width+Y_OFFSET;
        }
    }
    //Save that images are old ones
    //bool saved=[managedObjectContext save:&err];
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

@end
