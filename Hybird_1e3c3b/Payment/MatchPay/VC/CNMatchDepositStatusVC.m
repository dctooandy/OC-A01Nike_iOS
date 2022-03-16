//
//  CNMatchDepositStatusVC.m
//  Hybird_1e3c3b
//
//  Created by cean on 2/17/22.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "CNMatchDepositStatusVC.h"
#import "CNMAlertView.h"
#import <ZLPhotoBrowser/ZLPhotoBrowser.h>
#import <ZLPhotoBrowser/ZLShowBigImgViewController.h>
#import "BTTMineViewController+LoadData.h"

#import "CNMatchPayRequest.h"
#import "PublicMethod.h"

/// 页面 UI 状态区分
typedef NS_ENUM(NSUInteger, CNMPayUIStatus) {
    CNMPayUIStatusSubmit,  //已提交
    CNMPayUIStatusPaying,  //等待支付
    CNMPayUIStatusConfirm, //已确认
    CNMPayUIStatusSuccess  //已完成
};

@interface CNMatchDepositStatusVC ()

#pragma mark - 中间金额视图
@property (weak, nonatomic) IBOutlet UILabel *amountLb;
@property (weak, nonatomic) IBOutlet UILabel *amountTipLb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *amountTipLbH;

#pragma mark - 中间银行卡视图，一共有7行信息栏
@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (weak, nonatomic) IBOutlet UIImageView *bankLogo;
@property (weak, nonatomic) IBOutlet UILabel *bankName;
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *accountNo;
@property (weak, nonatomic) IBOutlet UILabel *subBankName;
/// 复制内容标签组
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray <UILabel *> *contentLbArray;
/// 复制按钮
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btnCopyArray;

#pragma mark - 底部按钮组
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
#pragma mark - 相册选择
@property (weak, nonatomic) IBOutlet UIView *midView;
@property (strong, nonatomic) IBOutlet UIView *pictureView;

/// 上面一个按钮
@property (weak, nonatomic) IBOutlet UIButton *pictureBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLb1;
/// 存放图片
@property (nonatomic, strong) NSMutableArray *pictureArr1;
/// 存放上传后返回图片名
@property (nonatomic, strong) NSMutableArray *pictureName1;

/// 下面面按钮组
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray <UIButton *> *pictureBtnArr;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray <UIButton *> *deleteBtnArr;
@property (weak, nonatomic) IBOutlet UILabel *countLb2;
/// 存放图片
@property (nonatomic, strong) NSMutableArray *pictureArr2;
/// 存放上传后返回图片名
@property (nonatomic, strong) NSMutableArray *pictureName2;

@property (nonatomic, strong) ZLPhotoActionSheet *photoSheet;

#pragma mark - 数据参数
@property (nonatomic, strong) CNMBankModel *bankModel;
/// 默认 CNMPayUIStatusPaying
@property (nonatomic, assign) CNMPayUIStatus status;


@end

@implementation CNMatchDepositStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.pictureArr1 = [NSMutableArray arrayWithCapacity:1];
    self.pictureArr2 = [NSMutableArray arrayWithCapacity:4];
    self.pictureName1 = [NSMutableArray arrayWithCapacity:1];
    self.pictureName2 = [NSMutableArray arrayWithCapacity:4];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupUI {
    self.bankView.layer.borderWidth = 1;
    self.bankView.layer.borderColor = kHexColor(0x3A3D46).CGColor;
    self.bankView.layer.cornerRadius = 8;
    self.title = @"存款";
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    [self showLoading];
    [CNMatchPayRequest queryDepisit:self.transactionId finish:^(id  _Nullable response, NSError * _Nullable error) {
        [weakSelf hideLoading];
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)response;
            [weakSelf reloadUIWithModel:[[CNMBankModel alloc] initWithDictionary:[dic objectForKey:@"data"] error:nil]];
            return;
        }
        IVJResponseObject *result = response;
        [weakSelf showError:result.head.errMsg];
    }];
}

