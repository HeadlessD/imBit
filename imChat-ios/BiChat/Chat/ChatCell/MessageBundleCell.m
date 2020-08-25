//
//  MessageBundleCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "MessageBundleCell.h"
#import "JSONKit.h"

@implementation MessageBundleCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return 144;
    else
        return 124;
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
    //解析消息组合内容
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *messageConbineInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *str4MessageConbine;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *messages = [messageConbineInfo objectForKey:@"conbineMessage"];
    
    for (int i = 0; i < [messages count]; i ++)
    {
        NSDictionary *message = [messages objectAtIndex:i];
        if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO ||
            [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT)
            [array addObject:[LLSTR(@"101181") llReplaceWithArray:@[[message objectForKey:@"content"]]]];
        else
            [array addObject:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]];
    }
    str4MessageConbine = [array componentsJoinedByString:@"\r\n"];
    
    //是否自己发言
    if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid
                                                nickName:[BiChatGlobal sharedManager].nickName
                                                  avatar:[BiChatGlobal sharedManager].avatar
                                                   frame:CGRectMake(cellWidth - 50, 0, 40, 40)];
        [self bundleView:view4Avatar
                WithUser:[message objectForKey:@"sender"]
                userName:[message objectForKey:@"senderUserName"]
                nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                  avatar:[message objectForKey:@"senderAvatar"]
                isPublic:[[message objectForKey:@"isPublic"]boolValue]
               tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
         longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
        [contentView addSubview:view4Avatar];
        
        //内容框
        UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 235 - 55,
                                                                                       0,
                                                                                       235,
                                                                                       112)];
        image4ContentFrame.image = [UIImage imageNamed:@"bubbleMine_light"];
        [contentView addSubview:image4ContentFrame];
        
        if (!inMultiSelectMode)
        {
            //给图片增加长按手势
            image4ContentFrame.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ContentFrame addGestureRecognizer:longPressGest];
            
            //给图片增加轻点手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ContentFrame addGestureRecognizer:tapGest];
        }
        
        //内容
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 235 - 40, 10, 200, 20)];
        label4Title.text = [messageConbineInfo objectForKey:@"title"];
        label4Title.font = [UIFont systemFontOfSize:16];
        [contentView addSubview:label4Title];
        
        for (int i = 0; i < 3; i ++)
        {
            if (i >= array.count)
                break;
            
            UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 235 - 40, 34 + i * 17, 200, 17)];
            label4Message.text = [array objectAtIndex:i];
            label4Message.font = [UIFont systemFontOfSize:13];
            label4Message.textColor = [UIColor grayColor];
            [contentView addSubview:label4Message];
        }
        
        //seperator
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 225 - 55, 92, 210, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [contentView addSubview:view4Seperator];
        
        //名片标志
        UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 222 - 55, 94, 190, 15)];
        label4Card.text = LLSTR(@"102422");
        label4Card.font = [UIFont systemFontOfSize:12];
        label4Card.textColor = THEME_GRAY;
        [contentView addSubview:label4Card];
    }
    else
    {
        if (inMultiSelectMode)  //是多重选择模式
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(70, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, cellWidth - 150, 20)];
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               20,
                                                                                               235,
                                                                                               112)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(112, 30, 200, 20)];
                label4Title.text = [messageConbineInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                for (int i = 0; i < 3; i ++)
                {
                    if (i >= array.count)
                        break;
                    
                    UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(112, 54 + i * 17, 200, 17)];
                    label4Message.text = [array objectAtIndex:i];
                    label4Message.font = [UIFont systemFontOfSize:13];
                    label4Message.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Message];
                }

                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 112, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 114, 190, 15)];
                label4Card.text = LLSTR(@"102422");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               0,
                                                                                               235,
                                                                                               112)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(112, 10, 200, 20)];
                label4Title.text = [messageConbineInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                for (int i = 0; i < 3; i ++)
                {
                    if (i >= array.count)
                        break;
                    
                    UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(112, 34 + i * 17, 200, 17)];
                    label4Message.text = [array objectAtIndex:i];
                    label4Message.font = [UIFont systemFontOfSize:13];
                    label4Message.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Message];
                }
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 92, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 94, 100, 15)];
                label4Card.text = LLSTR(@"102422");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
        }
        else
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(30, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, cellWidth - 150, 20)];
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               20,
                                                                                               235,
                                                                                               112)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:tapGest];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(72, 30, 200, 20)];
                label4Title.text = [messageConbineInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                for (int i = 0; i < 3; i ++)
                {
                    if (i >= array.count)
                        break;
                    
                    UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(72, 54 + i * 17, 200, 17)];
                    label4Message.text = [array objectAtIndex:i];
                    label4Message.font = [UIFont systemFontOfSize:13];
                    label4Message.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Message];
                }
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 112, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 114, 190, 15)];
                label4Card.text = LLSTR(@"102422");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               0,
                                                                                               235,
                                                                                               112)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:tapGest];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(72, 10, 200, 20)];
                label4Title.text = [messageConbineInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                for (int i = 0; i < 3; i ++)
                {
                    if (i >= array.count)
                        break;
                    
                    UILabel *label4Message = [[UILabel alloc]initWithFrame:CGRectMake(72, 34 + i * 17, 200, 17)];
                    label4Message.text = [array objectAtIndex:i];
                    label4Message.font = [UIFont systemFontOfSize:13];
                    label4Message.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Message];
                }
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 92, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 94, 190, 15)];
                label4Card.text = LLSTR(@"102422");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
        }
    }
}

@end
