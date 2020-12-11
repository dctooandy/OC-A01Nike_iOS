//
//  CNPayBQStep1VC.m
//  HybirdApp
//
//  Created by cean.q on 2018/10/23.
//  Copyright © 2018年 harden-imac. All rights reserved.
//

#import "CNPayBQStep1VC.h"
#import "CNPayNormalTF.h"
#import "BTTBishangStep1VC.h"

@interface CNPayBQStep1VC ()

@property (weak, nonatomic) IBOutlet UIView *preSettingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *preSettingViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *preSettingMessageLb;

@property (weak, nonatomic) IBOutlet CNPayAmountTF *amountTF;
@property (weak, nonatomic) IBOutlet UIButton *amountBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet CNPayNameTF *nameTF;
@property (weak, nonatomic) IBOutlet CNPayAmountRecommendView *nameView;
@property (weak, nonatomic) IBOutlet UIView *nameAreaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameAreaViewHeight;

@property (weak, nonatomic) IBOutlet CNPaySubmitButton *commitBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomTipView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTipViewHeight;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (nonatomic, strong) BTTBishangStep1VC *BSStep1VC;

@property (nonatomic, copy) NSArray *bankNames;
@property (nonatomic, strong) NSArray *amountList;
@property (nonatomic, strong) NSArray *bankList;
@property (nonatomic, assign) BOOL haveBankData;
@end

@implementation CNPayBQStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    _haveBankData = NO;
    self.amountBtn.hidden = YES;
    [self configPreSettingMessage];
    [self configDifferentUI];
    [self queryAmountList];
    // 初始化数据
    [self setViewHeight:450 fullScreen:NO];
    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(100);
    }];
    if (self.paymentModel.payType == 100) {
        [self configBishangUI];
        [self setViewHeight:400 fullScreen:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setViewHeight:450 fullScreen:NO];
    
}

- (void)configBishangUI {
    _BSStep1VC = [[BTTBishangStep1VC alloc] init];
    //    _BSStep1VC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1000);
    _BSStep1VC.paymentModel = self.paymentModel;
    [self addChildViewController:_BSStep1VC];
    [self.view addSubview:_BSStep1VC.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

- (void)queryAmountList{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:@(self.paymentModel.payType) forKey:@"payType"];
    [params setValue:[IVNetwork savedUserInfo].loginName forKey:@"loginName"];
    [IVNetwork requestPostWithUrl:BTTQueryAmountList paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (result.body[@"amounts"]!=nil) {
                self.amountList = result.body[@"amounts"];
                NSNumber * min = result.body[@"minAmount"];
                NSNumber * max = result.body[@"maxAmount"];
                self.amountTF.placeholder = [NSString stringWithFormat:@"最少%@，最多%@", min, max];
                [self configAmountList];
            }
        }else{
            self.amountTF.text = @"";
        }
    }];
}

- (void)configDifferentUI {
    switch (self.paymentModel.payType) {
        case 91:
        case 92:
            _nameLb.text = @"真实姓名";
            self.bottomTipView.hidden = YES;
            self.bottomTipViewHeight.constant = 0;
            break;
        default:
            break;
    }
}

- (void)configAmountList {
    //    self.amountBtn.hidden = self.paymentModel.amountCanEdit;
    //    if (!self.paymentModel.amountCanEdit) {
    //        self.amountTF.placeholder = @"仅可选择以下金额";
    //    }
}


- (IBAction)selectAmountList:(id)sender {
    weakSelf(weakSelf);
    [self.view endEditing:YES];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.amountList.count];
    for (id obj in self.amountList) {
        [array addObject:[[NSString stringWithFormat:@"%@", obj] mutableCopy]];
    }
    if (array.count == 0) {
        [self showError:@"无可选金额，请直接输入"];
        return;
    }
    NSString *addTip = @"其他金额请手动输入";
    [array addObject:[addTip mutableCopy]];
    [BRStringPickerView showStringPickerWithTitle:@"选择充值金额" dataSource:array defaultSelValue:self.amountTF.text resultBlock:^(id selectValue, NSInteger index) {
        if (index!=array.count-1) {
            if ([weakSelf.amountTF.text isEqualToString:selectValue]) {
                return;
            }
            weakSelf.amountTF.text = selectValue;
        }else{
            self.amountBtn.hidden = YES;
            self.amountTF.text = @"";
        }
        
    }];
}

- (IBAction)submitAction:(UIButton *)sender {
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
    double maxAmount = self.paymentModel.maxAmount > self.paymentModel.minAmount ? self.paymentModel.maxAmount : CGFLOAT_MAX;
    if ([amount doubleValue] > maxAmount || [amount doubleValue] < self.paymentModel.minAmount) {
        _amountTF.text = nil;
        [self showError:[NSString stringWithFormat:@"存款金额必须是%ld~%.f之间，最大允许2位小数", (long)self.paymentModel.minAmount, maxAmount]];
        return;
    }
    
    if (self.nameTF.text.length == 0) {
        [self showError:@"请输入存款人姓名"];
        return;
    }
    self.writeModel.depositBy = self.nameTF.text;
    self.writeModel.amount = self.amountTF.text;
    [self sumbitBill:sender amount:self.amountTF.text depositor:self.nameTF.text depositorType:@"" payType:[NSString stringWithFormat:@"%ld",(long)self.paymentModel.payType]];
}

- (void)sumbitBill:(UIButton *)sender amount:(NSString *)amount depositor:(NSString *)depositor depositorType:(NSString *)depositorType payType:(NSString *)payType{
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(sender) weakSender = sender;
    NSDictionary *params = @{
        @"amount":amount,
        @"depositor":depositor,
        @"depositorType":depositorType,
        @"payType":payType,
        @"loginName":[IVNetwork savedUserInfo].loginName
    };
    [IVNetwork requestPostWithUrl:BTTBQPayment paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            CNPayBankCardModel *model = [[CNPayBankCardModel alloc] initWithDictionary:result.body error:nil];
            if (!model) {
                weakSender.enabled = NO;
                [weakSelf showError:@"系统错误，请联系客服"];
                return;
            }
            weakSelf.writeModel.chooseBank = model;
            [weakSelf goToStep:1];
        }else{
            [weakSelf showError:result.head.errMsg];
        }
    }];
}

@end