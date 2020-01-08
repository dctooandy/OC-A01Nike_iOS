//
//  CNPayUSDTStep1VC.m
//  Hybird_A01
//
//  Created by Levy on 12/24/19.
//  Copyright © 2019 BTT. All rights reserved.
//

#import "CNPayUSDTStep1VC.h"
#import "CNPayConstant.h"
#import "USDTWalletCollectionCell.h"
#import "CNPayUSDTRateModel.h"
#import "BTTPayUsdtNoticeView.h"

@interface CNPayUSDTStep1VC ()<UITextFieldDelegate,UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *walletView;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *exchangeRateLabel;
@property (weak, nonatomic) IBOutlet UITextField *usdtInputField;
@property (weak, nonatomic) IBOutlet UILabel *rmbLabel;
@property (weak, nonatomic) IBOutlet UIView *normalWalletView;
@property (weak, nonatomic) IBOutlet UIView *elseWalletView;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UILabel *elseRateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addressCopyImg;
@property (weak, nonatomic) IBOutlet UILabel *walletAddressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImg;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *scanTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *noteInfoView;
@property (weak, nonatomic) IBOutlet UILabel *noteBottomLabel;
@property (nonatomic, strong) UICollectionView *walletCollectionView;
@property (nonatomic, strong) NSArray *itemsArray;
@property (nonatomic, strong) NSArray *bankCodeArray;
@property (nonatomic, strong) NSArray *itemImageArray;
@property (nonatomic, strong) NSArray *itemDataArray;
@property (nonatomic, assign) CGFloat usdtRate;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NSString *handType;
@end

@implementation CNPayUSDTStep1VC

- (UICollectionView *)walletCollectionView
{
    if (!_walletCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 15;  //行间距
        flowLayout.minimumInteritemSpacing = 15; //列间距
//        flowLayout.estimatedItemSize = CGSizeMake((SCREEN_WIDTH-60)/3, 36);  //预定的itemsize
        flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH-60)/3, 36); //固定的itemsize
        flowLayout.headerReferenceSize = CGSizeMake(0, 43);
        //初始化 UICollectionView
        _walletCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _walletCollectionView.delegate = self; //设置代理
        _walletCollectionView.dataSource = self;   //设置数据来源
        _walletCollectionView.backgroundColor = kBlackLightColor;
        
        [_walletCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionViewHeader"];
 
        _walletCollectionView.bounces = NO;   //设置弹跳
        _walletCollectionView.alwaysBounceVertical = NO;  //只允许垂直方向滑动
        //注册 cell  为了cell的重用机制  使用NIB  也可以使用代码 registerClass xxxx
        [_walletCollectionView registerClass:[USDTWalletCollectionCell class] forCellWithReuseIdentifier:@"USDTWalletCollectionCell"];
    }
    return _walletCollectionView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _selectedIndex = 0;
    self.handType = @"";
    [self setViewHeight:676 fullScreen:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self.walletCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self requestUSDTRate];
    [self requestWalletType];
}

