//
//  AppDelegate+Environment.m
//  Hybird_A01
//
//  Created by Domino on 2018/10/3.
//  Copyright © 2018年 BTT. All rights reserved.
//

#import "AppDelegate+Environment.h"
#import "CLive800Manager.h"
#import "BridgeProtocolExternal.h"
#import "BTTRedDotManager.h"
#import "WebViewUserAgaent.h"
#import "HAInitConfig.h"
#import "IVWebViewUtility.h"
#import "IVGameUtility.h"
#import "BTTRequestPrecache.h"
#import "IVCheckNetworkWrapper.h"


@implementation AppDelegate (Environment)

/**
 设置APP的启动环境, 第三方等
 */
- (void)setupAPPEnvironment {
    switch (EnvirmentType) {
        case 0:
            [IVHttpManager shareManager].environment = IVNEnvironmentPublishTest; // 运行环境
            break;
        case 1:
            [IVHttpManager shareManager].environment = IVNEnvironmentPublishTest; // 运行环境
            break;
        default:
            [IVHttpManager shareManager].environment = IVNEnvironmentPublishTest; // 运行环境
            break;
    }
    //设置初始数据
    [IVWebViewManager sharaManager].delegate = [IVWebViewUtility new];
    [IVGameManager sharedManager].delegate = [IVGameUtility new];
    [IVGameManager sharedManager].isPushAGQJ = YES;
    [WebViewUserAgaent writeIOSUserAgent];
    [IVHttpManager shareManager].productId = [HAInitConfig productId]; // 产品标识
    [IVHttpManager shareManager].appId = [HAInitConfig appId];     // 应用ID
    [IVHttpManager shareManager].parentId = @"1111";  // 渠道号
    [IVHttpManager shareManager].gateways = [HAInitConfig gateways];  // 网关列表
    [IVHttpManager shareManager].productCode = [HAInitConfig appKey]; // 产品码
    [IVHttpManager shareManager].domain = [HAInitConfig defaultH5Domain]; // 默认手机站
    [IVHttpManager shareManager].cdn = [HAInitConfig defaultCDN]; //默认cdn

    [IN3SAnalytics debugEnable:YES];
    [IN3SAnalytics setUserName:[IVHttpManager shareManager].loginName];
    [[CNTimeLog shareInstance] configProduct:@"A01"];
    
    [self setupRedDot];
    [self setupLive800];
    
    //获取最优的网关
    [IVCheckNetworkWrapper getOptimizeUrlWithArray:[IVHttpManager shareManager].gateways
                                            isAuto:YES
                                              type:IVKCheckNetworkTypeGateway
                                          progress:nil
                                        completion:nil
     ];
    //获取最优的手机站
    [IVCheckNetworkWrapper getOptimizeUrlWithArray:[IVHttpManager shareManager].domains
                                            isAuto:YES
                                              type:IVKCheckNetworkTypeDomain
                                          progress:nil
                                        completion:nil
     ];
}

- (void)setupRedDot {
    [GJRedDot registWithProfile:[BTTRedDotManager registerProfiles] defaultShow:YES];
    [GJRedDot setDefaultRadius:4];
    [GJRedDot setDefaultColor:[UIColor colorWithHexString:@"d13847"]];
}

- (void)setupLive800 {
    
    LIVUserInfo *userInfo = nil;
    if ([IVHttpManager shareManager].loginName.length) {
        userInfo = [LIVUserInfo new];
//        userInfo.userAccount = [NSString stringWithFormat:@"%@",@([IVHttpManager shareManager].customerId)];
//        userInfo.grade = [NSString stringWithFormat:@"%@",@([IVNetwork userInfo].customerLevel)];;
//        userInfo.loginName = [IVNetwork userInfo].loginName;
//        userInfo.name = [IVNetwork userInfo].loginName;
    }
    [[CLive800Manager sharedInstance] setUpLive800WithUserInfo:userInfo];
}

@end
