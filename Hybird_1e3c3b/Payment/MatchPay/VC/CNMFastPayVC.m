//
//  CNMFastPayVC.m
//  Hybird_1e3c3b
//
//  Created by cean on 2/16/22.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "CNMFastPayVC.h"
#import "CNMFastPayStatusVC.h"
#import "KYMFastWithdrewVC.h"

#import "CNMatchPayRequest.h"

#import "BTTMeMainModel.h"

#import "CNMAmountSelectCCell.h"
#import "CNMAlertView.h"

#define kCNMAmountSelectCCell  @"CNMAmountSelectCCell"

@interface CNMFastPayVC () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *warningView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *warningViewH;
@property (weak, nonatomic) IBOutlet UILabel *warningLb;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewH;
/// 今日可以使用该通道
@property (weak, nonatomic) IBOutlet UILabel *allowUseCount;
/// 今日可以取消/超时次数
@property (weak, nonatomic) IBOutlet UILabel *allowCancelCount;

@property (weak, nonatomic) IBOutlet UIButton *depositBtn;

@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *recommendBtn;

/// 金额列表
@property (nonatomic, copy) NSArray *amountList;
/// 推荐金额列表
@property (nonatomic, copy) NSArray *recommendAmountList;
/// 推荐金额
@property (nonatomic, copy) NSString *recommendAmount;
/// 选中金额
@property (nonatomic, copy) NSString *selectAmount;
@end

@implementation CNMFastPayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showTradeBill];
    });
}

- (void)showTradeBill {
    __weak typeof(self) weakSelf = self;
    if (self.paymentModel.mmProcessingOrderTransactionId.length > 0) {
        if (self.paymentModel.mmProcessingOrderType == 1) { // 存款
            [CNMAlertView showAlertTitle:@"交易提醒" content:@"老板！您当前有正在交易的存款订单" desc:nil needRigthTopClose:NO commitTitle:@"关闭" commitAction:^{
                [weakSelf removeFastPay];
            } cancelTitle:@"查看订单" cancelAction:^{
                CNMFastPayStatusVC *statusVC = [[CNMFastPayStatusVC alloc] init];
                statusVC.cancelTime = [weakSelf.paymentModel.remainCancelDepositTimes integerValue];
                statusVC.transactionId = weakSelf.paymentModel.mmProcessingOrderTransactionId;
                [weakSelf pushViewController:statusVC];
            }];
        } else { // 取款
            [CNMAlertView showAlertTitle:@"交易提醒" content:@"老板！您当前有正在交易的取款订单" desc:nil needRigthTopClose:NO commitTitle:@"关闭" commitAction:^{
                [weakSelf removeFastPay];
            } cancelTitle:@"查看订单" cancelAction:^{
                KYMFastWithdrewVC *withdrewVC = [[KYMFastWithdrewVC alloc] init];
                withdrewVC.mmProcessingOrderTransactionId = weakSelf.paymentModel.mmProcessingOrderTransactionId;
                [weakSelf pushViewController:withdrewVC];
            }];
        }
    }
}
    
