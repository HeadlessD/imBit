//
//  PersistentBackgroundLabel.m
//  BiChat Dev
//
//  Created by imac2 on 2018/8/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "PersistentBackgroundLabel.h"

@implementation PersistentBackgroundLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setPersistentBackgroundColor:(UIColor*)color {
    super.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)color {
    // do nothing - background color never changes
}

@end
