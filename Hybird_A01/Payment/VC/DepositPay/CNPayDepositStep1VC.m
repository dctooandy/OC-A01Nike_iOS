//
//  CNPayDepositStep1VC.m
//  A05_iPhone
//
//  Created by cean.q on 2018/10/1.
//  Copyright © 2018年 WRD. All rights reserved.
//

#import "CNPayDepositStep1VC.h"


@interface CNPayDepositStep1VC ()

@property (weak, nonatomic) IBOutlet UIView *preSettingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *preSettingViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *preSettingMessageLb;


@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *selectNameBtn;


@property (weak, nonatomic) IBOutlet UIView *otherNameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherNameViewHeight;
@property (weak, nonatomic) IBOutlet UITextField *otherNameTF;


@property (weak, nonatomic) IBOutlet CNPayAmountTF *amountTF;


@property (weak, nonatomic) IBOutlet CNPayAmountRecommendView *recommendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reconmendViewHeight;


@property (weak, nonatomic) IBOutlet UITextField *bankTF;


@property (weak, nonatomic) IBOutlet UIView *payTypeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payTypeViewHeight;
@property (weak, nonatomic) IBOutlet UITextField *payTypeTF;


@property (weak, nonatomic) IBOutlet UIView *firstTipView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstTipViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *secondTipLb;

@property (nonatomic, assign) BOOL isDeposit;
@property (nonatomic, copy) NSArray<NSDictionary *> *depositNames;
@property (nonatomic, assign) BOOL isOtherName;
@property (nonatomic, copy) NSString *referenceId;

@property (nonatomic, copy) NSArray<CNPayBankCardModel *> *bankList;
@property (nonatomic, strong) CNPayBankCardModel *chooseBank;
@property (nonatomic, assign) NSInteger payBQType;
@end

@implementation CNPayDepositStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isDeposit = (self.paymentModel.paymentType == CNPaymentDeposit);
    // 默认是只能输入的
    self.otherNameView.hidden = YES;
    self.otherNameViewHeight.constant = 0;
    self.nameTF.userInteractionEnabled = YES;
    self.selectNameBtn.hidden = YES;
    
    
    [self getManualDeposit];
    [self configPreSettingMessage];
    [self configRecommendView];
    
    // 手工存款和BQ存款
    [self configDifferentUI];
    
    /// 输入金额变化处理
    __weak typeof(self) weakSelf = self;
    self.amountTF.editingChanged = ^(NSString *text, BOOL isEmpty) {
        [weakSelf.recommendView cleanSelectedState];
    };
    
    // 金额提示语
    if (self.paymentModel.maxamount > self.paymentModel.minamount) {
        self.amountTF.placeholder = [NSString stringWithFormat:@"最少%.0f，最多%.0f", self.paymentModel.minamount, self.paymentModel.maxamount];
    } else {
        self.amountTF.placeholder = [NSString stringWithFormat:@"最少%.0f", self.paymentModel.minamount];
    }
    
    [self setViewHeight:(700 + self.reconmendViewHeight.constant) fullScreen:NO];
}

// 获取历史存款人姓名
- (void)getManualDeposit {
    __weak typeof(self) weakSelf = self;
    [CNPayRequestManager paymentGetDepositNameWithType:self.isDeposit CompleteHandler:^(IVRequestResultModel *result, id response) {
        if (result.status) {
            [weakSelf configNameView:result.data];
        }
    }];
}

- (void)configNameView:(NSArray *)data {
    self.depositNames = data;
    if (self.depositNames.count == 0) {
        self.nameTF.userInteractionEnabled = YES;
        self.selectNameBtn.hidden = YES;
    } else {
        self.nameTF.userInteractionEnabled = NO;
        self.selectNameBtn.hidden = NO;
    }
}

- (void)configPreSettingMessage {
    if (self.preSaveMsg.length > 0) {
        self.preSettingMessageLb.text = self.preSaveMsg;
        self.preSettingViewHeight.constant = 50;
        self.preSettingView.hidden = NO;
    } else {
        self.preSettingViewHeight.constant = 0;
        self.preSettingView.hidden = YES;
    }
}

/// 付款推荐金额
- (void)configRecommendView {
    NSArray *array = [self recommendAmountAccordingMinAmount:self.paymentModel.minamount max:self.paymentModel.maxamount];
    _recommendView.dataSource = array;
    // 根据数组个数与屏幕宽度来调节高度
    CGFloat height = ((array.count - 1)/3 + 1) * 200 * 100 / ([UIScreen mainScreen].bounds.size.width * 1.0);
    self.reconmendViewHeight.constant = height + 30;
    
    __weak typeof(self) weakSelf = self;
    _recommendView.clickHandler = ^(NSString *value, NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.amountTF.text = value;
    };
}

- (void)configDifferentUI {
    // 手工存款
    if (self.isDeposit) {
        self.payTypeView.hidden = YES;
        self.payTypeViewHeight.constant = 0;
        self.firstTipView.hidden = YES;
        self.firstTipViewHeight.constant = 0;
        self.secondTipLb.text = @"支持网银、手机银行、支付宝、ATM现金存款";
        return;
    }
    // BQ存款
    
}

