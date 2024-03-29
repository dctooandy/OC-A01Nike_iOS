//
//  BTTPTTransferController+LoadData.h
//  Hybird_1e3c3b
//
//  Created by Domino on 20/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTPTTransferController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTTPTTransferController (LoadData)

- (void)loadMainData;

- (void)loadCreditsTransfer:(BOOL)isReverse amount:(NSString *)amount transferType:(NSInteger)transferType;

@end

NS_ASSUME_NONNULL_END
