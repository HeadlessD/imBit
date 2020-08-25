//
//  UIView+Category.h
//  BiChat
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)
//截图
- (UIImage *)screenshotWithRect:(CGRect)rect;
//缩略图
- (UIImage *)thumbScreenshotWithRect:(CGRect)rect;

- (void)showLoading;

- (void)hideLoading;

@end
