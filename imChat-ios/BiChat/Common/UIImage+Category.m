//
//  UIImage+Category.m
//  BiChat
//
//  Created by 张迅 on 2018/4/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size alpha:(CGFloat)alpha {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[color colorWithAlphaComponent:alpha] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)placeholderImageWithSize:(CGSize)size
{
    if (size.width == 0 || size.height == 0)
    {
        return nil;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.backgroundColor = RGB(0xeeeeee);
    UIImage *placeImage = nil;
    if (size.width && size.height > 75) {
        // placeImage = Image(@"placeholder_large");
        placeImage = [UIImage imageWithColor:RGB(0xf5f5f5) size:CGSizeMake(size.width, size.height)];
        
    } else if (size.width > 40 && size.height > 40 && size.width <= 75 && size.height <= 75) {
        // placeImage = Image(@"placeholder_middle");
        placeImage = [UIImage imageWithColor:RGB(0xf5f5f5) size:CGSizeMake(size.width, size.height)];
    } else {
        // placeImage = Image(@"placeholder_small");
        placeImage = [UIImage imageWithColor:RGB(0xf5f5f5) size:CGSizeMake(size.width, size.height)];
    }
    UIImageView *imageView = [[UIImageView alloc]initWithImage:placeImage];
    imageView.center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
    [view addSubview:imageView];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithSize:(CGSize)size title:(NSString *)title fount:(UIFont *)font color:(UIColor *)color textColor:(UIColor *)textColor{
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (color) {
        view.backgroundColor = color;
    } else {
        view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    }
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [view addSubview:titlelabel];
    titlelabel.font = font;
    titlelabel.textAlignment = NSTextAlignmentCenter;
    unichar c = [title characterAtIndex:0];
    BOOL isEmoji = NO;
    if (c >= 0xd800 && c <= 0xdbff) {
        isEmoji = YES;
    }
    if (isEmoji) {
        titlelabel.text = [[title substringToIndex:2] uppercaseString];
    } else {
        titlelabel.text = [[title substringToIndex:1] uppercaseString];
    }
    
    if (textColor) {
        titlelabel.textColor = textColor;
    } else {
        titlelabel.textColor = [UIColor whiteColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//生成指定大小的图片
- (UIImage *)imageWithSize:(CGSize)size
{
    CGSize originImageSize = self.size;
    CGRect newRect =CGRectMake(0,0,size.width,size.height);
    
    //根据当前屏幕scaling factor创建一个透明的位图图形上下文(此处不能直接从UIGraphicsGetCurrentContext获取,原因是UIGraphicsGetCurrentContext获取的是上下文栈的顶,在drawRect:方法里栈顶才有数据,其他地方只能获取一个nil.详情看文档)
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //保持宽高比例,确定缩放倍数
    //(原图的宽高做分母,导致大的结果比例更小,做MAX后,ratio*原图长宽得到的值最小是40,最大则比40大,这样的好处是可以让原图在画进40*40的缩略矩形画布时,origin可以取=(缩略矩形长宽减原图长宽*ratio)/2 ,这样可以得到一个可能包含负数的origin,结合缩放的原图长宽size之后,最终原图缩小后的缩略图中央刚好可以对准缩略矩形画布中央)
    float ratio = MAX(newRect.size.width / originImageSize.width, newRect.size.height / originImageSize.height);
    
    //让image在缩略图范围内居中()
    CGRect projectRect;
    projectRect.size.width = originImageSize.width * ratio;
    projectRect.size.height = originImageSize.height * ratio;
    projectRect.origin.x = (newRect.size.width- projectRect.size.width) / 2;
    projectRect.origin.y = (newRect.size.height- projectRect.size.height) / 2;
    
    //在上下文中画图
    [self drawInRect:projectRect];
    
    //从图形上下文获取到UIImage对象,赋值给thumbnai属性
    UIImage *returnImg = UIGraphicsGetImageFromCurrentImageContext();
    
    //清理图形上下文(用了UIGraphicsBeginImageContext需要清理)
    UIGraphicsEndImageContext();
    return returnImg;
}

@end
