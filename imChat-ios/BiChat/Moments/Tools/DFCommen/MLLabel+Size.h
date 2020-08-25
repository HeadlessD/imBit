//
//  MLLabel+Size.h
//  DFWeChatView
//
//  Created by 豆凯强 on 17/10/3.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLLabel.h"
#import "MLLinkLabel.h"

@interface MLLabel (Size)

+(CGSize) getViewSize:(NSAttributedString *)attributedText maxWidth:(CGFloat) maxWidth font:(UIFont *) font lineHeight:(CGFloat) lineHeight lines:(NSUInteger)lines;


+(CGSize) getViewSizeByString:(NSString *)text maxWidth:(CGFloat) maxWidth font:(UIFont *) font lineHeight:(CGFloat) lineHeight lines:(NSUInteger)lines;

+(CGSize) getViewSizeByString:(NSString *)text maxWidth:(CGFloat) maxWidth font:(UIFont *) font;

+(CGSize) getViewSizeByString:(NSString *)text font:(UIFont *) font;

@end
