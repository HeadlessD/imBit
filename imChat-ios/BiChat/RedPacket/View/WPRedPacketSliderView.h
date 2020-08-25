//
//  WPRedPacketSliderView.h
//  BiChat
//
//  Created by 张迅 on 2018/6/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPRedPacketSliderView : UIView

@property (nonatomic,copy)void (^SelectValueBlock)(NSString *value);

@end
