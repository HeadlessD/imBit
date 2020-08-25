//
//  GroupHomeCell.m
//  BiChat
//
//  Created by worm_kc on 2019/1/15.
//  Copyright © 2019年 worm_kc. All rights reserved.
//

#import "GroupHomeCell.h"
#import "JSONKit.h"

@implementation GroupHomeCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return 162;
    else
        return 142;
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
    //解析链接内容
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *groupHomeInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //内容高度
    CGRect rect4Desc = [[groupHomeInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(205, 50)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                         context:nil];
    
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
        UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 235 - 55,
                                                                                       0,
                                                                                       235,
                                                                                       132)];
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
        
        //图片
        UIView *view4GroupHomeAvatar = [BiChatGlobal getAvatarWnd:@"" nickName:[groupHomeInfo objectForKey:@"groupNickName"] avatar:[groupHomeInfo objectForKey:@"groupAvatar"] frame:CGRectMake(cellWidth - 278, 12, 30, 30)];
        [contentView addSubview:view4GroupHomeAvatar];

        //内容
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 238, 12, 165, 30)];
        label4Title.text = [groupHomeInfo objectForKey:@"title"];
        label4Title.font = [UIFont systemFontOfSize:16];
        [contentView addSubview:label4Title];
        
        //seperator
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 280, 50, 210, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [contentView addSubview:view4Seperator];
        
        //副标题
        UILabel *label4Desc = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 278, 58, rect4Desc.size.width, rect4Desc.size.height)];
        label4Desc.text = [groupHomeInfo objectForKey:@"desc"];
        label4Desc.textColor = [UIColor grayColor];
        label4Desc.font = [UIFont systemFontOfSize:13];
        label4Desc.numberOfLines = 0;
        [contentView addSubview:label4Desc];

        //seperator
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 280, 112, 210, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [contentView addSubview:view4Seperator];
        
        //链接标志
        UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 278, 112, 190, 20)];
        label4Card.text = LLSTR(@"201022");
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
                                                                                               132)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //图片
                UIView *view4GroupHomeAvatar = [BiChatGlobal getAvatarWnd:@"" nickName:[groupHomeInfo objectForKey:@"groupNickName"] avatar:[groupHomeInfo objectForKey:@"groupAvatar"] frame:CGRectMake(112, 32, 30, 30)];
                [contentView addSubview:view4GroupHomeAvatar];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(152, 32, 165, 30)];
                label4Title.text = [groupHomeInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(112, 70, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //副标题
                UILabel *label4Desc = [[UILabel alloc]initWithFrame:CGRectMake(112, 78, rect4Desc.size.width, rect4Desc.size.height)];
                label4Desc.text = [groupHomeInfo objectForKey:@"desc"];
                label4Desc.textColor = [UIColor grayColor];
                label4Desc.font = [UIFont systemFontOfSize:13];
                label4Desc.numberOfLines = 0;
                [contentView addSubview:label4Desc];
                
                //seperator
                view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(112, 132, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 132, 190, 20)];
                label4Card.text = LLSTR(@"201022");
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
                                                                                               132)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //图片
                UIView *view4GroupHomeAvatar = [BiChatGlobal getAvatarWnd:@"" nickName:[groupHomeInfo objectForKey:@"groupNickName"] avatar:[groupHomeInfo objectForKey:@"groupAvatar"] frame:CGRectMake(112, 12, 30, 30)];
                [contentView addSubview:view4GroupHomeAvatar];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(152, 12, 165, 30)];
                label4Title.text = [groupHomeInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(112, 50, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //副标题
                UILabel *label4Desc = [[UILabel alloc]initWithFrame:CGRectMake(112, 58, rect4Desc.size.width, rect4Desc.size.height)];
                label4Desc.text = [groupHomeInfo objectForKey:@"desc"];
                label4Desc.textColor = [UIColor grayColor];
                label4Desc.font = [UIFont systemFontOfSize:13];
                label4Desc.numberOfLines = 0;
                [contentView addSubview:label4Desc];
                
                //seperator
                view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(112, 112, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 112, 190, 20)];
                label4Card.text = LLSTR(@"201022");
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
                                                                                               132)];
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
                
                //图片
                UIView *view4GroupHomeAvatar = [BiChatGlobal getAvatarWnd:@"" nickName:[groupHomeInfo objectForKey:@"groupNickName"] avatar:[groupHomeInfo objectForKey:@"groupAvatar"] frame:CGRectMake(72, 32, 30, 30)];
                [contentView addSubview:view4GroupHomeAvatar];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(112, 32, 165, 30)];
                label4Title.text = [groupHomeInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(72, 70, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //副标题
                UILabel *label4Desc = [[UILabel alloc]initWithFrame:CGRectMake(72, 78, rect4Desc.size.width, rect4Desc.size.height)];
                label4Desc.text = [groupHomeInfo objectForKey:@"desc"];
                label4Desc.textColor = [UIColor grayColor];
                label4Desc.font = [UIFont systemFontOfSize:13];
                label4Desc.numberOfLines = 0;
                [contentView addSubview:label4Desc];
                
                //seperator
                view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(72, 132, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 132, 190, 20)];
                label4Card.text = LLSTR(@"201022");
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
                                                                                               132)];
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
                
                //图片
                UIView *view4GroupHomeAvatar = [BiChatGlobal getAvatarWnd:@"" nickName:[groupHomeInfo objectForKey:@"groupNickName"] avatar:[groupHomeInfo objectForKey:@"groupAvatar"] frame:CGRectMake(72, 12, 30, 30)];
                [contentView addSubview:view4GroupHomeAvatar];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(112, 12, 165, 30)];
                label4Title.text = [groupHomeInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4Title];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(72, 50, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //副标题
                UILabel *label4Desc = [[UILabel alloc]initWithFrame:CGRectMake(72, 58, rect4Desc.size.width, rect4Desc.size.height)];
                label4Desc.text = [groupHomeInfo objectForKey:@"desc"];
                label4Desc.textColor = [UIColor grayColor];
                label4Desc.font = [UIFont systemFontOfSize:13];
                label4Desc.numberOfLines = 0;
                [contentView addSubview:label4Desc];
                
                //seperator
                view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(72, 112, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 112, 190, 20)];
                label4Card.text = LLSTR(@"201022");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
        }
    }
}

@end
