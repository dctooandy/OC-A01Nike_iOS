//
//  KYMNetworingWrapper.m
//  Hybird_1e3c3b
//
//  Created by Key.L on 2022/2/21.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "KYMWithdrewRequest.h"


@implementation KYMWithdrewRequest


+ (void)checkChannelWithParams:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"deposit/checkChannel",params, ^(BOOL status, NSString * msg , NSDictionary *body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",nil);
            return;
        }
        KYMWithdrewCheckModel *model = [KYMWithdrewCheckModel yy_modelWithJSON:body];
        NSString *errMsg = model.message ? : msg;
        
        if (model && [model isKindOfClass:[KYMWithdrewCheckModel class]] && model.data) {
            callback(YES,model.message,model);
        } else {
            callback(NO,errMsg,model);
        }
    });
}
+ (void)createWithdrawWithParams:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"withdraw/createRequest",params, ^(BOOL status, NSString * msg , id body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",nil);
            return;
        }
        KYMCreateWithdrewModel *model = nil;
        model = [KYMCreateWithdrewModel yy_modelWithJSON:body];
        callback(status,msg,model);
    });
}
+ (void)getWithdrawDetailWithParams:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"withdraw/getMMWithDrawDetail",params, ^(BOOL status, NSString * msg , id body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",nil);
            return;
        }
        KYMGetWithdrewDetailModel *model = [KYMGetWithdrewDetailModel yy_modelWithJSON:body];
        
        callback(status,msg,model);
    });
}
+ (void)checkReceiveStatus:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"withdraw/withdrawOperate",params, ^(BOOL status, NSString * msg , NSDictionary *body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",nil);
            return;
        }
        KYMCheckReceiveModel *model = [KYMCheckReceiveModel yy_modelWithJSON:body];
        NSString *errMsg = model.message ? : msg;
        if ([model.code isEqualToString:@"00000"]) {
            callback(YES,model.message,model);
        } else {
            callback(NO,errMsg,model);
        }
    });
}
+ (void)cancelWithdrawWithParams:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"withdraw/cancelRequest",params, ^(BOOL status, NSString * msg , id body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSNumber class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",@(NO));
            return;
        }
        if ([body boolValue]) {
            callback(YES, msg ,@(YES));
        } else {
            callback(NO, msg ,@(NO));
        }
    });
}
+ (void)checkReceiveStats:(BOOL)isNotRceived transactionId:(NSString *)transactionId   callBack:(void(^)(BOOL status, NSString *msg))callBack
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"merchant"] = @"A01";
    //            mparams[@"loginName"] = @""; //用户名，底层已拼接
    //            mparams[@"productId"] = @""; //脱敏产品编号，底层已拼接
    params[@"opType"] = isNotRceived ? @"2" : @"1"; //是否为未到账
    params[@"transactionId"] = transactionId;
    
    [self checkReceiveStatus:params callback:^(BOOL status, NSString * _Nonnull msg, id  _Nonnull body) {
        if (!status) {
            callBack(NO,msg);
        } else {
            callBack(YES,msg);
        }
    }];
}
@end
