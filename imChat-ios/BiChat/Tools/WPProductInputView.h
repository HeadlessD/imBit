//
//  WPProductInputView.h
//  BiChat
//
//  Created by iMac on 2018/12/13.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPProductInputView : UIView <UITextFieldDelegate>
@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)UITextField *titleTF;
@property (nonatomic,strong)UIButton *closeBtn;
//@property (nonatomic,strong)UILabel *countLabel;
@property (nonatomic,strong)UILabel *coinLabel;
@property (nonatomic,strong)UITextField *hideTF;

@property (nonatomic,strong)UILabel *aimLabel;
@property (nonatomic,strong)UILabel *productLabel;
@property (nonatomic,strong)UILabel *walletLabel;
//币图标
@property (nonatomic,strong)UIImageView *leftIV;
@property (nonatomic,strong)UIImageView *walletIV;

@property (nonatomic,copy)void (^passwordInputBlock)(NSString *password);
@property (nonatomic,copy)void (^closeBlock)(void);

//- (void)fillData:(NSDictionary *)data;
//- (void)fillScanData:(NSDictionary *)data;

/**
 填充数据

 @param image 币b图标
 @param count 数量
 @param coinName 币名字
 @param payTo 目标
 @param payDesc 商品名（群名）
 @param wallet 钱包 0:零钱包 1:商户钱包
 */
- (void)setCoinImag:(NSString *)image count:(NSString *)count coinName:(NSString *)coinName payTo:(NSString *)payTo payDesc:(NSString *)payDesc wallet:(NSInteger)wallet;

@end

NS_ASSUME_NONNULL_END
