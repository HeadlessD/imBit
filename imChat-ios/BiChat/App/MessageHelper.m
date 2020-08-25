//
//  MessageHelper.m
//  BiChat
//
//  Created by imac2 on 2018/7/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "MessageHelper.h"
#import "JSONKit.h"

@implementation MessageHelper

+ (BOOL)sendGroupMessageTo:(NSString *_Nonnull)groupId
                      type:(NSInteger)type
                   content:(NSString *_Nonnull)content
                  needSave:(BOOL)needSave
                  needSend:(BOOL)needSend
            completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //调整参数
    if (content == nil)
        content = @"";
    
    //获取群属性
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if (groupProperty == nil)
    {
        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                [MessageHelper sendGroupMessageTo:groupId type:type content:content needSave:needSave needSend:needSave completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    completedBlock(success, isTimeOut, errorCode, data);
                }];
            }
        }];
        return YES;
    }
    
    //如果本群已经被解散,只能发送重启消息
    if ([[groupProperty objectForKey:@"disabled"]boolValue] && type != MESSAGE_CONTENT_TYPE_GROUPRESTART)
        return NO;
        
    //生成消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:type], @"type",
                                     content, @"content",
                                     groupId, @"receiver",
                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"groupName"]], @"receiverNickName",
                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"]], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].nickName], @"senderNickName",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar], @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     contentId, @"contentId", nil];
    
    //先保存
    if (needSave)
    {
        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
        [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                              peerUserName:@""
                                              peerNickName:[groupProperty objectForKey:@"groupName"]
                                                peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO isGroup:YES isPublic:NO createNew:YES];
    }
    
    //再发送
    if (needSend)
    {
        return [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                completedBlock(success, isTimeOut, errorCode, sendData);
            }
            else if (errorCode == 3)
            {
                //新建一个批准群，然后重新发送消息
                [self createAppoveGroupAndSendMessage:sendData groupId:groupId needSave:NO completedBlock:completedBlock];
            }
            else
                completedBlock(success, isTimeOut, errorCode, sendData);
        }];
    }
    return YES;
}

+ (BOOL)sendGroupMessageToOperator:(NSString *_Nonnull)groupId
                              type:(NSInteger)type
                           content:(NSString *_Nonnull)content
                          needSave:(BOOL)needSave
                          needSend:(BOOL)needSend
                    completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //调整参数
    if (content == nil)
        content = @"";
    
    //获取群属性
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if (groupProperty == nil)
    {
        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                [MessageHelper sendGroupMessageToOperator:groupId type:type content:content needSave:needSave needSend:needSave completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    completedBlock(success, isTimeOut, errorCode, data);
                }];
            }
        }];
        return YES;
    }
    
    //如果本群已经被解散,只能发送重启消息
    if ([[groupProperty objectForKey:@"disabled"]boolValue] && type != MESSAGE_CONTENT_TYPE_GROUPRESTART)
        return NO;
    
    //生成消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:type], @"type",
                                     content, @"content",
                                     groupId, @"receiver",
                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"groupName"]], @"receiverNickName",
                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"]], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].nickName], @"senderNickName",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar], @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     contentId, @"contentId", nil];
    
    //先保存
    if (needSave)
    {
        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
        [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                              peerUserName:@""
                                              peerNickName:[groupProperty objectForKey:@"groupName"]
                                                peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO isGroup:YES isPublic:NO createNew:YES];
    }
    
    //再发送
    if (needSend)
    {
        return [NetworkModule sendMessageToGroupOperator:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                completedBlock(success, isTimeOut, errorCode, sendData);
            }
            else if (errorCode == 3)
            {
                //新建一个批准群，然后重新发送消息
                [self createAppoveGroupAndSendMessage:sendData groupId:groupId needSave:NO completedBlock:completedBlock];
            }
            else
                completedBlock(success, isTimeOut, errorCode, sendData);
        }];
    }
    return YES;
}

//创建一个批准群，然后发送消息到批准群，然后切换到批准群
+ (void)createAppoveGroupAndSendMessage:(NSMutableDictionary *)message
                                groupId:(NSString *)groupId
                               needSave:(BOOL)needSave
                         completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //首先创建群
    //[NetworkModule createGroupServiceGroup:groupId userId:[BiChatGlobal sharedManager].uid relatedGroupId:nil relatedGroupType:0 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
    //
    //    if (success)
    //    {
    //        NSString *customerServiceGroupId = [data objectForKey:@"customerServiceGroup"];
    //        [self sendCustomServiceGroupMessage:message
    //                                    groupId:groupId
    //                       customServiceGroupId:customerServiceGroupId
    //                                   needSave:needSave
    //                             completedBlock:completedBlock];
    //    }
    //    else
    //        completedBlock(success, isTimeOut, errorCode, data);
    //}];
    
    //上一段代码暂时停用，直接返回错误
    [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
}

