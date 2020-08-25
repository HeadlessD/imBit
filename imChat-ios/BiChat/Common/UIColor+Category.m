//
//  UIColor+Category.m
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

+ (UIColor *) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alphaValue];
}

+ (UIColor *)colorWithString:(NSString *)string {
    if (string.length == 7) {
        NSString *rString = [string substringWithRange:NSMakeRange(1, 2)];
        NSString *gString = [string substringWithRange:NSMakeRange(3, 2)];
        NSString *bString = [string substringWithRange:NSMakeRange(5, 2)];
        
        unsigned int r, g, b;
        
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:1.0f];
        
    } else {
        return [UIColor blackColor];
    }
    
}

@end
