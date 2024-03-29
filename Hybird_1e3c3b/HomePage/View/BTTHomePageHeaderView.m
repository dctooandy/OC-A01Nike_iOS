//
//  BTTHomePageHeaderView.m
//  Hybird_1e3c3b
//
//  Created by Domino on 2018/10/11.
//  Copyright © 2018年 BTT. All rights reserved.
//

#import "BTTHomePageHeaderView.h"
#import "AppInitializeConfig.h"
#import <UIImage+GIF.h>
#import "AppInitializeConfig.h"
#import "GradientImage.h"

#define BTTIconTop (KIsiPhoneX ? 24 : 0) // 按钮距离顶端的高度
#define BTTLeftConstants 15 // 边距
#define BTTBtnAndBtnConstants 30   //
#define BTTBtnWidthAndHeight 22
#define BTTCornerRadius      4     //圆角度数
#define BTTBorderWidth       1     //边框宽度

@interface BTTHomePageHeaderView ()

@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation BTTHomePageHeaderView

- (instancetype)initWithFrame:(CGRect)frame withNavType:(BTTNavType)navType {
    self = [super initWithFrame:frame];
    if (self) {
        self.image = ImageNamed(@"navbg");
        self.userInteractionEnabled = YES;
        [self setupSubviewsWithNavType:navType];
    }
    return self;
}