// 选择名字
- (IBAction)selectName:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSMutableArray *names = [NSMutableArray array];
    for (NSDictionary *dic in self.depositNames) {
        // 服务器返回的数据格式不统一，不知道为什么转不可变不成功
        NSString *name = [dic objectForKey:@"deposit_by"];
        [names addObject:[name mutableCopy]];
    }
    NSString *otherName = @"其他姓名";
    [names addObject:otherName];
    
    
    __weak typeof(self) weakSelf = self;
    [BRStringPickerView showStringPickerWithTitle:@"选择存款人姓名" dataSource:names defaultSelValue:self.nameTF.text resultBlock:^(id selectValue) {
        // 切换存款人姓名了，需要清空，重新获取
        weakSelf.bankList = nil;
        weakSelf.chooseBank = nil;
        weakSelf.bankTF.text = nil;
        
        weakSelf.nameTF.text = selectValue;
        BOOL show = [selectValue isEqualToString:otherName];
        [weakSelf configOtherView:show];
//        weakSelf.referenceId = show ? nil: [weakSelf.depositNames[index] objectForKey:@"reference_id"];
    }];
}

- (void)configOtherView:(BOOL)show {
    self.isOtherName = show;
    self.otherNameView.hidden = !show;
    self.otherNameViewHeight.constant = show ? 60 : 0;
}

// 选择银行
- (IBAction)selectBank:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *name = self.isOtherName ? self.otherNameTF.text : self.nameTF.text;
    if (name.length == 0) {
        [self showError:@"请填写存款人姓名"];
        return;
    }
    if (self.bankList.count > 0) {
        [self showBankList];
        return;
    }
    
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    // 获取银行卡列表
    [CNPayRequestManager paymentGetBankListWithType:self.isDeposit depositor:name referenceId:_referenceId completeHandler:^(IVRequestResultModel *result, id response) {
        [self hideLoading];
        if (result.status) {
            /// 数据解析
            NSArray *array = [result.data objectForKey:@"bankList"];
            NSError *error;
            weakSelf.bankList = [CNPayBankCardModel arrayOfModelsFromDictionaries:array error:&error];
            [weakSelf showBankList];
        } else {
            [weakSelf showError:result.message];
        }
    }];
}

- (void)showBankList {
    NSMutableArray *bankNames = [NSMutableArray array];
    for (CNPayBankCardModel *model in self.bankList) {
        [bankNames addObject:model.bankname];
    }
    
    weakSelf(weakSelf);
    [BRStringPickerView showStringPickerWithTitle:@"选择存入的银行" dataSource:bankNames defaultSelValue:self.bankTF.text resultBlock:^(id selectValue) {
        weakSelf.bankTF.text = selectValue;
//        weakSelf.chooseBank = weakSelf.bankList[index];
    }];
}

// 仅BQ才会显示，不用判断
- (IBAction)selectPayType:(id)sender {
    [self.view endEditing:YES];
    NSArray *payTypeArr = [self.paymentModel payTypeArray];
    weakSelf(weakSelf);
    [BRStringPickerView showStringPickerWithTitle:_payTypeTF.placeholder dataSource:payTypeArr defaultSelValue:nil resultBlock:^(id selectValue) {
//        weakSelf.payTypeTF.text = payTypeArr[index];
//        weakSelf.payBQType = index;
    }];
}

// 提交
- (IBAction)sumbitAction:(UIButton *)sender {
    
    [self goToStep:1];
    return;
    
    [self.view endEditing:YES];
    NSString *text = _amountTF.text;
    
    /// 输入为不合法数字
    if (![NSString isPureInt:text] && ![NSString isPureFloat:text]) {
        _amountTF.text = nil;
        [self showError:@"请输入充值金额"];
        return;
    }
    
    /// 超出额度范围
    NSNumber *amount = [NSString convertNumber:text];
    double maxAmount = self.paymentModel.maxamount > self.paymentModel.minamount ? self.paymentModel.maxamount : CGFLOAT_MAX;
    if ([amount doubleValue] > maxAmount || [amount doubleValue] < self.paymentModel.minamount) {
        _amountTF.text = nil;
        [self showError:_amountTF.placeholder];
        return;
    }
    
    if (!self.chooseBank && self.bankTF.text.length == 0) {
        [self showError:@"请选择支付银行"];
        return;
    }
    
    // 手工支付类型
    if (self.isDeposit) {
        [self saveWriteModel];
        [self goToStep:1];
        return;
    }
        
    // 下面是BQ支付类型
    if (_payTypeTF.text.length == 0) {
        [self showError:@"请选择支付方式"];
        return;
    }
    // 提交订单
    [self sumbitBill:sender];
}

- (void)saveWriteModel {
    self.writeModel.chooseBank = self.chooseBank;
    self.writeModel.depositBy = self.isOtherName ? self.otherNameTF.text : self.nameTF.text;
    self.writeModel.amount = self.amountTF.text;
    self.writeModel.payId = self.paymentModel.payid;
    self.writeModel.referenceId = self.referenceId;
    
    // BQ的支付类型
    if (!self.isDeposit) {
        self.writeModel.depositType = self.payTypeTF.text;
        self.writeModel.BQType = (CNPayBQType)self.payBQType;
    }
}

- (void)sumbitBill:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    
    __weak typeof(self) weakSelf = self;
    [CNPayRequestManager paymentSubmitBill:self.writeModel completeHandler:^(IVRequestResultModel *result, id response) {
        sender.selected = NO;
        if (result.status) {
            CNPayBankCardModel *model = [[CNPayBankCardModel alloc] initWithDictionary:result.data error:nil];
            weakSelf.writeModel.chooseBank = model;
            [weakSelf goToStep:1];
        }
    }];
}

@end