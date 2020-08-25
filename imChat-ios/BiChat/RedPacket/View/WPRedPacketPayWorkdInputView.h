//
//  WPRedPacketPayWorkdInputView.h
//  BiChat
//
//  Created by 张迅 on 2018/5/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPRedPacketPayWorkdInputView : UIView <UITextFieldDelegate>

@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)UITextField *titleTF;
@property (nonatomic,strong)UIButton *closeBtn;
@property (nonatomic,strong)UILabel *countLabel;
@property (nonatomic,strong)UILabel *coinLabel;
@property (nonatomic,strong)UITextField *hideTF;
//币图标
@property (nonatomic,strong)UIImageView *leftIV;

@property (nonatomic,copy)void (^passwordInputBlock)(NSString *password);
@property (nonatomic,copy)void (^closeBlock)(void);
@property (nonatomic,assign) BOOL hasFinish;

- (void)setCoinImag:(NSString *)image count:(NSString *)count coinName:(NSString *)name;

@end