- (void)setupSubviewsWithNavType:(BTTNavType)navType {
    switch (navType) {
        case BTTNavTypeVIPClub:
        {
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BTTLeftConstants, BTTIconTop + (64 - 30) / 2 + 5, 80, 30)];
            logoImageView.image = ImageNamed(@"Navlogo");
            [self addSubview:logoImageView];
            self.titleLabel = [UILabel new];
            [self addSubview:self.titleLabel];
            self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - 150) / 2, BTTIconTop + (64 - 18) / 2 + 10, 150, 18);
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.font = kFontSystem(17);
            self.titleLabel.textColor = [UIColor whiteColor];
            self.titleLabel.text = @"VIP俱乐部";

            UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:serviceBtn];
            serviceBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
            [serviceBtn setImage:ImageNamed(@"homepage_service") forState:UIControlStateNormal];
            [serviceBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            serviceBtn.tag = 2001;
            __block UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:messageBtn];
            messageBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight - BTTBtnAndBtnConstants - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
            [messageBtn setImage:ImageNamed(@"homepage_messege") forState:UIControlStateNormal];
            messageBtn.redDotOffset = CGPointMake(1, 3);
            messageBtn.tag = 2002;
            [messageBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [GJRedDot registNodeWithKey:BTTHomePageMessage
                              parentKey:BTTHomePageItemsKey
                            defaultShow:NO];
            [self setRedDotKey:BTTHomePageMessage refreshBlock:^(BOOL show) {
                NSInteger num = [[[NSUserDefaults standardUserDefaults] objectForKey:BTTUnreadMessageNumKey] integerValue];
                messageBtn.showRedDot = num;
            } handler:self];
        }
            break;
        case BTTNavTypeHomePage:
        {
            // 中秋装饰
//            NSString *path = nil;
//            if (KIsiPhoneX) {
//                path = [[NSBundle mainBundle] pathForResource:@"828x176-min" ofType:@"gif"];;
//            } else {
//                path = [[NSBundle mainBundle] pathForResource:@"828x128-min" ofType:@"gif"];;
//            }
//            NSData *data = [NSData dataWithContentsOfFile:path];
//            UIImage *image = [UIImage sd_animatedGIFWithData:data];
//            [self sd_setImageWithURL:nil placeholderImage:image];
//            UIImageView *moonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon"]];
//            if (KIsiPhoneX) {
//                moonImage.frame = CGRectMake(55, 15, 50, 50);
//            } else {
//                moonImage.frame = CGRectMake(80, 0, 50, 50);
//            }
//            [self addSubview:moonImage];
            __block BOOL isSpecialHidden = NO;
            [self serverTime:^(NSString * _Nonnull timeStr) {
                if (timeStr.length > 0) {
                    NSString * pathStr = @"";
                    //手動輸入要更換的日期
                    
                    if ([PublicMethod checksStartDate:@"2022-01-25" EndDate:@"2022-02-15" serverTime:timeStr])
                    {
                        pathStr = KIsiPhoneX ? @"newYear2":@"newYear1";//new year header
                        isSpecialHidden = YES;
                    }else
                    {
                        /// 不到时间
                    }
//                    if (![PublicMethod checkProductDate:@"2021-12-10" serverTime:timeStr]) {
//                        pathStr = @"";
//                        isSpecialHidden = YES;
//                    } else if (![PublicMethod checkProductDate:@"2021-12-08" serverTime:timeStr]) {
//                        pathStr = @"dEgg1";//双旦
//                        isSpecialHidden = YES;
//                    }
//                    else if (![PublicMethod checkProductDate:@"2021-09-25" serverTime:timeStr]) {
//                        pathStr = @"APPChinaNationalDay";//國慶
//                        isSpecialHidden = YES;
//                    } else if (![PublicMethod checkProductDate:@"2021-09-22" serverTime:timeStr]) {
//                        pathStr = @"";//
//                    }else if (![PublicMethod checkProductDate:@"2021-09-15" serverTime:timeStr]) {
//                        pathStr = @"APPMidAutumnFestival";//中秋
//                        isSpecialHidden = YES;
//                    } else if (![PublicMethod checkProductDate:@"2021-08-27" serverTime:timeStr]) {
//                        pathStr = @"918_Anniversary";//週年慶
//                    }
                    if (pathStr.length > 0) {
                        NSString *path = [[NSBundle mainBundle] pathForResource:pathStr ofType:@"gif"];
                        NSData *data = [NSData dataWithContentsOfFile:path];
                        UIImageView * img = [[UIImageView alloc] init];
                        img.image = [UIImage sd_imageWithGIFData:data];
                        [self addSubview:img];
                        [img mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.bottom.right.equalTo(self);
                            make.top.equalTo(self);
//                            make.top.equalTo(self);
                            make.left.equalTo(self);
                        }];
                    }
                }
                
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BTTLeftConstants, BTTIconTop + (64 - 30) / 2 + 5, 80, 30)];
                logoImageView.image = ImageNamed(@"Navlogo");
                self.titleLabel = [UILabel new];
                [self addSubview:self.titleLabel];
                self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - 150) / 2, BTTIconTop + (64 - 18) / 2 + 10, 150, 18);
                
                self.titleLabel.textAlignment = NSTextAlignmentCenter;
                self.titleLabel.font = kFontSystem(17);
                self.titleLabel.textColor = [UIColor whiteColor];
                self.titleLabel.text = @"首页";
                if (isSpecialHidden == NO)
                {
                    [self addSubview:logoImageView];
                    [self.titleLabel setHidden:NO];
                }else
                {
                    [self.titleLabel setHidden:YES];
                }
                
                UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [self addSubview:serviceBtn];
                serviceBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
                [serviceBtn setImage:ImageNamed(@"homepage_service") forState:UIControlStateNormal];
                [serviceBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                if (middle_app_version_num > 2)
                {
                    [serviceBtn addTarget:self action:@selector(switchEnvirmant) forControlEvents:UIControlEventTouchUpOutside];
                }
                serviceBtn.tag = 2001;
                __block UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [self addSubview:messageBtn];
                messageBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight - BTTBtnAndBtnConstants - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
                [messageBtn setImage:ImageNamed(@"homepage_messege") forState:UIControlStateNormal];
                messageBtn.redDotOffset = CGPointMake(1, 3);
                messageBtn.tag = 2002;
                [messageBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                [GJRedDot registNodeWithKey:BTTHomePageMessage
                                  parentKey:BTTHomePageItemsKey
                                defaultShow:NO];
                [self setRedDotKey:BTTHomePageMessage refreshBlock:^(BOOL show) {
                    NSInteger num = [[[NSUserDefaults standardUserDefaults] objectForKey:BTTUnreadMessageNumKey] integerValue];
                    messageBtn.showRedDot = num;
                } handler:self];
            }];
        }
            break;
        case BTTNavTypeOnlyTitle:
        {
            self.titleLabel = [UILabel new];
            [self addSubview:self.titleLabel];
            self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - 150) / 2, BTTIconTop + (64 - 18) / 2 + 10, 150, 18);
            self.titleLabel.text = @"首页";
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.font = kFontSystem(17);
            self.titleLabel.textColor = [UIColor whiteColor];
        }
            break;
        case BTTNavTypeDiscount:
        {
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BTTLeftConstants, BTTIconTop + (64 - 30) / 2 + 5, 80, 30)];
            [self addSubview:logoImageView];
            logoImageView.image = ImageNamed(@"Navlogo");
            self.titleLabel = [UILabel new];
            [self addSubview:self.titleLabel];
            self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - 150) / 2, BTTIconTop + (64 - 18) / 2 + 10, 150, 18);
            self.titleLabel.text = @"首页";
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.font = kFontSystem(17);
            self.titleLabel.textColor = [UIColor whiteColor];
            
            UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:serviceBtn];
            serviceBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
            [serviceBtn setImage:ImageNamed(@"homepage_service") forState:UIControlStateNormal];
            serviceBtn.tag = 2001;
            [serviceBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            __block UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:messageBtn];
            messageBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight - BTTBtnAndBtnConstants - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
            [messageBtn setImage:ImageNamed(@"homepage_messege") forState:UIControlStateNormal];
            messageBtn.redDotOffset = CGPointMake(1, 3);
            messageBtn.tag = 2002;
            [messageBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [GJRedDot registNodeWithKey:BTTDiscount
                              parentKey:BTTDiscountItemsKey
                            defaultShow:NO];
            [self setRedDotKey:BTTDiscountMessage refreshBlock:^(BOOL show) {
                messageBtn.showRedDot = [[[NSUserDefaults standardUserDefaults] objectForKey:BTTUnreadMessageNumKey] integerValue];
            } handler:self];
        }
            break;
            
        case BTTNavTypeMine:
        {
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BTTLeftConstants, BTTIconTop + (64 - 30) / 2 + 5, 80, 30)];
            [self addSubview:logoImageView];
            logoImageView.image = ImageNamed(@"Navlogo");
            self.titleLabel = [UILabel new];
            [self addSubview:self.titleLabel];
            self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - 150) / 2, BTTIconTop + (64 - 18) / 2 + 10, 150, 18);
            self.titleLabel.text = @"首页";
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.font = kFontSystem(17);
            self.titleLabel.textColor = [UIColor whiteColor];
            
            UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:serviceBtn];
            serviceBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
            [serviceBtn setImage:ImageNamed(@"homepage_service") forState:UIControlStateNormal];
            serviceBtn.tag = 2001;
            [serviceBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            __block UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:messageBtn];
            messageBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight - BTTBtnAndBtnConstants - 30, BTTIconTop + (64 - 30) / 2 + 5, 30, 30);
            [messageBtn setImage:ImageNamed(@"me_share") forState:UIControlStateNormal];
            messageBtn.redDotOffset = CGPointMake(1, 3);
            messageBtn.tag = 2002;
            [messageBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [GJRedDot registNodeWithKey:BTTMineCenter
                              parentKey:BTTMineCenterItemsKey
                            defaultShow:NO];
            [self setRedDotKey:BTTMineCenterNavMessage refreshBlock:^(BOOL show) {
                messageBtn.showRedDot = [[[NSUserDefaults standardUserDefaults] objectForKey:BTTUnreadMessageNumKey] integerValue];
            } handler:self];
            
            ///
//            UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [self addSubview:testBtn];
//            testBtn.frame = CGRectMake(SCREEN_WIDTH - BTTLeftConstants - BTTBtnWidthAndHeight - BTTBtnAndBtnConstants - 30 - 30 - BTTBtnWidthAndHeight, BTTIconTop + (64 - BTTBtnWidthAndHeight) / 2 + 5, BTTBtnWidthAndHeight, BTTBtnWidthAndHeight);
//            [testBtn setImage:ImageNamed(@"homepage_service") forState:UIControlStateNormal];
//            testBtn.tag = 2003;
//            [testBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            ///
        }
        default:
            break;
    }
}

