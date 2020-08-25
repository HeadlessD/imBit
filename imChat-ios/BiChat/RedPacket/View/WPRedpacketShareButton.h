//
//  WPRedpacketShareButton.h
//  BiChat
//
//  Created by 张迅 on 2018/5/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//


typedef enum {
    SortTypeHorizontal = 0,
    SortTypeVertical
}SortType;

#import <UIKit/UIKit.h>

@interface WPRedpacketShareButton : UIButton
@property (nonatomic,assign)CGFloat margin;
@property (nonatomic,assign)SortType soreType;

+ (instancetype)button;
- (void)setMargin:(CGFloat)margin;

@end