- (void)setupUI {
    self.buttonView.hidden = YES;
    self.continueBtn.layer.borderWidth = 1;
    self.continueBtn.layer.borderColor = kHexColor(0xF7F952).CGColor;
    self.continueBtn.layer.cornerRadius = 8;
    self.depositBtn.enabled = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:kCNMAmountSelectCCell bundle:nil] forCellWithReuseIdentifier:kCNMAmountSelectCCell];
    
    // 数据设置
    self.allowUseCount.text = self.paymentModel.remainDepositTimes;
    self.allowCancelCount.text = self.paymentModel.remainCancelDepositTimes;
    
    self.amountList = [self.paymentModel.amountList sortedArrayUsingComparator:^NSComparisonResult(CNWAmountListModel * obj1, CNWAmountListModel * obj2) {
        if (obj1.amount.floatValue < obj2.amount.floatValue) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    NSMutableArray *temArr = [NSMutableArray array];
    for (CNWAmountListModel *model in self.amountList) {
        if (model.isRecommend) {
            [temArr addObject:model.amount];
        }
    }
    self.recommendAmountList = temArr.copy;
    self.collectionViewH.constant = 80 * ceilf(self.amountList.count/3.0);
    [self setViewHeight:(450 + self.collectionViewH.constant) fullScreen:NO];
}

- (IBAction)depositAction:(UIButton *)sender {
    //提交订单
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [CNMatchPayRequest createDepisit:self.selectAmount finish:^(id  _Nullable response, NSError * _Nullable error) {
        [weakSelf hideLoading];
        if (error) {
            IVJResponseObject *result = response;
            [weakSelf showError:result.head.errMsg];
            return;
        }
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)response;
            if ([[dic objectForKey:@"mmFlag"] boolValue]) {
                NSError *err;
                CNMBankModel *bank = [[CNMBankModel alloc] initWithDictionary:[dic objectForKey:@"mmPaymentRsp"] error:&err];
                if (!err) {
                    // 成功跳转
                    CNMFastPayStatusVC *statusVC = [[CNMFastPayStatusVC alloc] init];
                    statusVC.cancelTime = [weakSelf.paymentModel.remainCancelDepositTimes integerValue];
                    statusVC.transactionId = bank.transactionId;
                    [weakSelf pushViewController:statusVC];
                    return;
                }
            }
        }
        // 失败走普通存款
        [CNMAlertView show3SecondAlertTitle:@"急速转卡系统繁忙" content:@"系统默认转为普通支付通道处理" interval:3 commitAction:^{
            [weakSelf removeFastPay];
        }];
    }];
}

- (IBAction)recommendAction:(UIButton *)sender {
    self.selectAmount = self.recommendAmount;
    [self depositAction:self.depositBtn];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.amountList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CNMAmountSelectCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCNMAmountSelectCCell forIndexPath:indexPath];
    CNWAmountListModel *model = self.amountList[indexPath.row];
    cell.amountLb.text = model.amount;
    cell.recommendTag.hidden = !model.isRecommend;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.bounds.size.width-20)/3.0, 70);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CNWAmountListModel *model = self.amountList[indexPath.row];
    self.selectAmount = model.amount;
    // 判断是否推荐
    if (self.recommendAmountList.count == 0 || model.isRecommend) {
        self.buttonView.hidden = YES;
        self.depositBtn.enabled = YES;
        self.depositBtn.hidden = NO;
        self.warningView.hidden = YES;
        self.warningViewH.constant = 0;
    } else {
        self.buttonView.hidden = NO;
        self.depositBtn.hidden = YES;
        self.warningView.hidden = NO;
        self.warningViewH.constant = 40;
        
        // 计算合理推荐金额
        self.recommendAmount = [self getRecommendAmountFromAmount:self.selectAmount];
        [self.continueBtn setTitle:[NSString stringWithFormat:@"继续存%@元", self.selectAmount] forState:UIControlStateNormal];
        [self.recommendBtn setTitle:[NSString stringWithFormat:@"存%@元", self.recommendAmount] forState:UIControlStateNormal];
        self.warningLb.text = [NSString stringWithFormat:@"存款 %@ 的用户过多，为了确保存款快速到账，推荐您选择 %@ 元存款金额。", self.selectAmount, self.recommendAmount];
    }
}

/// 计算合理推荐金额
- (NSString *)getRecommendAmountFromAmount:(NSString *)amount {
    if (self.recommendAmountList.count == 0 || [self.recommendAmountList containsObject:amount]) {
        return amount;
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.recommendAmountList];
    [array addObject:amount];
    
    NSArray *sortArr = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        if (obj1.intValue > obj2.intValue) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    NSInteger index = [sortArr indexOfObject:amount];
    if (index == (sortArr.count-1)) {
        return sortArr[index-1];
    } else {
        return sortArr[index+1];
    }
}
@end
