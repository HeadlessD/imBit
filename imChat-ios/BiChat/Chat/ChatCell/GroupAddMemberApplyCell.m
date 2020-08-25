//
//  GroupAddMemberApplyCell.m
//  BiChat
//
//  Created by Admin on 2018/4/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "GroupAddMemberApplyCell.h"
#import "JSONKit.h"

@implementation GroupAddMemberApplyCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    NSString *str4Hint = [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty];
    
    //我是群管理员
    if ([BiChatGlobal isMeGroupOperator:groupProperty])
        str4Hint = [str4Hint stringByAppendingString:LLSTR(@"203012")];

    //是我本人发的消息
    else if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //看看申请列表里面还有多少人
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *item = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        str4Hint = [str4Hint stringByAppendingString:LLSTR(@"203014")];
    }
    
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
    UILabel *label4Hint;
    
    //我是群管理员
    if ([BiChatGlobal isMeGroupOperator:groupProperty])
    {
        str4Hint = [str4Hint stringByAppendingString:LLSTR(@"203012")];
        CGRect rect = [str4Hint boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                             context:nil];
        
        label4Hint = [[UILabel alloc]initWithFrame:CGRectMake((cellWidth - rect.size.width - 20) / 2, 0, (int)rect.size.width + 20, (int)rect.size.height + 7)];
        label4Hint.text = str4Hint;
        label4Hint.font = [UIFont systemFontOfSize:12];
        label4Hint.textColor = [UIColor lightGrayColor];
        //label4Hint.backgroundColor = [UIColor colorWithWhite:.78 alpha:1];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.layer.cornerRadius = 5;
        label4Hint.clipsToBounds = YES;
        label4Hint.numberOfLines = 0;
        [contentView addSubview:label4Hint];
        
        //最后三个字符需要高亮显示
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Hint.text];
        [str addAttribute:NSForegroundColorAttributeName value:THEME_DARKBLUE range:NSMakeRange(str.length - LLSTR(@"203012").length, LLSTR(@"203012").length)];
        label4Hint.attributedText = str;
        
        if (!inMultiSelectMode)
        {
            //给消息增加长按手势
            label4Hint.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [label4Hint addGestureRecognizer:longPressGest];
            
            //给消息增加轻点手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [label4Hint addGestureRecognizer:tapGest];
        }
    }
    
    //是我发的消息
    else if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //看看申请列表里面还有多少人
        str4Hint = [str4Hint stringByAppendingString:LLSTR(@"203014")];
        CGRect rect = [str4Hint boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                             context:nil];
        
        label4Hint = [[UILabel alloc]initWithFrame:CGRectMake((cellWidth - rect.size.width - 20) / 2, 0, (int)rect.size.width + 20, (int)rect.size.height + 7)];
        label4Hint.text = str4Hint;
        label4Hint.font = [UIFont systemFontOfSize:12];
        label4Hint.textColor = [UIColor lightGrayColor];
        //label4Hint.backgroundColor = [UIColor colorWithWhite:.78 alpha:1];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.layer.cornerRadius = 5;
        label4Hint.clipsToBounds = YES;
        label4Hint.numberOfLines = 0;
        [contentView addSubview:label4Hint];
        
        //最后n个字符需要高亮显示
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Hint.text];
        [str addAttribute:NSForegroundColorAttributeName value:THEME_DARKBLUE range:NSMakeRange(str.length - LLSTR(@"203014").length, LLSTR(@"203014").length)];
        label4Hint.attributedText = str;
        
        if (!inMultiSelectMode)
        {
            //给消息增加长按手势
            label4Hint.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [label4Hint addGestureRecognizer:longPressGest];
            
            //给消息增加轻点手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [label4Hint addGestureRecognizer:tapGest];
        }
    }
    else
    {
        CGRect rect = [str4Hint boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                             context:nil];
        
        label4Hint = [[UILabel alloc]initWithFrame:CGRectMake((cellWidth - rect.size.width - 20) / 2, 0, (int)rect.size.width + 20, (int)rect.size.height + 7)];
        label4Hint.text = str4Hint;
        label4Hint.font = [UIFont systemFontOfSize:12];
        label4Hint.textColor = [UIColor lightGrayColor];
        //label4Hint.backgroundColor = [UIColor colorWithWhite:.78 alpha:1];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.layer.cornerRadius = 5;
        label4Hint.clipsToBounds = YES;
        label4Hint.numberOfLines = 0;
        [contentView addSubview:label4Hint];
    }
    
    if (!inMultiSelectMode)
    {
        //给消息增加长按手势
        label4Hint.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
        objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(longPressGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [label4Hint addGestureRecognizer:longPressGest];
        
        //给消息增加轻点手势
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
        objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [label4Hint addGestureRecognizer:tapGest];
    }
}

@end
