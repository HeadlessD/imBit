//
//  DFImageUnitView.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFImageUnitView.h"

@implementation DFImageUnitView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        
//        _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
//        [self addSubview:_imageButton];
    }
    return self;
}
@end
