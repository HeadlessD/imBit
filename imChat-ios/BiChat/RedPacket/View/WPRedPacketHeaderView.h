//
//  WPRedPacketHeaderView.h
//  BiChat
//
//  Created by 张迅 on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPRedPacketHeaderView : UITableViewHeaderFooterView

//@property (nonatomic,strong)UIImageView *iconIV;
//@property (nonatomic,strong)UILabel *titleLabel;

//@property (nonatomic,strong)UIView *leftLV;
//@property (nonatomic,strong)UIView *rightLV;

@property (nonatomic,strong)UILabel *bindLabel;

/**
 绑定微信回调
 */
@property (nonatomic,copy)void(^BindBlock)(void);

//0微信、1可抢、2不可抢

/**
设置页面样式
 @param status 0微信、1可抢、2不可抢
 @param bindStatus 是否绑定了微信
 */
- (void)setStatus:(NSInteger)status hasBind:(BOOL)bindStatus;

@end
