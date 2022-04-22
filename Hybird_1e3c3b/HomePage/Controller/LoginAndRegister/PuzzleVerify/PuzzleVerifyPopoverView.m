//
//  PuzzleVerifyPopoverView.m
//  Hybird_1e3c3b
//
//  Created by Kevin on 2022/4/18.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "PuzzleVerifyPopoverView.h"

#import "PuzzleVerifyPopoverView.h"
#import "PuzzleVerifyView.h"
#import <Masonry/Masonry.h>

NSInteger const kBTTLoginOrRegisterCaptchaPuzzle = 3;

@interface PuzzleVerifyPopoverView()<PuzzleVerifyViewDelegate>

@property(nonatomic,strong) UIView *bgView;
@property(nonatomic,strong) UIView *contentView;

@property(nonatomic,strong) PuzzleVerifyView *verifyView;
@property(nonatomic,strong) UIView *slidView;
@property(nonatomic,strong) UILabel *slidTitle;
@property(nonatomic,strong) UISlider *slider;

@property(nonatomic,strong) UIButton *cancelButton;
@property(nonatomic,assign) BOOL sliding;
@property(nonatomic,strong) CAGradientLayer *gradientLayer;
@property(nonatomic,strong) CABasicAnimation *locationAnimation;
@property(nonatomic,strong) UIButton *refreshButton;

@end

@implementation PuzzleVerifyPopoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setLayout];
    }
    return self;
}

-(void)setupUI {
    self.alpha = 0;
    self.layer.cornerRadius = 0;
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.verifyView];
    
    [self addSubview:self.slidView];
    [self.slidView addSubview:self.slidTitle];
    [self.slidView addSubview:self.slider];

    [self addSubview:self.cancelButton];
    [self addSubview:self.refreshButton];
}

-(void)setLayout {
    [self.verifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(95);
    }];
    
    [self.slidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyView.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(36);
    }];
    
    [self.slidTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(4);
        make.right.mas_equalTo(-4);
        make.height.mas_equalTo(36);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.slidView.mas_bottom).offset(10);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self);
    }];
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.verifyView);
        make.width.height.offset(30);
    }];
}

#pragma mark - event methods

- (void)refresh {
    if ([self.delegate respondsToSelector:@selector(puzzleViewRefresh)]) {
        [self.delegate puzzleViewRefresh];
    }
}

- (void)cancel {
    if ([self.delegate respondsToSelector:@selector(puzzleViewCanceled)]) {
        [self.delegate puzzleViewCanceled];
    }
    [self hide];
}

-(void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

-(void)show {
    if ([self superview]) {
        [self reset];
        return;
    }
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    
    [superView addSubview:self.bgView];
    [superView addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView);
        make.centerY.equalTo(superView).offset(-20);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }completion:^(BOOL finished) {}];
}

- (void)reset {
    _verifyView.puzzleXPercentage = 0;
    _slider.value = 0.0;
}

- (void)dismiss {
    [self hide];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_gradientLayer) {
        UILabel *animationLabel = [[UILabel alloc] initWithFrame:_slidTitle.bounds];
        animationLabel.text = _slidTitle.text;
        animationLabel.font = _slidTitle.font;
        animationLabel.textAlignment = NSTextAlignmentCenter;
        CGFloat duration = 1.0;
        NSArray *gradientColors = @[(id)[UIColor colorWithWhite:0.4 alpha:1.0].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithWhite:0.4 alpha:1.0].CGColor];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.bounds = _slidTitle.bounds;
        gradientLayer.position = CGPointMake(_slidTitle.width / 2.0, _slidTitle.height / 2.0);
        
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 0);
            
        gradientLayer.colors = gradientColors;
        gradientLayer.locations = @[@(0.2), @(0.5), @(0.8)];
        self.gradientLayer = gradientLayer;
        CABasicAnimation *locationAnimation = [CABasicAnimation animationWithKeyPath:@"locations"];
        locationAnimation.fromValue = @[@(0),@(0.0),@(0.3)];
        locationAnimation.toValue = @[@(0.7),@(1),@(1)];
        locationAnimation.duration = duration;
        locationAnimation.repeatCount = HUGE;
        locationAnimation.autoreverses = NO;
        self.locationAnimation = locationAnimation;
        [_slidTitle.layer addSublayer:gradientLayer];
        _slidTitle.maskView = animationLabel;
        gradientLayer.mask = animationLabel.layer;
        [gradientLayer addAnimation:locationAnimation forKey:locationAnimation.keyPath];
    }
}