- (void)requestWalletType{
    _itemsArray = @[@[@"Mobi",@"Huobi",@"Atoken",@"Bixin",@"Bitpie",@"Hicoin",@"Coldlar",@"Coincola"],@[@"其它钱包"]];
    _bankCodeArray = @[@"mobi",@"huobi",@"atoken",@"bixin",@"bitpie",@"hicoin",@"coldlar",@"coincola",@"others"];
    _itemDataArray = [[NSArray alloc]initWithArray:self.payments.firstObject.usdtArray];
    _itemImageArray = @[@[@"me_usdt_mobi",@"me_usdt_huobi",@"me_usdt_atoken",@"me_usdt_bixin",@"me_usdt_bitpie",@"me_usdt_hicoin",@"me_usdt_coldlar",@"me_usdt_coincola"],@[@"me_usdt_otherwallet"]];
    
    NSMutableArray *codeArray = [[NSMutableArray alloc]init];
    NSMutableArray *itemsArrayOne = [[NSMutableArray alloc]init];
    NSMutableArray *itemsArrayTwo = [[NSMutableArray alloc]init];
    NSMutableArray *itemImageArrayOne = [[NSMutableArray alloc]init];
    NSMutableArray *itemImageArrayTwo = [[NSMutableArray alloc]init];
    NSMutableArray *paymentArray = [[NSMutableArray alloc]init];
    for (int i=0; i<_itemDataArray.count; i++) {
        CNPaymentModel *model = [[CNPaymentModel alloc]initWithDictionary:_itemDataArray[i] error:nil];
        if (model.isAvailable) {
            [codeArray addObject:model.bankcode];
            if ([model.bankcode isEqualToString:@"others"]) {
                [itemsArrayTwo addObject:@"其他钱包"];
                [itemImageArrayTwo addObject:@"me_usdt_otherwallet"];
            }else{
                NSInteger index = [_bankCodeArray indexOfObject:model.bankcode];
                [itemsArrayOne addObject:_itemsArray[0][index]];
                [itemImageArrayOne addObject:_itemImageArray[0][index]];
            }
            [paymentArray addObject:_itemDataArray[i]];
        }
        if (i==0) {
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"最低%ld，最高%ld",(long)model.minamount,(long)model.maxamount] attributes:
            @{NSForegroundColorAttributeName:kTextPlaceHolderColor,
                         NSFontAttributeName:_usdtInputField.font
                 }];
            _usdtInputField.attributedPlaceholder = attrString;
        }
        if (i==_itemDataArray.count-1) {
            self.bankCodeArray = codeArray;
            self.itemsArray = @[itemsArrayOne,itemsArrayTwo];
            self.itemDataArray = paymentArray;
            self.itemImageArray = @[itemImageArrayOne,itemImageArrayTwo];
            [self.walletCollectionView reloadData];
            NSInteger sectionNumber = itemsArrayTwo.count==0 ? 1 : 2;
            CGFloat height = ((itemsArrayOne.count-1)/3+1)*54.5+sectionNumber*29+(sectionNumber-1)*54.5;
            [self.walletView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            CNPaymentModel *paymodel = [[CNPaymentModel alloc]initWithDictionary:paymentArray.firstObject error:nil];
            if (paymodel.manual==0) {
                _elseWalletView.hidden = YES;
                _normalWalletView.hidden = NO;
                
            }else{
                _walletAddressLabel.text = paymodel.bank_account_no;
                _noteLabel.text = [NSString stringWithFormat:@"%@",paymodel.remark];
                
                NSString *payTypeName = [NSString stringWithFormat:@"%@",itemsArrayOne.firstObject];
                NSString *noteBottomStr = [NSString stringWithFormat:@"(复制备注信息到%@可快速到账)",payTypeName];
                NSMutableAttributedString *noteBottomAttrStr = [[NSMutableAttributedString alloc] initWithString:noteBottomStr];

                [noteBottomAttrStr addAttribute:NSForegroundColorAttributeName
                value:COLOR_RGBA(36, 151, 255, 1)
                range:NSMakeRange(8, payTypeName.length)];
                
                _noteBottomLabel.attributedText = noteBottomAttrStr;
                _qrCodeImg.image = [PublicMethod QRCodeMethod:paymodel.bank_account_no];
                _elseWalletView.hidden = NO;
                _normalWalletView.hidden = YES;
                
                NSString *scanStr = [NSString stringWithFormat:@"请使用%@扫码充值",payTypeName];
                NSMutableAttributedString *scanAttrStr = [[NSMutableAttributedString alloc] initWithString:scanStr];
                [scanAttrStr addAttribute:NSForegroundColorAttributeName
                value:COLOR_RGBA(36, 151, 255, 1)
                                    range:NSMakeRange(3, payTypeName.length)];
                _scanTypeLabel.attributedText = scanAttrStr;
                
                self.handType = [payTypeName isEqualToString:@"Atoken"] ? @"atoken" : @"bitpie";
            }
            [self.walletCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}

- (void)requestUSDTRate{
    [self showLoading];
    [CNPayRequestManager getUSDTRateWithAmount:@"1" tradeType:@"01" target:@"cny" completeHandler:^(IVRequestResultModel *result, id response) {
        [self hideLoading];
        if (![result.data isKindOfClass:[NSDictionary class]]) {
            // 后台返回类型不一，全部转成字符串
            [self showError:[NSString stringWithFormat:@"%@", result.message]];
            return;
        }
        
        NSError *error;
        CNPayUSDTRateModel *rateModel = [[CNPayUSDTRateModel alloc] initWithDictionary:result.data error:&error];
        if (error && !rateModel) {
            [self showError:@"操作失败！请联系客户，或者稍后重试!"];
            return;
        }
        self.usdtRate = [rateModel.rate floatValue];
        NSLog(@"%.4f",self.usdtRate);
        [self handleRateLabelShowWithRate:rateModel.rate];
    }];
}

- (void)handleRateLabelShowWithRate:(NSString *)rate{
    NSString *str = [NSString stringWithFormat:@"当前参考汇率：1 USDT=%@ CNY，实际请以到账时为准",rate];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
    value:[UIColor whiteColor]
    range:NSMakeRange(7, 17)];
    
    _exchangeRateLabel.attributedText = attrStr;
    
    NSString *elseStr = [NSString stringWithFormat:@"请复制博天堂USDT钱包地址，或扫描博天堂钱包二维码进行充值\n当前参考汇率：1 USDT=%@ CNY，实际请以到账时为准",rate];
    NSMutableAttributedString *elseAttrStr = [[NSMutableAttributedString alloc] initWithString:elseStr];

    [elseAttrStr addAttribute:NSForegroundColorAttributeName
    value:[UIColor whiteColor]
    range:NSMakeRange(38, 17)];
    _elseRateLabel.attributedText = elseAttrStr;
}


- (void)setupView{
    self.view.backgroundColor = kBlackBackgroundColor;
    self.walletView.layer.backgroundColor = [[UIColor colorWithRed:41.0f/255.0f green:45.0f/255.0f blue:54.0f/255.0f alpha:1.0f] CGColor];
    _normalWalletView.layer.backgroundColor = kBlackBackgroundColor.CGColor;
    _elseWalletView.layer.backgroundColor = kBlackBackgroundColor.CGColor;
    self.walletCollectionView.frame = CGRectMake(15, 0, SCREEN_WIDTH-30, 276);
    [self.walletView addSubview:self.walletCollectionView];
    
    _saveView.backgroundColor = kBlackLightColor;
    
    _confirmBtn.layer.cornerRadius = 5;
    _confirmBtn.layer.backgroundColor = [[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] CGColor];
    _confirmBtn.alpha = 1;

    //Gradient 0 fill for 圆角矩形 11
    CAGradientLayer *gradientLayer0 = [[CAGradientLayer alloc] init];
    gradientLayer0.cornerRadius = 5;
    gradientLayer0.frame = _confirmBtn.bounds;
    gradientLayer0.colors = @[
        (id)[UIColor colorWithRed:247.0f/255.0f green:249.0f/255.0f blue:82.0f/255.0f alpha:1.0f].CGColor,
        (id)[UIColor colorWithRed:242.0f/255.0f green:218.0f/255.0f blue:15.0f/255.0f alpha:1.0f].CGColor];
    gradientLayer0.locations = @[@0, @1];
    [gradientLayer0 setStartPoint:CGPointMake(1, 1)];
    [gradientLayer0 setEndPoint:CGPointMake(0, 0)];
    [_confirmBtn.layer addSublayer:gradientLayer0];
    
    CAGradientLayer *gradientLayer1 = [[CAGradientLayer alloc] init];
    gradientLayer1.cornerRadius = 5;
    gradientLayer1.frame = _finishButton.bounds;
    gradientLayer1.colors = @[
        (id)[UIColor colorWithRed:247.0f/255.0f green:249.0f/255.0f blue:82.0f/255.0f alpha:1.0f].CGColor,
        (id)[UIColor colorWithRed:242.0f/255.0f green:218.0f/255.0f blue:15.0f/255.0f alpha:1.0f].CGColor];
    gradientLayer1.locations = @[@0, @1];
    [gradientLayer1 setStartPoint:CGPointMake(1, 1)];
    [gradientLayer1 setEndPoint:CGPointMake(0, 0)];
    
    [_finishButton.layer addSublayer:gradientLayer1];
    
    UIView *sepratorView = [[UIView alloc] initWithFrame:CGRectMake(15, 44, SCREEN_WIDTH-15, 1)];
    sepratorView.layer.backgroundColor = [[UIColor colorWithRed:74.0f/255.0f green:77.0f/255.0f blue:85.0f/255.0f alpha:1.0f] CGColor];
    sepratorView.alpha = 1;

    CALayer *solidLayer0 = [[CALayer alloc] init];
    solidLayer0.frame = sepratorView.bounds;
    solidLayer0.backgroundColor = [[UIColor colorWithRed:54.0f/255.0f green:54.0f/255.0f blue:76.0f/255.0f alpha:1.0f] CGColor];
    [sepratorView.layer addSublayer:solidLayer0];
    [_saveView addSubview:sepratorView];
    
    [self handleRateLabelShowWithRate:@"7.0000"];
        
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入充值金额" attributes:
    @{NSForegroundColorAttributeName:kTextPlaceHolderColor,
                 NSFontAttributeName:_usdtInputField.font
         }];
    _usdtInputField.attributedPlaceholder = attrString;
    _usdtInputField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressCopyBtn_click:)];
    [_addressCopyImg addGestureRecognizer:tap];
    
    self.noteInfoView.layer.cornerRadius = 5;
    self.noteInfoView.layer.backgroundColor = [[UIColor colorWithRed:41.0f/255.0f green:45.0f/255.0f blue:54.0f/255.0f alpha:1.0f] CGColor];
    self.noteInfoView.alpha = 1;
    
}

