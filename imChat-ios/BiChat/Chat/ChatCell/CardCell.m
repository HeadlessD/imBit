//
//  CardCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "CardCell.h"
#import "JSONKit.h"

@implementation CardCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return 118;
    else
        return 98;
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
    //解析名片内容
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *cardInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是否自己发言
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid nickName:[BiChatGlobal sharedManager].nickName avatar:[BiChatGlobal sharedManager].avatar frame:CGRectMake(cellWidth - 50, 0, 40, 40)];
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
        UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 290,
                                                                                       0,
                                                                                       235,
                                                                                       88)];
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
            
            //是否发送成功
            if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[message objectForKey:@"msgId"]])
            {
                UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - 335, 23, 40, 40)];
                [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [contentView addSubview:button4Resend];
            }
        }
        
        //内容
        //avatar
        UIView *view4CardAvatar = [BiChatGlobal getAvatarWnd:[cardInfo objectForKey:@"uid"] nickName:[cardInfo objectForKey:@"nickName"] avatar:[cardInfo objectForKey:@"avatar"] width:40 height:40];
        view4CardAvatar.center = CGPointMake(cellWidth - 256 , 35);
        [contentView addSubview:view4CardAvatar];
        
        //nickName
        UILabel *label4CardNickName = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 225, 15, 150, 40)];
        label4CardNickName.text = [cardInfo objectForKey:@"nickName"];
        label4CardNickName.font = [UIFont systemFontOfSize:16];
        label4CardNickName.numberOfLines = 0;
        [contentView addSubview:label4CardNickName];
        
        //seperator
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 225 - 55, 68, 210, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [contentView addSubview:view4Seperator];
        
        //名片标志
        UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 223 - 55, 70, 190, 15)];
        if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
            label4Card.text = LLSTR(@"201019");
        else if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"groupCard"])
            label4Card.text = LLSTR(@"201064");
        else
            label4Card.text = LLSTR(@"201015");
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
                                                                                               88)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                //avatar
                UIView *view4CardAvatar = [BiChatGlobal getAvatarWnd:[cardInfo objectForKey:@"uid"]
                                                            nickName:[cardInfo objectForKey:@"nickName"]
                                                              avatar:[cardInfo objectForKey:@"avatar"] width:40 height:40];
                view4CardAvatar.center = CGPointMake(135 , 55);
                [contentView addSubview:view4CardAvatar];
                
                //nickName
                UILabel *label4CardNickName = [[UILabel alloc]initWithFrame:CGRectMake(165, 35, 150, 40)];
                label4CardNickName.text = [cardInfo objectForKey:@"nickName"];
                label4CardNickName.font = [UIFont systemFontOfSize:16];
                label4CardNickName.numberOfLines = 0;
                [contentView addSubview:label4CardNickName];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 88, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 90, 190, 15)];
                if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
                    label4Card.text = LLSTR(@"201019");
                else if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"groupCard"])
                    label4Card.text = LLSTR(@"201064");
                else
                    label4Card.text = LLSTR(@"201015");
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
                                                                                               88)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                //avatar
                UIView *view4CardAvatar = [BiChatGlobal getAvatarWnd:[cardInfo objectForKey:@"uid"]
                                                            nickName:[cardInfo objectForKey:@"nickName"]
                                                              avatar:[cardInfo objectForKey:@"avatar"]
                                                               width:40 height:40];
                view4CardAvatar.center = CGPointMake(135 , 35);
                [contentView addSubview:view4CardAvatar];
                
                //nickName
                UILabel *label4CardNickName = [[UILabel alloc]initWithFrame:CGRectMake(165, 15, 150, 40)];
                label4CardNickName.text = [cardInfo objectForKey:@"nickName"];
                label4CardNickName.font = [UIFont systemFontOfSize:16];
                label4CardNickName.numberOfLines = 0;
                [contentView addSubview:label4CardNickName];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 68, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 70, 190, 15)];
                if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
                    label4Card.text = LLSTR(@"201019");
                else if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"groupCard"])
                    label4Card.text = LLSTR(@"201064");
                else
                    label4Card.text = LLSTR(@"201015");
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
                                                                                               88)];
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
                //avatar
                UIView *view4CardAvatar = [BiChatGlobal getAvatarWnd:[cardInfo objectForKey:@"uid"]
                                                            nickName:[cardInfo objectForKey:@"nickName"]
                                                              avatar:[cardInfo objectForKey:@"avatar"]
                                                               width:40 height:40];
                view4CardAvatar.center = CGPointMake(95 , 55);
                [contentView addSubview:view4CardAvatar];
                
                //nickName
                UILabel *label4CardNickName = [[UILabel alloc]initWithFrame:CGRectMake(125, 35, 150, 40)];
                label4CardNickName.text = [cardInfo objectForKey:@"nickName"];
                label4CardNickName.font = [UIFont systemFontOfSize:16];
                label4CardNickName.numberOfLines = 0;
                [contentView addSubview:label4CardNickName];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 88, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 90, 190, 15)];
                if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
                    label4Card.text = LLSTR(@"201019");
                else if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"groupCard"])
                    label4Card.text = LLSTR(@"201064");
                else
                    label4Card.text = LLSTR(@"201015");
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
                                                                                               88)];
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
                //avatar
                UIView *view4CardAvatar = [BiChatGlobal getAvatarWnd:[cardInfo objectForKey:@"uid"]
                                                            nickName:[cardInfo objectForKey:@"nickName"]
                                                              avatar:[cardInfo objectForKey:@"avatar"]
                                                               width:40 height:40];
                view4CardAvatar.center = CGPointMake(95 , 35);
                [contentView addSubview:view4CardAvatar];
                
                //nickName
                UILabel *label4CardNickName = [[UILabel alloc]initWithFrame:CGRectMake(125, 15, 150, 40)];
                label4CardNickName.text = [cardInfo objectForKey:@"nickName"];
                label4CardNickName.font = [UIFont systemFontOfSize:16];
                label4CardNickName.numberOfLines = 0;
                [contentView addSubview:label4CardNickName];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 68, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //名片标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 70, 190, 15)];
                if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
                    label4Card.text = LLSTR(@"201019");
                else if ([[cardInfo objectForKey:@"cardType"]isEqualToString:@"groupCard"])
                    label4Card.text = LLSTR(@"201064");
                else
                    label4Card.text = LLSTR(@"201015");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
        }
    }
}

@end
