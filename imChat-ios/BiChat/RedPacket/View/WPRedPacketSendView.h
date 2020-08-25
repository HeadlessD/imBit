//
//  WPRedPacketSendView.h
//  BiChat
//
//  Created by 张迅 on 2018/5/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPRedPacketSendView : UIView

@property (nonatomic,strong)UITextField *titleTF;
@property (nonatomic,strong)UITextField *subTF;
@property (nonatomic,strong)UIImageView *accessoryIV;

- (void)addTarget:(id)target selector:(SEL)selector;
@end
