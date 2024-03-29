//
//  BTTModifyLimitViewController.m
//  Hybird_1e3c3b
//
//  Created by Domino on 29/10/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTModifyLimitViewController.h"
#import "BTTBindingMobileOneCell.h"
#import "BTTMeMainModel.h"
#import "BRPickerView.h"
#import "BTTModifyLimitViewController+LoadData.h"
#import "BTTPublicBtnCell.h"

@interface BTTModifyLimitViewController ()<BTTElementsFlowLayoutDelegate>

@property (nonatomic, strong) NSMutableArray *sheetDatas;



@end

@implementation BTTModifyLimitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改限红";
    [self setupCollectionView];
    [self setupElements];
    [self loadMainData];
}

- (void)setupCollectionView {
    [super setupCollectionView];
    self.collectionView.backgroundColor = [UIColor colorWithHexString:@"212229"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTBindingMobileOneCell" bundle:nil] forCellWithReuseIdentifier:@"BTTBindingMobileOneCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTPublicBtnCell" bundle:nil] forCellWithReuseIdentifier:@"BTTPublicBtnCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.elementsHight.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.sheetDatas.count) {
        BTTPublicBtnCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTPublicBtnCell" forIndexPath:indexPath];
        cell.btnType = BTTPublicBtnTypeConfirm;
        weakSelf(weakSelf);
        cell.buttonClickBlock = ^(UIButton * _Nonnull button) {
            strongSelf(strongSelf);
            [strongSelf loadSetBetLimitWithAgin:self.aginStr bbin:self.bbinStr];
        };
        return cell;
    } else {
        BTTBindingMobileOneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTBindingMobileOneCell" forIndexPath:indexPath];
        BTTMeMainModel *model = self.sheetDatas[indexPath.row];
        cell.model = model;
        if (indexPath.row==0) {
            cell.textField.text = self.aginStr;
        }else{
            cell.textField.text = self.bbinStr;
        }
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%zd", indexPath.item);
    if (indexPath.row == 0) {
        BTTBindingMobileOneCell *cell = (BTTBindingMobileOneCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [BRStringPickerView showStringPickerWithTitle:@"请选择金额" dataSource:self.agin defaultSelValue:cell.textField.text resultBlock:^(id selectValue, NSInteger index) {
            cell.textField.text = selectValue;
            self.aginStr = selectValue;
            if (self.aginStr.length && self.bbinStr.length) {
                [[NSNotificationCenter defaultCenter] postNotificationName:BTTPublicBtnEnableNotification object:@"BetLimit"];
            }
        }];
    } else if (indexPath.row == 1) {
        BTTBindingMobileOneCell *cell = (BTTBindingMobileOneCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [BRStringPickerView showStringPickerWithTitle:@"请选择金额" dataSource:self.bbin defaultSelValue:cell.textField.text resultBlock:^(id selectValue, NSInteger index) {
            cell.textField.text = selectValue;
            self.bbinStr = selectValue;
            if (self.aginStr.length && self.bbinStr.length) {
                [[NSNotificationCenter defaultCenter] postNotificationName:BTTPublicBtnEnableNotification object:@"BetLimit"];
            }
        }];
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
    return UIEdgeInsetsMake(15, 0, 40, 0);
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
    NSMutableArray *elementsHight = [NSMutableArray array];
    NSInteger cellCount = 3;
    for (int i = 0; i < cellCount; i ++) {
        if (i == cellCount - 1) {
            [elementsHight addObject:[NSValue valueWithCGSize:CGSizeMake(SCREEN_WIDTH, 100)]];
        } else {
            [elementsHight addObject:[NSValue valueWithCGSize:CGSizeMake(SCREEN_WIDTH, 44)]];
        }
    }
    self.elementsHight = elementsHight.mutableCopy;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (NSMutableArray *)sheetDatas {
    if (!_sheetDatas) {
        _sheetDatas = [NSMutableArray array];
//        NSArray *titles = @[@"AG国际厅",@"波音厅"];
        NSArray *titles = @[@"国际厅",@"波音厅"];
        NSArray *placeholders = @[@"请选择金额",@"请选择金额"];
        for (NSString *title in titles) {
            NSInteger index = [titles indexOfObject:title];
            BTTMeMainModel *model = [[BTTMeMainModel alloc] init];
            model.name = title;
            model.iconName = placeholders[index];
            [_sheetDatas addObject:model];
        }
    }
    return _sheetDatas;
}

@end
