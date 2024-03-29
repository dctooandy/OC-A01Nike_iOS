//
//  BTTHomePageViewController+LoadData.m
//  Hybird_1e3c3b
//
//  Created by Domino on 2018/10/11.
//  Copyright © 2018年 BTT. All rights reserved.
//

#import "BTTHomePageViewController+LoadData.h"
#import "BTTBannerModel.h"
#import <objc/runtime.h>
#import "BTTNoticeModel.h"
#import "BTTHomePageHeaderModel.h"
#import "BTTActivityModel.h"
#import "BTTAmountModel.h"
#import "BTTMakeCallSuccessView.h"
#import "BTTPosterModel.h"
#import "BTTPromotionModel.h"
#import "BTTDownloadModel.h"
#import "BTTAGGJViewController.h"
#import "BTTGamesTryAlertView.h"
#import "BTTHomePageViewController+Nav.h"
#import "BTTMidAutumnPopView.h"
#import "BTTASGameModel.h"

static const char *noticeStrKey = "noticeStr";

static const char *BTTNextGroupKey = "nextGroup";
static const char *BTTAvailableNumKey = "availableNum";
static const char *BTTChanceCountKey = "chanceCount";
@interface BTTHomePageViewController (LoadData)
@property (nonatomic, assign) NSInteger availableNum;
@end
@implementation BTTHomePageViewController (LoadData)


- (void)loadDataOfHomePage {
    
    [self loadHeadersData];
    [self loadGamesData];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("homepage.data", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_enter(group);
    [self loadMainData:group];

    dispatch_group_enter(group);
    [self loadScrollText:group];

    dispatch_group_enter(group);
    [self loadOtherData:group];

    dispatch_group_enter(group);
    [self loadHightlightsBrand:group];
    
    dispatch_group_enter(group);
    [self loadASGame:group];

    dispatch_group_notify(group,queue, ^{
        [self endRefreshing];
        [self setupElements];
    });
}

- (void)refreshDatasOfHomePage {
    [[AppdelegateManager shareManager] recheckDomainWithTestSpeed];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("homepage.data", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
        [self loadMainData:group];
    });
    
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
        [self loadScrollText:group];
    });
    
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
        [self loadOtherData:group];
    });
    
    dispatch_group_notify(group,queue, ^{
        [self endRefreshing];
        [self setupElements];
     
    });
}

-(void)loadBiBiCun {
    [IVNetwork requestPostWithUrl:BBTBiBiCunAlert paramters:nil completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            NSString * contentStr = result.body;
            if (contentStr.length != 0) {
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString * dateStr = [dateFormatter stringFromDate:[NSDate date]];
                [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:BTTBiBiCunDate];
                [self showBiBiCunPopView:result.body];
            }
        }
    }];
}

// 博币数量查询
- (void)loadLuckyWheelCoinStatus {
    [IVNetwork requestPostWithUrl:BTTQueryIntegralAPI paramters:nil completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if ([result.body isKindOfClass:[NSDictionary class]]) {
                if ([result.body[@"amount"] integerValue]) {
                    [self showPopViewWithNum:result.body[@"amount"]];
                }
            }
        }
    }];
}

// 博币兑现
- (void)loadLuckyWheelCoinChangeWithAmount:(NSString *)amount {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[IVNetwork savedUserInfo].loginName forKey:@"loginName"];
    [params setValue:@"2" forKey:@"endPointType"];
    [params setValue:amount forKey:@"depositAmount"];
    [IVNetwork requestPostWithUrl:BTTCoinDepositAPI paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            [MBProgressHUD showSuccess:@"兑换成功" toView:nil];
        } else {
            [MBProgressHUD showError:result.head.errMsg toView:nil];
        }
    }];
}

