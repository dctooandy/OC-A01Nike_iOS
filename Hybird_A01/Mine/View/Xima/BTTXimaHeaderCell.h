//
//  BTTXimaHeaderCell.h
//  Hybird_A01
//
//  Created by Domino on 29/10/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTBaseCollectionViewCell.h"

typedef enum {
    BTTXimaHeaderBtnOneTypeLastWeekNormal,  ///< 上周
    BTTXimaHeaderBtnOneTypeLastWeekSelect,
    BTTXimaHeaderBtnOneTypeThisWeekNormal,   ///< 本周
    BTTXimaHeaderBtnOneTypeThisWeekSelect
}BTTXimaHeaderBtnOneType;

typedef enum {
    BTTXimaHeaderBtnTwoTypeThisWeekNormal,  ///< 本周
    BTTXimaHeaderBtnTwoTypeThisWeekSelect,
    BTTXimaHeaderBtnTwoTypeOtherNormal,     ///< 其他游戏厅
    BTTXimaHeaderBtnTwoTypeOtherSelect
}BTTXimaHeaderBtnTwoType;

NS_ASSUME_NONNULL_BEGIN

@interface BTTXimaHeaderCell : BTTBaseCollectionViewCell

@property (nonatomic, assign) BTTXimaHeaderBtnOneType btnOneType;  ///< 第一个按钮状态

@property (nonatomic, assign) BTTXimaHeaderBtnTwoType btnTwoType;  ///< 第二个按钮状态

@end

NS_ASSUME_NONNULL_END
