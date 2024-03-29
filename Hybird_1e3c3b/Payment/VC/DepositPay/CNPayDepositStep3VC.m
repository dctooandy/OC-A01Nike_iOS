//
//  CNPayDepositStep3VC.m
//  A05_iPhone
//
//  Created by cean.q on 2018/10/1.
//  Copyright © 2018年 WRD. All rights reserved.
//

#import "CNPayDepositStep3VC.h"
#import "CNPayDepositSuccessVC.h"

@interface CNPayDepositStep3VC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *preSettingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *preSettingViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *preSettingMessageLb;
@property (weak, nonatomic) IBOutlet UITextField *payTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *provinceTF;
@property (weak, nonatomic) IBOutlet UITextField *cityTF;
@property (weak, nonatomic) IBOutlet UILabel *depositByLb;
@property (weak, nonatomic) IBOutlet UITextField *dateTF;
@property (weak, nonatomic) IBOutlet UIButton *amountBtn;
@property (weak, nonatomic) IBOutlet UITextField *amountTF;
@property (weak, nonatomic) IBOutlet UITextField *chargeTF;
@property (weak, nonatomic) IBOutlet UITextField *remarkTF;
@property (nonatomic, strong) NSArray *amountList;
@property (nonatomic, assign) double maxAmount;
@property (nonatomic, assign) double minAmount;
@end

@implementation CNPayDepositStep3VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configPreSettingMessage];
    [self queryAmountList];
}

