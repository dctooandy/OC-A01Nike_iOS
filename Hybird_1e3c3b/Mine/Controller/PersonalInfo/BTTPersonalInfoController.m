//
//  BTTPersonalInfoController.m
//  Hybird_1e3c3b
//
//  Created by Domino on 22/10/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTPersonalInfoController.h"
#import "BTTPersonalInfoController+LoadData.h"
#import "BTTBindingMobileOneCell.h"
#import "BTTPublicBtnCell.h"
#import "BRPickerView.h"
#import "BTTBindEmailController.h"

@interface BTTPersonalInfoController ()<BTTElementsFlowLayoutDelegate>

@end

@implementation BTTPersonalInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人资料";
    [self setupCollectionView];
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
        cell.btnType = BTTPublicBtnTypeSave;
        cell.btn.enabled = YES;
        weakSelf(weakSelf)
        cell.buttonClickBlock = ^(UIButton * _Nonnull button) {
            [weakSelf submitChange];
        };
        return cell;
    } else {
        BTTBindingMobileOneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTBindingMobileOneCell" forIndexPath:indexPath];
        cell.model = self.sheetDatas[indexPath.row];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%zd", indexPath.item);
    [self.view endEditing:true];
    if (indexPath.item == 1) {
        BTTBindingMobileOneCell *cell = (BTTBindingMobileOneCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [BRStringPickerView showStringPickerWithTitle:@"请选择性别" dataSource:@[@"男", @"女"] defaultSelValue:cell.textField.text resultBlock:^(id selectValue, NSInteger index) {
            cell.textField.text = selectValue;
        }];
    } else if (indexPath.item == 2) {
        if ([IVNetwork savedUserInfo].birthday.length>0) {
            return;
        }
        BTTBindingMobileOneCell *cell = (BTTBindingMobileOneCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSDate *minDate = [NSDate br_setYear:1900 month:1 day:1];
        NSDate *maxDate = [NSDate date];
        [BRDatePickerView showDatePickerWithTitle:@"出生日期" dateType:BRDatePickerModeYMD defaultSelValue:cell.textField.text minDate:minDate maxDate:maxDate isAutoSelect:YES themeColor:nil resultBlock:^(NSString *selectValue) {
            cell.textField.text = selectValue;
        } cancelBlock:^{
            NSLog(@"点击了背景或取消按钮");
        }];
    }else if (indexPath.item == 3) {
        if ([IVNetwork savedUserInfo].email.length>0) {
            return;
        }
        BTTBindEmailController *bindVC = [[BTTBindEmailController alloc] init];
        bindVC.codeType = BTTSafeVerifyTypeBindEmail;
        [self.navigationController pushViewController:bindVC animated:YES];
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
    if (self.elementsHight.count) {
        [self.elementsHight removeAllObjects];
    }
    NSInteger total = self.sheetDatas.count + 1;
    NSMutableArray *elementsHight = [NSMutableArray array];
    for (int i = 0; i < total; i++) {
        if (i == self.sheetDatas.count) {
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
- (void)submitChange
{
//    UITextField *retentionTF = [self getCellTextFieldWithIndex:0];
    UITextField *realNameTF = [self getCellTextFieldWithIndex:0];
    UITextField *sexTF = [self getCellTextFieldWithIndex:1];
    UITextField *birthdayTF = [self getCellTextFieldWithIndex:2];
    UITextField *emailTF = [self getCellTextFieldWithIndex:3];
    UITextField *addressTF = [self getCellTextFieldWithIndex:4];
    UITextField *remarkTF = [self getCellTextFieldWithIndex:5];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    if ([IVNetwork savedUserInfo].realName.length == 0) {
        if (![PublicMethod checkRealName:realNameTF.text]) {
            [MBProgressHUD showError:@"输入的真实姓名格式有误！" toView:self.view];
            return;
        } else {
            params[@"realName"] = realNameTF.text;
        }
    }
    if ([IVNetwork savedUserInfo].email.length == 0) {
        if (emailTF.text.length !=0 && ![PublicMethod isValidateEmail:emailTF.text]) {
            [MBProgressHUD showError:@"输入的邮箱地址格式有误！" toView:self.view];
            return;
        }
        params[@"email"] = emailTF.text;
    }
    if (sexTF.text.length != 0) {
        params[@"gender"] = [sexTF.text isEqualToString:@"男"] ? @"M" : @"F";
    }
    if ([IVNetwork savedUserInfo].birthday.length == 0) {
        if (birthdayTF.text.length != 0) {
            NSString *birthdayStr = birthdayTF.text;
            BOOL isAdult = [PublicMethod isAdultWithBirthday:birthdayStr];
            if (!isAdult) {
                [MBProgressHUD showError:@"您的年龄未满十八岁" toView:self.view];
                return;
            }
            params[@"birth"] = birthdayStr;
        }
    }
    params[@"address"] = addressTF.text ? addressTF.text : @"";
    params[@"remark"] = remarkTF.text ? remarkTF.text : @"";
    weakSelf(weakSelf)
    [MBProgressHUD showLoadingSingleInView:self.view animated:YES];
    [IVNetwork requestPostWithUrl:BTTModifyCustomerInfo paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            [MBProgressHUD showSuccess:@"完善资料成功!" toView:nil];
            [BTTHttpManager fetchUserInfoCompleteBlock:nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:result.head.errMsg toView:weakSelf.view];
        }
    }];
}
- (UITextField *)getCellTextFieldWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    BTTBindingMobileOneCell *cell = (BTTBindingMobileOneCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.textField;
}
@end
