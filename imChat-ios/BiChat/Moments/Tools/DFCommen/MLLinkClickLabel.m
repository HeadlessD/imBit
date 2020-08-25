//
//  MLLinkClickLabel.m
//  DFCommon
//
//  Created by 豆凯强 on 17/10/10.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "MLLinkClickLabel.h"

@implementation MLLinkClickLabel


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mlLabelLongPress:)];
//        [self addGestureRecognizer:longPress];
    }
    return self;
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    MLLink *link = [self linkAtPoint:[touch locationInView:self]];
    if (!link) {
        NSLog(@"单击了第%ld个评论的非链接部分",(long)self.tag);
        if (_clickDelegate && [_clickDelegate respondsToSelector:@selector(onClickOutsideLinkWithIndex:)]) {
            [_clickDelegate onClickOutsideLinkWithIndex:self.tag];
        }
    }
}

- (void)longPressGestureDidFire:(UILongPressGestureRecognizer *)sender {
    if (sender.state==UIGestureRecognizerStateBegan) {
        MLLink *link = [self linkAtPoint:[sender locationInView:self]];
        if (link) {
//            NSString *linkText = [self.text substringWithRange:link.linkRange];
        }
        if (!link) {
            NSLog(@"长摁非链接部分");
//            if (_clickDelegate && [_clickDelegate respondsToSelector:@selector(onLongClickOutsideLink:LongPress:)]) {
//                [_clickDelegate onLongClickOutsideLink:_commentModel LongPress:sender];
//            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.backgroundColor = [UIColor clearColor];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.backgroundColor = [UIColor clearColor];
}

@end