#pragma mark - slider actions

// UISlider actions
- (void)sliderUp:(UISlider *)sender {
    if (_sliding) {
        _sliding = NO;
        [_verifyView performCallback];
    }
}

- (void)sliderDown:(UISlider *)sender {
    _sliding = YES;
}

- (void)sliderChanged:(UISlider *)sender {
    _verifyView.puzzleXPercentage = sender.value;
}

#pragma mark - PuzzleVerifyViewDelegate

- (void)puzzleVerifyView:(PuzzleVerifyView *)puzzleVerifyView didChangedPuzzlePosition:(CGPoint)newPosition xPercentage:(CGFloat)xPercentage yPercentage:(CGFloat)yPercentage {
    if ([self.delegate respondsToSelector:@selector(puzzleViewDidChangePosition:)]) {
        [self.delegate puzzleViewDidChangePosition:newPosition];
    }
}

#pragma mark - setter and getter

- (void)setOriginImage:(UIImage *)originImage {
    _verifyView.originImage = originImage;
}

- (void)setShadeImage:(UIImage *)shadeImage {
    _verifyView.shadeImage = shadeImage;
}

- (void)setCutoutImage:(UIImage *)cutoutImage {
    _verifyView.cutoutImage = cutoutImage;
}

- (void)setPosition:(CGPoint)position {
    _verifyView.puzzlePosition = CGPointMake(0, position.y);
}

-(UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor:[UIColor whiteColor]];
        _cancelButton.layer.borderColor = [UIColor brownColor].CGColor;
        _cancelButton.layer.borderWidth = 2.0;
        _cancelButton.layer.cornerRadius = 5.0;
        _cancelButton.clipsToBounds = true;
        _cancelButton.adjustsImageWhenHighlighted = NO;
        [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setImage:[UIImage imageNamed:@"bjl_refresh"] forState:UIControlStateNormal];
        _refreshButton.adjustsImageWhenHighlighted = NO;
        [_refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

-(PuzzleVerifyView *)verifyView{
    
    if (!_verifyView) {
        _verifyView = [[PuzzleVerifyView alloc] initWithFrame:CGRectMake(20, 20, 300, 95)];
        _verifyView.puzzlePosition = CGPointMake(100, 30);
        _verifyView.puzzleXPercentage = 0;
        _verifyView.layer.masksToBounds = YES;
        _verifyView.delegate = self;
    }
    return _verifyView;
}

-(UIView *)slidView{
    
    if (!_slidView) {
        _slidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 36)];
        _slidView.backgroundColor = [UIColor clearColor];
        _slidView.layer.borderWidth = 1;
        _slidView.layer.masksToBounds = YES;
        _slidView.layer.borderColor = [UIColor brownColor].CGColor;
    }
    return _slidView;
}

-(UILabel *)slidTitle {
    if (!_slidTitle) {
        _slidTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
        _slidTitle.textColor = [UIColor clearColor];
        _slidTitle.font = [UIFont boldSystemFontOfSize:16];
        _slidTitle.textAlignment = NSTextAlignmentCenter;
        _slidTitle.text = @"拖动滑块完成拼图验证>>>";
    }
    return _slidTitle;
}

-(UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.continuous = YES;
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 1.0;
        _slider.value = 0.0;
        _slider.backgroundColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor clearColor];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        // Set the slider action methods
        [_slider addTarget:self
                    action:@selector(sliderUp:)
          forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self
                    action:@selector(sliderUp:)
          forControlEvents:UIControlEventTouchUpOutside];
        [_slider addTarget:self
                    action:@selector(sliderDown:)
          forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self
                    action:@selector(sliderChanged:)
          forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

-(UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
        [_bgView addGestureRecognizer:tap];
    }
    return _bgView;
}

@end
