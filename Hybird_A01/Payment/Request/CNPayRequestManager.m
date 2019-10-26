//
//  CNPayRequestManager.m
//  A05_iPhone
//
//  Created by cean.q on 2018/9/28.
//  Copyright © 2018年 WRD. All rights reserved.
//

#import "CNPayRequestManager.h"
#import <objc/runtime.h>
#import "CNPayOrderModel.h"
#import "CNPayConstant.h"

@implementation CNPayRequestManager

+ (void)requestWithUrl:(NSString *)url parameters:(NSDictionary *)params handler:(KYHTTPCallBack)completeHandler {
    
    [[IVHttpManager shareManager] sendRequestWithUrl:url parameters:params callBack:^(id  _Nullable response, NSError * _Nullable error) {
#warning 调试接口
//        if (completeHandler) {
//            completeHandler(result,result.data);
//        }
    }];
//    [BTTHttpManager sendRequestWithUrl:url paramters:params completionBlock:^(IVRequestResultModel *result, id response) {
//
//    }];
}

+ (void)cacheWithUrl:(NSString *)url parameters:(NSDictionary *)params handler:(KYHTTPCallBack)completeHandler {
    [[IVHttpManager shareManager] sendRequestWithMethod:KYHTTPMethodPOST url:url parameters:params cache:YES cacheTimeout:3600 * 24 callBack:^(BOOL isCache, id  _Nullable response, NSError * _Nullable error) {
#warning 调试接口
//        if (completeHandler) {
//            completeHandler(result,result.data);
//        }
    } originCallBack:^(id  _Nullable response, NSError * _Nullable error) {
//        if (completeHandler) {
//            completeHandler(result,result.data);
//        }
    }];
}

#pragma mark - ========================* Payment *===========================================
/// 预设支付方式总个数
NSInteger const kPayTypeTotalCount = 21;

+ (void)queryAllChannelCompleteHandler:(KYHTTPCallBack)completeHandler {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 杂项：在线，点卡，手工，比特币，微信条码, 钻石币支付
    // app：微信，支付宝，QQ，网银, 京东
    // 扫码：支付宝，微信，QQ，银联, 京东
    // BQ快速：快速，微信，支付宝, 币商
    NSArray *channelArr = @[@"online-1",@"card",@"deposit",@"online-20",@"online-23",@"online-41",
                            @"online-8",@"online-9",@"online-11",@"online-27",@"online-19",@"online-17",
                            @"online-5",@"online-6",@"online-7",@"online-15",@"online-16",
                            @"bqpaytype-0",@"bqpaytype-1",@"bqpaytype-2",@"biMerchant"];
    params[@"list"] = [channelArr componentsJoinedByString:@";"];
    
    [self cacheWithUrl:kPaymentValidate parameters:params handler:completeHandler];
}

+ (void)paymentWithPayType:(NSString *)type payId:(NSInteger)payId amount:(NSString *)amout bankCode:(NSString *)bankCode completeHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = type;
    params[@"payId"] = @(payId);
    params[@"amount"] = amout;
    params[@"terminal"] = @"MOBILE";
    if ([type isEqualToString:@"1"]) {
        params[@"extend_field"] = [NSString stringWithFormat:@"bankCode=%@", bankCode];
    }
    [self requestWithUrl:kPaymentOnlinePay parameters:params handler:completeHandler];
}

+ (void)paymentGetDepositNameWithType:(BOOL)isDeposit CompleteHandler:(KYHTTPCallBack)completeHandler {
    NSString *path = isDeposit ? kPaymentGetDepositName : kPaymentGetBQName;
    [self requestWithUrl:path parameters:nil handler:completeHandler];
}

+ (void)paymentDeleteDepositNameWithId:(NSString *)requestId CompleteHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"ids"] = requestId;
    [self requestWithUrl:kPaymentDeleteDepositName parameters:params handler:completeHandler];
}

+ (void)paymentGetBankListWithType:(BOOL)isDeposit
                         depositor:(NSString *)depositor
                       referenceId:(NSString *)referenceId
                         BQPayType:(NSInteger)bqPayType
                   completeHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"depositor"] = depositor;
    params[@"reference_id"] = referenceId;
    if (!isDeposit) {
        params[@"bqpaytype"] = @(bqPayType);
    }
    NSString *path = isDeposit ? kPaymentGetBankList : kPaymentQueryBankInfo;
    [self requestWithUrl:path parameters:params handler:completeHandler];
}

+ (void)paymentQueryBillCompleteHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"flag"] = @"0";
    [self requestWithUrl:kPaymentQueryDeposit parameters:params handler:completeHandler];
}


+ (void)paymentCreateManualWithWriteInfo:(CNPayWriteModel *)infoModel completeHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    CNPayBankCardModel *bankModel = infoModel.chooseBank;
    params[@"bank_account_no"] = bankModel.bank_account_no;
    params[@"bank_account_name"] = bankModel.bank_account_name;
    params[@"bank_name"] = bankModel.bank_name;
    params[@"branch_name"] = bankModel.branch_name;
    params[@"bank_city"] = bankModel.bank_city;

    params[@"amount"] = infoModel.amount;
    params[@"deposit_by"] = infoModel.depositBy;
    params[@"deposit_type"] = infoModel.depositType;
    params[@"deposit_date"] = infoModel.date;
    params[@"province"] = infoModel.provience;
    params[@"city"] = infoModel.city;
    params[@"remittance_remarks"] = infoModel.remarks ?:@"";

    [self requestWithUrl:kPaymentDepositPay parameters:params handler:completeHandler];
}

+ (void)paymentSubmitBill:(CNPayWriteModel *)infoModel completeHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    CNPayBankCardModel *bankModel = infoModel.chooseBank;
    params[@"depositor"] = infoModel.depositBy;
    params[@"reference_id"] = infoModel.referenceId;
    params[@"payId"] = @(infoModel.payId);
    params[@"amount"] = infoModel.amount;
    params[@"remark"] = infoModel.remarks ?:@"";
    
    params[@"depositAccNo"] = bankModel.bank_account_no;
    params[@"bankcode"] = infoModel.chooseBank.bankcode;
    params[@"bqpaytype"] = @(infoModel.BQType);
    
    [self requestWithUrl:kPaymentOfflinePayBill parameters:params handler:completeHandler];
}

+ (void)paymentCardPay:(CNPayCardModel *)cardModel completeHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"cardNo"] = cardModel.cardNo;
    params[@"cardPwd"] = cardModel.cardPwd;
    params[@"payId"] = @(cardModel.payId);
    params[@"amount"] = cardModel.amount;
    params[@"mincredit"] = cardModel.minCredit;
    params[@"cardCode"] = cardModel.code;
    params[@"url"] = cardModel.postUrl;
    
    [self requestWithUrl:kPaymentCardPay parameters:params handler:completeHandler];
}

#pragma mark - ========================* Form 表单 *===========================================

+ (NSString *)submitPayFormWithOrderModel:(CNPayOrderModel *)model {
    
    NSString *loginName = [IVHttpManager shareManager].loginName;
    id PayModel = [model class];
    
    NSMutableString *htmljs = [[NSMutableString alloc] init];
    [htmljs appendFormat:@"%@", [NSString stringWithFormat:@"<form id=\"codePayForm\" name=\"query\" action=\"%@\" method=\"get\" class=\"form\">\n", model.des_url]];
    [htmljs appendFormat:@"%@", [NSString stringWithFormat:@"<input type=\"hidden\" name=\"%@\" value=\"%@\">\n", @"loginname", loginName]];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(PayModel, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
        id value = [model valueForKey:propName];
        [htmljs appendFormat:@"%@", [NSString stringWithFormat:@"<input type=\"hidden\" name=\"%@\" value=\"%@\">\n",propName,value]];
    }
    [htmljs appendFormat:@"%@",[NSString stringWithFormat:@"</form>"]];
    [htmljs appendFormat:@"%@",[NSString stringWithFormat:@"<script>document.getElementById(\"codePayForm\").submit();</script>"]];
    NSLog(@"\n%@\n", htmljs);
    return htmljs;
}

#pragma mark - ========================* 完善个人信息 *===========================================

+ (void)paymentCompleteUserName:(NSString *)name preSet:(NSString *)message completeHandler:(KYHTTPCallBack)completeHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"real_name"] = name;
    params[@"verify_code"] = message;
    [self requestWithUrl:kPaymentCompleteInfo parameters:params handler:completeHandler];
}
@end
