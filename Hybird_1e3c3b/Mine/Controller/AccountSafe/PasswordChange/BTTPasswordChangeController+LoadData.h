//
//  BTTPasswordChangeController+LoadData.h
//  Hybird_1e3c3b
//
//  Created by JerryHU on 2021/4/7.
//  Copyright © 2021 BTT. All rights reserved.
//

#import "BTTPasswordChangeController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTTPasswordChangeController (LoadData)
//- (void)sendCodeByPhone;
- (void)sendCode;
- (void)submitVerifySmsCode;
- (void)submitChange;
@end

NS_ASSUME_NONNULL_END