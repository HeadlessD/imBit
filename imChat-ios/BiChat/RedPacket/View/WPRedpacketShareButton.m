//
//  WPRedpacketShareButton.m
//  BiChat
//
//  Created by 张迅 on 2018/5/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedpacketShareButton.h"

@implementation WPRedpacketShareButton

+ (instancetype)button {
    return [WPRedpacketShareButton buttonWithType:UIButtonTypeCustom];
}

- (void)setMargin:(CGFloat)margin {
    _margin = margin;
    if (self.titleLabel.text.length > 0 && self.imageView.image) {
        CGRect rect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil];
        CGSize imageSize = self.imageView.image.size;
        if (self.soreType == SortTypeHorizontal) {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, rect.size.width + margin / 2.0, 0, -(rect.size.width + margin / 2.0));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width - margin / 2.0, 0, imageSize.width + margin / 2.0);
        } else {
            self.imageEdgeInsets = UIEdgeInsetsMake(-rect.size.height / 2.0 - margin / 2.0, rect.size.width / 2.0, -(-rect.size.height / 2.0 - margin), -rect.size.width / 2.0);
            self.titleEdgeInsets = UIEdgeInsetsMake(imageSize.height / 2.0 + margin / 2.0, -imageSize.width / 2.0, -(imageSize.height / 2.0 + margin / 2.0), imageSize.width / 2.0);
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
