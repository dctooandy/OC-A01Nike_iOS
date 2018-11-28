//
//  CNPayTipView.m
//  A05_iPhone
//
//  Created by cean.q on 2018/10/3.
//  Copyright © 2018年 WRD. All rights reserved.
//

#import "CNPayTipView.h"
#import "CNPayConstant.h"

@interface CNPayTipView ()
@property (weak, nonatomic) IBOutlet UIButton *repayBtn;
@end

@implementation CNPayTipView

+ (instancetype)tipView {
    return [[NSBundle mainBundle] loadNibNamed:@"CNPayTipView" owner:nil options:nil].firstObject;
}

+ (void)showTipView {
    CNPayTipView *tipView = [CNPayTipView tipView];
    tipView.repayBtn.layer.borderColor = COLOR_HEX(0xD8D8D8).CGColor;
    tipView.repayBtn.layer.borderWidth = 1;
    [tipView show];
}

///显示
- (void)show {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self.frame = window.bounds;
    [window addSubview:self];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}

- (IBAction)submitAction:(UIButton *)sender {
    [self removeFromSuperview];
    if (_btnAcitonBlock) {
        _btnAcitonBlock();
    }
}

- (IBAction)closeAction:(UIButton *)sender {
    [self removeFromSuperview];
}
@end
