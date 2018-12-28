//
//  BTTMeMoreSaveMoneyCell.m
//  Hybird_A01
//
//  Created by Domino on 26/12/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTMeMoreSaveMoneyCell.h"
#import "BTTMeSaveMoneyCell.h"
#import "BTTMeMainModel.h"

@interface BTTMeMoreSaveMoneyCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation BTTMeMoreSaveMoneyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTMeSaveMoneyCell" bundle:nil] forCellWithReuseIdentifier:@"BTTMeSaveMoneyCell"];
    self.mineSparaterType = BTTMineSparaterTypeNone;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = COLOR_RGBA(41, 45, 54, 1);
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake((SCREEN_WIDTH - 70) / 4, 110);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    self.collectionView.collectionViewLayout = layout;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BTTMeMainModel *model = self.dataSource.count ? self.dataSource[indexPath.row] : nil;;
    BTTMeSaveMoneyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTMeSaveMoneyCell" forIndexPath:indexPath];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    BTTMeMainModel *model = self.dataSource.count ? self.dataSource[indexPath.row] : nil;
    if (model && self.clickEventBlock) {
        self.clickEventBlock(model);
    }
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

@end