- (void)loadScrollText:(dispatch_group_t)group {
    [IVNetwork requestPostWithUrl:BTTHomeAnnouncementAPI paramters:nil completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            BTTNoticeMainModel *noticeModel = [BTTNoticeMainModel yy_modelWithDictionary:result.body];
            self.noticeStr = @"";
            for (BTTNoticeModel *dict in noticeModel.data) {
                NSError *error = nil;
                NSLog(@"%@",error.description);
                if (self.noticeStr) {
                    self.noticeStr  = [NSString stringWithFormat:@"%@%@%@",self.noticeStr,@"                ",dict.content];
                } else {
                    self.noticeStr = dict.content;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        dispatch_group_leave(group);
    }];
}

- (void)loadHeadersData {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *titleStr = [NSString stringWithFormat:@"%@高额及高倍盈利",dateStr];
    if (self.headers.count) {
        [self.headers removeAllObjects];
    }
    NSArray *titles = @[@"热门优惠",@"客户参与品牌活动集锦",titleStr];
    NSArray *btns = @[@"搜索更多",@"查看下一组",@""];
    NSMutableArray *headers = [NSMutableArray array];
    [self.headers removeAllObjects];
    for (NSString *title in titles) {
        NSInteger index = [titles indexOfObject:title];
        BTTHomePageHeaderModel *model = [BTTHomePageHeaderModel new];
        model.titleStr = title;
        model.detailBtnStr = btns[index];
        [headers addObject:model];
    }
    self.headers = [headers mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
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
            } else {
                NSString *errInfo = [NSString stringWithFormat:@"申请失败,%@",result.head.errMsg];
                [MBProgressHUD showError:errInfo toView:nil];
            }
        }];
}

- (void)loadGamesData {
    if (self.games.count) {
        [self.games removeAllObjects];
    }
    NSArray *gamesIcons = @[@"AGQJ",@"AGGJ",@"Fishing_king",@"game",@"shaba",@"YSB",@"AS",@"AGCP"];
//    NSArray *gameNames = @[@"AG旗舰厅",@"AG国际厅",@"捕鱼王",@"电子游戏",@"沙巴体育",@"YSB体育",@"AS真人棋牌",@"AG彩票"];
    NSArray *gameNames = @[@"旗舰厅",@"国际厅",@"捕鱼王",@"电子游戏",@"沙巴体育",@"YSB体育",@"AS真人棋牌",@"彩票"];
    NSMutableArray *games = [NSMutableArray array];
    for (NSString *icon in gamesIcons) {
        NSInteger index = [gamesIcons indexOfObject:icon];
        NSString *name = [gameNames objectAtIndex:index];
        BTTGameModel *model = [[BTTGameModel alloc] init];
        model.gameIcon = icon;
        model.name = name;
        [games addObject:model];
    }
    self.games = games.mutableCopy;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)showMidAutumnPopView {
    BTTMidAutumnPopView *customView = [BTTMidAutumnPopView viewFromXib];
    customView.frame = CGRectMake(0, 0, 350, 280);
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

- (void)showTryAlertViewWithBlock:(BTTBtnBlock)btnClickBlock {
    BTTGamesTryAlertView *customView = [BTTGamesTryAlertView viewFromXib];
    if (SCREEN_WIDTH == 414) {
        customView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 120, 132);
    } else {
        customView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 60, 132);
    }
    BTTAnimationPopView *popView = [[BTTAnimationPopView alloc] initWithCustomView:customView popStyle:BTTAnimationPopStyleNO dismissStyle:BTTAnimationDismissStyleNO];
    popView.isClickBGDismiss = YES;
    [popView pop];
    popView.dismissComplete = ^{
        if (self.idDisable) {
            self.idDisable = false;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnlockGameBtnPress" object:nil];
        }
    };
    customView.dismissBlock = ^{
        [popView dismiss];
    };
    customView.btnBlock = ^(UIButton *btn) {
        [popView dismiss];
        btnClickBlock(btn);
    };
}

- (void)loadMainData:(dispatch_group_t)group {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *date_start = [PublicMethod getCurrentTimesWithFormat:@"YYYY-MM-dd"];
    date_start = [NSString stringWithFormat:@"%@ 00:00:00",date_start];
    [params setObject:date_start forKey:@"date_start"];
    NSString *date_end = [PublicMethod getCurrentTimesWithFormat:@"YYYY-MM-dd HH:mm:ss"];
    [params setObject:date_end forKey:@"date_end"];
    [params setObject:@"50000" forKey:@"min_bet_amount"];
    [params setObject:@"100" forKey:@"page_size"];
    NSMutableArray *amounts = [NSMutableArray array];
    NSMutableArray *posters = [NSMutableArray array];
    NSMutableArray *promotions = [NSMutableArray array];
    [IVNetwork requestPostWithUrl:BTTHomePageNewAPI paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (![result.body[@"maxRecords"] isKindOfClass:[NSNull class]]) {
                [self.amounts removeAllObjects];
                for (NSMutableDictionary *dict in result.body[@"maxRecords"]) {
                    BTTAmountModel *model = [BTTAmountModel yy_modelWithDictionary:dict];
                    [amounts addObject:model];
                }
                self.amounts = amounts.mutableCopy;
            }

            if (![result.body[@"poster"] isKindOfClass:[NSNull class]]) {
                [self.posters removeAllObjects];
                for (NSMutableDictionary *dict in result.body[@"poster"]) {
                    BTTPosterModel *model = [BTTPosterModel yy_modelWithDictionary:dict];
                    [posters addObject:model];
                }
                self.posters = posters.mutableCopy;
            }

            if (![result.body[@"promotions"] isKindOfClass:[NSNull class]]) {
                [self.promotions removeAllObjects];
                for (NSMutableDictionary *dict in result.body[@"promotions"]) {
                    BTTPromotionProcessModel *model = [BTTPromotionProcessModel yy_modelWithDictionary:dict];
                    [promotions addObject:model];
                }
                self.promotions = promotions.mutableCopy;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        dispatch_group_leave(group);
    }];
}

