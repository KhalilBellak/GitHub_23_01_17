//
//  PicPranckCollectionViewFlowLayout.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 15/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PicPranckCollectionViewFlowLayout.h"

#define NB_CELLS_IN_LINE 3
#define ITEM_WIDTH 110
#define ITEM_HEIGHT 110
#define ITEM_SPACING 10
#define LINE_SPACING 15
#define HEADER_HEIGHT 15
@implementation PicPranckCollectionViewFlowLayout

- (CGSize)collectionViewContentSize
{
    
    self.cellSize=([UIScreen mainScreen].bounds.size.width-(NB_CELLS_IN_LINE+1)*ITEM_SPACING)/NB_CELLS_IN_LINE;
    //self.sectionInset=UIEdgeInsetsMake(10, 10, 30, 10);
    self.scrollDirection=UICollectionViewScrollDirectionVertical;
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    _nbOfElements=numberOfItems;
    //header settings
    self.headerReferenceSize=CGSizeMake(self.collectionView.frame.size.width, HEADER_HEIGHT);
    self.sectionHeadersPinToVisibleBounds=YES;
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, numberOfItems * self.cellSize+HEADER_HEIGHT);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger index = [indexPath indexAtPosition:0];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    attributes.frame = CGRectMake((indexPath.row%NB_CELLS_IN_LINE) * (self.cellSize+ITEM_SPACING)+ITEM_SPACING,floor(indexPath.row/NB_CELLS_IN_LINE)*(self.cellSize+LINE_SPACING)+HEADER_HEIGHT, self.cellSize, self.cellSize);
    return attributes;
}
//-(UICollectionReusableView *)
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //NSMutableArray *attributes = [NSMutableArray new];
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    NSUInteger firstIndex = floorf(CGRectGetMinX(rect) / ITEM_WIDTH);
    NSUInteger lastIndex = MIN( ceilf(CGRectGetMaxX(rect) / ITEM_WIDTH),_nbOfElements-1);
    if(0<_nbOfElements)
    {
        for (NSUInteger index = firstIndex; index <= lastIndex; index++)
        {
            NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:(NSUInteger [2]){ 0, index } length:2];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
//    else if([attributes isKindOfClass:[UICollectionViewLayoutAttributes class]])
//    {
//        UICollectionViewLayoutAttributes *collecAttr=(UICollectionViewLayoutAttributes *)attributes;
//        NSLog(@"ATTRIBUTE FRAME: (w,h)=(%f,%f)",collecAttr.frame.size.width,collecAttr.frame.size.height);
////        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:(NSUInteger [2]){ 0, 0 } length:2];
////        UICollectionViewLayoutAttributes *attributeHeader=[UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
////        attributeHeader.frame=CGRectMake(0, 0, self.collectionView.frame.size.width, HEADER_HEIGHT);
////        [attributes addObject:attributeHeader];
//    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    attributes.alpha = 0.0;
    return attributes;
}
+(CGFloat)getHeaderHeight
{
    return HEADER_HEIGHT;
}
//-(void)setHeaderReferenceSize:(CGSize)headerReferenceSize
//{
//    
//}
@end
