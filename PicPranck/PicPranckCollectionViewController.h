//
//  PicPranckCollectionViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CollectionViewController.h"
#import "PicPranckImageView.h"
#import "PicPranckButton.h"


@import Firebase;
@interface PicPranckCollectionViewController : CollectionViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property NSBlockOperation *blockOperation;
@property BOOL shouldReloadCollectionView;
@end