//发送一条客服消息到客服群
+ (void)sendCustomServiceGroupMessage:(NSMutableDictionary *)message
                              groupId:(NSString *)groupId
                 customServiceGroupId:(NSString *)customServiceGroupId
                             needSave:(BOOL)needSave
                       completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //修正消息里面的数据
    [message setObject:groupId forKey:@"orignalGroupId"];
    [message setObject:customServiceGroupId forKey:@"receiver"];
    [message setObject:[BiChatGlobal sharedManager].uid forKey:@"applyUser"];
    [message setObject:[BiChatGlobal sharedManager].nickName forKey:@"applyUserNickName"];
    [message setObject:[BiChatGlobal sharedManager].avatar forKey:@"applyUserAvatar"];
    
    //先保存
    if (needSave)
    {
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:message];
        [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                              peerUserName:@""
                                              peerNickName:[groupProperty objectForKey:@"groupName"]
                                                peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:groupProperty]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO isGroup:YES isPublic:NO createNew:YES];
    }
    
    //再发送
    [NetworkModule sendMessageToGroup:customServiceGroupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {        
        completedBlock(success, isTimeOut, errorCode, data);
    }];
}

+ (BOOL)checkCanMessageIntoGroup:(NSDictionary *)message
                         toGroup:(NSString *)groupId
{
    //获取群属性
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if (groupProperty == nil)
        return YES;
    
    //群是否为直播状态
    if ([[groupProperty objectForKey:@"mute"]boolValue] &&
        ![BiChatGlobal isMeGroupOperator:groupProperty] &&
        ![BiChatGlobal isMeGroupVIP:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"301321") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //我是否被禁言
    if ([BiChatGlobal isMeInMuteList:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"301322") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //我是否试用用户
    if ([BiChatGlobal isMeInTrailList:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"204302") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //我是否待支付用户
    if ([BiChatGlobal isMeInPayList:groupProperty])
    {
        [BiChatGlobal showInfo:LLSTR(@"204312") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //解散
    if ([[groupProperty objectForKey:@"disabled"]boolValue])
    {
        [BiChatGlobal showInfo:LLSTR(@"301323") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return NO;
    }
    
    //是否文字消息
    BOOL forbidTextWithLink = NO;
    BOOL forbitImageWithVRCode = NO;
    if ([[groupProperty objectForKey:@"forbidOperations"]count] >= 1)
        forbidTextWithLink = [[[groupProperty objectForKey:@"forbidOperations"]objectAtIndex:0]boolValue];
    if ([[groupProperty objectForKey:@"forbidOperations"]count] >= 2)
        forbitImageWithVRCode = [[[groupProperty objectForKey:@"forbidOperations"]objectAtIndex:1]boolValue];
    
    if (forbidTextWithLink && [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TEXT)
    {
        NSString *text = [message objectForKey:@"content"];
        if ([BiChatGlobal isTextContainLink:text] &&
            ![BiChatGlobal isMeGroupOperator:groupProperty] &&
            ![BiChatGlobal isMeGroupVIP:groupProperty])
        {
            [BiChatGlobal showInfo:LLSTR(@"301737") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return NO;
        }
    }
    if (forbitImageWithVRCode && [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_IMAGE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4ImageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];

        //NSLog(@"%@", dict4ImageInfo);
        //文件是否在本地
        UIImage *image = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        if ([[dict4ImageInfo objectForKey:@"localOrgFileName"]length] > 0)
        {
            NSString *localOrgPath = [documentsDirectory stringByAppendingPathComponent:[dict4ImageInfo objectForKey:@"localOrgFileName"]];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:localOrgPath])
                image = [[UIImage alloc]initWithContentsOfFile:localOrgPath];
        }
        if (image == nil && [[dict4ImageInfo objectForKey:@"localFileName"]length] > 0)
        {
            NSString *localImagePath = [documentsDirectory stringByAppendingPathComponent:[dict4ImageInfo objectForKey:@"localFileName"]];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:localImagePath])
                image = [[UIImage alloc]initWithContentsOfFile:localImagePath];
        }
        if (image == nil && [[dict4ImageInfo objectForKey:@"oriFileName"]length] > 0)
        {
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [dict4ImageInfo objectForKey:@"oriFileName"]];
            
            UIImage *image4PlaceHolder = [UIImage imageNamed:@"failure"];
            UIImageView *imageView = [UIImageView new];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]placeholderImage:image4PlaceHolder options:SDWebImageQueryDiskDataSync];
            if (imageView.image != image4PlaceHolder)
                image = imageView.image;
        }
        if (image == nil && [[dict4ImageInfo objectForKey:@"FileName"]length] > 0)
        {
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [dict4ImageInfo objectForKey:@"FileName"]];
            
            UIImage *image4PlaceHolder = [UIImage imageNamed:@"failure"];
            UIImageView *imageView = [UIImageView new];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]placeholderImage:image4PlaceHolder options:SDWebImageQueryDiskDataSync];
            if (imageView.image != image4PlaceHolder)
                image = imageView.image;
        }
        if (image == nil && [[dict4ImageInfo objectForKey:@"ThumbName"]length] > 0)
        {
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [dict4ImageInfo objectForKey:@"ThumbName"]];
            
            UIImage *image4PlaceHolder = [UIImage imageNamed:@"failure"];
            UIImageView *imageView = [UIImageView new];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]placeholderImage:image4PlaceHolder options:SDWebImageQueryDiskDataSync];
            if (imageView.image != image4PlaceHolder)
                image = imageView.image;
        }

        //没有找到任何现场图片，允许发送(可能造成漏洞)
        if (image == nil)
            return YES;
        
        //判断图片是否含有二维码
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
        //2. 扫描获取的特征组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        //3. 获取扫描结果
        CIQRCodeFeature *feature = features.count > 0 ? [features objectAtIndex:0] : nil;
        NSString *scannedResult = feature.messageString;
        if (scannedResult.length > 0 &&
            ![BiChatGlobal isMeGroupOperator:groupProperty] &&
            ![BiChatGlobal isMeGroupVIP:groupProperty])
        {
            [BiChatGlobal showInfo:LLSTR(@"301738") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION
                       enableClick:YES];
            return NO;
        }
    }
    //是组合消息
    if (forbidTextWithLink &&
        forbitImageWithVRCode &&
        [[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MESSAGECONBINE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4MessageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //NSLog(@"%@", dict4MessageInfo);
        for (NSDictionary *item in [dict4MessageInfo objectForKey:@"conbineMessage"])
        {
            if (![MessageHelper checkCanMessageIntoGroup:item toGroup:groupId])
                return NO;
        }
    }

    return YES;
}

+ (BOOL)sendUserMessageTo:(NSString *_Nonnull)peerUid
             peerNickName:(NSString *_Nonnull)peerNickName
               peerAvatar:(NSString *_Nullable)peerAvatar
             peerUserName:(NSString *_Nullable)peerUserName
                     type:(NSInteger)type
                  content:(NSString *_Nonnull)content
                 needSave:(BOOL)needSave
                 needSend:(BOOL)needSend
           completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //调整参数
    if (content == nil)
        content = @"";
    
    //生成消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:type], @"type",
                                     content, @"content",
                                     peerUid, @"receiver",
                                     [NSString stringWithFormat:@"%@", peerNickName], @"receiverNickName",
                                     [NSString stringWithFormat:@"%@", peerAvatar], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].nickName], @"senderNickName",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar], @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"0", @"isGroup",
                                     msgId, @"msgId",
                                     contentId, @"contentId", nil];
    
    //先保存
    if (needSave)
    {
        [[BiChatDataModule sharedDataModule]addChatContentWith:peerUid content:sendData];
        [[BiChatDataModule sharedDataModule]setLastMessage:peerUid
                                              peerUserName:@""
                                              peerNickName:peerNickName
                                                peerAvatar:peerAvatar
                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO isGroup:YES isPublic:NO createNew:YES];
    }
    
    //再发送
    if (needSend)
    {
        return [NetworkModule sendMessageToUser:peerUid message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                completedBlock(success, isTimeOut, errorCode, sendData);
            }
            else
                completedBlock(success, isTimeOut, errorCode, sendData);
        }];
    }
    return YES;
}