- (void)switchEnvirmant
{
    weakSelf(weakSelf)
    BOOL isSetting = [[NSUserDefaults standardUserDefaults] boolForKey:RedPacketCustomSetting];
    IVActionHandler handler = ^(UIAlertAction *action){

        [weakSelf rebootBySecWithEnvirment:BTT_DEV];
    };
    IVActionHandler handler1 = ^(UIAlertAction *action){
        [weakSelf rebootBySecWithEnvirment:BTT_STAGE];
    };
    IVActionHandler handler2 = ^(UIAlertAction *action){
        [weakSelf rebootBySecWithEnvirment:BTT_DIS];
    };
    IVActionHandler handler3 = ^(UIAlertAction *action){
        if (isSetting == YES)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:RedPacketCustomSetting];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [MBProgressHUD showSuccessWithTime:@"已为您将红包雨时间定为\n接口回传为主\n3秒后将关闭APP\n请重新启动" toView:nil duration:2];
            [self rebootWithSecond:3];
        }else
        {
            [self showDatePicker];
        }
    };
    IVActionHandler handler4 = ^(UIAlertAction *action){};
    
    NSString *title = [NSString stringWithFormat:@"目前环境为 %@",[self formatTypeToString:EnvirmentType]];
    NSString *message = [NSString stringWithFormat:@"当前版本是: %@ \n选定切换环境,\n1秒后将重启APP",app_version];
    
    [IVUtility showAlertWithActionTitles:@[@"测试",@"运测",@"运营",(isSetting ? @"接口红包雨时间" : @"自设定红包雨时间"),@"取消"] handlers:@[handler,handler1,handler2,handler3,handler4] title:title message:message];
}
- (void)rebootBySecWithEnvirment:(NSInteger)env
{
    [[NSUserDefaults standardUserDefaults] setInteger:env forKey:@"Envirment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self rebootWithSecond:1.5];
}
- (void)rebootWithSecond:(CGFloat)second
{
    [IVCacheWrapper setObject:nil forKey:IVCacheAllGatewayKey];
    [IVCacheWrapper setObject:nil forKey:IVCacheAllH5DomainsKey];
    [IVCacheWrapper clearCache];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}
- (void)showDatePicker
{
    NSDate *minDate = [NSDate br_setYear:2018 month:01 day:01 hour:0 minute:0];
    NSDate *maxDate = [NSDate br_setYear:2030 month:12 day:31 hour:23 minute:59];
 
    [BRDatePickerView showDatePickerWithTitle:@"红包雨时间" dateType:BRDatePickerModeHM defaultSelValue:nil minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:nil resultBlock:^(NSString *selectValue) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RedPacketCustomSetting];
        [[NSUserDefaults standardUserDefaults] setObject:selectValue forKey:@"RainningSelectValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MBProgressHUD showSuccessWithTime:@"已为您将红包雨时间定为\n两分钟之后,一次为限\n3秒后将关闭APP\n请重新启动" toView:nil duration:2];
        [self rebootWithSecond:3];
    } cancelBlock:^{
        NSLog(@"点击了背景或取消按钮");
    }];
}
- (NSString*)formatTypeToString:(NSInteger)formatType {
    NSString *result = nil;
    switch(formatType) {
        case BTT_DEV:
            result = @"测试";
            break;
        case BTT_STAGE:
            result = @"运测";
            break;
        case BTT_DIS:
            result = @"运营";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    return result;
}

- (void)setIsLogin:(BOOL)isLogin {
    _isLogin = isLogin;
    if (_isLogin) {
        self.loginBtn.hidden = YES;
        self.registerBtn.hidden = YES;
    } else {
        self.loginBtn.hidden = NO;
        self.registerBtn.hidden = NO;
    }
}

- (void)setupLoginAndRegisterBtn {
    CGFloat btnWidth = (SCREEN_WIDTH - 40) / 2.0f;
    CGFloat btnHeight = 35.0f;
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:loginBtn];
    loginBtn.frame = CGRectMake(BTTLeftConstants, KIsiPhoneX ? 89 : 69, btnWidth, btnHeight);
    [loginBtn setTitle:@"用户登录" forState:UIControlStateNormal];
    loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    loginBtn.layer.borderWidth = BTTBorderWidth;
    loginBtn.layer.cornerRadius = BTTCornerRadius;
    loginBtn.clipsToBounds = YES;
    loginBtn.tag = 2003;
    loginBtn.layer.borderWidth = 0.5;
    loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    loginBtn.layer.cornerRadius = 4;
    loginBtn.clipsToBounds = YES;
    [loginBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.loginBtn = loginBtn;
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:registerBtn];
    registerBtn.frame = CGRectMake(BTTLeftConstants + btnWidth + 10, KIsiPhoneX ? 89 : 69, btnWidth, btnHeight);
    [registerBtn setTitle:@"立即开户" forState:UIControlStateNormal];
    registerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    registerBtn.layer.borderWidth = BTTBorderWidth;
    registerBtn.layer.cornerRadius = BTTCornerRadius;
    registerBtn.clipsToBounds = YES;
    registerBtn.tag = 2004;
    registerBtn.layer.borderWidth = 0.5;
    registerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    registerBtn.layer.cornerRadius = 4;
    registerBtn.clipsToBounds = YES;
    [registerBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.registerBtn = registerBtn;
}

- (void)buttonClick:(UIButton *)button {
    if (_btnClickBlock) {
        _btnClickBlock(button);
    }
}

-(void)serverTime:(ServerTimeCompleteBlock)completeBlock {
    NSDate *timeDate = [NSDate new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    completeBlock([dateFormatter stringFromDate:timeDate]);
//    [IVNetwork requestPostWithUrl:BTTServerTime paramters:nil completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
//        IVJResponseObject *result = response;
//        if ([result.head.errCode isEqualToString:@"0000"]) {
//            NSDate *timeDate = [[NSDate alloc]initWithTimeIntervalSince1970:[result.body longLongValue]];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//            completeBlock([dateFormatter stringFromDate:timeDate]);
//        } else {
//            completeBlock(@"");
//        }
//    }];
}
@end