- (void)reloadUIWithModel:(CNMBankModel *)bank {
    if (bank == nil) {
        return;
    }
    self.bankModel = bank;
    
    // 银行卡栏目信息
    self.amountLb.text = [NSString stringWithFormat:@"%ld", bank.amount.integerValue];
    [self.bankLogo sd_setImageWithURL:[NSURL URLWithString:[PublicMethod nowCDNWithUrl:bank.bankIcon]]];
    self.bankName.text = bank.bankName;
    self.accountName.text = bank.bankAccountName;
    self.accountNo.text = bank.bankAccountNo;
    self.subBankName.text = bank.bankBranchName;
    
    switch (bank.status) {
        case CNMPayBillStatusSubmit:
            break;
        case CNMPayBillStatusPaying:
            break;
        case CNMPayBillStatusCancel:
            // 订单取消，直接回到首页
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        case CNMPayBillStatusConfirm:
            
            break;
        case CNMPayBillStatusUnMatch:
            
            break;
        default:
            
            break;
    }
}

#pragma mark - 按钮组事件

- (IBAction)confirm:(UIButton *)sender {
    
    /* 需求变更 屏蔽图片了
    if (self.pictureView.superview) {
        // 上传图片
        [self uploadImages];
        return;
    }
    self.pictureView.frame = self.midView.bounds;
    [self.midView addSubview:self.pictureView];
    sender.enabled = NO; */
    
    [self uploadFinish];
}

- (void)uploadFinish {
    /* 屏蔽图片
    // 只要没有，重选上传
    if (self.pictureName1.count == 0 || self.pictureName2.count == 0) {
        [self uploadImages];
        return;
    } */
    // 上报数据
    [self showLoading];
    [CNMatchPayRequest commitDepisit:self.transactionId receiptImg:self.pictureName1.firstObject transactionImg:self.pictureName2 finish:^(id  _Nullable response, NSError * _Nullable error) {
        [self hideLoading];
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)response;
            if ([[dic objectForKey:@"code"] isEqualToString:@"00000"]) {
                [self goToBack];
            } else {
                [self showError:[dic objectForKey:@"message"]];
            }
        }
    }];
}

- (IBAction)copyContent:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.contentLbArray[sender.tag].text;
    [self showSuccess:@"复制成功"];
}

- (void)goToBack {
    if (_backToLastVC) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - 选择相册

- (IBAction)selectSinglePicture:(UIButton *)sender {
    if (sender.selected) {
        //放大图片查看
        [self showBigImages:self.pictureArr1 index:sender.tag];
        return;
    }
    self.photoSheet.configuration.maxSelectCount = 1;
    self.photoSheet.configuration.maxPreviewCount = 1;
    self.photoSheet.configuration.allowTakePhotoInLibrary = NO;
    __weak typeof(sender) weakSender = sender;
    __weak typeof(self) weakSelf = self;
    self.photoSheet.selectImageBlock = ^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        [weakSender setBackgroundImage:images.firstObject forState:UIControlStateSelected];
        weakSender.selected = YES;
        weakSelf.deleteBtn.hidden = NO;
        [weakSelf.pictureArr1 addObject:images.firstObject];
        [weakSelf checkConfirmBtnEnable];
    };
    [self.photoSheet showPhotoLibrary];
}

- (IBAction)selectPictures:(UIButton *)sender {
    if (sender.selected) {
        //放大图片查看
        [self showBigImages:self.pictureArr2 index:sender.tag];
        return;
    }
    NSInteger leftCount = 4 - self.pictureArr2.count;
    self.photoSheet.configuration.maxSelectCount = leftCount;
    self.photoSheet.configuration.allowTakePhotoInLibrary = NO;
    __weak typeof(sender) weakSender = sender;
    __weak typeof(self) weakSelf = self;
    self.photoSheet.selectImageBlock = ^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        weakSender.selected = YES;
        [weakSelf.pictureArr2 addObjectsFromArray:images];
        //按序加载图片
        [weakSelf reloadImages];
    };
    [self.photoSheet showPhotoLibrary];
}