- (void)addressCopyBtn_click:(id)sender{
    [UIPasteboard generalPasteboard].string = _walletAddressLabel.text;
    [self showSuccess:@"已复制到剪切板"];
}
- (IBAction)nextBtn_click:(id)sender {
    NSInteger type = 25;
    if (self.selectedIndex==0) {
        type = 31;
    }
    CNPaymentModel *model = [[CNPaymentModel alloc]initWithDictionary:self.itemDataArray[_selectedIndex] error:nil];
    if ([_usdtInputField.text doubleValue]==0||_usdtInputField.text.length==0) {
        [self showError:@"请输入需要存款的金额"];
    }else if ([_usdtInputField.text doubleValue]<model.minamount||[_usdtInputField.text doubleValue]>model.maxamount){
        [self showError:[NSString stringWithFormat:@"请输入%.2f-%.2f的存款金额",model.minamount,model.maxamount]];
    }else{
        [self usdtOnlinePayHanlerWithType:type];
    }
}
- (IBAction)noteInfoBtn_click:(id)sender {
    BTTPayUsdtNoticeView *customView = [BTTPayUsdtNoticeView viewFromXib];
    [customView setIamgeWithType:self.handType];
    customView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    BTTAnimationPopView *popView = [[BTTAnimationPopView alloc] initWithCustomView:customView popStyle:BTTAnimationPopStyleNO dismissStyle:BTTAnimationDismissStyleNO];
    popView.isClickBGDismiss = YES;
    [popView pop];
    customView.dismissBlock = ^{
        [popView dismiss];
    };
}
- (IBAction)bottomCopyBtn_click:(id)sender {
    [UIPasteboard generalPasteboard].string = _noteLabel.text;
    [self showSuccess:@"已复制到剪切板"];
}

