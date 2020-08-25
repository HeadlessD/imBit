//
//  RedPacketMessageCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "RedPacketMessageCell.h"

@implementation RedPacketMessageCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    NSString *str4Hint = [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty];
    CGRect rect = [str4Hint boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                         context:nil];
    return rect.size.height + 17;
}

+ (void)renderCellInView:(UIView *)contentView
                 peerUid:(NSString *)peerUid
                 message:(NSMutableDictionary *)message
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
       inMultiSelectMode:(BOOL)inMultiSelectMode
               indexPath:(NSIndexPath *)indexPath
         longPressTarget:(id)longPressTarget
         longPressAction:(SEL)longPressAction
               tapTarget:(id)tapTarget
               tapAction:(SEL)tapAction
     tapUserAvatarTarget:(id)tapUserAvatarTarget
     tapUserAvatarAction:(SEL)tapUserAvatarAction
longPressUserAvatarTarget:(id)longPressUserAvatarTarget
longPressUserAvatarAction:(SEL)longPressUserAvatarAction
            remarkTarget:(id)remarkTarget
            remarkAction:(SEL)remarkAction
            resendTarget:(id)resendTarget
            resendAction:(SEL)resendAction
{
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    NSString *str4Hint = [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty];
    CGRect rect = [str4Hint boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                         context:nil];
    
    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake((cellWidth - rect.size.width - 20) / 2, 0, (int)rect.size.width + 20, (int)rect.size.height + 7)];
    label4Hint.text = str4Hint;
    label4Hint.font = [UIFont systemFontOfSize:12];
    label4Hint.textColor = [UIColor lightGrayColor];
    //label4Hint.backgroundColor = [UIColor colorWithWhite:.78 alpha:1];
    label4Hint.textAlignment = NSTextAlignmentCenter;
    label4Hint.layer.cornerRadius = 5;
    label4Hint.clipsToBounds = YES;
    label4Hint.numberOfLines = 0;
    [contentView addSubview:label4Hint];
    
    if (!inMultiSelectMode)
    {
        //给消息增加长按手势
        label4Hint.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
        objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(longPressGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [label4Hint addGestureRecognizer:longPressGest];
    }
}

@end
