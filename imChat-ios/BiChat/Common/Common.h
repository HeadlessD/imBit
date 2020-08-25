//
//  Common.h
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#ifndef Common_h
#define Common_h

//返回名字为weakSelf的弱引用self对象
#define WEAKSELF typeof(self) __weak weakSelf = self

//屏幕宽高
#define ScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define UIAdaptiveRate(x) ((float) x * ScreenWidth / 320.0)

//状态栏高度
#define  IPX_STATUS_H        (isIphonex ? 44 : 20)
//导航栏高度
#define  IPX_NAVI_H          (isIphonex ? 88 : 64)
//头部安全高度
#define  IPX_TOP_SAFE_H       (isIphonex ? 24 : 0)
//底部安全高度
#define  IPX_BOTTOM_SAFE_H    (isIphonex ? 34 : 0)
//Tarbar高度
#define  IPX_TABBAR_H         (isIphonex ? 83 : 49)


#define LightBlue RGB(0x2f93fa)
#define DarkBlue RGB(0x347ac4)

//简化根据名字获取图片方法
#define Image(name) [UIImage imageNamed:name]

//宏定义rgb方法
#define RGB(rgbValue) [UIColor colorWithHex:rgbValue alpha:1]

//字体
#define Font(x)                     [UIFont systemFontOfSize:x]
#define BoldFont(x)                 [UIFont boldSystemFontOfSize:x]
//系统版本
#define SystemVersion [[UIDevice currentDevice].systemVersion substringToIndex:2]

#endif /* Common_h */