- (void)loadOtherData:(dispatch_group_t)group {
    NSMutableArray *banners = [NSMutableArray array];
    NSMutableArray *imageUrls = [NSMutableArray array];
    NSMutableArray *downloads = [NSMutableArray array];
    [IVNetwork requestPostWithUrl:BTTIndexBannerDownloads paramters:nil completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (![result.body[@"banners"] isKindOfClass:[NSNull class]]) {
                [self.banners removeAllObjects];
                [self.imageUrls removeAllObjects];
                for (NSMutableDictionary *dict in result.body[@"banners"]) {
                    BTTBannerModel *model = [BTTBannerModel yy_modelWithDictionary:dict];
                    [imageUrls addObject:model.imgurl];
                    [banners addObject:model];
                }
                self.banners = banners.mutableCopy;
                self.imageUrls = imageUrls.mutableCopy;
            }
            if (![result.body[@"downloads"] isKindOfClass:[NSNull class]]) {
                [self.downloads removeAllObjects];
                for (NSMutableDictionary *dict in result.body[@"downloads"]) {
                    BTTDownloadModel *model = [BTTDownloadModel yy_modelWithDictionary:dict];
                    [downloads addObject:model];
                }
                self.downloads = downloads.mutableCopy;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        dispatch_group_leave(group);
    }];
}

