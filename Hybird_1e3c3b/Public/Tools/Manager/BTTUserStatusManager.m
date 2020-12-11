//
//  BTTUserStatusManager.m
//  Hybird_1e3c3b
//
//  Created by Key on 2018/11/19.
//  Copyright © 2018年 BTT. All rights reserved.
//

#import "BTTUserStatusManager.h"
#import "WebViewUserAgaent.h"
#import <tingyunApp/NBSAppAgent.h>
#import <IVHeartPacketLibrary/IVHeartSocketManager.h>
#import "CLive800Manager.h"
#import "BTTRequestPrecache.h"
#import "CNPreCacheMananger.h"
#import "IVPushManager.h"
@implementation BTTUserStatusManager
+ (void)loginSuccessWithUserInfo:(NSDictionary *)userInfo isBackHome:(BOOL)isBackHome
{
    [IVNetwork updateUserInfo:userInfo];
    NSString *userId = [IVNetwork savedUserInfo].customerId;
    [NBSAppAgent setUserIdentifier:userId];
    [[IVGameManager sharedManager] userStatusChanged:YES];
    LIVUserInfo *userModel = nil;
       if ([IVNetwork savedUserInfo]) {
           userModel = [LIVUserInfo new];
           userModel.userAccount = [IVNetwork savedUserInfo].customerId;
           userModel.grade = [NSString stringWithFormat:@"%@",@([IVNetwork savedUserInfo].starLevel)];;
           userModel.loginName = [IVNetwork savedUserInfo].loginName;
           userModel.name = [IVNetwork savedUserInfo].loginName;;
       }
    [IVPushManager sharedManager].customerId = [IVNetwork savedUserInfo].customerId;
    [[IVPushManager sharedManager] sendIpsSuperSign];
    [CLive800Manager switchLive800UserWithCustomerId:userModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccessNotification object:@{@"isBackHome":[NSNumber numberWithBool:isBackHome]}];
    [BTTRequestPrecache updateCacheNeedLoginRequest];
    [CNPreCacheMananger prepareCacheDataNeedLogin];
}
+ (void)logoutSuccess
{
    [IVNetwork cleanUserInfo];
    [WebViewUserAgaent clearCookie];
    [[IVGameManager sharedManager] userStatusChanged:NO];
    [IVHeartSocketManager exitLoginSendHearPacket];
    [CLive800Manager switchLive800UserWithCustomerId:nil];
    [NBSAppAgent setUserIdentifier:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:LogoutSuccessNotification object:nil];
}
@end