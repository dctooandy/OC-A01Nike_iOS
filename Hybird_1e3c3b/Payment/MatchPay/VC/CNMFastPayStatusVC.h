//
//  CNMFastPayStatusVC.h
//  Hybird_1e3c3b
//
//  Created by cean on 2/17/22.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "CNPayBaseVC.h"
#import "CNMBankModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNMFastPayStatusVC : CNPayBaseVC
/// 订单号
@property (nonatomic, copy) NSString *transactionId;
/// 剩余取消次数, 必传
@property (nonatomic, assign) NSInteger cancelTime;
@end

NS_ASSUME_NONNULL_END
