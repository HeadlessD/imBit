//
//  SoundCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "SoundCell.h"
#import "JSONKit.h"

@implementation SoundCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return [[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?70:110;
    else
        return [[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?50:90;
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
   lastPlaySoundFileName:(NSString *)lastPlaySoundFileName
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *dict4SoundInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", dict4SoundInfo);
    
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
        
        //是否带有remark
        if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
        {
            //声音长度
            NSInteger length = [[dict4SoundInfo objectForKey:@"length"]integerValue];
            if (length < 1) length = 1;
            CGFloat soundLength = 55 + length * SOUND_PIXEL_PERSECOND - 27;
            
            NSString *remarkSenderNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"remarkSender"] groupProperty:groupProperty nickName: [message objectForKey:@"remarkSenderNickName"]];
            NSDictionary *remarkMessage = [[NSDictionary alloc]initWithObjectsAndKeys:
                                           [message objectForKey:@"remarkContent"]==nil?@"":[message objectForKey:@"remarkContent"], @"content",
                                           [message objectForKey:@"remarkType"]==nil?@"":[message objectForKey:@"remarkType"], @"type", nil];
            NSString *remarkContent = [BiChatGlobal getMessageReadableString:remarkMessage groupProperty:groupProperty];
            
            //计算引用者昵称长度
            CGRect rect4RemarkSenderNickNameRect = [remarkSenderNickName boundingRectWithSize:CGSizeMake(cellWidth - 165, MAXFLOAT)
                                                                                      options:NSStringDrawingUsesFontLeading
                                                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                                      context:nil];
            
            //计算引用内容长度
            CGRect rect4RemarkContentRect = [remarkContent boundingRectWithSize:CGSizeMake(cellWidth - 165, MAXFLOAT)
                                                                        options:NSStringDrawingUsesFontLeading
                                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                        context:nil];
            CGFloat contentLength = MAX(soundLength, rect4RemarkContentRect.size.width + 6);
            contentLength = MAX(contentLength, rect4RemarkSenderNickNameRect.size.width + 6);
            
            UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 55 - contentLength - 27 , 0, contentLength + 27, 80)];
            image4ContentFrame.image = [UIImage imageNamed:@"bubbleMine"];
            [contentView addSubview:image4ContentFrame];

            //引用数据
            UIView *view4RemarkFlag = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 71, 12, 2, 32)];
            view4RemarkFlag.backgroundColor = THEME_LIGHT_GREEN;
            [contentView addSubview:view4RemarkFlag];
            
            UILabel *label4RemarkSenderNickName = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 65, 12, rect4RemarkSenderNickNameRect.size.width, 15)];
            label4RemarkSenderNickName.text = remarkSenderNickName;
            label4RemarkSenderNickName.font = [UIFont systemFontOfSize:13];
            label4RemarkSenderNickName.textColor = THEME_LIGHT_GREEN;
            [contentView addSubview:label4RemarkSenderNickName];
            
            UILabel *label4RemarkContent = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 65, 28, rect4RemarkContentRect.size.width, 15)];
            label4RemarkContent.text = remarkContent;
            label4RemarkContent.font = [UIFont systemFontOfSize:13];
            label4RemarkContent.textColor = [UIColor colorWithWhite:.80 alpha:1];
            [contentView addSubview:label4RemarkContent];
            
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
                
                //引用部分
                UIView *view4Remark = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 55 - contentLength - 27,
                                                                              showNickName?20:0,
                                                                              contentLength, 33)];
                [contentView addSubview:view4Remark];
                
                //给引用部分加长按手势
                view4Remark.userInteractionEnabled = YES;
                longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [view4Remark addGestureRecognizer:longPressGest];
                
                //给引用部分加点击手势
                tapGest = [[UITapGestureRecognizer alloc]initWithTarget:remarkTarget action:remarkAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [view4Remark addGestureRecognizer:tapGest];
                
                //是否发送成功
                if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[message objectForKey:@"msgId"]])
                {
                    UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 140, 20, 40, 40)];
                    [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                    [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                    objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [contentView addSubview:button4Resend];
                }
                //是否正在发送
                else if ([[BiChatDataModule sharedDataModule]isMessageSending:[message objectForKey:@"msgId"]])
                {
                    //计算需要延迟多少时间显示菊花
                    double interval = [[BiChatDataModule sharedDataModule]getMessageSendingTime:[message objectForKey:@"msgId"]];
                    interval = 1 - ([[NSDate date]timeIntervalSince1970] - interval);
                    if (interval > 0)
                    {
                        //延迟显示菊花
                        [NSTimer scheduledTimerWithTimeInterval:interval repeats:NO block:^(NSTimer * _Nonnull timer) {
                            
                            //判断是否还在发送状态
                            if ([[BiChatDataModule sharedDataModule]isMessageSending:[message objectForKey:@"msgId"]])
                            {
                                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 140, 20, 40, 40)];
                                activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                                [activityView startAnimating];
                                [contentView addSubview:activityView];
                            }
                        }];
                    }
                    else
                    {
                        //立即出菊花
                        //判断是否还在发送状态
                        if ([[BiChatDataModule sharedDataModule]isMessageSending:[message objectForKey:@"msgId"]])
                        {
                            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 140, 20, 40, 40)];
                            activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                            [activityView startAnimating];
                            [contentView addSubview:activityView];
                        }
                    }
                }
                //是否正在重新上传
                else if ([[BiChatDataModule sharedDataModule]isMessageResending:[message objectForKey:@"msgId"]])
                {
                    NSLog(@"resending");
                    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, 20, 40, 40)];
                    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                    [activityView startAnimating];
                    [contentView addSubview:activityView];
                }
            }
            
            UIImageView *image4Sound;
            //是否正在播放
            if ([lastPlaySoundFileName isEqualToString:[dict4SoundInfo objectForKey:@"FileName"]])
            {
                NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"SenderVoicePlaying000"], [UIImage imageNamed:@"SenderVoicePlaying001"], [UIImage imageNamed:@"SenderVoicePlaying002"], [UIImage imageNamed:@"SenderVoicePlaying003"], nil];
                image4Sound = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:images duration:1]];
            }
            else
                image4Sound = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SenderVoicePlaying"]];
            image4Sound.center = CGPointMake(cellWidth - 75, 60);
            [contentView addSubview:image4Sound];
            
            //声音长度
            UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 112, 40, 25, 40)];
            label4SoundLength.text = [NSString stringWithFormat:@"%zd\"", length];
            label4SoundLength.font = [UIFont systemFontOfSize:13];
            label4SoundLength.textColor = [UIColor grayColor];
            label4SoundLength.textAlignment = NSTextAlignmentRight;
            [contentView addSubview:label4SoundLength];
        }
        else
        {
            //声音内容框
            NSInteger length = [[dict4SoundInfo objectForKey:@"length"]integerValue];
            if (length < 1) length = 1;
            CGFloat soundLength = 55 + length * SOUND_PIXEL_PERSECOND;
            CGFloat contentLength = soundLength;
            UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 110 - length * SOUND_PIXEL_PERSECOND , 0, contentLength, 40)];
            image4ContentFrame.image = [UIImage imageNamed:@"bubbleMine"];
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
                    UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - soundLength - 117, 0, 40, 40)];
                    [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                    [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                    objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [contentView addSubview:button4Resend];
                }
                //是否正在发送
                else if ([[BiChatDataModule sharedDataModule]isMessageSending:[message objectForKey:@"msgId"]])
                {
                    //计算需要延迟多少时间显示菊花
                    double interval = [[BiChatDataModule sharedDataModule]getMessageSendingTime:[message objectForKey:@"msgId"]];
                    interval = 1 - ([[NSDate date]timeIntervalSince1970] - interval);
                    if (interval > 0)
                    {
                        //延迟显示菊花
                        [NSTimer scheduledTimerWithTimeInterval:interval repeats:NO block:^(NSTimer * _Nonnull timer) {
                            
                            //判断是否还在发送状态
                            if ([[BiChatDataModule sharedDataModule]isMessageSending:[message objectForKey:@"msgId"]])
                            {
                                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, 0, 40, 40)];
                                activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                                [activityView startAnimating];
                                [contentView addSubview:activityView];
                            }
                        }];
                    }
                    else
                    {
                        //立即出菊花
                        //判断是否还在发送状态
                        if ([[BiChatDataModule sharedDataModule]isMessageSending:[message objectForKey:@"msgId"]])
                        {
                            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, 0, 40, 40)];
                            activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                            [activityView startAnimating];
                            [contentView addSubview:activityView];
                        }
                    }
                }
                //是否正在重新上传
                else if ([[BiChatDataModule sharedDataModule]isMessageResending:[message objectForKey:@"msgId"]])
                {
                    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, 0, 40, 40)];
                    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                    [activityView startAnimating];
                    [contentView addSubview:activityView];
                }
            }
            
            UIImageView *image4Sound;
            //是否正在播放
            if ([lastPlaySoundFileName isEqualToString:[dict4SoundInfo objectForKey:@"FileName"]])
            {
                NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"SenderVoicePlaying000"], [UIImage imageNamed:@"SenderVoicePlaying001"], [UIImage imageNamed:@"SenderVoicePlaying002"], [UIImage imageNamed:@"SenderVoicePlaying003"], nil];
                image4Sound = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:images duration:1]];
            }
            else
                image4Sound = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SenderVoicePlaying"]];
            image4Sound.center = CGPointMake(cellWidth - 75, 20);
            [contentView addSubview:image4Sound];
            
            //声音长度
            UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 140 - length * SOUND_PIXEL_PERSECOND, 0, 25, 40)];
            label4SoundLength.text = [NSString stringWithFormat:@"%zd\"", length];
            label4SoundLength.font = [UIFont systemFontOfSize:13];
            label4SoundLength.textColor = [UIColor grayColor];
            label4SoundLength.textAlignment = NSTextAlignmentRight;
            [contentView addSubview:label4SoundLength];
        }
    }
    else    //对方发言
    {
        if (inMultiSelectMode)
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       frame:CGRectMake(50, 0, 40, 40)];
            [contentView addSubview:view4Avatar];
            
            //是否带有remark
            if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
            {
                //声音长度
                NSInteger length = [[dict4SoundInfo objectForKey:@"length"]integerValue];
                if (length < 1) length = 1;
                CGFloat soundLength = 55 + length * SOUND_PIXEL_PERSECOND - 27;
                
                NSString *remarkSenderNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"remarkSender"] groupProperty:groupProperty nickName: [message objectForKey:@"remarkSenderNickName"]];
                NSDictionary *remarkMessage = [[NSDictionary alloc]initWithObjectsAndKeys:
                                               [message objectForKey:@"remarkContent"]==nil?@"":[message objectForKey:@"remarkContent"], @"content",
                                               [message objectForKey:@"remarkType"]==nil?@"":[message objectForKey:@"remarkType"], @"type", nil];
                NSString *remarkContent = [BiChatGlobal getMessageReadableString:remarkMessage groupProperty:groupProperty];
                
                //计算引用者昵称长度
                CGRect rect4RemarkSenderNickNameRect = [remarkSenderNickName boundingRectWithSize:CGSizeMake(cellWidth - 165, MAXFLOAT)
                                                                                          options:NSStringDrawingUsesFontLeading
                                                                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                                          context:nil];
                
                //计算引用内容长度
                CGRect rect4RemarkContentRect = [remarkContent boundingRectWithSize:CGSizeMake(cellWidth - 165, MAXFLOAT)
                                                                            options:NSStringDrawingUsesFontLeading
                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                            context:nil];
                CGFloat contentLength = MAX(soundLength, rect4RemarkContentRect.size.width + 6);
                contentLength = MAX(contentLength, rect4RemarkSenderNickNameRect.size.width + 6);

                UIImageView *image4ContentFrame;
                if (showNickName)
                {
                    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, cellWidth - 150, 20)];
                    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                    label4NickName.font = [UIFont systemFontOfSize:12];
                    label4NickName.textColor = [UIColor grayColor];
                    [contentView addSubview:label4NickName];
                    
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95, 20, contentLength + 27, 80)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                    
                    //引用数据
                    UIView *view4RemarkFlag = [[UIView alloc]initWithFrame:CGRectMake(110, 32, 2, 32)];
                    view4RemarkFlag.backgroundColor = THEME_GREEN;
                    [contentView addSubview:view4RemarkFlag];
                    
                    UILabel *label4RemarkSenderNickName = [[UILabel alloc]initWithFrame:CGRectMake(116, 32, rect4RemarkSenderNickNameRect.size.width, 15)];
                    label4RemarkSenderNickName.text = remarkSenderNickName;
                    label4RemarkSenderNickName.font = [UIFont systemFontOfSize:13];
                    label4RemarkSenderNickName.textColor = THEME_GREEN;
                    [contentView addSubview:label4RemarkSenderNickName];
                    
                    UILabel *label4RemarkContent = [[UILabel alloc]initWithFrame:CGRectMake(116, 48, rect4RemarkContentRect.size.width, 15)];
                    label4RemarkContent.text = remarkContent;
                    label4RemarkContent.font = [UIFont systemFontOfSize:13];
                    label4RemarkContent.textColor = [UIColor grayColor];
                    [contentView addSubview:label4RemarkContent];
                }
                else
                {
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95, 0, contentLength + 27, 80)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                    
                    //引用数据
                    UIView *view4RemarkFlag = [[UIView alloc]initWithFrame:CGRectMake(110, 12, 2, 32)];
                    view4RemarkFlag.backgroundColor = THEME_GREEN;
                    [contentView addSubview:view4RemarkFlag];
                    
                    UILabel *label4RemarkSenderNickName = [[UILabel alloc]initWithFrame:CGRectMake(116, 12, rect4RemarkSenderNickNameRect.size.width, 15)];
                    label4RemarkSenderNickName.text = remarkSenderNickName;
                    label4RemarkSenderNickName.font = [UIFont systemFontOfSize:13];
                    label4RemarkSenderNickName.textColor = THEME_GREEN;
                    [contentView addSubview:label4RemarkSenderNickName];
                    
                    UILabel *label4RemarkContent = [[UILabel alloc]initWithFrame:CGRectMake(116, 28, rect4RemarkContentRect.size.width, 15)];
                    label4RemarkContent.text = remarkContent;
                    label4RemarkContent.font = [UIFont systemFontOfSize:13];
                    label4RemarkContent.textColor = [UIColor grayColor];
                    [contentView addSubview:label4RemarkContent];
                }
                
                //是否正在播放
                UIImageView *image4Sound;
                if ([lastPlaySoundFileName isEqualToString:[dict4SoundInfo objectForKey:@"FileName"]])
                {
                    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"ReceiverVoicePlaying000"], [UIImage imageNamed:@"ReceiverVoicePlaying001"], [UIImage imageNamed:@"ReceiverVoicePlaying002"], [UIImage imageNamed:@"ReceiverVoicePlaying003"], nil];
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:images duration:1]];
                }
                else
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ReceiverVoicePlaying"]];
                image4Sound.center = CGPointMake(115, showNickName?80:60);
                [contentView addSubview:image4Sound];
                
                //声音长度
                UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(130 + contentLength, showNickName?60:40, 25, 40)];
                label4SoundLength.text = [NSString stringWithFormat:@"%zd\"", length];
                label4SoundLength.font = [UIFont systemFontOfSize:13];
                label4SoundLength.textColor = [UIColor grayColor];
                [contentView addSubview:label4SoundLength];
                
                //是否新消息
                if ([[message objectForKey:@"isNew"]boolValue])
                {
                    //生成本文件所在的位置
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *soundFile = [[dict4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                    NSString *soundPath = [documentsDirectory stringByAppendingPathComponent:soundFile];
                    NSFileManager *fmgr = [NSFileManager defaultManager];
                    
                    //是否正在下载
                    if ([[[BiChatGlobal sharedManager].dict4DownloadingSound objectForKey:[dict4SoundInfo objectForKey:@"FileName"]]isEqualToString:@"downloading"])
                    {
                        //显示一个新标志
                        UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(130 + contentLength, showNickName?62:42, 8, 8)];
                        view4NewFlag.backgroundColor = [UIColor redColor];
                        view4NewFlag.layer.cornerRadius = 4;
                        view4NewFlag.clipsToBounds = YES;
                        [contentView addSubview:view4NewFlag];
                        
                        //当前文件是否存在
                        if (![fmgr fileExistsAtPath:soundPath] )
                        {
                            //开始闪烁新标志
                            __block BOOL flagShow = YES;
                            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
                                
                                if ([fmgr fileExistsAtPath:soundPath])
                                {
                                    [timer invalidate];
                                    timer = nil;
                                    view4NewFlag.hidden = NO;
                                }
                                else
                                {
                                    flagShow = !flagShow;
                                    view4NewFlag.hidden = !flagShow;
                                }
                            }];
                            timer = nil;
                        }
                    }
                    else
                    {
                        //当前文件是否存在
                        if ([fmgr fileExistsAtPath:soundPath])
                        {
                            //显示一个新标志
                            UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(130 + contentLength, showNickName?62:42, 8, 8)];
                            view4NewFlag.backgroundColor = [UIColor redColor];
                            view4NewFlag.layer.cornerRadius = 4;
                            view4NewFlag.clipsToBounds = YES;
                            [contentView addSubview:view4NewFlag];
                        }
                        else
                        {
                            UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(143 + contentLength, showNickName?60:40, 40, 40)];
                            [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                            [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                            objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                            [contentView addSubview:button4Resend];
                        }
                    }
                }
            }
            else
            {
                NSInteger length = [[dict4SoundInfo objectForKey:@"length"]integerValue];
                if (length < 1) length = 1;
                UIImageView *image4ContentFrame;
                if (showNickName)
                {
                    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, cellWidth - 150, 20)];
                    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                    label4NickName.font = [UIFont systemFontOfSize:12];
                    label4NickName.textColor = [UIColor grayColor];
                    [contentView addSubview:label4NickName];
                    
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95, 20, 55 + length * SOUND_PIXEL_PERSECOND, 40)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                }
                else
                {
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95, 0, 55 + length * SOUND_PIXEL_PERSECOND, 40)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                }
                
                //是否正在播放
                UIImageView *image4Sound;
                if ([lastPlaySoundFileName isEqualToString:[dict4SoundInfo objectForKey:@"FileName"]])
                {
                    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"ReceiverVoicePlaying000"], [UIImage imageNamed:@"ReceiverVoicePlaying001"], [UIImage imageNamed:@"ReceiverVoicePlaying002"], [UIImage imageNamed:@"ReceiverVoicePlaying003"], nil];
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:images duration:1]];
                }
                else
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ReceiverVoicePlaying"]];
                image4Sound.center = CGPointMake(115, showNickName?40:20);
                [contentView addSubview:image4Sound];
                
                //声音长度
                UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(157 + length * SOUND_PIXEL_PERSECOND, showNickName?20:0, 25, 40)];
                label4SoundLength.text = [NSString stringWithFormat:@"%zd\"", length];
                label4SoundLength.font = [UIFont systemFontOfSize:13];
                label4SoundLength.textColor = [UIColor grayColor];
                [contentView addSubview:label4SoundLength];
                
                //是否新消息
                if ([[message objectForKey:@"isNew"]boolValue])
                {
                    //生成本文件所在的位置
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *soundFile = [[dict4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                    NSString *soundPath = [documentsDirectory stringByAppendingPathComponent:soundFile];
                    NSFileManager *fmgr = [NSFileManager defaultManager];
                    
                    //是否正在下载
                    if ([[[BiChatGlobal sharedManager].dict4DownloadingSound objectForKey:[dict4SoundInfo objectForKey:@"FileName"]]isEqualToString:@"downloading"])
                    {
                        //显示一个新标志
                        UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(157 + length * SOUND_PIXEL_PERSECOND, showNickName?22:2, 8, 8)];
                        view4NewFlag.backgroundColor = [UIColor redColor];
                        view4NewFlag.layer.cornerRadius = 4;
                        view4NewFlag.clipsToBounds = YES;
                        [contentView addSubview:view4NewFlag];
                        
                        //当前文件是否存在
                        if (![fmgr fileExistsAtPath:soundPath])
                        {
                            //开始闪烁新标志
                            __block BOOL flagShow = YES;
                            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
                                
                                if ([fmgr fileExistsAtPath:soundPath])
                                {
                                    [timer invalidate];
                                    timer = nil;
                                    view4NewFlag.hidden = NO;
                                }
                                else
                                {
                                    flagShow = !flagShow;
                                    view4NewFlag.hidden = !flagShow;
                                }
                            }];
                            timer = nil;
                        }
                    }
                    else
                    {
                        //当前文件是否存在
                        if ([fmgr fileExistsAtPath:soundPath])
                        {
                            //显示一个新标志
                            UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(157 + length * SOUND_PIXEL_PERSECOND, showNickName?22:2, 8, 8)];
                            view4NewFlag.backgroundColor = [UIColor redColor];
                            view4NewFlag.layer.cornerRadius = 4;
                            view4NewFlag.clipsToBounds = YES;
                            [contentView addSubview:view4NewFlag];
                        }
                        else
                        {
                            UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(170 + length * SOUND_PIXEL_PERSECOND, showNickName?20:0, 40, 40)];
                            [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                            [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                            objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                            [contentView addSubview:button4Resend];
                        }
                    }
                }
            }
        }
        else
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       frame:CGRectMake(10, 0, 40, 40)];
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            //是否带有remark
            if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
            {
                //声音长度
                NSInteger length = [[dict4SoundInfo objectForKey:@"length"]integerValue];
                if (length < 1) length = 1;
                CGFloat soundLength = 55 + length * SOUND_PIXEL_PERSECOND - 27;
                
                NSString *remarkSenderNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"remarkSender"] groupProperty:groupProperty nickName: [message objectForKey:@"remarkSenderNickName"]];
                NSDictionary *remarkMessage = [[NSDictionary alloc]initWithObjectsAndKeys:
                                               [message objectForKey:@"remarkContent"]==nil?@"":[message objectForKey:@"remarkContent"], @"content",
                                               [message objectForKey:@"remarkType"]==nil?@"":[message objectForKey:@"remarkType"], @"type", nil];
                NSString *remarkContent = [BiChatGlobal getMessageReadableString:remarkMessage groupProperty:groupProperty];
                
                //计算引用者昵称长度
                CGRect rect4RemarkSenderNickNameRect = [remarkSenderNickName boundingRectWithSize:CGSizeMake(cellWidth - 165, MAXFLOAT)
                                                                                          options:NSStringDrawingUsesFontLeading
                                                                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                                          context:nil];
                
                //计算引用内容长度
                CGRect rect4RemarkContentRect = [remarkContent boundingRectWithSize:CGSizeMake(cellWidth - 165, MAXFLOAT)
                                                                            options:NSStringDrawingUsesFontLeading
                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                            context:nil];
                CGFloat contentLength = MAX(soundLength, rect4RemarkContentRect.size.width + 6);
                contentLength = MAX(contentLength, rect4RemarkSenderNickNameRect.size.width + 6);
                
                UIImageView *image4ContentFrame;
                if (showNickName)
                {
                    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, cellWidth - 150, 20)];
                    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                    label4NickName.font = [UIFont systemFontOfSize:12];
                    label4NickName.textColor = [UIColor grayColor];
                    [contentView addSubview:label4NickName];
                    
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55, 20, contentLength + 27, 80)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                    
                    //引用数据
                    UIView *view4RemarkFlag = [[UIView alloc]initWithFrame:CGRectMake(70, 32, 2, 32)];
                    view4RemarkFlag.backgroundColor = THEME_GREEN;
                    [contentView addSubview:view4RemarkFlag];
                    
                    UILabel *label4RemarkSenderNickName = [[UILabel alloc]initWithFrame:CGRectMake(76, 32, rect4RemarkSenderNickNameRect.size.width, 15)];
                    label4RemarkSenderNickName.text = remarkSenderNickName;
                    label4RemarkSenderNickName.font = [UIFont systemFontOfSize:13];
                    label4RemarkSenderNickName.textColor = THEME_GREEN;
                    [contentView addSubview:label4RemarkSenderNickName];
                    
                    UILabel *label4RemarkContent = [[UILabel alloc]initWithFrame:CGRectMake(76, 48, rect4RemarkContentRect.size.width, 15)];
                    label4RemarkContent.text = remarkContent;
                    label4RemarkContent.font = [UIFont systemFontOfSize:13];
                    label4RemarkContent.textColor = [UIColor grayColor];
                    [contentView addSubview:label4RemarkContent];
                }
                else
                {
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55, 0, contentLength + 27, 80)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                    
                    //引用数据
                    UIView *view4RemarkFlag = [[UIView alloc]initWithFrame:CGRectMake(70, 12, 2, 32)];
                    view4RemarkFlag.backgroundColor = THEME_GREEN;
                    [contentView addSubview:view4RemarkFlag];
                    
                    UILabel *label4RemarkSenderNickName = [[UILabel alloc]initWithFrame:CGRectMake(76, 12, rect4RemarkSenderNickNameRect.size.width, 15)];
                    label4RemarkSenderNickName.text = remarkSenderNickName;
                    label4RemarkSenderNickName.font = [UIFont systemFontOfSize:13];
                    label4RemarkSenderNickName.textColor = THEME_GREEN;
                    [contentView addSubview:label4RemarkSenderNickName];
                    
                    UILabel *label4RemarkContent = [[UILabel alloc]initWithFrame:CGRectMake(76, 28, rect4RemarkContentRect.size.width, 15)];
                    label4RemarkContent.text = remarkContent;
                    label4RemarkContent.font = [UIFont systemFontOfSize:13];
                    label4RemarkContent.textColor = [UIColor grayColor];
                    [contentView addSubview:label4RemarkContent];
                }
                
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
                
                //引用部分
                UIView *view4Remark = [[UIView alloc]initWithFrame:CGRectMake(55, showNickName?20:0, contentLength, 33)];
                [contentView addSubview:view4Remark];
                
                //给引用部分加长按手势
                view4Remark.userInteractionEnabled = YES;
                longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [view4Remark addGestureRecognizer:longPressGest];
                
                //给引用部分加点击手势
                tapGest = [[UITapGestureRecognizer alloc]initWithTarget:remarkTarget action:remarkAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [view4Remark addGestureRecognizer:tapGest];

                //是否正在播放
                UIImageView *image4Sound;
                if ([lastPlaySoundFileName isEqualToString:[dict4SoundInfo objectForKey:@"FileName"]])
                {
                    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"ReceiverVoicePlaying000"], [UIImage imageNamed:@"ReceiverVoicePlaying001"], [UIImage imageNamed:@"ReceiverVoicePlaying002"], [UIImage imageNamed:@"ReceiverVoicePlaying003"], nil];
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:images duration:1]];
                }
                else
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ReceiverVoicePlaying"]];
                image4Sound.center = CGPointMake(75, showNickName?80:60);
                [contentView addSubview:image4Sound];
                
                //声音长度
                UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(90 + contentLength, showNickName?60:40, 25, 40)];
                label4SoundLength.text = [NSString stringWithFormat:@"%zd\"", length];
                label4SoundLength.font = [UIFont systemFontOfSize:13];
                label4SoundLength.textColor = [UIColor grayColor];
                [contentView addSubview:label4SoundLength];
                
                //是否新消息
                if ([[message objectForKey:@"isNew"]boolValue])
                {
                    
                    //生成本文件所在的位置
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *soundFile = [[dict4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                    NSString *soundPath = [documentsDirectory stringByAppendingPathComponent:soundFile];
                    NSFileManager *fmgr = [NSFileManager defaultManager];

                    //是否正在下载
                    if ([[[BiChatGlobal sharedManager].dict4DownloadingSound objectForKey:[dict4SoundInfo objectForKey:@"FileName"]]isEqualToString:@"downloading"])
                    {
                        //显示一个新标志
                        UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(90 + contentLength, showNickName?62:42, 8, 8)];
                        view4NewFlag.backgroundColor = [UIColor redColor];
                        view4NewFlag.layer.cornerRadius = 4;
                        view4NewFlag.clipsToBounds = YES;
                        [contentView addSubview:view4NewFlag];
                        
                        //当前文件是否存在
                        if (![fmgr fileExistsAtPath:soundPath])
                        {
                            //开始闪烁新标志
                            __block BOOL flagShow = YES;
                            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
                                
                                if ([fmgr fileExistsAtPath:soundPath])
                                {
                                    [timer invalidate];
                                    timer = nil;
                                    view4NewFlag.hidden = NO;
                                }
                                else
                                {
                                    flagShow = !flagShow;
                                    view4NewFlag.hidden = !flagShow;
                                }
                            }];
                            timer = nil;
                        }
                    }
                    else
                    {
                        //当前文件是否存在
                        if ([fmgr fileExistsAtPath:soundPath])
                        {
                            //显示一个新标志
                            UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(90 + contentLength, showNickName?62:42, 8, 8)];
                            view4NewFlag.backgroundColor = [UIColor redColor];
                            view4NewFlag.layer.cornerRadius = 4;
                            view4NewFlag.clipsToBounds = YES;
                            [contentView addSubview:view4NewFlag];
                        }
                        else
                        {
                            UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(103 + contentLength, showNickName?60:40, 40, 40)];
                            [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                            [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                            objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                            [contentView addSubview:button4Resend];
                        }
                    }
                }
            }
            else
            {
                NSInteger length = [[dict4SoundInfo objectForKey:@"length"]integerValue];
                if (length < 1) length = 1;
                UIImageView *image4ContentFrame;
                if (showNickName)
                {
                    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, cellWidth - 150, 20)];
                    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                    label4NickName.font = [UIFont systemFontOfSize:12];
                    label4NickName.textColor = [UIColor grayColor];
                    [contentView addSubview:label4NickName];
                    
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55, 20, 55 + length * SOUND_PIXEL_PERSECOND, 40)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                }
                else
                {
                    //声音内容框
                    image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55, 0, 55 + length * SOUND_PIXEL_PERSECOND, 40)];
                    image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                    [contentView addSubview:image4ContentFrame];
                }
                
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
                
                //是否正在播放
                UIImageView *image4Sound;
                if ([lastPlaySoundFileName isEqualToString:[dict4SoundInfo objectForKey:@"FileName"]])
                {
                    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"ReceiverVoicePlaying000"], [UIImage imageNamed:@"ReceiverVoicePlaying001"], [UIImage imageNamed:@"ReceiverVoicePlaying002"], [UIImage imageNamed:@"ReceiverVoicePlaying003"], nil];
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:images duration:1]];
                }
                else
                    image4Sound = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ReceiverVoicePlaying"]];
                image4Sound.center = CGPointMake(75, showNickName?40:20);
                [contentView addSubview:image4Sound];
                
                //声音长度
                UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(117 + length * SOUND_PIXEL_PERSECOND, showNickName?20:0, 25, 40)];
                label4SoundLength.text = [NSString stringWithFormat:@"%zd\"", length];
                label4SoundLength.font = [UIFont systemFontOfSize:13];
                label4SoundLength.textColor = [UIColor grayColor];
                [contentView addSubview:label4SoundLength];
                
                //NSLog(@"%@", [BiChatGlobal sharedManager].dict4DownloadingSound);
                //NSLog(@"%@", dict4SoundInfo);
                
                //是否新消息
                if ([[message objectForKey:@"isNew"]boolValue])
                {
                    //生成本文件所在的位置
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *soundFile = [[dict4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                    NSString *soundPath = [documentsDirectory stringByAppendingPathComponent:soundFile];
                    NSFileManager *fmgr = [NSFileManager defaultManager];

                    //是否正在下载
                    if ([[[BiChatGlobal sharedManager].dict4DownloadingSound objectForKey:[dict4SoundInfo objectForKey:@"FileName"]]isEqualToString:@"downloading"])
                    {
                        //显示一个新标志
                        UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(117 + length * SOUND_PIXEL_PERSECOND, showNickName?22:2, 8, 8)];
                        view4NewFlag.backgroundColor = [UIColor redColor];
                        view4NewFlag.layer.cornerRadius = 4;
                        view4NewFlag.clipsToBounds = YES;
                        [contentView addSubview:view4NewFlag];
                        
                        //当前文件是否存在
                        if (![fmgr fileExistsAtPath:soundPath])
                        {
                            //开始闪烁新标志
                            __block BOOL flagShow = YES;
                            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
                                
                                if ([fmgr fileExistsAtPath:soundPath])
                                {
                                    [timer invalidate];
                                    timer = nil;
                                    view4NewFlag.hidden = NO;
                                }
                                else
                                {
                                    flagShow = !flagShow;
                                    view4NewFlag.hidden = !flagShow;
                                }
                            }];
                            timer = nil;
                        }
                    }
                    else
                    {
                        //当前文件是否存在
                        if ([fmgr fileExistsAtPath:soundPath])
                        {
                            //显示一个新标志
                            UIView *view4NewFlag = [[UIView alloc]initWithFrame:CGRectMake(117 + length * SOUND_PIXEL_PERSECOND, showNickName?22:2, 8, 8)];
                            view4NewFlag.backgroundColor = [UIColor redColor];
                            view4NewFlag.layer.cornerRadius = 4;
                            view4NewFlag.clipsToBounds = YES;
                            [contentView addSubview:view4NewFlag];
                        }
                        else
                        {
                            UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(130 + length * SOUND_PIXEL_PERSECOND, showNickName?20:0, 40, 40)];
                            [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                            [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                            objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                            objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                            [contentView addSubview:button4Resend];
                        }
                    }
                }
            }
        }
    }
}

@end
