//
//  BTTHttpManager.m
//  Hybird_A01
//
//  Created by Key on 2018/11/19.
//  Copyright © 2018年 BTT. All rights reserved.
//

#import "BTTHttpManager.h"
#import "BTTBankModel.h"
@implementation BTTHttpManager
+ (void)sendRequestWithUrl:(NSString *)url paramters:(NSDictionary *)paramters completionBlock:(KYHTTPCallBack)completionBlock
{
    [[IVHttpManager shareManager] sendRequestWithUrl:url parameters:paramters callBack:completionBlock];
}

+ (void)sendRequestUseCacheWithUrl:(NSString *)url paramters:(NSDictionary *)paramters completionBlock:(KYHTTPCallBack)completionBlock
{
    [[IVHttpManager shareManager] sendRequestWithMethod:KYHTTPMethodPOST url:url parameters:paramters cache:YES cacheTimeout:3600 * 24 callBack:^(BOOL isCache, id  _Nullable response, NSError * _Nullable error) {
        KYHTTPCallBack *complete = 
    } originCallBack:completionBlock];
   
}
+ (void)publicGameLoginWithParams:(NSDictionary *)params isTry:(BOOL)isTry completeBlock:(KYHTTPCallBack)completeBlock{
#warning 调试接口
    NSString *subUrl = isTry ? @"public/game/tryPlay" : @"public/game/login";
    [self sendRequestWithUrl:subUrl paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
//        NSString *url = nil;
//        if (result.status && [result.data isKindOfClass:[NSDictionary class]]) {
//            url = [result.data valueForKey:@"url"];
//        }
//        if (completeBlock) {
//            completeBlock(result,url);
//        }
    }];
    
}

+ (void)publicGameTransferWithProvider:(NSString *)provider completeBlock:(KYHTTPCallBack)completeBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setValue:provider forKey:@"game_name"];
    [self sendRequestWithUrl: @"public/game/transfer" paramters:params.copy completionBlock:completeBlock];
}
+ (void)fetchBankListWithUseCache:(BOOL)useCache completion:(KYHTTPCallBack)completion
{
    NSMutableDictionary *params = @{
                             @"flag" : @"9;1",
                             @"order":@"PRIORITY_ORDER",
                             @"delete_flag":@"0"
                             }.mutableCopy;
//    [params setObject:@"1" forKey:@"cache_type"];
    NSString *url = @"public/bankcard/getList";
    weakSelf(weakSelf)
    if (useCache) {
        [self sendRequestUseCacheWithUrl:url paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
            [weakSelf fetchBankListResult:result completion:completion];
        }];
    } else {
        [self sendRequestWithUrl:url paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
            [weakSelf fetchBankListResult:result completion:completion];
        }];
    }
}
+ (void)fetchGamePlatformsWithCompletion:(KYHTTPCallBack)completion
{
    [self sendRequestUseCacheWithUrl:BTTGamePlatforms paramters:nil completionBlock:completion];
}
//处理银行卡列表获取结果
+ (void)fetchBankListResult:(NSDictionary *)result completion:(KYHTTPCallBack)completion
{
#warning 调试接口
//    if (result.data) {
//        [[IVCacheManager sharedInstance] nativeWriteValue:result.data forKey:BTTCacheBankListKey];
//    }
//    if (completion) {
//        completion(result,nil);
//    }
}
//处理绑定状态获取结果
+ (void)fetchBindStatusWithUseCache:(BOOL)useCache completionBlock:(KYHTTPCallBack)completionBlock
{
    NSString *typeList = @"phone;email;bank;btc";
    NSDictionary *params = @{@"typeList":typeList};
    NSString *url = BTTIsBindStatusAPI;
    weakSelf(weakSelf)
    if (useCache) {
        [self sendRequestUseCacheWithUrl:url paramters:params completionBlock:^(IVRequestResultModel *result, id response) {
            [weakSelf fetchBindStatusResult:result completionBlock:completionBlock];
        }];
    } else {
        [self sendRequestWithUrl:url paramters:params completionBlock:^(IVRequestResultModel *result, id response) {
            [weakSelf fetchBindStatusResult:result completionBlock:completionBlock];
        }];
    }
}
+ (void)fetchBindStatusResult:(NSDictionary *)result completionBlock:(KYHTTPCallBack)completionBlock {
#warning 调试接口
//    if (result.data && [result.data isKindOfClass:[NSDictionary class]]) {
//        NSMutableDictionary *userInfo = @{}.mutableCopy;
//        userInfo[@"isPhoneBinded"] = [result.data valueForKey:@"phone"];
//        userInfo[@"isEmailBinded"] = [result.data valueForKey:@"email"];
//        userInfo[@"isBankBinded"] = [result.data valueForKey:@"bank"];
//        userInfo[@"isBtcBinded"] = [result.data valueForKey:@"btc"];
//        [IVNetwork updateUserInfo:userInfo];
//    }
//    if (completionBlock) {
//        completionBlock(result,nil);
//    }
}

+ (void)getOpenAccountStatusCompletion:(KYHTTPCallBack)completion {
    [IVNetwork sendUseCacheRequestWithSubURL:BTTOpenAccountStatus paramters:nil completionBlock:completion];
}

