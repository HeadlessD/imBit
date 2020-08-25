//
//  BiTextView.m
//  BiChat
//
//  Created by worm_kc on 2018/3/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiTextView.h"
#import "objc/runtime.h"

@implementation BiTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSMutableDictionary *dict4Target = (NSMutableDictionary *)objc_getAssociatedObject(sender, @"targetData");
    if (dict4Target != nil)
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:LLSTR(@"104021") action:@selector(newLine:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:[NSArray arrayWithObject:menuItem]];
    [menuController setMenuVisible:NO];
}

- (void)newLine:(id)sender
{
    NSInteger pt = self.selectedRange.location;
    self.text = [self.text stringByReplacingCharactersInRange:self.selectedRange withString:@"\r\n"];
    self.selectedRange = NSMakeRange(pt + 2, 0);
    
    //通知delegate
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
}

@end
