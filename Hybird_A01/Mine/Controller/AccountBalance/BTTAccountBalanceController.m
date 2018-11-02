//
//  BTTAccountBalanceController.m
//  Hybird_A01
//
//  Created by Domino on 2018/10/19.
//  Copyright © 2018年 BTT. All rights reserved.
//

#import "BTTAccountBalanceController.h"
#import "BTTAccountBlanceHeaderCell.h"
#import "BTTAccountBlanceCell.h"
#import "BTTAccountBlanceHiddenCell.h"

@interface BTTAccountBalanceController ()<BTTElementsFlowLayoutDelegate>

@property (nonatomic, assign) BOOL isShowHidden;

@end

@implementation BTTAccountBalanceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账户余额";
    [self setupCollectionView];
    [self setupElements];
}

- (void)setupCollectionView {
    [super setupCollectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTAccountBlanceHeaderCell" bundle:nil] forCellWithReuseIdentifier:@"BTTAccountBlanceHeaderCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTAccountBlanceCell" bundle:nil] forCellWithReuseIdentifier:@"BTTAccountBlanceCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTAccountBlanceHiddenCell" bundle:nil] forCellWithReuseIdentifier:@"BTTAccountBlanceHiddenCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.elementsHight.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        BTTAccountBlanceHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTAccountBlanceHeaderCell" forIndexPath:indexPath];
        return cell;
    } else if (indexPath.row == 1 || indexPath.row == 2) {
        BTTAccountBlanceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTAccountBlanceCell" forIndexPath:indexPath];
        if (indexPath.row == 1) {
            cell.mineArrowsType = BTTMineArrowsTypeHidden;
        } else {
            cell.mineArrowsType = BTTMineArrowsTypeNoHidden;
        }
        if (self.isShowHidden) {
            cell.mineArrowsDirectionType = BTTMineArrowsDirectionTypeUp;
        } else {
            cell.mineArrowsDirectionType = BTTMineArrowsDirectionTypeRight;
        }
        return cell;
    } else {
        BTTAccountBlanceHiddenCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTAccountBlanceHiddenCell" forIndexPath:indexPath];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%zd", indexPath.item);
    if (indexPath.item == 2) {
        self.isShowHidden = !self.isShowHidden;
        [self setupElements];
    }
}

#pragma mark - LMJCollectionViewControllerDataSource

- (UICollectionViewLayout *)collectionViewController:(BTTCollectionViewController *)collectionViewController layoutForCollectionView:(UICollectionView *)collectionView {
    BTTCollectionViewFlowlayout *elementsFlowLayout = [[BTTCollectionViewFlowlayout alloc] initWithDelegate:self];
    
    return elementsFlowLayout;
}

#pragma mark - LMJElementsFlowLayoutDelegate

- (CGSize)waterflowLayout:(BTTCollectionViewFlowlayout *)waterflowLayout collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.elementsHight[indexPath.item].CGSizeValue;
}

- (UIEdgeInsets)waterflowLayout:(BTTCollectionViewFlowlayout *)waterflowLayout edgeInsetsInCollectionView:(UICollectionView *)collectionView {
    return UIEdgeInsetsMake(0, 0, 40, 0);
}

/**
 *  列间距, 默认10
 */
- (CGFloat)waterflowLayout:(BTTCollectionViewFlowlayout *)waterflowLayout collectionView:(UICollectionView *)collectionView columnsMarginForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

/**
 *  行间距, 默认10
 */
- (CGFloat)waterflowLayout:(BTTCollectionViewFlowlayout *)waterflowLayout collectionView:(UICollectionView *)collectionView linesMarginForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (void)setupElements {
    if (self.elementsHight.count) {
        [self.elementsHight removeAllObjects];
    }
    NSInteger count = 0;
    if (self.isShowHidden) {
        count = 14;
    } else {
        count = 3;
    }
    for (int i = 0; i < count; i++) {
        if (i == 0) {
            [self.elementsHight addObject:[NSValue valueWithCGSize:CGSizeMake(SCREEN_WIDTH, 192)]];
        } else if (i == 1 || i == 2) {
            [self.elementsHight addObject:[NSValue valueWithCGSize:CGSizeMake(SCREEN_WIDTH, 60)]];
        } else {
            [self.elementsHight addObject:[NSValue valueWithCGSize:CGSizeMake(SCREEN_WIDTH, 42)]];
        }
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

@end
