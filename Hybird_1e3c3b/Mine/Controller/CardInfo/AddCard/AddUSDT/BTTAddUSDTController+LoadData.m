//
//  BTTAddUSDTController+LoadData.m
//  Hybird_1e3c3b
//
//  Created by Domino on 24/12/2019.
//  Copyright © 2019 BTT. All rights reserved.
//

#import "BTTAddUSDTController+LoadData.h"
#import "CNPayRequestManager.h"
#import "BTTUSDTWalletTypeModel.h"
#import "BTTAddUSDTController+Nav.h"

@implementation BTTAddUSDTController (LoadData)

- (void)loadUSDTData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:@"WALLET_TYPE" forKey:@"bizCode"];
    [IVNetwork requestPostWithUrl:BTTDynamicQuery paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if ([result.body[@"data"] isKindOfClass:[NSArray class]]) {
                NSArray *array = result.body[@"data"];
                if (array.count>0) {
                    for (int i = 0; i<array.count; i++) {
                        
                        BTTUSDTWalletTypeModel *typeModel = [BTTUSDTWalletTypeModel yy_modelWithJSON:array[i]];
                        if (![typeModel.code isEqualToString:@"bitoll"] &&
                            ![typeModel.code isEqualToString:@"DCBOX"] &&
                            ![typeModel.code isEqualToString:@"Bitbase"] &&
                            ![typeModel.code isEqualToString:@"ICHIPAY"]) {
                            [self.usdtDatas addObject:array[i]];
                        }
                        if (i==array.count-1) {
                            CGFloat height = 96+(self.usdtDatas.count-1)/3*36;
                            [self.elementsHight replaceObjectAtIndex:0 withObject:[NSValue valueWithCGSize:CGSizeMake(SCREEN_WIDTH, height)]];
                            [self.collectionView reloadData];
                        }
                    }
                }else{
                    [self.usdtDatas addObjectsFromArray:array];
                    CGFloat height = 96+(self.usdtDatas.count-1)/3*36;
                    [self.elementsHight replaceObjectAtIndex:0 withObject:[NSValue valueWithCGSize:CGSizeMake(SCREEN_WIDTH, height)]];
                    [self.collectionView reloadData];
                }
            }
        }
    }];
}

- (void)makeCallWithPhoneNum:(NSString *)phone captcha:(NSString *)captcha captchaId:(NSString *)captchaId {
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setValue:captcha forKey:@"captcha"];
    [params setValue:captchaId forKey:@"captchaId"];
    if ([phone containsString:@"*"]) {
        [params setValue:@1 forKey:@"type"];
    } else {
        [params setValue:@0 forKey:@"type"];
    }
    if ([IVNetwork savedUserInfo]) {
        [params setValue:[IVNetwork savedUserInfo].mobileNo forKey:@"mobileNo"];
        [params setValue:[IVNetwork savedUserInfo].loginName forKey:@"loginName"];
    } else {
        [params setValue:phone forKey:@"mobileNo"];
    }
    
    [IVNetwork requestPostWithUrl:BTTCallBackAPI paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            [self showCallBackSuccessView];
        }else{
            NSString *errInfo = [NSString stringWithFormat:@"申请失败,%@",result.head.errMsg];
            [MBProgressHUD showError:errInfo toView:nil];
        }
    }];
}

- (NSMutableArray *)usdtDatas {
    NSMutableArray *usdtDatas = objc_getAssociatedObject(self, _cmd);
    if (!usdtDatas) {
        usdtDatas = [NSMutableArray array];
        [self setUsdtDatas:usdtDatas];
    }
    return usdtDatas;
}

- (void)setUsdtDatas:(NSMutableArray *)usdtDatas{
    objc_setAssociatedObject(self, @selector(usdtDatas), usdtDatas, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
