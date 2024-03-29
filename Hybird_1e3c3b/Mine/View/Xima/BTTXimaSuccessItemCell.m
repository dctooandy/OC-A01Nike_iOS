//
//  BTTXimaSuccessItemCell.m
//  Hybird_1e3c3b
//
//  Created by Domino on 24/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTXimaSuccessItemCell.h"
#import "BTTXimaSuccessItemModel.h"

@interface BTTXimaSuccessItemCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;


@end

@implementation BTTXimaSuccessItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.mineSparaterType = BTTMineSparaterTypeNone;
    self.backgroundColor = [UIColor colorWithHexString:@"212229"];
}


- (void)setModel:(BTTXimaSuccessItemModel *)model {
    _model = model;
    if ([[IVNetwork savedUserInfo].uiMode isEqualToString:@"USDT"]) {
        self.nameLabel.text = model.xmTypeName;
        self.noticeLabel.text = @"成功! 洗码金额已添加至您账户";
    } else {
        self.nameLabel.text = [NSString stringWithFormat:@"%@洗码成功！", model.xmTypeName];
        self.noticeLabel.text = [NSString stringWithFormat:@"本次洗码金额：%@元", [PublicMethod transferNumToThousandFormat:[model.xmAmount floatValue]]];
    }
}

@end
