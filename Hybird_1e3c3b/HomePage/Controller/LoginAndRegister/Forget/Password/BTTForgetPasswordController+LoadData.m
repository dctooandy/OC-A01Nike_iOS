//
//  BTTForgetPasswordController+LoadData.m
//  Hybird_1e3c3b
//
//  Created by Domino on 15/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTForgetPasswordController+LoadData.h"
#import "BTTMeMainModel.h"
#import "BTTMakeCallSuccessView.h"

@implementation BTTForgetPasswordController (LoadData)

// 图形验证码
- (void)loadVerifyCode {
    [self showLoading];
    [IVNetwork requestPostWithUrl:BTTVerifyCaptcha paramters:nil completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        [self hideLoading];
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (result.body && ![result.body isKindOfClass:[NSNull class]]) {
                if (result.body[@"image"] && ![result.body[@"image"] isKindOfClass:[NSNull class]]) {
                    NSString *base64Str = result.body[@"image"];
                    // 将base64字符串转为NSData
                    NSData *decodeData = [[NSData alloc]initWithBase64EncodedString:base64Str options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
                    // 将NSData转为UIImage
                    UIImage *decodedImage = [UIImage imageWithData: decodeData];
                    self.codeImage = decodedImage;
                    //获取到验证码ID
                    self.uuid = result.body[@"captchaId"];
                    self.codeImage = decodedImage;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView reloadData];
                    });
                }
            }
        }
    }];
}

-(void)verifyPhotoCode:(NSString *)code loginName:(NSString *)loginName WithCaptchaId:(NSString *)captchaId mobileNo:(NSString *)mobileNo completeBlock:(KYHTTPCallBack)completeBlock {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:code forKey:@"captcha"];
    [params setValue:captchaId forKey:@"captchaId"];
    [params setValue:loginName forKey:@"loginName"];
    [params setValue:self.findType == BTTFindWithPhone ? @0:@1 forKey:@"type"];
    [params setValue:[IVRsaEncryptWrapper encryptorString:mobileNo] forKey:self.findType == BTTFindWithPhone ? @"mobileNo":@"email"];
    [params setValue:@4 forKey:@"use"];
    [IVNetwork requestPostWithUrl:BTTValidateCaptcha paramters:params completionBlock:completeBlock];
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

- (void)showCallBackSuccessView {
    BTTMakeCallSuccessView *customView = [BTTMakeCallSuccessView viewFromXib];
    customView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    BTTAnimationPopView *popView = [[BTTAnimationPopView alloc] initWithCustomView:customView popStyle:BTTAnimationPopStyleNO dismissStyle:BTTAnimationDismissStyleNO];
    popView.isClickBGDismiss = YES;
    [popView pop];
    customView.dismissBlock = ^{
        [popView dismiss];
    };
    customView.btnBlock = ^(UIButton *btn) {
        [popView dismiss];
    };
}

- (void)loadMainData {
    NSString * str = @"";
    NSString * strPlacehold = @"";
    if (self.findType == BTTFindWithPhone) {
        str = @"ic_forget_phone_logo";
        strPlacehold = @"请输入您的手机号";
    } else if (self.findType == BTTFindWithEmail) {
        str = @"ic_forget_email_logo";
        strPlacehold = @"请输入您的邮箱地址";
    }
    NSArray *iconNames = @[@"ic_forget_account_logo",str,@"ic_forget_captcha_logo"];
    NSArray *placeholds = @[@"请输入账号",strPlacehold,@"请输入验证码"];
    for (NSString *name in iconNames) {
        NSInteger index = [iconNames indexOfObject:name];
        BTTMeMainModel *model = [[BTTMeMainModel alloc] init];
        model.name = placeholds[index];
        model.iconName = iconNames[index];
        [self.mainData addObject:model];
    }
    [self setupElements];
}

- (void)setMainData:(NSMutableArray *)mainData {
    objc_setAssociatedObject(self, @selector(mainData), mainData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)mainData {
    NSMutableArray *mainData = objc_getAssociatedObject(self, _cmd);
    if (!mainData) {
        mainData = [NSMutableArray array];
        [self setMainData:mainData];
    }
    return mainData;
}

@end

