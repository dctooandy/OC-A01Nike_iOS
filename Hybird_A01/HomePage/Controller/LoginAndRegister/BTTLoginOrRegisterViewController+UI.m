//
//  BTTLoginOrRegisterViewController+UI.m
//  Hybird_A01
//
//  Created by Domino on 13/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTLoginOrRegisterViewController+UI.h"
#import "BTTUnlockPopView.h"
#import "BTTAndroid88PopView.h"

@implementation BTTLoginOrRegisterViewController (UI)

- (void)showPopViewWithAccount:(NSString *)account {
    BTTUnlockPopView *customView = [BTTUnlockPopView viewFromXib];
    
    customView.account = account;
    customView.layer.cornerRadius = 5;
    customView.clipsToBounds = YES;
    customView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 50, 313);
    BTTAnimationPopView *popView = [[BTTAnimationPopView alloc] initWithCustomView:customView popStyle:BTTAnimationPopStyleScale dismissStyle:BTTAnimationDismissStyleNO];
    popView.isClickBGDismiss = YES;
    [popView pop];
    customView.dismissBlock = ^{
        [popView dismiss];
    };
}

- (void)showPopView {
    BTTAndroid88PopView *customView = [BTTAndroid88PopView viewFromXib];
    customView.frame = CGRectMake(0, 0, 320, 360);
    BTTAnimationPopView *popView = [[BTTAnimationPopView alloc] initWithCustomView:customView popStyle:BTTAnimationPopStyleScale dismissStyle:BTTAnimationDismissStyleNO];
    popView.isClickBGDismiss = YES;
    [popView pop];
    customView.dismissBlock = ^{
        [popView dismiss];
    };
    customView.btnBlock = ^(UIButton *btn) {
        
    };
}

@end
