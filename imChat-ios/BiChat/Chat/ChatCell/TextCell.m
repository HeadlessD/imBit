//
//  TextCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "TextCell.h"

@implementation TextCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    NSString *comments = [message objectForKey:@"comments"];
    
    //计算文本的大小
    static NSMutableDictionary *dict4TransEmotionCache = nil;
    if (dict4TransEmotionCache == nil)
        dict4TransEmotionCache = [NSMutableDictionary dictionary];
    NSString *str4Message = [BiChatGlobal getMessageReadableString:message groupProperty:nil];
    if (str4Message.length == 0)
        return 0;
    NSMutableAttributedString *str;
    str = [dict4TransEmotionCache objectForKey:str4Message];
    if (str == nil)
    {
        str = [str4Message transEmotionWithFont:[UIFont systemFontOfSize:CHATTEXT_FONTSIZE]];

        if ([dict4TransEmotionCache count] > 1000)
        {
            for (NSString *key in dict4TransEmotionCache)
            {
                [dict4TransEmotionCache removeObjectForKey:key];
                break;
            }
        }
        [dict4TransEmotionCache setObject:str forKey:str4Message];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:1];
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:CHATTEXT_FONTSIZE] range:NSMakeRange(0, str.length)];
    CGRect rect = [str boundingRectWithSize:CGSizeMake(cellWidth - 150, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
    CGRect rect2 = [comments boundingRectWithSize:CGSizeMake(cellWidth - 150, MAXFLOAT)
                                          options:NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CHATTEXT_FONTSIZE]}
                                          context:nil];
    
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return rect.size.height + 54 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT) + (comments.length > 0?rect2.size.height:0);
    else
        return rect.size.height + 34 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT) + (comments.length > 0?rect2.size.height:0);
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
        textViewDelegate:(id<UITextViewDelegate>)textViewDelegate
{
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    NSString *remarkSenderNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"remarkSender"] groupProperty:groupProperty nickName: [message objectForKey:@"remarkSenderNickName"]];
    NSDictionary *remarkMessage = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   [message objectForKey:@"remarkContent"]==nil?@"":[message objectForKey:@"remarkContent"], @"content",
                                   [message objectForKey:@"remarkType"]==nil?@"":[message objectForKey:@"remarkType"], @"type", nil];
    NSString *remarkContent = [BiChatGlobal getMessageReadableString:remarkMessage groupProperty:groupProperty];
    
    //计算文本的大小
    static NSMutableDictionary *dict4TransEmotionCache = nil;
    if (dict4TransEmotionCache == nil)
        dict4TransEmotionCache = [NSMutableDictionary dictionary];
    NSString *str4Message = [BiChatGlobal getMessageReadableString:message groupProperty:nil];
    if (str4Message.length == 0)
        return;
    NSMutableAttributedString *str;
    str = [dict4TransEmotionCache objectForKey:str4Message];
    if (str == nil)
    {
        str = [str4Message transEmotionWithFont:[UIFont systemFontOfSize:CHATTEXT_FONTSIZE]];
        if ([dict4TransEmotionCache count] > 1000)
        {
            for (NSString *key in dict4TransEmotionCache)
            {
                [dict4TransEmotionCache removeObjectForKey:key];
                break;
            }
        }
        [dict4TransEmotionCache setObject:str forKey:str4Message];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:1];
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:CHATTEXT_FONTSIZE] range:NSMakeRange(0, str.length)];
    CGRect rect4Content = [str boundingRectWithSize:CGSizeMake(cellWidth - 150, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
    if (rect4Content.size.width < 13)
        rect4Content.size.width = 13;
    
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
    CGFloat contentLength = MAX(rect4Content.size.width, rect4RemarkContentRect.size.width + 6);
    contentLength = MAX(contentLength, rect4RemarkSenderNickNameRect.size.width + 6);
    
    //comments
    NSString *comments = [message objectForKey:@"comments"];
    if (comments.length > 0) comments = [LLSTR(@"101024") stringByAppendingString:comments];
    CGRect rect4Comments = [comments boundingRectWithSize:CGSizeMake(cellWidth - 165, MAXFLOAT)
                                                  options:NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                                  context:nil];
    
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
        CGFloat contentFrameHeight = rect4Content.size.height + 24 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT);
        UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 82,
                                                                                       0,
                                                                                       contentLength + 27,
                                                                                       contentFrameHeight)];
        image4ContentFrame.image = [UIImage imageNamed:@"bubbleMine"];
        [contentView addSubview:image4ContentFrame];
        
        //给图片增加长按手势
        if (!inMultiSelectMode)
        {
            image4ContentFrame.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ContentFrame addGestureRecognizer:longPressGest];
        }
        
        //是否引用？
        if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
        {
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
            
            //引用部分
            UIView *view4Remark = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 82, 0, contentLength, 33)];
            [contentView addSubview:view4Remark];
            
            //给引用部分加长按手势
            view4Remark.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [view4Remark addGestureRecognizer:longPressGest];
            
            //给引用部分加点击手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:remarkTarget action:remarkAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [view4Remark addGestureRecognizer:tapGest];
        }
        
        UITextView *text4Content = [[UITextView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 71,
                                                                               12 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT),
                                                                               rect4Content.size.width,
                                                                               rect4Content.size.height)];
        text4Content.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
        text4Content.linkTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           LINK_COLOR_2, NSForegroundColorAttributeName,
                                           /*[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,*/
                                           nil];
        text4Content.attributedText = str;
        //text4Content.font = [UIFont systemFontOfSize:CHATTEXT_FONTSIZE];
        text4Content.textColor = [UIColor whiteColor];
        text4Content.backgroundColor = [UIColor clearColor];
        text4Content.editable = NO;
        text4Content.selectable = YES;
        text4Content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
        text4Content.layoutManager.allowsNonContiguousLayout=NO;
        text4Content.delegate = textViewDelegate;
        text4Content.scrollEnabled = NO;
        text4Content.clipsToBounds = NO;
        [contentView addSubview:text4Content];
        
        //给文字增加长按手势
        if (!inMultiSelectMode)
        {
            for(UIGestureRecognizer *recognizer in text4Content.gestureRecognizers)
            {
                if([NSStringFromClass([recognizer class]) isEqualToString:@"UITapAndAHalfRecognizer"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"UILongPressGestureRecognizer"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"_UITextSelectionForceGesture"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"UITapGestureRecognizer"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragAutoScrollGestureRecognizer"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragLiftGestureRecognizer"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"_UIRelationshipGestureRecognizer"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragAddItemsGesture"] ||
                   [NSStringFromClass([recognizer class]) isEqualToString:@"_UIRelationshipGestureRecognizer"]) {
                    [text4Content removeGestureRecognizer:recognizer];
                }
            }
            
            //添加自定义的长按手势
            image4ContentFrame.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", text4Content, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            longPressGest.delaysTouchesBegan = NO;
            longPressGest.delaysTouchesEnded = NO;
            [text4Content addGestureRecognizer:longPressGest];
            
            //是否未发送成功
            if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[message objectForKey:@"msgId"]])
            {
                UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, contentFrameHeight / 2 - 20, 40, 40)];
                [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4Resend, @"targetView", text4Content, OBJC_ASSOCIATION_ASSIGN);
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
                            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, contentFrameHeight / 2 - 20, 40, 40)];
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
                        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, contentFrameHeight / 2 - 20, 40, 40)];
                        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                        [activityView startAnimating];
                        [contentView addSubview:activityView];
                    }
                }
            }
            //是否正在重新上传
            else if ([[BiChatDataModule sharedDataModule]isMessageResending:[message objectForKey:@"msgId"]])
            {
                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(cellWidth - contentLength - 125, contentFrameHeight / 2 - 20, 40, 40)];
                activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                [activityView startAnimating];
                [contentView addSubview:activityView];
            }
        }
        
        //comments
        if (comments.length > 0)
        {
            UILabel *label4Comments = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - rect4Comments.size.width - 60,
                                                                               rect4Content.size.height + 26 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT),
                                                                               rect4Comments.size.width,
                                                                               rect4Comments.size.height)];
            label4Comments.text = comments;
            label4Comments.font = [UIFont systemFontOfSize:12];
            label4Comments.textColor = [UIColor grayColor];
            [contentView addSubview:label4Comments];
        }
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
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               20,
                                                                                               contentLength + 27,
                                                                                               rect4Content.size.height + 24 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT))];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //是否引用？
                if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
                {
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
                
                UITextView *text4Content = [[UITextView alloc]initWithFrame:CGRectMake(110,
                                                                                       32 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT),
                                                                                       rect4Content.size.width,
                                                                                       rect4Content.size.height)];
                text4Content.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
                text4Content.linkTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   THEME_COLOR, NSForegroundColorAttributeName,
                                                   /*[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,*/
                                                   nil];
                text4Content.attributedText = str;
                text4Content.font = [UIFont systemFontOfSize:CHATTEXT_FONTSIZE];
                text4Content.textColor = [UIColor blackColor];
                text4Content.backgroundColor = [UIColor clearColor];
                text4Content.editable = NO;
                text4Content.selectable = YES;
                text4Content.userInteractionEnabled = NO;
                text4Content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
                text4Content.layoutManager.allowsNonContiguousLayout=NO;
                text4Content.delegate = textViewDelegate;
                text4Content.scrollEnabled = NO;
                text4Content.clipsToBounds = NO;
                [contentView addSubview:text4Content];
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               0,
                                                                                               contentLength + 27,
                                                                                               rect4Content.size.height + 24 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT))];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //是否引用？
                if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
                {
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
                
                UITextView *text4Content = [[UITextView alloc]initWithFrame:CGRectMake(110,
                                                                                       12 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT),
                                                                                       rect4Content.size.width,
                                                                                       rect4Content.size.height)];
                text4Content.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
                text4Content.linkTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   THEME_COLOR, NSForegroundColorAttributeName,
                                                   /*[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,*/
                                                   nil];
                text4Content.attributedText = str;
                text4Content.font = [UIFont systemFontOfSize:CHATTEXT_FONTSIZE];
                text4Content.textColor = [UIColor blackColor];
                text4Content.backgroundColor = [UIColor clearColor];
                text4Content.editable = NO;
                text4Content.selectable = YES;
                text4Content.userInteractionEnabled = NO;
                text4Content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
                text4Content.layoutManager.allowsNonContiguousLayout=NO;
                text4Content.delegate = textViewDelegate;
                text4Content.scrollEnabled = NO;
                text4Content.clipsToBounds = NO;
                [contentView addSubview:text4Content];
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
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0,cellWidth - 150, 20)];
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               20,
                                                                                               contentLength + 27,
                                                                                               rect4Content.size.height + 24 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT))];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //是否引用？
                if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
                {
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
                    
                    //引用部分
                    UIView *view4Remark = [[UIView alloc]initWithFrame:CGRectMake(55, 20, contentLength, 33)];
                    [contentView addSubview:view4Remark];
                    
                    //给引用部分加长按手势
                    view4Remark.userInteractionEnabled = YES;
                    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                    objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [view4Remark addGestureRecognizer:longPressGest];
                    
                    //给引用部分加点击手势
                    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:remarkTarget action:remarkAction];
                    objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [view4Remark addGestureRecognizer:tapGest];
                }
                
                UITextView *text4Content = [[UITextView alloc]initWithFrame:CGRectMake(70,
                                                                                       32 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT),
                                                                                       rect4Content.size.width,
                                                                                       rect4Content.size.height)];
                text4Content.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
                text4Content.linkTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   THEME_COLOR, NSForegroundColorAttributeName,
                                                   /*[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,*/
                                                   nil];
                text4Content.attributedText = str;
                text4Content.font = [UIFont systemFontOfSize:CHATTEXT_FONTSIZE];
                text4Content.textColor = [UIColor blackColor];
                text4Content.backgroundColor = [UIColor clearColor];
                text4Content.editable = NO;
                text4Content.selectable = YES;
                text4Content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
                text4Content.layoutManager.allowsNonContiguousLayout=NO;
                text4Content.delegate = textViewDelegate;
                text4Content.scrollEnabled = NO;
                text4Content.clipsToBounds = NO;
                [contentView addSubview:text4Content];
                
                //给文字增加长按手势
                if (!inMultiSelectMode)
                {
                    for(UIGestureRecognizer *recognizer in text4Content.gestureRecognizers)
                    {
                        if([NSStringFromClass([recognizer class]) isEqualToString:@"UITapAndAHalfRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"UILongPressGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UITextSelectionForceGesture"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"UITapGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragAutoScrollGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragLiftGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIRelationshipGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragAddItemsGesture"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIRelationshipGestureRecognizer"]) {
                            [text4Content removeGestureRecognizer:recognizer];
                        }
                    }
                    
                    image4ContentFrame.userInteractionEnabled = YES;
                    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                    objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetView", text4Content, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [text4Content addGestureRecognizer:longPressGest];
                }
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               0,
                                                                                               contentLength + 27,
                                                                                               rect4Content.size.height + 24 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT))];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //是否引用？
                if ([[message objectForKey:@"remarkType"]integerValue] != MESSAGE_CONTENT_TYPE_NONE)
                {
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
                    
                    //引用部分
                    UIView *view4Remark = [[UIView alloc]initWithFrame:CGRectMake(55, 0, contentLength, 33)];
                    [contentView addSubview:view4Remark];
                    
                    //给引用部分加长按手势
                    view4Remark.userInteractionEnabled = YES;
                    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                    objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [view4Remark addGestureRecognizer:longPressGest];
                    
                    //给引用部分加点击手势
                    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:remarkTarget action:remarkAction];
                    objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [view4Remark addGestureRecognizer:tapGest];
                }
                
                UITextView *text4Content = [[UITextView alloc]initWithFrame:CGRectMake(70,
                                                                                       12 + ([[message objectForKey:@"remarkType"]integerValue] == MESSAGE_CONTENT_TYPE_NONE?0:REMARK_SECTION_HEIGHT),
                                                                                       rect4Content.size.width,
                                                                                       rect4Content.size.height)];
                text4Content.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
                text4Content.linkTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   THEME_COLOR, NSForegroundColorAttributeName,
                                                   /*[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,*/
                                                   nil];
                text4Content.attributedText = str;
                text4Content.font = [UIFont systemFontOfSize:CHATTEXT_FONTSIZE];
                text4Content.textColor = [UIColor blackColor];
                text4Content.backgroundColor = [UIColor clearColor];
                text4Content.editable = NO;
                text4Content.selectable = YES;
                text4Content.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
                text4Content.layoutManager.allowsNonContiguousLayout = NO;
                text4Content.delegate = textViewDelegate;
                text4Content.clipsToBounds = NO;
                text4Content.scrollEnabled = NO;
                [contentView addSubview:text4Content];
                
                //给文字增加长按手势
                if (!inMultiSelectMode)
                {
                    for(UIGestureRecognizer *recognizer in text4Content.gestureRecognizers)
                    {
                        if([NSStringFromClass([recognizer class]) isEqualToString:@"UITapAndAHalfRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"UILongPressGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UITextSelectionForceGesture"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"UITapGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragAutoScrollGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragLiftGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIRelationshipGestureRecognizer"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIDragAddItemsGesture"] ||
                           [NSStringFromClass([recognizer class]) isEqualToString:@"_UIRelationshipGestureRecognizer"]) {
                            [text4Content removeGestureRecognizer:recognizer];
                        }
                    }
                    
                    image4ContentFrame.userInteractionEnabled = YES;
                    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                    objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetView", text4Content, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                    [text4Content addGestureRecognizer:longPressGest];
                }
            }
        }
    }
}

@end
