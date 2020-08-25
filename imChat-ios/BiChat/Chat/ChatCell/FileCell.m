//
//  FileCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "FileCell.h"
#import "JSONKit.h"

@implementation FileCell

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
    
    //解析文件内容
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *fileInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是否自己发言
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
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
        }
        
        //内容
        //avatar
        UIView *view4FileAvatar = [BiChatGlobal getFileAvatarWnd:[fileInfo objectForKey:@"type"]frame:CGRectMake(cellWidth - 279, 12, 46, 46)];
        [contentView addSubview:view4FileAvatar];
        
        //fileName
        UILabel *label4FileName = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 225, 15, 150, 40)];
        label4FileName.text = [fileInfo objectForKey:@"fileName"];
        label4FileName.font = [UIFont systemFontOfSize:16];
        label4FileName.numberOfLines = 0;
        [contentView addSubview:label4FileName];
        
        //seperator
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 225 - 55, 68, 210, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [contentView addSubview:view4Seperator];
        
        //下载进度条
        UIView *view4Progress = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 280, 66, 210, 2)];
        view4Progress.hidden = YES;
        [contentView addSubview:view4Progress];
        [message setObject:view4Progress forKey:@"progressBar"];
        
        //停止下载按钮
        UIButton *button4StopDownload = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - 330 , 53, 30, 30)];
        button4StopDownload.hidden = YES;
        [button4StopDownload setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        [button4StopDownload addTarget:remarkTarget action:remarkAction forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(button4StopDownload, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(button4StopDownload, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(button4StopDownload, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [contentView addSubview:button4StopDownload];
        [message setObject:button4StopDownload forKey:@"stopDownload"];
        
        //名片标志
        UILabel *label4File = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 279, 70, 100, 15)];
        label4File.text = LLSTR(@"201020");
        label4File.font = [UIFont systemFontOfSize:12];
        label4File.textColor = THEME_GRAY;
        [contentView addSubview:label4File];
        
        //fileLength
        UILabel *label4FileLength = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 170, 70, 100, 15)];
        label4FileLength.text = [BiChatGlobal transFileLength:[[fileInfo objectForKey:@"fileLength"]longLongValue]];
        label4FileLength.font = [UIFont systemFontOfSize:12];
        label4FileLength.textAlignment = NSTextAlignmentRight;
        label4FileLength.textColor = THEME_GRAY;
        [contentView addSubview:label4FileLength];
        [self checkFileExist:label4FileLength fileName:[fileInfo objectForKey:@"uploadName"]];
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
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 88, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //下载进度条
                UIView *view4Progress = [[UIView alloc]initWithFrame:CGRectMake(110, 86, 210, 2)];
                view4Progress.hidden = YES;
                [contentView addSubview:view4Progress];
                [message setObject:view4Progress forKey:@"progressBar"];
                
                //名片标志
                UILabel *label4File = [[UILabel alloc]initWithFrame:CGRectMake(112, 90, 100, 15)];
                label4File.text = LLSTR(@"201020");
                label4File.font = [UIFont systemFontOfSize:12];
                label4File.textColor = THEME_GRAY;
                [contentView addSubview:label4File];
                
                //内容
                //avatar
                UIView *view4FileAvatar = [BiChatGlobal getFileAvatarWnd:[fileInfo objectForKey:@"type"]frame:CGRectMake(112, 32, 46, 46)];
                [contentView addSubview:view4FileAvatar];
                
                //nickName
                UILabel *label4FileName = [[UILabel alloc]initWithFrame:CGRectMake(165, 35, 150, 40)];
                label4FileName.text = [fileInfo objectForKey:@"fileName"];
                label4FileName.font = [UIFont systemFontOfSize:16];
                label4FileName.numberOfLines = 0;
                [contentView addSubview:label4FileName];
                
                //fileLength
                UILabel *label4FileLength = [[UILabel alloc]initWithFrame:CGRectMake(220, 90, 100, 15)];
                label4FileLength.text = [BiChatGlobal transFileLength:[[fileInfo objectForKey:@"fileLength"]longLongValue]];
                label4FileLength.font = [UIFont systemFontOfSize:12];
                label4FileLength.textAlignment = NSTextAlignmentRight;
                label4FileLength.textColor = THEME_GRAY;
                [contentView addSubview:label4FileLength];
                [self checkFileExist:label4FileLength fileName:[fileInfo objectForKey:@"uploadName"]];
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
                UIView *view4FileAvatar = [BiChatGlobal getFileAvatarWnd:[fileInfo objectForKey:@"type"]frame:CGRectMake(112, 12, 46, 46)];
                [contentView addSubview:view4FileAvatar];
                
                //nickName
                UILabel *label4FileName = [[UILabel alloc]initWithFrame:CGRectMake(165, 15, 150, 40)];
                label4FileName.text = [fileInfo objectForKey:@"fileName"];
                label4FileName.font = [UIFont systemFontOfSize:16];
                label4FileName.numberOfLines = 0;
                [contentView addSubview:label4FileName];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 68, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //下载进度条
                UIView *view4Progress = [[UIView alloc]initWithFrame:CGRectMake(110, 66, 210, 2)];
                view4Progress.hidden = YES;
                [contentView addSubview:view4Progress];
                [message setObject:view4Progress forKey:@"progressBar"];
                
                //名片标志
                UILabel *label4File = [[UILabel alloc]initWithFrame:CGRectMake(112, 70, 100, 15)];
                label4File.text = LLSTR(@"201020");
                label4File.font = [UIFont systemFontOfSize:12];
                label4File.textColor = THEME_GRAY;
                [contentView addSubview:label4File];
                
                //fileLength
                UILabel *label4FileLength = [[UILabel alloc]initWithFrame:CGRectMake(220, 70, 100, 15)];
                label4FileLength.text = [BiChatGlobal transFileLength:[[fileInfo objectForKey:@"fileLength"]longLongValue]];
                label4FileLength.font = [UIFont systemFontOfSize:12];
                label4FileLength.textAlignment = NSTextAlignmentRight;
                label4FileLength.textColor = THEME_GRAY;
                [contentView addSubview:label4FileLength];
                [self checkFileExist:label4FileLength fileName:[fileInfo objectForKey:@"uploadName"]];
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
                UIView *view4FileAvatar = [BiChatGlobal getFileAvatarWnd:[fileInfo objectForKey:@"type"]frame:CGRectMake(72, 32, 46, 46)];
                [contentView addSubview:view4FileAvatar];
                
                //nickName
                UILabel *label4FileName = [[UILabel alloc]initWithFrame:CGRectMake(125, 35, 150, 40)];
                label4FileName.text = [fileInfo objectForKey:@"fileName"];
                label4FileName.font = [UIFont systemFontOfSize:16];
                label4FileName.numberOfLines = 0;
                [contentView addSubview:label4FileName];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 88, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //下载进度条
                UIView *view4Progress = [[UIView alloc]initWithFrame:CGRectMake(70, 86, 210, 2)];
                view4Progress.hidden = YES;
                [contentView addSubview:view4Progress];
                [message setObject:view4Progress forKey:@"progressBar"];
                
                //停止下载按钮
                UIButton *button4StopDownload = [[UIButton alloc]initWithFrame:CGRectMake(300, 73, 30, 30)];
                button4StopDownload.hidden = YES;
                [button4StopDownload setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                [button4StopDownload addTarget:remarkTarget action:remarkAction forControlEvents:UIControlEventTouchUpInside];
                objc_setAssociatedObject(button4StopDownload, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4StopDownload, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4StopDownload, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [contentView addSubview:button4StopDownload];
                [message setObject:button4StopDownload forKey:@"stopDownload"];

                //名片标志
                UILabel *label4File = [[UILabel alloc]initWithFrame:CGRectMake(72, 90, 100, 15)];
                label4File.text = LLSTR(@"201020");
                label4File.font = [UIFont systemFontOfSize:12];
                label4File.textColor = THEME_GRAY;
                [contentView addSubview:label4File];
                
                //fileLength
                UILabel *label4FileLength = [[UILabel alloc]initWithFrame:CGRectMake(180, 90, 100, 15)];
                label4FileLength.text = [BiChatGlobal transFileLength:[[fileInfo objectForKey:@"fileLength"]longLongValue]];
                label4FileLength.font = [UIFont systemFontOfSize:12];
                label4FileLength.textAlignment = NSTextAlignmentRight;
                label4FileLength.textColor = THEME_GRAY;
                [contentView addSubview:label4FileLength];
                [self checkFileExist:label4FileLength fileName:[fileInfo objectForKey:@"uploadName"]];
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
                UIView *view4FileAvatar = [BiChatGlobal getFileAvatarWnd:[fileInfo objectForKey:@"type"]frame:CGRectMake(72, 12, 46, 46)];
                [contentView addSubview:view4FileAvatar];
                
                //nickName
                UILabel *label4FileName = [[UILabel alloc]initWithFrame:CGRectMake(125, 15, 150, 40)];
                label4FileName.text = [fileInfo objectForKey:@"fileName"];
                label4FileName.font = [UIFont systemFontOfSize:16];
                label4FileName.numberOfLines = 0;
                [contentView addSubview:label4FileName];
                
                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 68, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //下载进度条
                UIView *view4Progress = [[UIView alloc]initWithFrame:CGRectMake(70, 66, 210, 2)];
                view4Progress.hidden = YES;
                [contentView addSubview:view4Progress];
                [message setObject:view4Progress forKey:@"progressBar"];
                
                //停止下载按钮
                UIButton *button4StopDownload = [[UIButton alloc]initWithFrame:CGRectMake(300 , 53, 30, 30)];
                button4StopDownload.hidden = YES;
                [button4StopDownload setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                [button4StopDownload addTarget:remarkTarget action:remarkAction forControlEvents:UIControlEventTouchUpInside];
                objc_setAssociatedObject(button4StopDownload, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4StopDownload, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4StopDownload, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [contentView addSubview:button4StopDownload];
                [message setObject:button4StopDownload forKey:@"stopDownload"];
                
                //文件标志
                UILabel *label4File = [[UILabel alloc]initWithFrame:CGRectMake(72, 70, 100, 15)];
                label4File.text = LLSTR(@"201020");
                label4File.font = [UIFont systemFontOfSize:12];
                label4File.textColor = THEME_GRAY;
                [contentView addSubview:label4File];
                
                //fileLength
                UILabel *label4FileLength = [[UILabel alloc]initWithFrame:CGRectMake(180, 70, 100, 15)];
                label4FileLength.text = [BiChatGlobal transFileLength:[[fileInfo objectForKey:@"fileLength"]longLongValue]];
                label4FileLength.font = [UIFont systemFontOfSize:12];
                label4FileLength.textAlignment = NSTextAlignmentRight;
                label4FileLength.textColor = THEME_GRAY;
                [contentView addSubview:label4FileLength];
                [self checkFileExist:label4FileLength fileName:[fileInfo objectForKey:@"uploadName"]];
            }
        }
    }
}

+ (void)checkFileExist:(UILabel *)label4File fileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath])
    {
        label4File.text = [NSString stringWithFormat:@"%@ ✓", label4File.text];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4File.text];
        [str addAttribute:NSForegroundColorAttributeName value:THEME_COLOR range:NSMakeRange(str.length - 1, 1)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(str.length - 1, 1)];
        label4File.attributedText = str;
    }
}

@end
