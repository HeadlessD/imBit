//
//  UIImageView+Category.h
//  BiChat
//
//  Created by 张迅 on 2018/5/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Category)

/**
 智能设置图片

 @param url 头像URL（可空）
 @param title 没有头像的情况下显示的标题（可空）
 @param size imageView的size
 @param placeholder 占位图（可空）
 @param placeHolder 背景色（可空）
 @param textColor 文本颜色
 */
- (void)setImageWithURL:(NSString *)url title:(NSString *)title size:(CGSize)size placeHolde:(UIImage *)placeHolder color:(UIColor *)color textColor:(UIColor *)textColor;

@end
