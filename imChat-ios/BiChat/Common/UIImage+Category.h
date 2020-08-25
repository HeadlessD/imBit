//
//  UIImage+Category.h
//  BiChat
//
//  Created by 张迅 on 2018/4/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)
/**
 *  根据颜色获取指定尺寸的图片
 *
 *  @param color 传入的颜色
 *  @param size  传入的尺寸（最小为1*1）
 *
 *  @return 符合规则的图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
/**
 *  根据颜色获取指定尺寸的图片
 *
 *  @param color 传入的颜色
 *  @param size  传入的尺寸（最小为1*1）
 *  @param alpha 透明度
 *
 *  @return 符合规则的图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size alpha:(CGFloat)alpha;

/**
 *  根据传入的view获得占位图
 *
 *  @param passView 传入的View
 *
 *  @return 生成的占位图
 */
//+ (UIImage *)placeholderImageWithView:(UIView *)passView;
//根据传入的尺寸、字体、标题创建头像
+ (UIImage *)imageWithSize:(CGSize)size title:(NSString *)title fount:(UIFont *)font color:(UIColor *)color textColor:(UIColor *)textColor;
//生成指定大小的图片
- (UIImage *)imageWithSize:(CGSize)size;
@end