+ (void)updateBankCardWithUrl:(NSString *)url params:(NSDictionary *)params completion:(KYHTTPCallBack)completion
{
    [self sendRequestWithUrl:url paramters:params completionBlock:completion];
}
+ (void)fetchHumanBankAndPhoneWithBankId:(NSString *)bankId Completion:(KYHTTPCallBack)completion
{
    NSDictionary *params = nil;
    if (bankId.length) {
        params = @{@"login_name":[IVNetwork userInfo].loginName,@"customer_bank_id":bankId};
    } else {
        params = @{@"login_name":[IVNetwork userInfo].loginName};
    }
    [self sendRequestWithUrl:@"public/forgot/getBanknoAndPhone" paramters:params completionBlock:completion];
}
+ (void)verifyHumanBankAndPhoneWithParams:(NSDictionary *)params completion:(KYHTTPCallBack)completion
{
    [self sendRequestWithUrl:@"public/forgot/verfiyByBankAndPhone" paramters:params completionBlock:completion];
}
+ (void)addBTCCardWithUrl:(NSString *)url params:(NSDictionary *)params completion:(KYHTTPCallBack)completion
{
    [self sendRequestWithUrl:url paramters:params completionBlock:completion];
}
+ (void)deleteBankOrBTC:(BOOL)isBTC isAuto:(BOOL)isAuto completion:(KYHTTPCallBack)completion
{
    NSString *url = nil;
    if (isBTC) {
        url = isAuto ? @"public/bankcard/delBtcAuto" : @"public/bankcard/delBtc";
    } else {
        url = isAuto ? @"public/bankcard/delAuto" : @"public/bankcard/del";
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"customer_bank_id"] = [[NSUserDefaults standardUserDefaults] valueForKey:BTTSelectedBankId];
    [self sendRequestWithUrl:url paramters:params.copy completionBlock:completion];
}
+ (void)updatePhoneHumanWithParams:(NSDictionary *)params completion:(KYHTTPCallBack)completion
{
    [self sendRequestWithUrl:@"users/updatePhone" paramters:params completionBlock:completion];
}
+ (void)fetchBTCRateWithUseCache:(BOOL)useCache
{
    NSDictionary *params = @{@"amount":@"1",@"querytype" : @"01"};
    NSString *url = @"public/payment/btcRate";
    weakSelf(weakSelf)
    if (useCache) {
        [self sendRequestUseCacheWithUrl:url paramters:params completionBlock:^(IVRequestResultModel *result, id response) {
            [weakSelf fetchBTCRateResult:result];
        }];
    } else {
        [self sendRequestWithUrl:url paramters:params completionBlock:^(IVRequestResultModel *result, id response) {
            [weakSelf fetchBTCRateResult:result];
        }];
    }
}
+ (void)fetchBTCRateResult:(IVRequestResultModel *)result {
    if (result.data && [result.data isKindOfClass:[NSDictionary class]] && [result.data valueForKey:@"btcrate"]) {
        NSString *rate = [result.data valueForKey:@"btcrate"];
        [[NSUserDefaults standardUserDefaults] setValue:rate forKey:BTTCacheBTCRateKey];
    }
}
+ (void)submitWithdrawWithUrl:(NSString *)url params:(NSDictionary *)params completion:(KYHTTPCallBack)completion
{
    [self sendRequestWithUrl:url paramters:params completionBlock:completion];
}
+ (void)fetchUserInfoCompleteBlock:(KYHTTPCallBack)completeBlock{
    if (![IVNetwork userInfo]) {
        return;
    }
    NSMutableDictionary  *param = @{}.mutableCopy;
    [self sendRequestWithUrl:@"public/users/userInfo" paramters:param completionBlock:^(IVRequestResultModel *result, id response) {
        if (result.status && result.data && [result.data isKindOfClass:[NSDictionary class]]) {
            [IVNetwork updateUserInfo:result.data];
        }
    }];
}


+ (void)requestUnReadMessageNum:(KYHTTPCallBack)completeBlock {
    [IVNetwork sendRequestWithSubURL:BTTIsUnviewedAPI paramters:nil completionBlock:^(IVRequestResultModel *result, id response) {
        NSLog(@"%@",response);
        if (result.status && [result.data isKindOfClass:[NSDictionary class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:result.data[@"val"] forKey:BTTUnreadMessageNumKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if ([result.data[@"val"] integerValue]) {
                [self resetRedDotState:YES forKey:BTTHomePageMessage]; // BTTMineCenterMessage
                [self resetRedDotState:YES forKey:BTTMineCenterMessage];
                [self resetRedDotState:YES forKey:BTTDiscountMessage];
                [self resetRedDotState:YES forKey:BTTMineCenterNavMessage];
            } else {
                [self resetRedDotState:NO forKey:BTTHomePageMessage];
                [self resetRedDotState:NO forKey:BTTMineCenterMessage];
                [self resetRedDotState:NO forKey:BTTDiscountMessage];
                [self resetRedDotState:NO forKey:BTTMineCenterNavMessage];
            }
        }
    }];
}

@end