- (void)loadHightlightsBrand:(dispatch_group_t)group {
    NSMutableArray *Activities = [NSMutableArray array];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"formName"] = @"brandHighlights";
    params[@"dataType"] = @"1";
    [IVNetwork requestPostWithUrl:BTTBrandHighlights paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (result.body) {
                [self.Activities removeAllObjects];
                for (NSMutableDictionary *imageDict in result.body) {
                    BTTActivityModel *model = [BTTActivityModel yy_modelWithDictionary:imageDict];
                    [Activities addObject:model];
                }
                self.Activities = Activities.mutableCopy;
            }
        }
        dispatch_group_leave(group);
    }];
}
- (void)loadASGame:(dispatch_group_t)group {
    NSMutableArray *asGameData = [NSMutableArray array];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [IVNetwork requestPostWithUrl:BTTASWms paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (result.body) {
                [self.asGameData removeAllObjects];
                for (NSMutableDictionary *imageDict in result.body) {
                    BTTASGameModel *model = [BTTASGameModel yy_modelWithDictionary:imageDict];
                    //测试
//                    model.gameName = @"汪汪之家";
//                    model.gameEnName = @"The Dog‘s House";
//                    model.gameId = @"1547739735";
//                    model.gameCode = @"067";
//                    model.gameType = @"1";
//                    model.gameKind = @"1";
                    [asGameData addObject:model];
                }
                self.asGameData = asGameData.mutableCopy;
            }
        }
        dispatch_group_leave(group);
    }];
}
- (void)loadAssistiveDataWithBlock:(BTTAssistiveBlock)assistiveBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [IVNetwork requestPostWithUrl:BTTAssistiveData paramters:params completionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        IVJResponseObject *result = response;
        if ([result.head.errCode isEqualToString:@"0000"]) {
            if (result.body) {
                BTTAssistiveButtonModel *model = [BTTAssistiveButtonModel yy_modelWithDictionary:result.body];
                assistiveBlock(model);
            }
        }
    }];
}
#pragma mark - 动态添加属性
- (void)setNextGroup:(NSInteger)nextGroup {
    objc_setAssociatedObject(self, &BTTNextGroupKey, @(nextGroup), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)nextGroup {
    return [objc_getAssociatedObject(self, &BTTNextGroupKey) integerValue];
}

- (NSMutableArray *)imageUrls {
    NSMutableArray *imageUrls = objc_getAssociatedObject(self, _cmd);
    if (!imageUrls) {
        imageUrls = [NSMutableArray array];
        [self setImageUrls:imageUrls];
    }
    return imageUrls;
}

- (void)setImageUrls:(NSMutableArray *)imageUrls {
    objc_setAssociatedObject(self, @selector(imageUrls), imageUrls, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)noticeStr {
    return objc_getAssociatedObject(self, &noticeStrKey);
}

- (void)setNoticeStr:(NSString *)noticeStr {
    objc_setAssociatedObject(self, &noticeStrKey, noticeStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)headers {
    NSMutableArray *headers = objc_getAssociatedObject(self, _cmd);
    if (!headers) {
        headers = [NSMutableArray array];
        [self setHeaders:headers];
    }
    return headers;
}

- (void)setHeaders:(NSMutableArray *)headers {
     objc_setAssociatedObject(self, @selector(headers), headers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)asGameData {
    NSMutableArray *asGameData = objc_getAssociatedObject(self, _cmd);
    if (!asGameData) {
        asGameData = [NSMutableArray array];
        [self setAsGameData:asGameData];
    }
    return asGameData;
}

- (void)setAsGameData:(NSMutableArray *)asGameData
{
    objc_setAssociatedObject(self, @selector(asGameData), asGameData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)Activities {
    NSMutableArray *Activities = objc_getAssociatedObject(self, _cmd);
    if (!Activities) {
        Activities = [NSMutableArray array];
        [self setActivities:Activities];
    }
    return Activities;
}

- (void)setActivities:(NSMutableArray *)Activities {
    objc_setAssociatedObject(self, @selector(Activities), Activities, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)amounts {
    NSMutableArray *amounts = objc_getAssociatedObject(self, _cmd);
    if (!amounts) {
        amounts = [NSMutableArray array];
        [self setAmounts:amounts];
    }
    return amounts;
}

- (void)setAmounts:(NSMutableArray *)amounts {
    objc_setAssociatedObject(self, @selector(amounts), amounts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)posters {
    NSMutableArray *posters = objc_getAssociatedObject(self, _cmd);
    if (!posters) {
        posters = [NSMutableArray array];
        [self setPosters:posters];
    }
    return posters;
}

- (void)setPosters:(NSMutableArray *)posters {
    objc_setAssociatedObject(self, @selector(posters), posters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)promotions {
    NSMutableArray *promotions = objc_getAssociatedObject(self, _cmd);
    if (!promotions) {
        promotions = [NSMutableArray array];
        [self setPromotions:promotions];
    }
    return promotions;
}

- (void)setPromotions:(NSMutableArray *)promotions {
    objc_setAssociatedObject(self, @selector(promotions), promotions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)banners {
    NSMutableArray *banners = objc_getAssociatedObject(self, _cmd);
    if (!banners) {
        banners = [NSMutableArray array];
        [self setBanners:banners];
    }
    return banners;
}

- (void)setBanners:(NSMutableArray *)banners {
    objc_setAssociatedObject(self, @selector(banners), banners, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)downloads {
    NSMutableArray *downloads = objc_getAssociatedObject(self, _cmd);
    if (!downloads) {
        downloads = [NSMutableArray array];
        [self setDownloads:downloads];
    }
    return downloads;
}

- (void)setDownloads:(NSMutableArray *)downloads {
    objc_setAssociatedObject(self, @selector(downloads), downloads, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)games {
    NSMutableArray *games = objc_getAssociatedObject(self, _cmd);
    if (!games) {
        games = [NSMutableArray array];
        [self setGames:games];
    }
    return games;
}

- (void)setGames:(NSMutableArray *)games {
    objc_setAssociatedObject(self, @selector(games), games, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setAvailableNum:(NSInteger)availableNum {
    objc_setAssociatedObject(self, &BTTAvailableNumKey, @(availableNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)availableNum {
    return [objc_getAssociatedObject(self, &BTTAvailableNumKey) integerValue];
}
- (NSMutableArray *)lotteryNumList {
    NSMutableArray *lotteryNumList = objc_getAssociatedObject(self, _cmd);
    if (!lotteryNumList) {
        lotteryNumList = [NSMutableArray array];
        [self setLotteryNumList:lotteryNumList];
    }
    return lotteryNumList;
}

- (void)setLotteryNumList:(NSMutableArray *)lotteryNumList {
    objc_setAssociatedObject(self, @selector(lotteryNumList), lotteryNumList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setChanceCount:(NSInteger)chanceCount {
    objc_setAssociatedObject(self, &BTTChanceCountKey, @(chanceCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)chanceCount {
    return [objc_getAssociatedObject(self, &BTTChanceCountKey) integerValue];
}
@end
