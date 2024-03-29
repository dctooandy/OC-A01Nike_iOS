//
//  BTTAppCollectionViewCell.m
//  Hybird_1e3c3b
//
//  Created by Domino on 2018/8/15.
//  Copyright © 2018年 Key. All rights reserved.
//

#import "BTTAppCollectionViewCell.h"
#import "BTTDownloadModel.h"

@interface BTTAppCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UILabel *appName;


@end

@implementation BTTAppCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(BTTDownloadModel *)model {
    _model = model;
    if (model) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.icon.path] placeholderImage:ImageNamed(@"default_5")];
        self.appName.text = model.name;
    }
}

@end