/// 放大图片查看
- (void)showBigImages:(NSArray *)images index:(NSInteger)index {
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:images.count];
    for (UIImage *img in images) {
        [photos addObject:GetDictForPreviewPhoto(img, ZLPreviewPhotoTypeUIImage)];
    }
    ZLPhotoActionSheet *sheet = [[ZLPhotoActionSheet alloc] init];
    sheet.sender = self;
    sheet.configuration.allowSelectImage = NO;
    sheet.configuration.allowSelectVideo = NO;
    sheet.configuration.allowTakePhotoInLibrary = NO;
    sheet.configuration.allowEditImage = NO;
    sheet.configuration.navTitleColor = self.view.backgroundColor;
    sheet.configuration.navBarColor = kHexColor(0x4083E8);
    [sheet previewPhotos:photos index:index hideToolBar:YES complete:^(NSArray * _Nonnull photos) {}];
}

- (void)reloadImages {
    
    for (UIButton *btn in self.pictureBtnArr) {
        btn.selected = NO;
    }
    
    for (UIButton *btn in self.deleteBtnArr) {
        btn.hidden = YES;
    }
    
    for (int i = 0; i < self.pictureArr2.count; i++) {
        [self.pictureBtnArr[i] setImage:self.pictureArr2[i] forState:UIControlStateSelected];
        self.pictureBtnArr[i].selected = YES;
        self.deleteBtnArr[i].hidden = NO;
    }
    [self checkConfirmBtnEnable];
}

- (void)checkConfirmBtnEnable {
    self.countLb1.text = [NSString stringWithFormat:@"%ld/1", self.pictureArr1.count];
    self.countLb2.text = [NSString stringWithFormat:@"%ld/4", self.pictureArr2.count];
    self.confirmBtn.enabled = (self.pictureArr1.count > 0 && self.pictureArr2.count > 0);
}

- (IBAction)deleteSinglePicture:(UIButton *)sender {
    self.pictureBtn.selected = NO;
    sender.hidden = YES;
    [self.pictureArr1 removeAllObjects];
    [self checkConfirmBtnEnable];
}

- (IBAction)deleteSelectPictures:(UIButton *)sender {
    [self.pictureArr2 removeObjectAtIndex:sender.tag];
    [self reloadImages];
}

#pragma mark - 图片上传

/// 图片上传
- (void)uploadImages {
    [self showLoading];
    __block NSInteger uploadCount = self.pictureArr1.count + self.pictureArr2.count;
    // 有就不用再次上传了
    if (self.pictureName1.count == 0) {
        [CNMatchPayRequest uploadImage:self.pictureArr1.lastObject finish:^(id  _Nullable response, NSError * _Nullable error) {
            uploadCount -= 1;
            if ([response isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)response;
                NSString *name = [dic objectForKey:@"fileName"];
                if (name) {
                    [self.pictureName1 addObject:name];
                }
            }
            if (uploadCount == 0) {
                [self uploadFinish];
            }
        }];
    } else {
        uploadCount -= self.pictureArr1.count;
    }
    
    // 有就不用再次上传了
    if (self.pictureName2.count > 0) {
        uploadCount -= self.pictureArr2.count;
        return;
    }
    for (int i = 0; i < self.pictureArr2.count; i ++) {
        // 同时上传会超时
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((i+1)*2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [CNMatchPayRequest uploadImage:self.pictureArr2[i] finish:^(id  _Nullable response, NSError * _Nullable error) {
                uploadCount -= 1;
                if ([response isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary *)response;
                    NSString *name = [dic objectForKey:@"fileName"];
                    if (name) {
                        [self.pictureName2 addObject:name];
                    }
                }
                if (uploadCount == 0) {
                    [self uploadFinish];
                }
            }];
        });
    }
}

- (ZLPhotoActionSheet *)photoSheet {
    if (!_photoSheet) {
        _photoSheet = [[ZLPhotoActionSheet alloc] init];
        _photoSheet.sender = self;
        _photoSheet.configuration.allowSelectImage = YES;
        _photoSheet.configuration.allowSelectVideo = NO;
        _photoSheet.configuration.allowTakePhotoInLibrary = NO;
        _photoSheet.configuration.allowEditImage = YES;
        _photoSheet.configuration.allowSelectOriginal = NO;
        _photoSheet.configuration.navTitleColor = self.view.backgroundColor;
        _photoSheet.configuration.navBarColor = kHexColor(0x4083E8);
    }
    return _photoSheet;
}
@end
