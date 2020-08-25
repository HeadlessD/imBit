//
//  UIImageView+Category.m
//  BiChat
//
//  Created by 张迅 on 2018/5/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "UIImageView+Category.h"

@implementation UIImageView (Category)

- (void)setImageWithURL:(NSString *)url title:(NSString *)title size:(CGSize)size placeHolde:(UIImage *)placeHolder color:(UIColor *)color textColor:(UIColor *)textColor {
    if ([url isEqualToString:@"<null>"] || [url isKindOfClass:[NSNull class]] || [url rangeOfString:@"(null)"].location != NSNotFound || [url isEqualToString:[BiChatGlobal sharedManager].S3URL]) {
        url = nil;
    }
    if (url.length > 0 && ![url isEqualToString:[BiChatGlobal sharedManager].S3URL]) {
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeHolder ? placeHolder : Image(@"defaultavatar")];
    } else {
        if (title.length > 0) {
            unichar c = [title characterAtIndex:0];
            BOOL isEmoji = NO;
            if (c >= 0xd800 && c <= 0xdbff) {
                isEmoji = YES;
            }
            if (isEmoji) {
                [self setImage:[UIImage imageWithSize:size title:[title substringToIndex:2] fount:Font(size.height / 2) color:color ? color :[UIColor colorWithWhite:.8 alpha:1] textColor:textColor ? textColor : [UIColor whiteColor]]];
            } else {
                [self setImage:[UIImage imageWithSize:size title:[title substringToIndex:1] fount:Font(size.height / 2) color:color ? color :[UIColor colorWithWhite:.8 alpha:1] textColor:textColor ? textColor : [UIColor whiteColor]]];
            }
        } else {
            [self setImage:[UIImage imageWithSize:size title:@"头" fount:Font(size.height / 2) color:color textColor:textColor]];
        }
    }
}

@end