- (void)usdtOnlinePayHanlerWithType:(NSInteger)type{
    [self showLoading];
    weakSelf(weakSelf)
    [CNPayRequestManager usdtPayOnlineHandleWithType:[NSString stringWithFormat:@"%ld",(long)type] amount:_usdtInputField.text bankCode:self.bankCodeArray[_selectedIndex] completeHandler:^(IVRequestResultModel *result, id response) {
        [self hideLoading];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (result.status) {
            [strongSelf paySucessUSDTHandler:result repay:nil];
        }else{
            [self showError:result.message];
        }
    }];
}

- (IBAction)finishedBtn_click:(id)sender {
    CNPaymentModel *model = [[CNPaymentModel alloc]initWithDictionary:self.itemDataArray[_selectedIndex] error:nil];
    [[NSUserDefaults standardUserDefaults]setObject:_noteLabel.text forKey:@"manual_usdt_note"];
    [[NSUserDefaults standardUserDefaults]setObject:_walletAddressLabel.text forKey:@"manual_usdt_account"];
    [[NSUserDefaults standardUserDefaults]setFloat:self.usdtRate forKey:@"manual_usdt_rate"];
    [[NSUserDefaults standardUserDefaults]setObject:@(model.minamount) forKey:@"usdt_minamount"];
    [[NSUserDefaults standardUserDefaults]setObject:@(model.maxamount) forKey:@"usdt_maxamount"];
    [self goToStep:1];
}

