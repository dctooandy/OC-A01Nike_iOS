//
//  BTTLoginCodeCell.m
//  Hybird_1e3c3b
//
//  Created by Domino on 14/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTLoginCodeCell.h"

@interface BTTLoginCodeCell () {
    dispatch_source_t _timer;
}

@property (weak, nonatomic) IBOutlet UIView *bgView;


@end

@implementation BTTLoginCodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 4;
    self.codeBtn.enabled = NO;
    [self.accountTextField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *refreshCode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshCode:)];
    [self.codeImageView addGestureRecognizer:refreshCode];
}

- (void)refreshCode:(UITapGestureRecognizer *)tap {
    if (self.clickEventBlock) {
        self.clickEventBlock(tap);
    }
}

- (IBAction)sendCode:(UIButton *)sender {
    [self countDown];
    if (self.clickEventBlock) {
        self.clickEventBlock(self.accountTextField.text);
    }
}


- (void)textFieldChange:(UITextField *)textField {
    if ([textField.text hasPrefix:@"g"]) {
        if (textField.text.length > 10) {
            [MBProgressHUD showError:@"账号长度不能超过9位" toView:nil];
            textField.text = [textField.text substringToIndex:10];
            
            
        }
        _pwdTextField.placeholder = @"密码";
        self.eyeBtn.hidden = NO;
        self.codeBtn.hidden = YES;
        self.eyeLeftConstants.priority = 750;
        self.sendBtnLeftConstants.priority = 250;
    } else {
        if ([textField.text hasPrefix:@"1"] && [PublicMethod isNum:textField.text]) {
            if (textField.text.length > 11 ) {
                textField.text = [textField.text substringToIndex:11];
            }
        } else {
            if (textField.text.length > 10) {
                [MBProgressHUD showError:@"账号长度不能超过9位" toView:nil];
                textField.text = [textField.text substringToIndex:10];
            }
        }
    }
    
    if ([PublicMethod isValidatePhone:textField.text]) {
        self.codeBtn.enabled = YES;
        _pwdTextField.placeholder = @"手机验证码";
        self.pwdTextField.secureTextEntry = NO;
        self.eyeBtn.hidden = YES;
        self.codeBtn.hidden = NO;
        self.eyeLeftConstants.priority = 250;
        self.sendBtnLeftConstants.priority = 750;
    } else {
        self.codeBtn.enabled = NO;
        self.pwdTextField.secureTextEntry = YES;
        if (_timer) {
            dispatch_source_cancel(_timer);
        }
        self.codeBtn.titleLabel.text = @"发送验证码";
        [self.codeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        self.pwdTextField.text = @"";
    }
    if (!textField.text.length) {
        _pwdTextField.placeholder = @"密码/手机验证码";
        self.eyeBtn.selected = NO;
        self.eyeBtn.hidden = NO;
        self.codeBtn.hidden = YES;
        self.eyeLeftConstants.priority = 750;
        self.sendBtnLeftConstants.priority = 250;
    }
}

- (void)countDown {
    __block int timeout = 60; // 倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0 * NSEC_PER_SEC, 0); // 每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(self->_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                if ([PublicMethod isValidatePhone:self.accountTextField.text]) {
                    self.codeBtn.enabled = YES;
                    self.codeBtn.titleLabel.text = @"重新发送";
                    [self.codeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                } else {
                    self.codeBtn.enabled = NO;
                    self.codeBtn.titleLabel.text = @"发送验证码";
                    [self.codeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
                }
                
            });
        } else {
            int seconds = timeout;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];;
            if (seconds < 10) {
                strTime = [NSString stringWithFormat:@"%.1d", seconds];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                self.codeBtn.titleLabel.text = [NSString stringWithFormat:@"重新发送(%@)",strTime];
                [self.codeBtn setTitle:[NSString stringWithFormat:@"重新发送(%@)",strTime] forState:UIControlStateNormal];
                
                self.codeBtn.enabled = NO;
            });
            
            timeout--;
        }
        
    });
    dispatch_resume(_timer);
    
}

- (IBAction)eyeBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    _pwdTextField.secureTextEntry = !sender.selected;
}

@end
