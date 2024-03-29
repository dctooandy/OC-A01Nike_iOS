//
//  CNPreCacheMananger.m
//  A05_iPhone
//
//  Created by cean.q on 2018/10/5.
//  Copyright © 2018年 WRD. All rights reserved.
//

#import "CNPreCacheMananger.h"
#import "CNPayRequestManager.h"

@implementation CNPreCacheMananger

/// 需要登录
+ (void)prepareCacheDataNeedLogin {
    if (![IVHttpManager shareManager].userToken) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ///支付所有渠道数据
        [CNPreCacheMananger cachePaymentData];
    });
}

/// 不需要登录
+ (void)prepareCacheDataNormal {

}

/// 预加载支付所有渠道数据
+ (void)cachePaymentData {
//    [CNPayRequestManager queryAllChannelCompleteHandler:nil];
}
@end
