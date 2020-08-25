//
//  UIColor+Category.h
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Category)

/**
 *  16进制颜色转为UIColor对象
 *
 *  @param hexValue   传入的16进制颜色例如 “0x000000”为黑色
 *  @param alphaValue 透明度
 *
 *  @return 根据16进制生成的UIColor对象
 */
+ (UIColor *) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;


/**
 *  字符串转成UIColor颜色对象
 *
 *  @param string 传入的颜色字符串
 *
 *  @return 根据字符串生成的UIColor对象
 */
+ (UIColor *)colorWithString:(NSString *)string;

@end