- (IBAction)ustdFieldDidChange:(id)sender {
    if (_usdtInputField.text.length>0) {
        CGFloat rmbCash = [_usdtInputField.text integerValue] * self.usdtRate;
        NSString *cnyStr = [NSString stringWithFormat:@"%.3f",rmbCash];
        _rmbLabel.text = [cnyStr substringWithRange:NSMakeRange(0, cnyStr.length-1)];
    }else{
        _rmbLabel.text = @"0";
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSArray *array = _itemsArray.lastObject;
    if (array.count==0) {
        return 1;
    }else{
       return 2;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *array = _itemsArray[section];
    return array.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        if (_selectedIndex!=indexPath.row) {
            _usdtInputField.text = @"";
            _rmbLabel.text = @"";
        }
        _selectedIndex = indexPath.row;
        CNPaymentModel *model = [[CNPaymentModel alloc]initWithDictionary:self.itemDataArray[indexPath.row] error:nil];
        if (model.manual==0) {
            _elseWalletView.hidden = YES;
            _normalWalletView.hidden = NO;
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"最低%ld，最高%ld",(long)model.minamount,(long)model.maxamount] attributes:
            @{NSForegroundColorAttributeName:kTextPlaceHolderColor,
                         NSFontAttributeName:_usdtInputField.font
                 }];
            _usdtInputField.attributedPlaceholder = attrString;
        }else{
            _walletAddressLabel.text = model.bank_account_no;
            _noteLabel.text = [NSString stringWithFormat:@"%@",model.remark];
            _qrCodeImg.image = [PublicMethod QRCodeMethod:model.bank_account_no];
            _elseWalletView.hidden = NO;
            _normalWalletView.hidden = YES;
            
            NSString *payTypeName = [NSString stringWithFormat:@"%@",_itemsArray[indexPath.section][indexPath.row]];
            NSString *noteBottomStr = [NSString stringWithFormat:@"(复制备注信息到%@可快速到账)",payTypeName];
            NSMutableAttributedString *noteBottomAttrStr = [[NSMutableAttributedString alloc] initWithString:noteBottomStr];

            [noteBottomAttrStr addAttribute:NSForegroundColorAttributeName
            value:COLOR_RGBA(36, 151, 255, 1)
            range:NSMakeRange(8, payTypeName.length)];
            _noteBottomLabel.attributedText = noteBottomAttrStr;
            
            NSString *scanStr = [NSString stringWithFormat:@"请使用%@扫码充值",payTypeName];
            NSMutableAttributedString *scanAttrStr = [[NSMutableAttributedString alloc] initWithString:scanStr];
            [scanAttrStr addAttribute:NSForegroundColorAttributeName
            value:COLOR_RGBA(36, 151, 255, 1)
                                range:NSMakeRange(3, payTypeName.length)];
            _scanTypeLabel.attributedText = scanAttrStr;
            
            self.handType = [payTypeName isEqualToString:@"Atoken"] ? @"atoken" : @"bitpie";
        }
        
    }else{
        _usdtInputField.text = @"";
        _rmbLabel.text = @"";
        _selectedIndex = self.bankCodeArray.count-1;
        CNPaymentModel *model = [[CNPaymentModel alloc]initWithDictionary:self.itemDataArray.lastObject error:nil];
        if (model.manual==0) {
            _elseWalletView.hidden = YES;
            _normalWalletView.hidden = NO;
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"最低%ld，最高%ld",(long)model.minamount,(long)model.maxamount] attributes:
            @{NSForegroundColorAttributeName:kTextPlaceHolderColor,
                         NSFontAttributeName:_usdtInputField.font
                 }];
            _usdtInputField.attributedPlaceholder = attrString;
        }else{
            _walletAddressLabel.text = model.bank_account_no;
            _noteLabel.text = [NSString stringWithFormat:@"%@",model.remark];
            _qrCodeImg.image = [PublicMethod QRCodeMethod:model.bank_account_no];
            
            _elseWalletView.hidden = NO;
            _normalWalletView.hidden = YES;
            
            NSString *payTypeName = [NSString stringWithFormat:@"%@",_itemsArray[indexPath.section][indexPath.row]];
            NSString *noteBottomStr = [NSString stringWithFormat:@"(复制备注信息到%@可快速到账)",payTypeName];
            NSMutableAttributedString *noteBottomAttrStr = [[NSMutableAttributedString alloc] initWithString:noteBottomStr];
            [noteBottomAttrStr addAttribute:NSForegroundColorAttributeName
            value:COLOR_RGBA(36, 151, 255, 1)
            range:NSMakeRange(8, payTypeName.length)];
            _noteBottomLabel.attributedText = noteBottomAttrStr;
            
            NSString *scanStr = [NSString stringWithFormat:@"请使用%@扫码充值",payTypeName];
            NSMutableAttributedString *scanAttrStr = [[NSMutableAttributedString alloc] initWithString:scanStr];
            [scanAttrStr addAttribute:NSForegroundColorAttributeName
            value:COLOR_RGBA(36, 151, 255, 1)
                                range:NSMakeRange(3, payTypeName.length)];
            _scanTypeLabel.attributedText = scanAttrStr;
            
            self.handType = [payTypeName isEqualToString:@"Atoken"] ? @"atoken" : @"bitpie";
        }
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    USDTWalletCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"USDTWalletCollectionCell" forIndexPath:indexPath];
    [cell setCellWithName:_itemsArray[indexPath.section][indexPath.row] imageName:_itemImageArray[indexPath.section][indexPath.row]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                withReuseIdentifier:@"UICollectionViewHeader"
                                                                                       forIndexPath:indexPath];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, 60, 14)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = indexPath.section==0? @"推荐钱包" : @"其它钱包";
    [headView addSubview:titleLabel];
    
    UILabel *noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 15, SCREEN_WIDTH-90, 14)];
    noticeLabel.textColor = COLOR_RGBA(129, 135, 145, 1);
    noticeLabel.font = [UIFont systemFontOfSize:12];
    noticeLabel.text = indexPath.section==0? @"同钱包转账5分钟即可到账" : @"跨钱包转账即跨行操作，需以实际到账时间为准";
    [headView addSubview:noticeLabel];
        
    return headView;
}



@end