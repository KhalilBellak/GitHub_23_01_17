//
//  PicPranckFirebaseCollectionViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "CollectionViewController.h"
@import Firebase;
@import FirebaseStorage;
@import FirebaseDatabase;
@import FirebaseDatabaseUI;

@interface PicPranckFirebaseCollectionViewController : CollectionViewController
@property FIRStorage *storage;
@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (strong, nonatomic) FUICollectionViewDataSource *dataSource;
@property FIRStorageReference *availablePPRef;
@property (strong, nonatomic) NSMutableDictionary *dicoNSURLOfAvailablePickPranks;
//@property (strong,nonatomic) NSMutableArray *listOfKeys;
@property NSInteger nbOfItems;
@end
