//
//  CNMAmountSelectCCell.m
//  Hybird_1e3c3b
//
//  Created by cean on 2/16/22.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "CNMAmountSelectCCell.h"

@implementation CNMAmountSelectCCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.checkIV.layer.borderWidth = 1;
    self.checkIV.layer.borderColor = kHexColor(0x55AAF5).CGColor;
}

@end
