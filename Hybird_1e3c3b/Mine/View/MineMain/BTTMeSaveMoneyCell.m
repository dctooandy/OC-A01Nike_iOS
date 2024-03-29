//
//  BTTMeSaveMoneyCell.m
//  Hybird_1e3c3b
//
//  Created by Domino on 2018/10/17.
//  Copyright © 2018年 BTT. All rights reserved.
//

#import "BTTMeSaveMoneyCell.h"
#import "BTTMeMainModel.h"

@interface BTTMeSaveMoneyCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImg;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstants;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstants;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstants;

@end

@implementation BTTMeSaveMoneyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.mineSparaterType = BTTMineSparaterTypeNone;
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor =  COLOR_RGBA(36, 40, 49, 1);
    [self setSelectedBackgroundView:backgroundView];
}

- (void)setModel:(BTTMeMainModel *)model {
    _model = model;
    self.iconImg.image = ImageNamed(model.iconName);
    self.nameLabel.text = model.name;
    if ([model.name isEqualToString:@"银行快捷网银"] ||
        [model.name isEqualToString:@"点卡"] ||
        [model.name isEqualToString:@"钻石币"] ||
        [model.name isEqualToString:@"比特币"] ||
        [model.name isEqualToString:@"微信条码支付"]) {
        self.topConstants.constant = 15;
        self.heightConstants.constant = 40;
        self.widthConstants.constant = 40;
    } else  {
        self.topConstants.constant = 5;
        self.heightConstants.constant = 50;
        self.widthConstants.constant = 50;
    }
    
    if ([model.name isEqualToString:@"支付宝/微信/QQ/京东WAP"] || [model.name isEqualToString:@"微信/QQ/京东WAP"]) {
        self.nameLabel.font = [UIFont systemFontOfSize:8];
    } else {
        self.nameLabel.font = [UIFont systemFontOfSize:11];
    }
}

@end
