//
//  RedPacketsRainView.h
//  Hybird_1e3c3b
//
//  Created by RM03 on 2022/1/3.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "BTTBaseAnimationPopView.h"
/**
 显示时动画弹框样式
 */
typedef NS_ENUM(NSInteger, RedPocketsViewStyle) {
    RedPocketsViewBegin = 0,
    RedPocketsViewResult
};
typedef NS_ENUM(NSInteger, RedPocketsViewPosition) {
    RedPocketsViewToFront = 0,
    RedPocketsViewToBack
};
NS_ASSUME_NONNULL_BEGIN

@interface RedPacketsRainView : BTTBaseAnimationPopView
- (void)configForRedPocketsView:(RedPocketsViewStyle)style withDuration:(int)duration;
@end

NS_ASSUME_NONNULL_END