+ (BOOL)sendGroupMessageToUser:(NSString *_Nonnull)peerUid
                       groupId:(NSString *_Nonnull)groupId
                          type:(NSInteger)type
                       content:(NSString *_Nonnull)content
                      needSave:(BOOL)needSave
                      needSend:(BOOL)needSend
                completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //调整参数
    if (content == nil)
        content = @"";
    
    //获取群属性
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if (groupProperty == nil)
    {
        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                [MessageHelper sendGroupMessageToUser:peerUid
                                              groupId:groupId
                                                 type:type
                                              content:content
                                             needSave:needSave
                                             needSend:needSend
                                       completedBlock:completedBlock];
            }
        }];
        return YES;
    }
    
    //如果本群已经被解散,只能发送重启消息
    if ([[groupProperty objectForKey:@"disabled"]boolValue] && type != MESSAGE_CONTENT_TYPE_GROUPRESTART)
        return NO;
    
    //生成消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSString *contentId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:type], @"type",
                                     content, @"content",
                                     groupId, @"receiver",
                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"groupName"]], @"receiverNickName",
                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"]], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].nickName], @"senderNickName",
                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar], @"senderAvatar",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     contentId, @"contentId", nil];
    
    //先保存
    if (needSave)
    {
        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
        [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                              peerUserName:@""
                                              peerNickName:[groupProperty objectForKey:@"groupName"]
                                                peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO isGroup:YES isPublic:NO createNew:YES];
    }
    
    //再发送
    if (needSend)
    {
        return [NetworkModule sendMessageToUser:peerUid message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
                completedBlock(success, isTimeOut, errorCode, sendData);
            else
                completedBlock(success, isTimeOut, errorCode, sendData);
        }];
    }
    return YES;
}

@end
