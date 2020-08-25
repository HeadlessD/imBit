//
//  UIView+Category.m
//  BiChat
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#define kMBTag 123

#import "UIView+Category.h"

@implementation UIView (Category)

- (UIImage *)screenshotWithRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        return nil;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else
    {
        [self.layer renderInContext:context];
    }
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)thumbScreenshotWithRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        return nil;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else
    {
        [self.layer renderInContext:context];
    }
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)showLoading
{
    CGRect activityframe = CGRectMake(self.frame.size.width / 2 - 30.0f,
                                      self.frame.size.height / 2 - 55.0f,
                                      60.0f,
                                      60.0f);
    
    //风火轮
    UIActivityIndicatorView *activityView = [self viewWithTag:kMBTag];
    if (activityView != nil)
    {
        [self bringSubviewToFront:activityView];
        activityView.frame = activityframe;
        [activityView startAnimating];
    }
    else
    {
        activityView = [[UIActivityIndicatorView alloc]initWithFrame:activityframe];
        [self addSubview:activityView];
        activityView.tag = kMBTag;
        activityView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        activityView.clipsToBounds = YES;
        activityView.layer.cornerRadius = 10;
        [activityView startAnimating];
    }
}

- (void)hideLoading {
    UIView *view = [self viewWithTag:kMBTag];
    if (view) {
        [view removeFromSuperview];
        view = nil;
    }
}

@end
