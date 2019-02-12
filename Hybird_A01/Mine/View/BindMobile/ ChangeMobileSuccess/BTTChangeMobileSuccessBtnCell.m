//
//  BTTChangeMobileSuccessBtnCell.m
//  Hybird_A01
//
//  Created by Domino on 19/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTChangeMobileSuccessBtnCell.h"

@implementation BTTChangeMobileSuccessBtnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.mineSparaterType = BTTMineSparaterTypeNone;
    self.backgroundColor = [UIColor colorWithHexString:@"212229"];
    self.memberCenterBtn.layer.cornerRadius = 4;
}
- (IBAction)backMemberCenter:(id)sender {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(sender);
    }
}

@end
