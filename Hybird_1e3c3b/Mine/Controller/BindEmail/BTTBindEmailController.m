//
//  BTTBindEmailController.m
//  Hybird_1e3c3b
//
//  Created by Domino on 25/10/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTBindEmailController.h"
#import "BTTBindEmailController+LoadData.h"
#import "BTTMeMainModel.h"
#import "BTTBindingMobileBtnCell.h"
#import "BTTBindingMobileOneCell.h"
#import "BTTBindingMobileTwoCell.h"
#import "BTTChangeMobileSuccessController.h"
#import "IVRsaEncryptWrapper.h"
#import "IVOtherInfoModel.h"
@interface BTTBindEmailController ()<BTTElementsFlowLayoutDelegate>
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *validateId;
@end

@implementation BTTBindEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    switch (self.codeType) {
        case BTTSafeVerifyTypeBindEmail:
            self.title = @"绑定邮箱";
            break;
        case BTTSafeVerifyTypeVerifyEmail:
        case BTTSafeVerifyTypeChangeEmail:
            self.title = @"修改邮箱地址";
            break;
        default:
            self.title = @"绑定邮箱";
            break;
    }
    [self setupCollectionView];
    [self loadMainData];
}

- (void)setupCollectionView {
    [super setupCollectionView];
    self.collectionView.backgroundColor = [UIColor colorWithHexString:@"212229"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTBindingMobileBtnCell" bundle:nil] forCellWithReuseIdentifier:@"BTTBindingMobileBtnCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTBindingMobileOneCell" bundle:nil] forCellWithReuseIdentifier:@"BTTBindingMobileOneCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BTTBindingMobileTwoCell" bundle:nil] forCellWithReuseIdentifier:@"BTTBindingMobileTwoCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.elementsHight.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    weakSelf(weakSelf)
    if (indexPath.row == self.sheetDatas.count) {
        BTTBindingMobileBtnCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTBindingMobileBtnCell" forIndexPath:indexPath];
        cell.buttonClickBlock = ^(UIButton * _Nonnull button) {
            [weakSelf submitBind];
        };
        return cell;
    } else {
        if (indexPath.row == 0) {
            BTTBindingMobileOneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTBindingMobileOneCell" forIndexPath:indexPath];
            [cell.textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            [cell.textField addTarget:self action:@selector(textBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
            BTTMeMainModel *model = self.sheetDatas[indexPath.row];
            cell.model = model;
            return cell;
        } else {
            BTTBindingMobileTwoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTTBindingMobileTwoCell" forIndexPath:indexPath];
            [cell.textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            BTTMeMainModel *model = self.sheetDatas[indexPath.row];
            cell.model = model;
            cell.mineSparaterType = BTTMineSparaterTypeNone;
            BOOL isUseRegEmail = ([IVNetwork savedUserInfo].emailBind==0 && [IVNetwork savedUserInfo].email.length != 0);
            if (self.codeType == BTTSafeVerifyTypeChangeEmail) {
                cell.sendBtn.enabled = NO;
            } else {
                cell.sendBtn.enabled = isUseRegEmail || [IVNetwork savedUserInfo].emailBind==1;
            }
            cell.buttonClickBlock = ^(UIButton * _Nonnull button) {
                [weakSelf sendCode];
            };
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%zd", indexPath.item);
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
- (void)textBeginEditing:(UITextField *)textField
{
    if (textField == [self getMailTF]) {
        if ([IVNetwork savedUserInfo].emailBind==0 && [IVNetwork savedUserInfo].email.length != 0) {
            textField.text = @"";
            [self getSendBtn].enabled = NO;
            [self getSubmitBtn].enabled = NO;
        }
    }
}
- (void)textChanged:(UITextField *)textField
{
    if (textField == [self getMailTF]) {
        [self getSendBtn].enabled = [PublicMethod isValidateEmail:[self getMailTF].text];
    }
    if ([self getCodeTF].text.length == 0) {
        [self getSubmitBtn].enabled = NO;
    } else {
        if ([IVNetwork savedUserInfo].emailBind==1) {
            [self getSubmitBtn].enabled = YES;
        } else {
            if ([[self getMailTF].text isEqualToString:[IVNetwork savedUserInfo].email]) {
                [self getSubmitBtn].enabled = YES;
            } else {
                [self getSubmitBtn].enabled = [PublicMethod isValidateEmail:[self getMailTF].text];
            }
        }
    }
}
- (UITextField *)getMailTF
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    BTTBindingMobileOneCell *cell = (BTTBindingMobileOneCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.textField;
}
- (UITextField *)getCodeTF
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    BTTBindingMobileTwoCell *cell = (BTTBindingMobileTwoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.textField;
}
- (UIButton *)getSubmitBtn
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    BTTBindingMobileBtnCell *cell = (BTTBindingMobileBtnCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.btn;
}
- (UIButton *)getSendBtn
{
    return [self getVerifyCell].sendBtn;
}
- (BTTBindingMobileTwoCell *)getVerifyCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    BTTBindingMobileTwoCell *cell = (BTTBindingMobileTwoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}
- (void)sendCode
{
    NSString *url = @"";
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"use"] = @"12";
    
    params[@"loginName"] = [IVNetwork savedUserInfo].loginName;
    params[@"validateId"] = self.validateId;
    switch (self.codeType) {
        case BTTSafeVerifyTypeBindEmail:
            params[@"use"] = @"12";
            params[@"email"] = [IVRsaEncryptWrapper encryptorString:[self getMailTF].text];
            url = BTTEmailSendCode;
            break;
        case BTTSafeVerifyTypeVerifyEmail:
            params[@"use"] = @"13";
            url = BTTEmailSendCodeLoginName;
            break;
        case BTTSafeVerifyTypeChangeEmail:
            params[@"use"] = @"13";
            url = BTTEmailSendCode;
            params[@"email"] = [IVRsaEncryptWrapper encryptorString:[self getMailTF].text];
            break;
        default:
            params[@"use"] = @"12";
            break;
    }
    /// 加上 agentID判斷
    IVOtherInfoModel *infoModel = [[IVOtherInfoModel alloc] init];
    if (infoModel.agentId.length != 0) {
        [IVHttpManager shareManager].parentId = infoModel.agentId;  // 渠道号
    }
    weakSelf(weakSelf)
    [MBProgressHUD showLoadingSingleInView:self.view animated:YES];
    [IVNetwork requestPostWithUrl:url paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            [[weakSelf getVerifyCell] countDown];
            weakSelf.messageId = result.body[@"messageId"];
            [MBProgressHUD showSuccess:@"验证码已发送，请注意查收" toView:nil];
        }else{
            [MBProgressHUD showError:result.head.errMsg toView:weakSelf.view];
        }
    }];
}
- (void)submitBind
{
    NSString *url = @"";
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"use"] = @"12";
    params[@"email"] = [self getMailTF].text;
    params[@"emailCode"] = [self getCodeTF].text;
    params[@"messageId"] = self.messageId;
    params[@"validateId"] = @"";
    params[@"loginName"] = [IVNetwork savedUserInfo].loginName;
    switch (self.codeType) {
        case BTTSafeVerifyTypeBindEmail:
            params[@"use"] = @"12";
            url = BTTEmailCodeVerify;
            break;
        case BTTSafeVerifyTypeVerifyEmail:
        case BTTSafeVerifyTypeChangeEmail:
            params[@"use"] = @"13";
            url = BTTEmailCodeVerify;
            break;
        default:
            params[@"use"] = @"9";
            break;
    }
    weakSelf(weakSelf)
    [MBProgressHUD showLoadingSingleInView:self.view animated:YES];
    [IVNetwork requestPostWithUrl:url paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            self.validateId = result.body[@"validateId"];
            switch (self.codeType) {
                case BTTSafeVerifyTypeBindEmail:
                    [self bindEmailWithValidateId:self.validateId type:12];
                    break;
                case BTTSafeVerifyTypeVerifyEmail:{
                    BTTBindEmailController *vc = [BTTBindEmailController new];
                    vc.codeType = BTTSafeVerifyTypeChangeEmail;
                    vc.validateId = self.validateId;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                    
                }
                    break;
                case BTTSafeVerifyTypeChangeEmail:
                    [self bindEmailWithValidateId:self.validateId type:13];
                    break;
                default:
                    break;
            }
        }else{
            [MBProgressHUD showError:result.head.errMsg toView:weakSelf.view];
        }
    }];

}

- (void)bindEmailWithValidateId:(NSString *)validateId type:(NSInteger)type{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSString *url = type==12?BTTEmailBind:BTTEmailBindUpdate;
    params[@"use"] = type==12? @"12" : @"13";
    params[@"email"] = [self getMailTF].text;
    params[@"emailCode"] = [self getCodeTF].text;
    params[@"messageId"] = self.messageId;
    params[@"validateId"] = validateId;
    params[@"loginName"] = [IVNetwork savedUserInfo].loginName;
    weakSelf(weakSelf)
    [MBProgressHUD showLoadingSingleInView:self.view animated:YES];
    [IVNetwork requestPostWithUrl:url paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            [MBProgressHUD showSuccess:@"绑定成功" toView:nil];
            BTTChangeMobileSuccessController *vc = [BTTChangeMobileSuccessController new];
            vc.mobileCodeType = self.codeType;
            vc.email = [self getMailTF].text;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:result.head.errMsg toView:weakSelf.view];
        }
    }];
}

@end