- (void)queryAmountList{
    [self showLoading];
    weakSelf(weakSelf)
    NSDictionary *params = @{@"payType":@(self.paymentModel.payType),@"loginName":[IVNetwork savedUserInfo].loginName};
    [IVNetwork requestPostWithUrl:BTTQueryAmountList paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        [self hideLoading];
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (result.body[@"amounts"]!=nil) {
                self.amountList = result.body[@"amounts"];
                NSString *maxAmount = result.body[@"maxAmount"];
                NSString *minAmount = result.body[@"minAmount"];
                weakSelf.maxAmount = [maxAmount doubleValue];
                weakSelf.minAmount = [minAmount doubleValue];
                [self configAmountList];
                [self configUI];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addBankView];
    [self setViewHeight:550 fullScreen:NO];
    [self configAmountList];
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

- (void)configUI {
    self.preSettingMessageLb.text = self.preSaveMsg;
    self.depositByLb.text = self.writeModel.depositBy;
    // 金额提示语
    if (self.maxAmount > self.minAmount) {
        self.amountTF.placeholder = [NSString stringWithFormat:@"最少%.0f，最多%.0f", self.minAmount, self.maxAmount];
    } else {
        self.amountTF.placeholder = [NSString stringWithFormat:@"最少%.0f", self.minAmount];
    }
}


- (void)configAmountList {
    self.amountBtn.hidden = self.amountList.count>0;
    if (self.amountList.count>0) {
        self.amountTF.placeholder = @"仅可选择以下金额";
    }
}



- (IBAction)selectPayType:(id)sender {
    [self.view endEditing:YES];
    NSArray *payTypeArr = @[@"ATM现金存款",@"跨行ATM现金存款",@"柜台转账",@"微信转账",@"网银转账",@"跨行网银转账",@"电话转账",@"手机转账",@"跨行手机转账",@"支付宝转账",@"其他方式"];
    weakSelf(weakSelf);
    [BRStringPickerView showStringPickerWithTitle:_payTypeTF.placeholder dataSource:payTypeArr defaultSelValue:_payTypeTF.text resultBlock:^(id selectValue, NSInteger index) {
        weakSelf.payTypeTF.text = selectValue;
    }];
}

// 选择省市
- (IBAction)selectProvince:(id)sender {
    [self.view endEditing:YES];
    weakSelf(weakSelf);
    // 默认选择的省市
    NSArray *defaultSelect = @[_provinceTF.text, _cityTF.text];
    [BRAddressPickerView showAddressPickerWithShowType:BRAddressPickerModeCity dataSource:nil defaultSelected:defaultSelect isAutoSelect:YES themeColor:nil resultBlock:^(BRProvinceModel *province, BRCityModel *city, BRAreaModel *area) {
        weakSelf.provinceTF.text = province.name;
        weakSelf.cityTF.text = city.name;
    } cancelBlock:^{
        
    }];
}

// 选择日期
- (IBAction)selectDate:(id)sender {
    [self.view endEditing:YES];
    
    weakSelf(weakSelf);
    NSDate *minDate = [NSDate br_setYear:2018 month:01 day:01 hour:0 minute:0];
    NSDate *maxDate = [NSDate br_setYear:2030 month:12 day:31 hour:23 minute:59];
    
    [BRDatePickerView showDatePickerWithTitle:_dateTF.placeholder dateType:BRDatePickerModeYMDHM defaultSelValue:nil minDate:minDate maxDate:maxDate isAutoSelect:YES themeColor:nil resultBlock:^(NSString *selectValue) {
        weakSelf.dateTF.text = selectValue;
    } cancelBlock:^{
        
    }];
}

- (IBAction)selectAmountList:(id)sender {
    weakSelf(weakSelf);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.amountList.count];
    for (id obj in self.amountList) {
        [array addObject:[NSString stringWithFormat:@"%@", obj]];
    }
    if (array.count == 0) {
        [self showError:@"无可选金额，请直接输入"];
        self.amountBtn.hidden = YES;
        return;
    }
    [BRStringPickerView showStringPickerWithTitle:@"选择充值金额" dataSource:array defaultSelValue:self.amountTF.text resultBlock:^(id selectValue, NSInteger index) {
        if ([weakSelf.amountTF.text isEqualToString:selectValue]) {
            return;
        }
        weakSelf.amountTF.text = selectValue;
    }];
}

- (IBAction)submitAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_payTypeTF.text.length == 0) {
        [self showError:_payTypeTF.placeholder];
        return;
    }
    if (_provinceTF.text.length == 0) {
        [self showError:_provinceTF.placeholder];
        return;
    }
    if (_cityTF.text.length == 0) {
        [self showError:_cityTF.placeholder];
        return;
    }
    if (_dateTF.text.length == 0) {
        [self showError:_dateTF.placeholder];
        return;
    }
    
    NSString *text = _amountTF.text;
    
    /// 输入为不合法数字
    if (![NSString isPureInt:text] && ![NSString isPureFloat:text]) {
        _amountTF.text = nil;
        [self showError:@"请输入充值金额"];
        return;
    }
    
    /// 超出额度范围
    NSNumber *amount = [NSString convertNumber:text];
    double maxAmount = self.maxAmount > self.minAmount ? self.maxAmount : CGFLOAT_MAX;
    if ([amount doubleValue] > maxAmount || [amount doubleValue] < self.minAmount) {
        _amountTF.text = nil;
        [self showError:_amountTF.placeholder];
        return;
    }
    
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    
    [self showLoading];
    NSString *remarkStr = @"";
    if ([self.chargeTF.text isEqualToString:@""]) {
        remarkStr = self.remarkTF.text;
    }else{
        if (self.remarkTF.text.length==0) {
            remarkStr = [NSString stringWithFormat:@"手续费:%@",self.chargeTF.text];
        }else{
            remarkStr = [NSString stringWithFormat:@"手续费:%@|%@",self.chargeTF.text,self.remarkTF.text];
        }
    }
    weakSelf(weakSelf)
    NSDictionary *params = @{
        @"accountId" : self.writeModel.chooseBank.accountId,
        @"depositor" : self.writeModel.depositBy,
        @"depositDate" : [PublicMethod getCurrentTimesWithFormat:@"yyyy-MM-dd hh:mm:ss"],
        @"depositType" : self.payTypeTF.text,
        @"depositLocation" : [NSString stringWithFormat:@"%@,%@",self.provinceTF.text,self.cityTF.text],
        @"amount" : self.amountTF.text,
        @"remark" : remarkStr,
        @"depositorType" : @(self.paymentModel.payType),
        @"loginName" : [IVNetwork savedUserInfo].loginName
    };
    [IVNetwork requestPostWithUrl:BTTManualPay paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        [self hideLoading];
        IVJResponseObject *result = response;
        sender.selected = NO;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            [weakSelf paySucessHandler:result.body];
        } else {
            // 后台返回类型不一，全部转成字符串
            [weakSelf showError:[NSString stringWithFormat:@"%@", result.head.errMsg]];
        }
    }];
}

- (void)paySucessHandler:(NSDictionary *)dic {
    
    NSError *error;
    CNPayOrderModel *orderModel = [[CNPayOrderModel alloc] initWithDictionary:dic error:&error];
    if (error && !orderModel) {
        [self showError:@"操作失败！请联系客户，或者稍后重试!"];
        return;
    }
    CNPayDepositSuccessVC *successVC = [[CNPayDepositSuccessVC alloc] initWithAmount:self.amountTF.text];
    [self pushViewController:successVC];
}
@end
