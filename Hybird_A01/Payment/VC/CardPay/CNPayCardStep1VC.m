//
//  CNPayCardStep1VC.m
//  HybirdApp
//
//  Created by cean.q on 2018/10/24.
//  Copyright © 2018年 harden-imac. All rights reserved.
//

#import "CNPayCardStep1VC.h"
#import "UIButton+WebCache.h"

@interface CNPayCardStep1VC ()
@property (weak, nonatomic) IBOutlet UIView *preSettingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *preSettingViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *preSettingMessageLb;

@property (weak, nonatomic) IBOutlet UITextField *cardTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *cardValueTF;
@property (weak, nonatomic) IBOutlet UITextField *cardNoTF;
@property (weak, nonatomic) IBOutlet UITextField *cardPwdTF;


@property (nonatomic, strong) CNPayCardModel *chooseCardModel;
@end

@implementation CNPayCardStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configPreSettingMessage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setViewHeight:350 fullScreen:NO];
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

// 选择点卡类型
- (IBAction)selectCard:(UIButton *)sender {
    [self.view endEditing:YES];
//    NSMutableArray *cardTypeArr = [NSMutableArray array];
//    for (CNPayCardModel *model in self.paymentModel.cardList) {
//        [cardTypeArr addObject:model.name];
//    }
//    weakSelf(weakSelf);
//    [BRStringPickerView showStringPickerWithTitle:_cardTypeTF.placeholder dataSource:cardTypeArr defaultSelValue:_cardTypeTF.text resultBlock:^(NSString *selectValue, NSInteger index) {
//        weakSelf.cardTypeTF.text = selectValue;
//        CNPayCardModel *model = weakSelf.paymentModel.cardList[index];
//        weakSelf.chooseCardModel = model;
//        weakSelf.cardValueTF.text = nil;
//    }];
}

/// 选择点卡面额
- (IBAction)selectCardValue:(UIButton *)sender {
    [self.view endEditing:YES];
    if (!_chooseCardModel) {
        [self showError:_cardTypeTF.placeholder];
        return;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.chooseCardModel.cardValues.count];
    for (id obj in self.chooseCardModel.cardValues) {
        [array addObject:[NSString stringWithFormat:@"%@", obj]];
    }
    weakSelf(weakSelf);
    [BRStringPickerView showStringPickerWithTitle:_cardValueTF.placeholder dataSource:array defaultSelValue:_cardValueTF.text resultBlock:^(NSString * selectValue, NSInteger index) {
        weakSelf.cardValueTF.text = selectValue;
    }];
}


- (IBAction)submitAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (!_chooseCardModel) {
        [self showError:_cardTypeTF.placeholder];
        return;
    }
    
    if (_cardValueTF.text.length == 0) {
        [self showError:_cardValueTF.placeholder];
        return;
    }
    
    if (_cardNoTF.text.length == 0) {
        [self showError:_cardNoTF.placeholder];
        return;
    }
    
    if (_cardPwdTF.text.length == 0) {
        [self showError:_cardPwdTF.placeholder];
        return;
    }
    
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    
    /// 提交
    __weak typeof(self) weakSelf =  self;
    [CNPayRequestManager paymentCardPay:[self getCardModel] completeHandler:^(IVJResponseObject *result, id response) {
        sender.selected = NO;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            CNPayOrderModel *model = [[CNPayOrderModel alloc] initWithDictionary:result.body error:nil];
            weakSelf.writeModel.orderModel = model;
            [weakSelf goToStep:1];
        } else {
            [self showError:result.head.errMsg];
        }
    }];
}

- (CNPayCardModel *)getCardModel {
    CNPayCardModel *card = self.chooseCardModel;
//    card.cardNo = self.cardNoTF.text;
//    card.cardPwd = self.cardPwdTF.text;
//    card.payId = self.paymentModel.payid;
//    card.amount = self.cardValueTF.text;
//    card.postUrl = self.paymentModel.postUrl;
//    self.writeModel.cardModel = card;
    return card;
}
@end
