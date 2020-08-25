//
//  BiChatDataModule.m
//  BiChat
//
//  Created by worm_kc on 2018/2/22.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "JSONKit.h"

@implementation BiChatDataModule

static BiChatDataModule *sharedModule = nil;
+ (BiChatDataModule *)sharedDataModule
{
    @synchronized(self)
    {
        if  (sharedModule == nil)
        {
            sharedModule = [[BiChatDataModule alloc]init];
            //加载一些全局变量
            [sharedModule loadGlobalInfo];
        }
    }
    return sharedModule;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedModule == nil) {
            sharedModule = [super allocWithZone:zone];
            return sharedModule;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)loadGlobalInfo
{
}

- (void)clearCurrentUserData
{
    @synchronized (self) {
        
        //保存未保存的数据
        [timer4SaveChatListInfo fire];
        [timer4SaveChatListInfo invalidate];
        timer4SaveChatListInfo = nil;
        
        //清除数据
        array4ChatList = [NSMutableArray array];
        dict4ContactOperationTime = [NSMutableDictionary dictionary];
        dict4ChatLastTimeInfo = [NSMutableDictionary dictionary];
        dict4UnsentMessageInfo = [NSMutableDictionary dictionary];
        dict4ReceivingMessageInfo = [NSMutableDictionary dictionary];
        dict4DraftMessageInfo = [NSMutableDictionary dictionary];
        
        //其他数据
        dict4ChatContentCache = [NSMutableDictionary dictionary];
        dict4BigGroupChatCache = [NSMutableDictionary dictionary];
        dict4BigGroupChatContentCache = [NSMutableDictionary dictionary];
    }
}

- (void)setuid:(NSString *)uidArg
{
    @synchronized (self) {
        if (uidArg.length == 0)
            return;
        uid = uidArg;
        chatLastIndexTableName = [NSString stringWithFormat:@"'%@_chat_last_index'", uid];
        chatMsgIdTableName = [NSString stringWithFormat:@"'%@_chat_msg_id'", uid];
        redPacketStatusTableName = [NSString stringWithFormat:@"'%@_redpacket_status'", uid];
        transferStatusTableName = [NSString stringWithFormat:@"'%@_trasfer_status'", uid];
        exchangeStatusTableName = [NSString stringWithFormat:@"'%@_exchange_status'", uid];
        
        //加载数据库
        chatDataStore = [[YTKKeyValueStore alloc]initDBWithName:[NSString stringWithFormat:@"%@_chat_data.db", uid]];
        [chatDataStore createTableWithName:chatLastIndexTableName];
        [chatDataStore createTableWithName:chatMsgIdTableName];
        [chatDataStore createTableWithName:redPacketStatusTableName];
        [chatDataStore createTableWithName:transferStatusTableName];
        [chatDataStore createTableWithName:exchangeStatusTableName];
        
        //加载这个人的聊天列表
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatListInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chatlist_%@.dat", uid]];
        
        //读文件并解析数据
        array4ChatList = [[NSMutableArray alloc]initWithContentsOfFile:chatListInfoFile];
        if (array4ChatList == nil)
            array4ChatList = [NSMutableArray array];
        
        //加载这个人的聊天最后index数据(兼容老数据)
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *chatLastIndexInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chatlastIndex_%@.dat", uid]];
        
        //读文件并解析数据
        NSMutableDictionary *dict4ChatLastIndex = [[NSMutableDictionary alloc]initWithContentsOfFile:chatLastIndexInfoFile];
        if (dict4ChatLastIndex != nil)
        {
            
            NSLog(@"transfer chat last index data into database");
            //将所有数据导入新的数据库并且删除老的数据文件
            for (NSString *key in dict4ChatLastIndex)
            {
                [chatDataStore putNumber:[NSNumber numberWithInteger:[[dict4ChatLastIndex objectForKey:key]integerValue]]
                                  withId:key
                               intoTable:chatLastIndexTableName];
            }
            [[NSFileManager defaultManager]removeItemAtPath:chatLastIndexInfoFile error:nil];
        }
        
        //加载这个人的朋友操作时间数据
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *contactOperationTimeInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"contactOperationTimeInfo_%@.dat", uid]];
        
        //读文件并解析数据
        dict4ContactOperationTime = [[NSMutableDictionary alloc]initWithContentsOfFile:contactOperationTimeInfoFile];
        if (dict4ContactOperationTime == nil)
            dict4ContactOperationTime = [NSMutableDictionary dictionary];
        
        //加载这个人的聊天最后记录的时间数据
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *chatLastTimeInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chatLastTimeInfo_%@.dat", uid]];
        
        //读文件并解析数据
        dict4ChatLastTimeInfo = [[NSMutableDictionary alloc]initWithContentsOfFile:chatLastTimeInfoFile];
        if (dict4ChatLastTimeInfo == nil)
            dict4ChatLastTimeInfo = [NSMutableDictionary dictionary];
        
        //加载这个人的超大群最后读到的消息的index
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *bigGroupLastReadMessageIndexInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupLastReadMessageIndexInfo_%@.dat", uid]];
        
        //读文件并解析数据
        dict4BigGroupLastReadMessageIndex = [[NSMutableDictionary alloc]initWithContentsOfFile:bigGroupLastReadMessageIndexInfoFile];
        if (dict4BigGroupLastReadMessageIndex == nil)
            dict4BigGroupLastReadMessageIndex = [NSMutableDictionary dictionary];
        
        //加载这个人的超大群的最上方消息的index
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *bigGroupTopMessageIndexInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupTopMessageIndexInfo_%@.dat", uid]];
        
        //读文件并解析数据
        dict4BigGroupTopMessageIndex = [[NSMutableDictionary alloc]initWithContentsOfFile:bigGroupTopMessageIndexInfoFile];
        if (dict4BigGroupTopMessageIndex == nil)
            dict4BigGroupTopMessageIndex = [NSMutableDictionary dictionary];
        
        //加载这个人的未发送成功的消息信息
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *unSentMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"unSentMessageInfo_%@.dat", uid]];
        
        //读文件并解析数据
        dict4UnsentMessageInfo = [[NSMutableDictionary alloc]initWithContentsOfFile:unSentMessageInfoFile];
        if (dict4UnsentMessageInfo == nil)
            dict4UnsentMessageInfo = [NSMutableDictionary dictionary];
        
        //加载这个人的正在上传的消息信息，所有的正在上传的消息都直接变为未发送成功的消息
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *sendingMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sendingMessageInfo_%@.dat", uid]];
        
        //读文件并解析数据
        dict4SendingMessageInfo = [[NSMutableDictionary alloc]initWithContentsOfFile:sendingMessageInfoFile];
        if (dict4SendingMessageInfo == nil)
            dict4SendingMessageInfo = [NSMutableDictionary dictionary];
        for (NSString *key in dict4SendingMessageInfo)//kc
            [dict4UnsentMessageInfo setObject:[NSNumber numberWithBool:YES] forKey:key];
        [dict4SendingMessageInfo removeAllObjects];
        
        //创建正在接受消息cache
        dict4ReceivingMessageInfo = [NSMutableDictionary dictionary];
        
        //加载这个人的草稿信息
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *draftMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"draftMessageInfo_%@.dat", uid]];
        
        //读文件并解析数据
        dict4DraftMessageInfo = [[NSMutableDictionary alloc]initWithContentsOfFile:draftMessageInfoFile];
        if (dict4DraftMessageInfo == nil)
            dict4DraftMessageInfo = [NSMutableDictionary dictionary];
        
        //其他数据
        dict4ChatContentCache = [NSMutableDictionary dictionary];
        dict4BigGroupChatCache = [NSMutableDictionary dictionary];
        dict4BigGroupChatContentCache = [NSMutableDictionary dictionary];
        [self freshTotalNewMessageCount];
    }
}

- (void)addChatItem:(NSString *)peerUid
       peerNickName:(NSString *)peerNickName
         peerAvatar:(NSString *)peerAvatar
            isGroup:(BOOL)isGroup
{
    @synchronized (self) {
        //修改参数
        if (peerNickName.length == 0) peerNickName = @"";
        if (peerAvatar.length == 0) peerAvatar = @"";
        
        //如果在聊天列表中已经存在
        for (NSDictionary *item in array4ChatList)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"peerUid"]])
                return;
        }
        
        //添加一个新的条目
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        [item setObject:@"" forKey:@"lastMessage"];
        [item setObject:@"" forKey:@"lastMessageTime"];
        [item setObject:peerUid forKey:@"peerUid"];
        [item setObject:peerNickName forKey:@"peerNickName"];
        [item setObject:peerAvatar forKey:@"peerAvatar"];
        [item setObject:[NSString stringWithFormat:@"%d", isGroup] forKey:@"isGroup"];
        [array4ChatList insertObject:item atIndex:0];
        
        //保存一下
        [self saveChatListInfo];
        [self freshTotalNewMessageCount];
    }
}

//聊天是否存在
- (BOOL)isChatExist:(NSString *)peerUid
{
    @synchronized (self) {
        //如果在聊天列表中已经存在
        for (NSDictionary *item in array4ChatList)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"peerUid"]])
                return YES;
        }
        
        return NO;
    }
}

//修改一个聊天的peerId
- (void)changePeerUid:(NSString *)peerUid to:(NSString *)newPeerUid
{
    @synchronized (self) {
        for (NSMutableDictionary *item in array4ChatList)
        {
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:newPeerUid forKey:@"peerUid"];
                
                //保存一下
                [self saveChatListInfo];
                break;
            }
        }
        
        //所有聊天消息也要修改
        //获取这个人的最后聊天消息index
        NSString *key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, peerUid];
        NSInteger index = [[chatDataStore getNumberById:key fromTable:chatLastIndexTableName]integerValue];
        NSInteger bundleIndex = index / 20;
        
        //设置新的peerUid的index
        key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, newPeerUid];
        [chatDataStore putNumber:[NSNumber numberWithInteger:index] withId:key intoTable:chatLastIndexTableName];
        
        //修改所有的bundle
        for (int i = 0; i < bundleIndex + 1; i ++)
        {
            //先找缓存
            NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)i];
            NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
            if (array != nil)
                [dict4ChatContentCache removeObjectForKey:key];
            
            //然后找相应的文件
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)i]];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:chatContentFile])
            {
                NSString *newChatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, newPeerUid, (long)i]];
                [[NSFileManager defaultManager]moveItemAtPath:chatContentFile toPath:newChatContentFile error:nil];
            }
        }
    }
}

//设置一个聊天的最后消息信息
- (void)setLastMessage:(NSString *)peerUid
          peerUserName:(NSString *)peerUserName
          peerNickName:(NSString *)peerNickName
            peerAvatar:(NSString *)peerAvatar
               message:(NSString *)message
           messageTime:(NSString *)messageTime
                 isNew:(BOOL)isNew
               isGroup:(BOOL)isGroup
              isPublic:(BOOL)isPublic
             createNew:(BOOL)createNew
{
    @synchronized (self) {
        //修改参数
        if (peerUserName.length == 0) peerUserName = @"";
        if (peerNickName.length == 0) peerNickName = @"";
        if (peerAvatar.length == 0) peerAvatar = @"";
        if (message.length == 0) message = @"";
        messageTime = [NSString stringWithFormat:@"%@", messageTime];
        
        //先查找有没有这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:message forKey:@"lastMessage"];
                if (peerUserName.length > 0)[item setObject:peerUserName forKey:@"peerUserName"];
                if (peerNickName.length > 0)[item setObject:peerNickName forKey:@"peerNickName"];
                if (peerAvatar.length > 0)[item setObject:peerAvatar forKey:@"peerAvatar"];
                if ([messageTime length] > 0)[item setObject:messageTime forKey:@"lastMessageTime"];
                else [item setObject:[BiChatGlobal getCurrentDateString] forKey:@"lastMessageTime"];
                
                //是否新消息
                if (isNew)
                    [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"newMessageCount"]integerValue] + 1] forKey:@"newMessageCount"];
                
                //调整到第一位
                [array4ChatList removeObject:item];
                [array4ChatList insertObject:item atIndex:0];
                
                //重新排序
                [array4ChatList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [[obj2 objectForKey:@"lastMessageTime"]compare:[obj1 objectForKey:@"lastMessageTime"] options:NSLiteralSearch];
                }];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
        
        //添加一个新的条目
        if (createNew && peerUid != nil)
        {
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setObject:message forKey:@"lastMessage"];
            if (messageTime.length == 0) [item setObject:[BiChatGlobal getCurrentDateString] forKey:@"lastMessageTime"];
            else [item setObject:messageTime forKey:@"lastMessageTime"];
            [item setObject:peerUid forKey:@"peerUid"];
            [item setObject:peerUserName.length==0?@"":peerUserName forKey:@"peerUserName"];
            [item setObject:peerNickName.length==0?@"":peerNickName forKey:@"peerNickName"];
            [item setObject:peerAvatar.length==0?@"":peerAvatar forKey:@"peerAvatar"];
            [item setObject:[NSNumber numberWithInteger:isNew?1:0] forKey:@"newMessageCount"];
            [item setObject:[NSString stringWithFormat:@"%d", isGroup] forKey:@"isGroup"];
            [item setObject:[NSString stringWithFormat:@"%d", isPublic] forKey:@"isPublic"];
            [array4ChatList insertObject:item atIndex:0];
            
            //重新排序
            [array4ChatList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [[obj2 objectForKey:@"lastMessageTime"]compare:[obj1 objectForKey:@"lastMessageTime"] options:NSLiteralSearch];
            }];
            
            //保存一下
            [self saveChatListInfo];
            [self freshTotalNewMessageCount];
        }
    }
}

- (void)setLastMessage:(NSString *)peerUid
          peerUserName:(NSString *)peerUserName
          peerNickName:(NSString *)peerNickName
            peerAvatar:(NSString *)peerAvatar
               message:(NSString *)message
           messageTime:(NSString *)messageTime
                 isNew:(BOOL)isNew
             isApprove:(BOOL)isApprove
        orignalGroupId:(NSString *)orignalGroupId
             applyUser:(NSString *)applyUser
     applyUserNickName:(NSString *)applyUserNickName
       applyUserAvatar:(NSString *)applyUserAvatar
             createNew:(BOOL)createNew
{
    @synchronized (self) {
        //修改参数
        if (peerNickName.length == 0) peerNickName = @"";
        if (peerAvatar.length == 0) peerAvatar = @"";
        if (orignalGroupId.length == 0) orignalGroupId = @"";
        messageTime = [NSString stringWithFormat:@"%@", messageTime];
        
        //先查找有没有这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:message forKey:@"lastMessage"];
                if (peerUserName.length > 0)[item setObject:peerUserName forKey:@"peerUserName"];
                if (peerNickName.length > 0)[item setObject:peerNickName forKey:@"peerNickName"];
                if (peerAvatar.length > 0)[item setObject:peerAvatar forKey:@"peerAvatar"];
                if ([messageTime length] > 0)[item setObject:messageTime forKey:@"lastMessageTime"];
                else [item setObject:[BiChatGlobal getCurrentDateString] forKey:@"lastMessageTime"];
                
                //是否新消息
                if (isNew)
                    [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"newMessageCount"]integerValue] + 1] forKey:@"newMessageCount"];
                
                [item setObject:@"1" forKey:@"isApprove"];
                [item setObject:orignalGroupId forKey:@"orignalGroupId"];
                [item setObject:applyUser.length==0?@"":applyUser forKey:@"applyUser"];
                [item setObject:applyUserNickName.length==0?@"":applyUserNickName forKey:@"applyUserNickName"];
                [item setObject:applyUserAvatar.length==0?@"":applyUserAvatar forKey:@"applyUserAvatar"];
                
                //调整到第一位
                [array4ChatList removeObject:item];
                [array4ChatList insertObject:item atIndex:0];
                
                //重新排序
                [array4ChatList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [[obj2 objectForKey:@"lastMessageTime"]compare:[obj1 objectForKey:@"lastMessageTime"] options:NSLiteralSearch];
                }];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
        
        //添加一个新的条目
        if (createNew && peerUid != nil)
        {
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setObject:message forKey:@"lastMessage"];
            if (messageTime.length == 0) [item setObject:[BiChatGlobal getCurrentDateString] forKey:@"lastMessageTime"];
            else [item setObject:messageTime forKey:@"lastMessageTime"];
            [item setObject:peerUid forKey:@"peerUid"];
            [item setObject:peerUserName.length==0?@"":peerUserName forKey:@"peerUserName"];
            [item setObject:peerNickName.length==0?@"":peerNickName forKey:@"peerNickName"];
            [item setObject:peerAvatar.length==0?@"":peerAvatar forKey:@"peerAvatar"];
            [item setObject:[NSNumber numberWithInteger:isNew?1:0] forKey:@"newMessageCount"];
            [item setObject:@"1" forKey:@"isGroup"];
            [item setObject:@"0" forKey:@"isPublic"];
            [item setObject:@"1" forKey:@"isApprove"];
            [item setObject:orignalGroupId forKey:@"orignalGroupId"];
            [item setObject:applyUser.length==0?@"":applyUser forKey:@"applyUser"];
            [item setObject:applyUserNickName.length==0?@"":applyUserNickName forKey:@"applyUserNickName"];
            [item setObject:applyUserAvatar.length==0?@"":applyUserAvatar forKey:@"applyUserAvatar"];
            [array4ChatList insertObject:item atIndex:0];
            
            //重新排序
            [array4ChatList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [[obj2 objectForKey:@"lastMessageTime"]compare:[obj1 objectForKey:@"lastMessageTime"] options:NSLiteralSearch];
            }];
            
            //保存一下
            [self saveChatListInfo];
            [self freshTotalNewMessageCount];
        }
    }
}

//设置和一个人的聊天的新消息数
- (void)setNewMessageCountWith:(NSString *)peerUid count:(NSInteger)count
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:[NSNumber numberWithInteger:count] forKey:@"newMessageCount"];
                
                //保存一下
                [self saveChatListInfo];
                [self freshTotalNewMessageCount];
                return;
            }
        }
    }
}

//获取和一个人的聊天的新消息数
- (NSInteger)getNewMessageCountWith:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
                return [[item objectForKey:@"newMessageCount"]integerValue];
        }
        return 0;
    }
}

//清除和一个人的聊天的新消息数
- (void)clearNewMessageCountWith:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"newMessageCount"];
                
                //保存一下
                [self saveChatListInfo];
                [self freshTotalNewMessageCount];
                return;
            }
        }
    }
}

//增加有人at我
- (void)addAtMeInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"atMe"]integerValue] + 1] forKey:@"atMe"];
                [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"atMe2"]integerValue] + 1] forKey:@"atMe2"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//设置有人at我
- (void)setAtMeInGroup:(NSString *)peerUid count:(NSInteger)count
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:[NSNumber numberWithInteger:count] forKey:@"atMe"];
                [item setObject:[NSNumber numberWithInteger:count] forKey:@"atMe2"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//获取at我的次数
- (NSInteger)getAtMe2InGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                return [[item objectForKey:@"atMe2"]integerValue];
            }
        }
        return 0;
    }
}

//清除有人at我标志
- (void)clearAtMeInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"atMe"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//清除有人at我标志2
- (void)clearAtMe2InGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"atMe2"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//增加有人回复我
- (void)addReplyMeInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"replyMe"]integerValue] + 1] forKey:@"replyMe"];
                [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"replyMe2"]integerValue] + 1] forKey:@"replyMe2"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//设置有人回复我
- (void)setReplyMeInGroup:(NSString *)peerUid count:(NSInteger)count
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:[NSNumber numberWithInteger:count] forKey:@"replyMe"];
                [item setObject:[NSNumber numberWithInteger:count] forKey:@"replyMe2"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//获取回复我的次数
- (NSInteger)getReplyMe2InGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                return [[item objectForKey:@"replyMe2"]integerValue];
            }
        }
        return 0;
    }
}

//清除有人回复我
- (void)clearReplyMeInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"replyMe"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//清除有人回复我2
- (void)clearReplyMe2InGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"replyMe2"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//设置有新的群公告
- (void)setNewBoardInfoInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:[NSNumber numberWithInteger:1] forKey:@"newGroupBoardInfo"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//获取是否有新的群公告
- (BOOL)getNewBoardInfoInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                return [[item objectForKey:@"newGroupBoardInfo"]boolValue];
            }
        }
        return NO;
    }
}

//清除是否有新的群公告
- (void)clearNewBoardInfoInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"newGroupBoardInfo"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//设置有新的群聊邀请确认
- (void)setNewApplyGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:[NSNumber numberWithInteger:1] forKey:@"newApplyGroup"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//获取是否有新的群邀请确认
- (BOOL)getNewApplyGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                return [[item objectForKey:@"newApplyGroup"]boolValue];
            }
        }
        return NO;
    }
}

//清除是否有新的群邀请确认
- (void)clearNewApplyGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"newApplyGroup"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

- (void)setGroupHomeNoticeInGroup:(NSString *)peerUid groupHomeId:(NSString *)groupHomeId groupHomeNotice:(NSString *)groupHomeNotice
{
    if (groupHomeId == nil ||
        groupHomeNotice == nil)
        return;
    
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:groupHomeId forKey:@"groupHomeId"];
                [item setObject:groupHomeNotice forKey:@"groupHomeNotice"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

- (NSDictionary *)getGroupHomeNoticeInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                if ([item objectForKey:@"groupHomeId"] != nil &&
                    [item objectForKey:@"groupHomeNotice"] != nil)
                    return @{@"groupHomeId":[item objectForKey:@"groupHomeId"], @"groupHomeNotice":[item objectForKey:@"groupHomeNotice"]};
                else
                    return nil;
            }
        }
        return nil;
    }
}

- (void)clearGroupHomeNoticeInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item removeObjectForKey:@"groupHomeId"];
                [item removeObjectForKey:@"groupHomeNotice"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

- (void)setGroupHomeHighlightInGroup:(NSString *)peerUid groupHomeId:(NSString *)groupHomeId
{
    if (groupHomeId == nil)
        return;
    
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[item objectForKey:@"groupHomeHighlight"]];
                [dict setObject:@"" forKey:groupHomeId];
                [item setObject:dict forKey:@"groupHomeHighlight"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

- (NSArray *)getGroupHomeHighlightInGroup:(NSString *)peerUid
{
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                NSDictionary *dict = [item objectForKey:@"groupHomeHighlight"];
                NSMutableArray *array = [NSMutableArray array];
                for (NSString *key in dict)
                    [array addObject:key];
                
                return array;
            }
        }
        return nil;
    }
}

- (void)clearGroupHomeHighlightInGroup:(NSString *)peerUid groupHomeId:(NSString *)groupHomeId
{
    if (groupHomeId == nil)
        return;
    
    @synchronized (self) {
        //先找到这个人的聊天
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[item objectForKey:@"groupHomeHighlight"]];
                [dict removeObjectForKey:groupHomeId];
                [item setObject:dict forKey:@"groupHomeHighlight"];
                
                //保存一下
                [self saveChatListInfo];
                return;
            }
        }
    }
}

//获取同一个虚拟群在聊天列表中有几个元素存在
- (NSInteger)getSameVirtualGroupCountInChatList:(NSString *)virtualGroupId
{
    if (virtualGroupId.length == 0)
        return 0;
    
    @synchronized (self) {
        //查找缓存
        if ([[dict4VirtualGroupCountInChatList objectForKey:virtualGroupId]integerValue] > 0)
            return [[dict4VirtualGroupCountInChatList objectForKey:virtualGroupId]integerValue];
        
        //没有从缓存中查到，重新查找
        NSInteger count = 0;
        array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"isGroup"]boolValue])
            {
                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
                if ([virtualGroupId isEqualToString:[groupProperty objectForKey:@"virtualGroupId"]])
                    count ++;
            }
        }
        
        //设置入缓存
        [dict4VirtualGroupCountInChatList setObject:[NSNumber numberWithInteger:count] forKey:virtualGroupId];
        return count;
    }
}

//清楚同一个虚拟群在聊天列表中的元素个数缓存
- (void)clearSameVirtualGroupCountInChatListCache
{
    dict4VirtualGroupCountInChatList = [NSMutableDictionary dictionary];
}

//获取所有的新消息条数
- (void)freshTotalNewMessageCount
{
    [self performSelectorOnMainThread:@selector(freshTotalNewMessageCountInternal) withObject:nil waitUntilDone:NO];
}

- (void)freshTotalNewMessageCountInternal
{
    @synchronized (self) {
        //遍历所有的聊天条目
        NSInteger count = 0;
        for (NSDictionary *item in array4ChatList)
        {
            NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
            //NSInteger vCount = [[BiChatDataModule sharedDataModule]getSameVirtualGroupCountInChatList:[groupProperty objectForKey:@"virtualGroupId"]];
            if (![[BiChatGlobal sharedManager]isFriendInFoldList:[item objectForKey:@"peerUid"]] &&
                ![[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]] &&
                ([[BiChatGlobal sharedManager]isFriendInContact:[item objectForKey:@"peerUid"]] || [[item objectForKey:@"isGroup"]boolValue] || [[item objectForKey:@"isPublic"]boolValue]) &&
                ![[item objectForKey:@"isApprove"]boolValue] &&
                ![[item objectForKey:@"peerUid"]isEqualToString:REQUEST_FOR_APPROVE] &&
                //(![BiChatGlobal isMeGroupOperator:groupProperty] && vCount == 1) &&
                ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
                ![BiChatGlobal isCustomerServiceGroup:[item objectForKey:@"peerUid"]])
                count += [[item objectForKey:@"newMessageCount"]integerValue];
        }
        
        //查一下有没有需要批准的入群请求
        //统计有效的approve条目
        NSInteger availableApproveCount = 0;
        for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
        {
            if ([item objectForKey:@"status"] == nil)
                availableApproveCount ++;
        }
        
        count += availableApproveCount;
        
        //通知一下服务器
        [NetworkModule reportMyUnreadMessageCount:count completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        
        //显示界面
        dispatch_async(dispatch_get_main_queue(), ^{
            if (count == 0)
                [[[BiChatGlobal sharedManager].mainGUI.tabBar.items objectAtIndex:0]setBadgeValue:nil];
            else
                [[[BiChatGlobal sharedManager].mainGUI.tabBar.items objectAtIndex:0]setBadgeValue:[NSString stringWithFormat:@"%ld", (long)count]];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = count;
        });
    }
}

- (void)saveChatListInfo
{
    [self performSelectorOnMainThread:@selector(saveChatListInfoInternal) withObject:nil waitUntilDone:NO];
}

- (void)saveChatListInfoInternal
{
    //1秒内没有新的调用，才会触发保存机制
    [timer4SaveChatListInfo invalidate];
    timer4SaveChatListInfo = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        //数据保护
        if (array4ChatList == nil ||
            array4ChatList.count == 0)
            return;
        
        //保存这个人的聊天列表
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatListInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chatlist_%@.dat", uid]];
        
        [array4ChatList writeToFile:chatListInfoFile atomically:YES];
        [timer4SaveChatListInfo invalidate];
        timer4SaveChatListInfo = nil;
    }];
}

- (NSMutableArray *)getChatListInfo
{
    if (uid.length == 0)
        return nil;
    
    @synchronized (self) {
        return [NSMutableArray arrayWithArray:array4ChatList];
    }
}

- (void)deleteChatItemInList:(NSString *)peerUid
{
    @synchronized (self) {
        //查找
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [array4ChatList removeObjectAtIndex:i];
                [self saveChatListInfo];
                [self freshTotalNewMessageCount];
                return;
            }
        }
    }
}

//交换信息
- (void)addExchangeMessageForGroup:(NSString *)groupId message:(NSDictionary *)message
{
    //检查参数
    if (groupId == nil ||
        message == nil)
        return;
    
    @synchronized (self) {
        //准备数据
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatExchangeFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chatexchange_%@_%@.dat", [BiChatGlobal sharedManager].uid, groupId]];
        
        //找缓存
        if (dict4GroupExchangeCache == nil)
            dict4GroupExchangeCache = [NSMutableDictionary dictionary];
        NSMutableArray *array = [dict4GroupExchangeCache objectForKey:groupId];
        if (array == nil)
        {
            //然后找相应的文
            array = [NSMutableArray arrayWithContentsOfFile:chatExchangeFile];
            if (array == nil)
                array = [NSMutableArray array];
            [dict4GroupExchangeCache setObject:array forKey:groupId];
        }
        [array addObject:message];
        
        //保存
        NSLog(@"write 12");
        [array writeToFile:chatExchangeFile atomically:YES];
        NSLog(@"write 12 end");
    }
}

- (void)delExchangeMessageForGroup:(NSString *)groupId msgId:(NSString *)msgId
{
    //检查参数
    if (groupId == nil ||
        msgId == nil)
        return;
    
    @synchronized (self) {
        //准备数据
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatExchangeFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chatexchange_%@_%@.dat", [BiChatGlobal sharedManager].uid, groupId]];
        
        //找缓存
        if (dict4GroupExchangeCache == nil)
            dict4GroupExchangeCache = [NSMutableDictionary dictionary];
        NSMutableArray *array = [dict4GroupExchangeCache objectForKey:groupId];
        if (array == nil)
        {
            //然后找相应的文
            array = [NSMutableArray arrayWithContentsOfFile:chatExchangeFile];
            if (array != nil)
                [dict4GroupExchangeCache setObject:array forKey:groupId];
        }
        
        for (NSDictionary *item in array)
        {
            if ([[item objectForKey:@"msgId"]isEqualToString:msgId])
            {
                [array removeObject:item];
                
                //保存
                NSLog(@"write 13");
                [array writeToFile:chatExchangeFile atomically:YES];
                NSLog(@"write 13 end");
                return;
            }
        }
    }
}

- (NSMutableArray *)getExchangeMesssageForGroup:(NSString *)groupId
{
    @synchronized (self) {
        if ([dict4GroupExchangeCache objectForKey:groupId] != nil)
            return [NSMutableArray arrayWithArray:[dict4GroupExchangeCache objectForKey:groupId]];
        
        //准备数据
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatExchangeFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chatexchange_%@_%@.dat", [BiChatGlobal sharedManager].uid, groupId]];
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:chatExchangeFile];
        if (array != nil)
            [dict4GroupExchangeCache setObject:array forKey:groupId];
        return [NSMutableArray arrayWithArray:array];
    }
}

//修改聊天记录里面对方的名字
- (void)changePeerNameFor:(NSString *)peerUid withName:(NSString *)name
{
    @synchronized (self) {
        //查找
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
            {
                [item setObject:name forKey:@"peerNickName"];
                [self saveChatListInfo];
                //NSLog(@"%@", array4ChatList);
                return;
            }
        }
    }
}

//获取一个聊天朋友的名字
- (NSString *)getPeerNickNameFor:(NSString *)peerUid
{
    @synchronized (self) {
        //查找
        for (int i = 0; i < array4ChatList.count; i ++)
        {
            NSMutableDictionary *item = [array4ChatList objectAtIndex:i];
            if ([[item objectForKey:@"peerUid"]isEqualToString:peerUid])
                return [item objectForKey:@"peerNickName"];
        }
        
        //没有找到
        return nil;
    }
}

//设置聊天记录里面一个朋友的头像
- (void)setPeerAvatar:(NSString *)peerUid withAvatar:(NSString *)avatar
{
    if (avatar == nil)
        avatar = @"";
    
    @synchronized (self) {
        for (NSMutableDictionary *item in array4ChatList)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"peerUid"]])
            {
                [item setObject:avatar forKey:@"peerAvatar"];
                [self saveChatListInfo];
                break;
            }
        }
    }
}

//设置聊天记录里面的一个朋友的昵称
- (void)setPeerNickName:(NSString *)peerUid withNickName:(NSString *)nickName
{
    if (nickName.length == 0)
        return;
    
    @synchronized (self) {
        for (NSMutableDictionary *item in array4ChatList)
        {
            //直接找到
            if ([peerUid isEqualToString:[item objectForKey:@"peerUid"]])
            {
                [item setObject:nickName forKey:@"peerNickName"];
            }
            
            //是否虚拟群
            //NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
            //if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            //    [[[[groupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]isEqualToString:peerUid])
            //{
            //    [item setObject:nickName forKey:@"peerNickName"];
            //}
        }
        [self saveChatListInfo];
    }
}

//获取暂存的群组属性
- (NSMutableDictionary *)getGroupProperty:(NSString *)groupId
{
    //安全性检查
    if (groupId == nil)
        return nil;
    
    @synchronized (self) {
        //cache是否已经存在
        if (dict4GroupPropertyCache == nil)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *groupInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"groupInfo_%@.dat", uid]];
            dict4GroupPropertyCache = [[NSMutableDictionary alloc]initWithContentsOfFile:groupInfoFile];
        }
        NSMutableDictionary *ret = [dict4GroupPropertyCache objectForKey:groupId];
        
        //如果这个groupId是一个虚拟群ID，需要重新查找
        if (ret == nil)
        {
            for (NSString *key in dict4GroupPropertyCache)
            {
                NSMutableDictionary *groupProperty = [dict4GroupPropertyCache objectForKey:key];
                if ([[groupProperty objectForKey:@"virtualGroupId"]isEqualToString:groupId])
                {
                    ret = groupProperty;
                    [self setGroupProperty:groupId property:ret];
                    break;
                }
            }
        }
        
        //返回值是否合法
        if ([ret objectForKey:@"virtualGroupSubList"] != nil &&
            ![[ret objectForKey:@"virtualGroupSubList"]isKindOfClass:[NSArray class]])
        {
            [dict4GroupPropertyCache removeObjectForKey:groupId];
            return nil;
        }
        
        //为groupProperty添加本群的id
        [ret setObject:groupId forKey:@"groupId"];
        return ret;
    }
}

//设置一个群组属性到暂存区
- (void)setGroupProperty:(NSString *)groupId property:(NSMutableDictionary *)property
{
    //检查参数
    if (groupId == nil)
        return;
    
    @synchronized (self) {
        //如果还没有读取？
        if (dict4GroupPropertyCache == nil)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *groupInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"groupInfo_%@.dat", uid]];
            dict4GroupPropertyCache = [[NSMutableDictionary alloc]initWithContentsOfFile:groupInfoFile];
        }
        
        //压根就没有数据
        if (dict4GroupPropertyCache == nil)
            dict4GroupPropertyCache = [NSMutableDictionary dictionary];
        if (property == nil)
            [dict4GroupPropertyCache removeObjectForKey:groupId];
        else
            [dict4GroupPropertyCache setObject:property forKey:groupId];

        //设置群属性不马上保存，而是在app进入后台的时候保存一次
    }
}

//保存群组信息到内存
- (void)saveGroupProperty
{
    @synchronized (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *groupInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"groupInfo_%@.dat", uid]];
        NSLog(@"write 14");
        [dict4GroupPropertyCache writeToFile:groupInfoFile atomically:YES];
        NSLog(@"write 14 end");
    }
}

//打印一个人的聊天记录，用于测试
- (void)logContentOfChatContentWith:(NSString *)peerUid
{
    //普通聊天记录
    NSLog(@"Normal message ---------------");
    for (int i = 0; i < 100; i ++)
    {
        //读取存储
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)i]];
        
        //NSLog(@"read content from:%@", chatContentFile);
        
        //读文件并解析数据
        NSMutableArray *array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
        if (array == nil)
            break;
        
        NSLog(@"message bundle (%d) - %@",i ,array);
    }
    
    //超大群聊天记录
    NSLog(@"Big group message ---------------------");
    
}

//获取和一个朋友聊天的最后一个bundle的数据
- (NSMutableArray *)getLastBundleOfChatContentWith:(NSString *)peerUid hasMore:(BOOL *)hasMore
{
    //查一查是不是大大群
    NSMutableDictionary *groupProperty = [self getGroupProperty:peerUid];
    if (groupProperty == nil || ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        NSMutableArray *array4Return = [self getLastBundleOfChatContentWith:peerUid];
        *hasMore = (array4Return.count >= 20);
        return array4Return;
    }
    else
    {
        NSMutableArray *array4Return = [self getLastBundleOfBigGroupChatContentWith:peerUid];
        
        //是否需要加载上面的一批数据
        if (array4Return.count >= 20)
        {
            *hasMore = YES;
            return array4Return;
        }
        else if (array4Return.count < 20 && [[[array4Return firstObject]objectForKey:@"msgIndex"]integerValue] > 1)
        {
            *hasMore = YES;
            [self getBigGroupMessageFromServer:peerUid
                                          from:[[[array4Return firstObject]objectForKey:@"msgIndex"]integerValue] - 20
                                            to:[[[array4Return firstObject]objectForKey:@"msgIndex"]integerValue]];
        }
        else
        {
            NSMutableArray *array = [self getLastBundleOfChatContentWith:peerUid];
            *hasMore = (array.count >= 20);
            NSRange range = NSMakeRange(0, [array count]);
            [array4Return insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        }
        return array4Return;
    }
}

//从服务器获取一批大大群的聊天
- (void)getBigGroupMessageFromServer:(NSString *)peerUid from:(NSInteger)from to:(NSInteger)to
{
    //参数合理性检查
    if (from < 0) from = 1;
    if (to < 0) to = 1;
    if (from == to) return;
    
    //开始获取
    [NetworkModule getBigGroupMessage:peerUid from:from to:to completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            //将所有的消息入库
            for (NSString *str in [data objectForKey:@"data"])
            {
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *message = [dec mutableObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
                [[BiChatDataModule sharedDataModule]addChatContentWith:peerUid content:message];
            }
        }
        //上方没有任何数据了
        else if (errorCode == 999)
        {
            [[BiChatDataModule sharedDataModule]setBigGroupTopMessageIndex:peerUid msgIndex:to];
        }
    }];
}

//获取和一个朋友聊天的最后一个bundle的数据，如果没有满20条，则还要增加上面的一个bundle
- (NSMutableArray *)getLastBundleOfChatContentWith:(NSString *)peerUid
{
    //获取这个人的最后聊天消息index
    NSString *key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, peerUid];
    NSInteger index = [[chatDataStore getNumberById:key fromTable:chatLastIndexTableName]integerValue];
    NSInteger bundleIndex = index / 20;
    
    //开始获取这个bundle
    NSMutableArray *array4Return = [NSMutableArray array];
    while (array4Return.count < 20)
    {
        //读取这个bundle，
        //先找缓存
        NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
        NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
        if (array == nil)
        {
            //读取存储
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
            
            //NSLog(@"read content from:%@", chatContentFile);

            //读文件并解析数据
            array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
            //NSLog(@"%ld", array.count);
            if (array != nil)
            {
                //记录到缓存里面
                //NSLog(@"%@", dict4ChatContentCache);
                [dict4ChatContentCache setObject:array forKey:key];

                //加到最上面
                NSRange range = NSMakeRange(0, [array count]);
                [array4Return insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
            }
        }
        else
        {
            //加到最上面
            NSRange range = NSMakeRange(0, [array count]);
            [array4Return insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        }
        
        //读前一个bundle
        bundleIndex --;
        if (bundleIndex < 0)
            break;
    }
    
    //返回读到的数据
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < array4Return.count; i ++)
        [array addObject:[[array4Return objectAtIndex:i]mutableCopy]];
    return array;
}

//获取和一个朋友聊天某一条消息上方的更多消息，
- (NSMutableArray *)getTopMoreBundleOfChatContentWith:(NSString *)peerUid topMessage:(NSMutableDictionary *)topMessage hasMore:(BOOL *)hasMore
{
    //NSLog(@"get top more from message : %@", topMessage);
    
    //查一下是不是一个群
    NSMutableDictionary *groupProperty = [self getGroupProperty:peerUid];
    if (groupProperty == nil ||
        ![[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] ||
        [topMessage objectForKey:@"msgIndex"] == nil)
    {
        NSMutableArray *array4Return = [self getTopMoreBundleOfChatContentWith:peerUid topChatItemIndex:[[topMessage objectForKey:@"index"]integerValue]];
        *hasMore = (array4Return.count >= 20);
        return array4Return;
    }
    
    //正好处于大大群和普通群数据的边界
    else if ([[topMessage objectForKey:@"msgIndex"]integerValue] == 1 ||
             [[topMessage objectForKey:@"msgIndex"]integerValue] == 0)
    {
        NSMutableArray *array4Return = [self getLastBundleOfChatContentWith:peerUid];
        *hasMore = (array4Return.count >= 20);
        return array4Return;
    }
    
    //是超大群，而且当前所在的位置上方已经没有数据
    if ([[topMessage objectForKey:@"msgIndex"]integerValue] - 1 <= [[BiChatDataModule sharedDataModule]getBigGroupTopMessageIndex:peerUid])
    {
        *hasMore = NO;
        return nil;
    }
    
    //是超大群，而且当前所在的位置是大大群数据
    else
    {
        NSMutableArray *array4Return = [self getTopMoreBundleOfBigGroupChatContentWith:peerUid messageIndex:[[topMessage objectForKey:@"msgIndex"]integerValue]];
        if (array4Return.count > 0)
            *hasMore = ([[[array4Return firstObject]objectForKey:@"msgIndex"]integerValue] >= 1);
        else
            *hasMore = ([[topMessage objectForKey:@"msgIndex"]integerValue] >= 1);
       return array4Return;
    }
}

//获取和一个朋友聊天的一条记录的前面一个bundle的数据，如果不满20条，则还要增加上面的一个bundle
- (NSMutableArray *)getTopMoreBundleOfChatContentWith:(NSString *)peerUid topChatItemIndex:(NSInteger)topChatItemIndex
{
    NSInteger bundleIndex = topChatItemIndex / 20;
    if (bundleIndex == 0) return nil;
    
    //开始获取这个bundle
    NSMutableArray *array4Return = [NSMutableArray array];
    while (array4Return.count < 20)
    {
        bundleIndex --;
        if (bundleIndex < 0) return array4Return;
        
        //读取这个bundle，
        //先找缓存
        NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
        NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
        if (array == nil)
        {
            //读取存储
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
            
            //读文件并解析数据
            array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
            if (array != nil)
            {
                //记录到缓存里面
                [dict4ChatContentCache setObject:array forKey:key];
                
                //加到最上面
                NSRange range = NSMakeRange(0, [array count]);
                [array4Return insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
            }
        }
        else
        {
            //加到最上面
            NSRange range = NSMakeRange(0, [array count]);
            [array4Return insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        }
    }
    
    //返回读到的数据
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < array4Return.count; i ++)
        [array addObject:[[array4Return objectAtIndex:i]mutableCopy]];
    return array;
}

- (NSMutableArray *)getLastMessageFromIndexWith:(NSString *)peerUid fromIndex:(NSInteger)fromIndex
{
    NSMutableArray *array4Ret = [NSMutableArray array];
    NSInteger bundleIndex = fromIndex / 20;
    
    //读取这个bundle，先找缓存
    NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
    NSMutableArray *array4Return = [dict4ChatContentCache objectForKey:key];
    if (array4Return == nil)
    {
        //读取存储
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
        
        //读文件并解析数据
        array4Return = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
        if (array4Return != nil)
        {
            //记录到缓存里面
            [dict4ChatContentCache setObject:array4Return forKey:key];
        }
    }
    
    //找出这个bundle里面所有的符合条件的记录
    for (int i = 0; i < array4Return.count; i ++)
    {
        if ([[[array4Return objectAtIndex:i]objectForKey:@"index"]integerValue] > fromIndex)
            [array4Ret addObject:[array4Return objectAtIndex:i]];
    }

    //读取所有的后续bundle
    for (;;)
    {
        bundleIndex ++;
        
        //读取这个bundle，先找缓存
        NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
        NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
        if (array == nil)
        {
            //读取存储
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
            
            //读文件并解析数据
            array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
            if (array != nil)
            {
                //记录到缓存里面
                [dict4ChatContentCache setObject:array forKey:key];
            }
            else
                break;
        }
        
        //将这个bundle里面所有的记录加入
        [array4Ret addObjectsFromArray:array];
    }
    
    //调整最后消息的序号
    if (array4Ret.count > 0)
    {
        NSInteger index = [[[array4Ret lastObject] objectForKey:@"index"]integerValue];
        NSString *index_key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, peerUid];
        if (index > [[chatDataStore getNumberById:index_key fromTable:chatLastIndexTableName]integerValue])
            [chatDataStore putNumber:[NSNumber numberWithInteger:index] withId:index_key intoTable:chatLastIndexTableName];
    }
    
    //返回数据
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < array4Ret.count; i ++)
        [array addObject:[[array4Ret objectAtIndex:i]mutableCopy]];
    return array;
}

- (void)addChatContentWith:(NSString *)peerUid
                   content:(NSMutableDictionary *)content
{
    //检查参数
    if (content == nil)
        return;
    
    //生成一个新的结构，保证前后数据分离
    content = [content mutableCopy];
    
    //检查参数的合法性
    for (NSString *key in content)
    {
        if ([[content objectForKey:key]isKindOfClass:[UIView class]])
        {
            [content removeObjectForKey:key];
        }
    }
    
    //这条消息是不是来自于一个大大群
    NSMutableDictionary *groupProperty = [self getGroupProperty:peerUid];
    if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        [self addBigGroupChatContentWith:peerUid content:content];
        return;
    }
    
    //这个群不是一个大大群，但是这个消息是一个大大群消息
    if ([content objectForKey:@"msgIndex"] != nil)
    {
        //需要重新获取这个群的属性
        [NetworkModule getGroupProperty:[groupProperty objectForKey:@"groupId"]  completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        return;
    }
    
    //先获取这个消息的序号
    NSInteger index = [[content objectForKey:@"index"]integerValue];
    if (index == 0)
    {
        //消息里面没有最后消息的序号，自己生成
        NSString *index_key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, peerUid];
        index = [[chatDataStore getNumberById:index_key fromTable:chatLastIndexTableName]integerValue] + 1;
        
        //检查一下这个index后面还有没有消息在库里面
        NSArray *array = [self getLastMessageFromIndexWith:peerUid fromIndex:index];
        if (array.count > 0)
            index = [[[array lastObject]objectForKey:@"index"]integerValue] + 1;
        [content setObject:[NSString stringWithFormat:@"%ld", (long)index] forKey:@"index"];
    }
    
    //先判断是否需要保存前一次的数据
    NSInteger bundleIndex = index / 20;

    //先找缓存
    NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
    NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
    if (array == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
        
        //读文件并解析数据
        array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];

        //设进cache
        if (array == nil)
        {
            array = [NSMutableArray array];
            [array addObject:content];
        }
        else
            [array addObject:content];
        [dict4ChatContentCache setObject:array forKey:key];
    }
    else
        [array addObject:content];
    
    //保存一下这个人的最后序号信息
    NSString *index_key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, peerUid];
    [chatDataStore putNumber:[NSNumber numberWithInteger:index] withId:index_key intoTable:chatLastIndexTableName];

    //保存聊天内容
    [self saveChatContentWith:peerUid bundleIndex:bundleIndex data:array];
}

- (void)saveChatContentWith:(NSString *)peerUid bundleIndex:(NSInteger)bundleIndex data:(NSMutableArray *)data
{
    //保存这个人的聊天列表
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
    
    //保存
    //NSLog(@"write 15");
    [data writeToFile:chatContentFile atomically:YES];
}

//删除某个聊天的所有聊天记录
- (void)deleteAllChatContentWith:(NSString *)peerUid;
{
    //先获取这个聊天的最后消息序号
    NSString *key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, peerUid];
    NSInteger index = [[chatDataStore getNumberById:key fromTable:chatLastIndexTableName]integerValue];
    NSInteger bundleIndex = index / 20;
    [chatDataStore putNumber:[NSNumber numberWithInteger:0] withId:key intoTable:chatLastIndexTableName];

    for (int i = 0; i <= bundleIndex + 100; i ++)
    {
        //先删除内存内数据
        key = [NSString stringWithFormat:@"%@_%@_%d", [BiChatGlobal sharedManager].uid, peerUid, i];
        [dict4ChatContentCache removeObjectForKey:key];
        
        //再删除存储卡上的内容
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%d.dat", [BiChatGlobal sharedManager].uid, peerUid, i]];

        [[NSFileManager defaultManager]removeItemAtPath:chatContentFile error:nil];
    }
    
    //设置最后聊天的时间记录
    //[self setLastMessageTime:peerUid time:nil];
    
    //如果是大大群，再删除大大群里面的消息
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        [self deleteAllBigGroupChatContentWith:peerUid];
}

//删除某个聊天的一条聊天记录
- (void)deleteAPieceOfChatContentWith:(NSString *)peerUid index:(NSInteger)index
{
    NSInteger bundleIndex = index / 20;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
    
    //先找内存中的数据
    NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
    NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
    
    //没有发现
    if (array == nil)
    {
        //从存储卡中调取
        array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
        if (array != nil)
            [dict4ChatContentCache setObject:array forKey:key];
    }
    
    //有数据
    if (array.count > 0)
    {
        for (int i = 0; i < array.count; i ++)
        {
            if (index == [[[array objectAtIndex:i]objectForKey:@"index"]integerValue])
            {
                [array removeObjectAtIndex:i];
                NSLog(@"write 17");
                [array writeToFile:chatContentFile atomically:YES];
                NSLog(@"write 17 end");
                return;
            }
        }
    }
}

//替换某个聊天中的一条记录
- (void)replaceAPieceOfChatContentWith:(NSString *)peerUid index:(NSInteger)index message:(NSMutableDictionary *)content
{
    //检查参数
    if (content == nil)
        return;
    
    //开始定位
    NSInteger bundleIndex = index / 20;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
    
    //先找内存中的数据
    NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
    NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
    
    //没有发现
    if (array == nil)
    {
        //从存储卡中调取
        array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
        if (array == nil)
            return;
        [dict4ChatContentCache setObject:array forKey:key];
    }
    
    //有数据
    if (array.count > 0)
    {
        for (int i = 0; i < array.count; i ++)
        {
            if (index == [[[array objectAtIndex:i]objectForKey:@"index"]integerValue])
            {
                [array setObject:content atIndexedSubscript:i];
                NSLog(@"write 18");
                [array writeToFile:chatContentFile atomically:YES];
                NSLog(@"write 18 end");
                return;
            }
        }
    }
}

//替换某个聊天中的一条记录
- (void)replaceAPieceOfChatContentWith:(NSString *)peerUid msgId:(NSString *)msgId message:(NSMutableDictionary *)content
{
    //获取这个人的最后聊天消息index
    NSString *key = [NSString stringWithFormat:@"%@_%@", [BiChatGlobal sharedManager].uid, peerUid];
    NSInteger index = [[chatDataStore getNumberById:key fromTable:chatLastIndexTableName]integerValue];
    NSInteger bundleIndex = index / 20;

    //最多搜索1000条记录
    for (int i = 0; i < 50; i ++)
    {
        if (bundleIndex <0)
            return;
        
        //开始定位
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
        
        //先找内存中的数据
        NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
        NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
        
        //没有发现
        if (array == nil)
        {
            //从存储卡中调取
            array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
            if (array == nil)
                return;
            [dict4ChatContentCache setObject:array forKey:key];
        }
        
        //有数据
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                if ([msgId isEqualToString:[[array objectAtIndex:i]objectForKey:@"msgId"]] ||
                    ([[content objectForKey:@"orignalSender"]isEqualToString:[[array objectAtIndex:i]objectForKey:@"sender"]] &&
                     [[content objectForKey:@"contentId"]isEqualToString:[[array objectAtIndex:i]objectForKey:@"contentId"]]))
                {
                    id index = [[array objectAtIndex:i]objectForKey:@"index"];
                    if (index != nil)
                        [content setObject:index forKey:@"index"];
                                        
                    [array setObject:content atIndexedSubscript:i];
                    NSLog(@"write 19");
                    [array writeToFile:chatContentFile atomically:YES];
                    NSLog(@"write 19 end");
                    return;
                }
            }
        }

        bundleIndex --;
    }
}

//设置一条消息已经被阅读
- (void)setMessageRead:(NSString *)peerUid index:(NSInteger)index
{
    NSInteger bundleIndex = index / 20;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *chatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"chat_%@_%@_%ld.dat", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex]];
    
    //先找内存中的数据
    NSString *key = [NSString stringWithFormat:@"%@_%@_%ld", [BiChatGlobal sharedManager].uid, peerUid, (long)bundleIndex];
    NSMutableArray *array = [dict4ChatContentCache objectForKey:key];
    
    //没有发现
    if (array == nil)
    {
        //从存储卡中调取
        array = [[NSMutableArray alloc]initWithContentsOfFile:chatContentFile];
    }
    
    //有数据
    if (array.count > 0)
    {
        for (int i = 0; i < array.count; i ++)
        {
            if (index == [[[array objectAtIndex:i]objectForKey:@"index"]integerValue])
            {
                [[array objectAtIndex:i]setObject:[NSNumber numberWithBool:NO] forKey:@"isNew"];
                [array writeToFile:chatContentFile atomically:YES];
                return;
            }
        }
    }
}

//添加一条大大群的消息
- (void)addBigGroupChatContentWith:(NSString *)peerUid content:(NSMutableDictionary *)content
{
    //检查一下数据是否有msgIndex
    if ([content objectForKey:@"msgIndex"] == nil)
    {
        //检查数据合法性
        if ([content objectForKey:@"msgId"] == nil)
            return;
        
        //放入暂存空间
        if (dict4BigGroupChatContentTmp == nil)
            dict4BigGroupChatContentTmp = [NSMutableDictionary dictionary];
        [dict4BigGroupChatContentTmp setObject:content forKey:[content objectForKey:@"msgId"]];
        return;
    }
    
    //先生成target目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupChatContent%@_%@.dat", [BiChatGlobal sharedManager].uid, peerUid]];
    
    //先从cache里面查一下有没有加载和这个人的聊天记录
    NSMutableArray *array4BigGroupContent = [dict4BigGroupChatCache objectForKey:peerUid];
    if (array4BigGroupContent == nil)
    {
        //从存储中获取
        array4BigGroupContent = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
        if (array4BigGroupContent == nil)
            array4BigGroupContent = [NSMutableArray array];
        [dict4BigGroupChatCache setObject:array4BigGroupContent forKey:peerUid];
    }
    
    //开始入库数据,先搜索这个msgIndex所对应的位置
    BOOL found = NO;
    NSInteger msgIndex = [[content objectForKey:@"msgIndex"]integerValue];
    for (int i = 0; i < array4BigGroupContent.count; i ++)
    {
        //应该添加到一个消息bundle的头部
        if ([[[array4BigGroupContent objectAtIndex:i]objectForKey:@"begin"]integerValue] == msgIndex + 1)
        {
            NSMutableDictionary *item = [array4BigGroupContent objectAtIndex:i];
            if ([self getChatContentFileLength:[[[item objectForKey:@"contents"]firstObject]objectForKey:@"fileName"]] >= 20)
            {
                //生成一个文件用来保存数据
                NSString *fileName = [self createChatContentFile:content];
                [[item objectForKey:@"contents"]insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:fileName, @"fileName",
                                                              [NSNumber numberWithInteger:msgIndex], @"begin",
                                                              [NSNumber numberWithInteger:msgIndex], @"end", nil] atIndex:0];
            }
            else
                [self addBigGroupChatContentAtHeader:[[item objectForKey:@"contents"]firstObject] content:content];
            
            //修改begin
            [item setObject:[NSNumber numberWithInteger:msgIndex] forKey:@"begin"];
            found = YES;
            break;
        }
        
        //应该添加到一个消息bunle的尾部
        if ([[[array4BigGroupContent objectAtIndex:i]objectForKey:@"end"]integerValue] == msgIndex - 1)
        {
            NSMutableDictionary *item = [array4BigGroupContent objectAtIndex:i];
            if ([self getChatContentFileLength:[[[item objectForKey:@"contents"]lastObject]objectForKey:@"fileName"]] >= 20)
            {
                //生成一个文件用来保存数据
                NSString *fileName = [self createChatContentFile:content];
                [[item objectForKey:@"contents"]addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:fileName, @"fileName",
                                                           [NSNumber numberWithInteger:msgIndex], @"begin",
                                                           [NSNumber numberWithInteger:msgIndex], @"end", nil]];
            }
            else
                [self addBigGroupChatContentAtTail:[[item objectForKey:@"contents"]lastObject] content:content];
            
            //修改begin
            [item setObject:[NSNumber numberWithInteger:msgIndex] forKey:@"end"];
            found = YES;
            break;
        }
        
        //已经包含在本bundle中, 直接忽略
        if ([[[array4BigGroupContent objectAtIndex:i]objectForKey:@"begin"]integerValue] <= msgIndex &&
            [[[array4BigGroupContent objectAtIndex:i]objectForKey:@"end"]integerValue] >= msgIndex)
            return;
    }
    
    //没有找到,需要生成一个新的msgbundle
    if (!found)
    {
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:msgIndex], @"begin", [NSNumber numberWithInteger:msgIndex], @"end", nil];
        
        //生成一个文件用来保存数据
        NSString *fileName = [self createChatContentFile:content];
        [item setObject:[NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:fileName, @"fileName",
                                                         [NSNumber numberWithInteger:msgIndex], @"begin",
                                                         [NSNumber numberWithInteger:msgIndex], @"end", nil]] forKey:@"contents"];
        
        //将本条目放到应该有的位置
        if (array4BigGroupContent.count == 0)
            [array4BigGroupContent addObject:item];
        else if (msgIndex < [[[array4BigGroupContent firstObject]objectForKey:@"begin"]integerValue])
            [array4BigGroupContent insertObject:item atIndex:0];
        else if (msgIndex > [[[array4BigGroupContent lastObject]objectForKey:@"end"]integerValue])
            [array4BigGroupContent addObject:item];
        else
        {
            for (int i = 0; i < array4BigGroupContent.count - 1; i ++)
            {
                if (msgIndex > [[[array4BigGroupContent objectAtIndex:i]objectForKey:@"end"]integerValue] &&
                    msgIndex < [[[array4BigGroupContent objectAtIndex:i]objectForKey:@"begin"]integerValue])
                    [array4BigGroupContent insertObject:item atIndex:i + 1];
            }
        }
    }
    
    //整理数据，合并相邻块
    for (int i = 0; i < array4BigGroupContent.count - 1; i ++)
    {
        if ([[[array4BigGroupContent objectAtIndex:i]objectForKey:@"end"]integerValue] + 1 == [[[array4BigGroupContent objectAtIndex:i + 1]objectForKey:@"begin"]integerValue])
        {
            [[[array4BigGroupContent objectAtIndex:i]objectForKey:@"contents"]addObjectsFromArray:[[array4BigGroupContent objectAtIndex:i + 1]objectForKey:@"contents"]];
            [[array4BigGroupContent objectAtIndex:i]setObject:[[array4BigGroupContent objectAtIndex:i + 1]objectForKey:@"end"] forKey:@"end"];
            [array4BigGroupContent removeObjectAtIndex:i + 1];
            i --;
        }
    }
    
    //保存数据
    //NSLog(@"2-%@", array4BigGroupContent);
    [array4BigGroupContent writeToFile:bigGroupChatContentFile atomically:YES];
}

//保存一条聊天记录
- (NSString *)createChatContentFile:(NSMutableDictionary *)content
{
    NSString *fileName = [NSString stringWithFormat:@"%@.dat", [BiChatGlobal getUuidString]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    //生成一个含有一条记录的array
    NSMutableArray *array = [NSMutableArray arrayWithObject:content];
    [array writeToFile:bigGroupChatContentFile atomically:YES];

    //保存到cache里面
    [dict4BigGroupChatContentCache setObject:array forKey:fileName];

    //返回文件名
    return fileName;
}

//获取一个聊天文件里面的消息条数
- (NSInteger)getChatContentFileLength:(NSString *)fileName
{
    //先从缓存里面查找
    NSMutableArray *array = [dict4BigGroupChatContentCache objectForKey:fileName];
    if (array == nil)
    {
        //从内存中读取
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:fileName];

        array = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
    }
    return array.count;
}

//把一条消息加在消息bundle的头部
- (void)addBigGroupChatContentAtHeader:(NSMutableDictionary *)contentInfo content:(NSMutableDictionary *)content
{
    //生成文件信息
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:[contentInfo objectForKey:@"fileName"]];
    
    //先从缓存里面查找
    NSMutableArray *array = [dict4BigGroupChatContentCache objectForKey:[contentInfo objectForKey:@"fileName"]];
    if (array == nil)
    {
        //从内存中读取
        array = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
    }
    [array insertObject:content atIndex:0];
    
    //保存
    [array writeToFile:bigGroupChatContentFile atomically:YES];

    //修改内部数据
    [contentInfo setObject:[content objectForKey:@"msgIndex"] forKey:@"begin"];
}

//把一条消息加在消息bundle的尾部
- (void)addBigGroupChatContentAtTail:(NSMutableDictionary *)contentInfo content:(NSMutableDictionary *)content
{
    //生成文件信息
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:[contentInfo objectForKey:@"fileName"]];
    
    //先从缓存里面查找
    NSMutableArray *array = [dict4BigGroupChatContentCache objectForKey:[contentInfo objectForKey:@"fileName"]];
    if (array == nil)
    {
        //从内存中读取
        array = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
    }
    [array addObject:content];
    
    //保存
    [array writeToFile:bigGroupChatContentFile atomically:YES];

    //修改内部数据
    [contentInfo setObject:[content objectForKey:@"msgIndex"] forKey:@"end"];
}

//删除一个大大群的聊天记录
- (void)deleteAllBigGroupChatContentWith:(NSString *)peerUid
{
    //先生成target目录
    NSLog(@"delete all big group chat content with:%@", peerUid);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupChatContent%@_%@.dat", [BiChatGlobal sharedManager].uid, peerUid]];
    
    //先从cache里面查一下有没有加载和这个人的聊天记录
    NSMutableArray *array4BigGroupContent = [dict4BigGroupChatCache objectForKey:peerUid];
    if (array4BigGroupContent == nil)
    {
        //从存储中获取
        array4BigGroupContent = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
        if (array4BigGroupContent == nil)
            array4BigGroupContent = [NSMutableArray array];
    }
    else
        [dict4BigGroupChatCache removeObjectForKey:peerUid];

    //开始查找所有的消息bundle
    for (int i = 0; i < array4BigGroupContent.count; i ++)
    {
        for (NSDictionary *contentInfo in [[array4BigGroupContent objectAtIndex:i]objectForKey:@"contents"])
        {
            if ([contentInfo isKindOfClass:[NSDictionary class]])
                [[NSFileManager defaultManager]removeItemAtPath:[contentInfo objectForKey:@"fileName"] error:nil];
        }
    }
    
    //删除聊天信息文件
    [[NSFileManager defaultManager]removeItemAtPath:bigGroupChatContentFile error:nil];
}

//获取一个大大群的本地聊天中最后聊天记录的msgIndex
- (NSInteger)getBigGroupLastMessageIndex:(NSString *)peerUid
{
    //先生成target目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupChatContent%@_%@.dat", [BiChatGlobal sharedManager].uid, peerUid]];
    
    //先从cache里面查一下有没有加载和这个人的聊天记录
    NSMutableArray *array4BigGroupContent = [dict4BigGroupChatCache objectForKey:peerUid];
    if (array4BigGroupContent == nil)
    {
        //从存储中获取
        array4BigGroupContent = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
        if (array4BigGroupContent == nil)
            array4BigGroupContent = [NSMutableArray array];
        [dict4BigGroupChatCache setObject:array4BigGroupContent forKey:peerUid];
    }
    if (array4BigGroupContent.count > 0)
        return [[[array4BigGroupContent lastObject]objectForKey:@"end"]integerValue];
    else
        return 0;
}

//设置一个大大群的暂存聊天内容的msgIndex
- (void)setBigGroupChatContentMsgIndex:(NSString *)msgId msgIndex:(NSInteger)msgIndex peerUid:(NSString *)peerUid
{
    //先找到这条message
    NSMutableDictionary *message = [dict4BigGroupChatContentTmp objectForKey:msgId];
    if (message == nil)
        return;
    
    //重新给这条消息定位
    [message setObject:[NSNumber numberWithInteger:msgIndex] forKey:@"msgIndex"];
    [self addBigGroupChatContentWith:peerUid content:message];
    [dict4BigGroupChatContentTmp removeObjectForKey:msgId];
}

//获取一个大大群的最后阅读消息的msgIndex
- (NSInteger)getBigGroupLastReadMessageIndex:(NSString *)peerUid
{
    return [[dict4BigGroupLastReadMessageIndex objectForKey:peerUid]integerValue];
}

//设置一个大大群最后阅读的消息的msgIndex
- (void)setBigGroupLastReadMessageIndex:(NSString *)peerUid msgIndex:(NSInteger)msgIndex
{
    //检查参数合法性
    if ([[dict4BigGroupLastReadMessageIndex objectForKey:peerUid]integerValue] >= msgIndex)
        return;

    //设置
    [dict4BigGroupLastReadMessageIndex setObject:[NSNumber numberWithInteger:msgIndex] forKey:peerUid];
    
    //保存一下内容
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupLastReadMessageIndexInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupLastReadMessageIndexInfo_%@.dat", uid]];
    
    //保存一下最新内容
    NSLog(@"write 25");
    [dict4BigGroupLastReadMessageIndex writeToFile:bigGroupLastReadMessageIndexInfoFile atomically:YES];
    NSLog(@"write 25 end");
}

//获取一个大大群最上方消息的msgIndex
- (NSInteger)getBigGroupTopMessageIndex:(NSString *)peerUid
{
    return [[dict4BigGroupTopMessageIndex objectForKey:peerUid]integerValue];
}

//设置一个大大群的最上方消息的msgIndex
- (void)setBigGroupTopMessageIndex:(NSString *)peerUid msgIndex:(NSInteger)msgIndex
{
    //检查合法性
    if ([[dict4BigGroupTopMessageIndex objectForKey:peerUid]integerValue] >= msgIndex)
        return;
    
    //设置
    [dict4BigGroupTopMessageIndex setObject:[NSNumber numberWithInteger:msgIndex] forKey:peerUid];
    
    //保存一下内容
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupTopMessageIndexInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupTopMessageIndexInfo_%@.dat", uid]];
    
    //保存一下最新内容
    NSLog(@"write 26");
    [dict4BigGroupTopMessageIndex writeToFile:bigGroupTopMessageIndexInfoFile atomically:YES];
    NSLog(@"write 26 end");
}

- (NSMutableArray *)getLastBundleOfBigGroupChatContentWith:(NSString *)peerUid
{
    //先生成target目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupChatContent%@_%@.dat", [BiChatGlobal sharedManager].uid, peerUid]];
    
    //先从cache里面查一下有没有加载和这个人的聊天记录
    NSMutableArray *array4BigGroupContent = [dict4BigGroupChatCache objectForKey:peerUid];
    if (array4BigGroupContent == nil)
    {
        //从存储中获取
        array4BigGroupContent = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
        if (array4BigGroupContent == nil)
            array4BigGroupContent = [NSMutableArray array];
        [dict4BigGroupChatCache setObject:array4BigGroupContent forKey:peerUid];
    }
    
    //NSLog(@"111-%@", array4BigGroupContent);
    
    //从最后一个开始算起
    NSMutableArray *array4Return = [NSMutableArray array];
    NSArray *array4Content = [[array4BigGroupContent lastObject]objectForKey:@"contents"];
    for (int i = (int)(array4Content.count - 1); i >= 0; i --)
    {
        NSString *fileName = [[array4Content objectAtIndex:i]objectForKey:@"fileName"];
        
        //获取这一个文件的内容
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        NSArray *array = [[NSArray alloc]initWithContentsOfFile:filePath];
        
        //加到最上面
        NSRange range = NSMakeRange(0, [array count]);
        [array4Return insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        if (array4Return.count >= 20)
            break;
    }

    //返回读到的数据
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < array4Return.count; i ++)
        [array addObject:[[array4Return objectAtIndex:i]mutableCopy]];
    return array;
}

//获取超大群聊天某一条消息上方的更多的聊天消息
- (NSMutableArray *)getTopMoreBundleOfBigGroupChatContentWith:(NSString *)peerUid messageIndex:(NSInteger)messageIndex
{
    //检查参数
    if (messageIndex <= 1)
        return nil;
    
    //上方没有更多的消息
    if (messageIndex <= [[BiChatDataModule sharedDataModule]getBigGroupTopMessageIndex:peerUid])
        return nil;
    
    //先生成target目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bigGroupChatContentFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"bigGroupChatContent%@_%@.dat", [BiChatGlobal sharedManager].uid, peerUid]];
    
    //先从cache里面查一下有没有加载和这个人的聊天记录
    NSMutableArray *array4BigGroupContent = [dict4BigGroupChatCache objectForKey:peerUid];
    if (array4BigGroupContent == nil)
    {
        //从存储中获取
        array4BigGroupContent = [[NSMutableArray alloc]initWithContentsOfFile:bigGroupChatContentFile];
        if (array4BigGroupContent == nil)
            array4BigGroupContent = [NSMutableArray array];
        [dict4BigGroupChatCache setObject:array4BigGroupContent forKey:peerUid];
    }
    
    //NSLog(@"111-%@", array4BigGroupContent);
    
    //从头开始查找，messageIndex一定要落在一个块内，否则不能返回任何消息
    for (NSDictionary *item in array4BigGroupContent)
    {
        if ([[item objectForKey:@"begin"]integerValue] <= messageIndex && [[item objectForKey:@"end"]integerValue] >= messageIndex)
        {
            //查到了大块，然后从最后往前查小块
            NSMutableArray *array4Return = [NSMutableArray array];
            NSArray *array4Content = [item objectForKey:@"contents"];
            for (int i = (int)array4Content.count - 1; i >= 0; i --)
            {
                //是否需要copy全部小块
                if ([[[array4Content objectAtIndex:i]objectForKey:@"end"]integerValue] == messageIndex - 1)
                {
                    NSString *fileName = [[array4Content objectAtIndex:i]objectForKey:@"fileName"];
                    
                    //获取这一个文件的内容
                    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                    NSArray *array = [[NSArray alloc]initWithContentsOfFile:filePath];
                    
                    //加到最上面
                    NSRange range = NSMakeRange(0, [array count]);
                    [array4Return insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];

                    //调整index
                    messageIndex = [[[array4Return firstObject]objectForKey:@"msgIndex"]integerValue];
                }
                
                //是否需要copy一部分小块
                else if ([[[array4Content objectAtIndex:i]objectForKey:@"end"]integerValue] >= messageIndex &&
                         [[[array4Content objectAtIndex:i]objectForKey:@"begin"]integerValue] < messageIndex)
                {
                    NSString *fileName = [[array4Content objectAtIndex:i]objectForKey:@"fileName"];
                    
                    //获取这一个文件的内容
                    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                    NSArray *array = [[NSArray alloc]initWithContentsOfFile:filePath];
                    NSMutableArray *arrayTmp = [NSMutableArray array];
                    for (int j = 0; j < array.count; j ++)
                    {
                        if ([[[array objectAtIndex:j]objectForKey:@"msgIndex"]integerValue] < messageIndex ||
                            [[array objectAtIndex:j]objectForKey:@"msgIndex"] == nil)
                            [arrayTmp addObject:[array objectAtIndex:j]];
                        else
                            break;
                    }
                    
                    //加到最上面
                    NSRange range = NSMakeRange(0, [arrayTmp count]);
                    [array4Return insertObjects:arrayTmp atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];

                    messageIndex = [[[array4Return firstObject]objectForKey:@"msgIndex"]integerValue];
                }
                
                //是否已经满20条数据或者本数据块已经结束
                if (array4Return.count >= 20 || i == 0)
                {
                    //需不需要从网络加在上方的数据
                    if (array4Return.count < 20 && i == 0)
                        [self getBigGroupMessageFromServer:peerUid from:messageIndex - 20 to:messageIndex];
                    
                    //返回读到的数据
                    NSMutableArray *array = [NSMutableArray array];
                    for (int i = 0; i < array4Return.count; i ++)
                        [array addObject:[[array4Return objectAtIndex:i]mutableCopy]];
                    return array;
                }
            }
        }
    }

    return nil;
}

//设置一条消息为未发送成功状态
- (void)setUnSentMessage:(NSString *)msgId
{
    [dict4UnsentMessageInfo setObject:[NSNumber numberWithBool:YES] forKey:msgId];
    
    //保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *unSentMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"unSentMessageInfo_%@.dat", uid]];
    NSLog(@"write 27");
    [dict4UnsentMessageInfo writeToFile:unSentMessageInfoFile atomically:YES];
    NSLog(@"write 27 end");
}

//设置一条消息结束未发送成功状态
- (void)clearUnSentMessage:(NSString *)msgId
{
    [dict4UnsentMessageInfo removeObjectForKey:msgId];
    
    //保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *unSentMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"unSentMessageInfo_%@.dat", uid]];
    NSLog(@"write 28");
    [dict4UnsentMessageInfo writeToFile:unSentMessageInfoFile atomically:YES];
    NSLog(@"write 28 end");
}

//获取一条消息是否已经发送成功
- (BOOL)isMessageUnSent:(NSString *)msgId
{
    if ([dict4UnsentMessageInfo objectForKey:msgId] == nil)
        return NO;
    else
        return YES;
}

//设置一条消息正在第一次发送
- (void)setSendingMessage:(NSString *)msgId
{
    if (msgId == nil)
        return;
    
    //生成第一次开始发送的时间
    NSDate *data = [NSDate new];
    NSTimeInterval interval = [data timeIntervalSince1970];
    [dict4SendingMessageInfo setObject:[NSNumber numberWithDouble:interval] forKey:msgId];
    
    //保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *unSentMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sendingMessageInfo_%@.dat", uid]];
    NSLog(@"write 29");
    [dict4SendingMessageInfo writeToFile:unSentMessageInfoFile atomically:YES];
    NSLog(@"write 29 end");
}

//设置一条消息正在重新发送
- (void)setResendingMessage:(NSString *)msgId
{
    if (msgId == nil)
        return;
    [dict4SendingMessageInfo setObject:@"resending" forKey:msgId];
    
    //保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *unSentMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sendingMessageInfo_%@.dat", uid]];
    NSLog(@"write 30");
    [dict4SendingMessageInfo writeToFile:unSentMessageInfoFile atomically:YES];
    NSLog(@"write 30 end");
}

//设置一条消息结束正在发送
- (void)clearSendingMessage:(NSString *)msgId
{
    if (msgId == nil)
        return;
    [dict4SendingMessageInfo removeObjectForKey:msgId];
    
    //保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *unSentMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sendingMessageInfo_%@.dat", uid]];
    NSLog(@"write 31");
    [dict4SendingMessageInfo writeToFile:unSentMessageInfoFile atomically:YES];
    NSLog(@"write 31 end");
}

//获取一条消息是否正在上传
- (BOOL)isMessageSending:(NSString *)msgId
{
    if (msgId == nil)
        return NO;
    if ([[dict4SendingMessageInfo objectForKey:msgId]isKindOfClass:[NSNumber class]])
        return YES;
    else
        return NO;
}

//获取一条消息第一次开始上传的时间
- (NSTimeInterval)getMessageSendingTime:(NSString *)msgId
{
    if (msgId == nil)
        return 0;
    if ([[dict4SendingMessageInfo objectForKey:msgId]isKindOfClass:[NSNumber class]])
        return [[dict4SendingMessageInfo objectForKey:msgId]doubleValue];
    else
        return 0;
}

//获取一条消息是否正在重新上传
- (BOOL)isMessageResending:(NSString *)msgId
{
    if (msgId == nil)
        return NO;
    if ([[dict4SendingMessageInfo objectForKey:msgId]isKindOfClass:[NSString class]] &&
        [[dict4SendingMessageInfo objectForKey:msgId]isEqualToString:@"resending"])
        return YES;
    else
        return NO;
}

//设置一条消息正在下载
- (void)setReceivingMessage:(NSString *)msgId
{
    if (msgId == nil)
        return;
    [dict4ReceivingMessageInfo setObject:[NSNumber numberWithBool:YES] forKey:msgId];
}

//清除一条消息正在下载
- (void)clearReceivingMessage:(NSString *)msgId
{
    if (msgId == nil)
        return;
    [dict4ReceivingMessageInfo removeObjectForKey:msgId];
}

//获取一条消息是否正在下载
- (BOOL)isMessageReceiving:(NSString *)msgId
{
    if (msgId == nil)
        return NO;
    if ([dict4ReceivingMessageInfo objectForKey:msgId] == nil)
        return NO;
    else
        return YES;
}

//设置我在一个聊天中的草稿
- (void)setDraftMessage:(NSString *)draftMessage peerUid:(NSString *)peerUid
{
    if (peerUid.length == 0)
        return;
    
    //写入
    if (draftMessage.length == 0)
        [dict4DraftMessageInfo removeObjectForKey:peerUid];
    else
        [dict4DraftMessageInfo setObject:draftMessage forKey:peerUid];
    
    //保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *draftMessageInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"draftMessageInfo_%@.dat", uid]];
    NSLog(@"write 32");
    [dict4DraftMessageInfo writeToFile:draftMessageInfoFile atomically:YES];
    NSLog(@"write 32 end");
}

//获取一个聊天中的草稿
- (NSString *)getDraftMessageFor:(NSString *)peerUid
{
    return [dict4DraftMessageInfo objectForKey:peerUid];
}

//检查一条消息是否重复
- (BOOL)isDuplicationMessage:(NSString *)msgId peerUid:(NSString *)peerUid
{
    //检查参数
    if (msgId.length == 0 || peerUid.length == 0)
        return NO;
    
    //快速查找key
    NSString *key = [NSString stringWithFormat:@"%@_%@", peerUid, [BiChatGlobal sharedManager].uid];
    NSMutableDictionary *chatMsgDict = [NSMutableDictionary dictionaryWithDictionary:[chatDataStore getObjectById:key fromTable:chatMsgIdTableName]];
    if ([chatMsgDict objectForKey:msgId] != nil)
        return YES;
    
    //没有找到，需要添加一条心记录
    if (chatMsgDict == nil)
        chatMsgDict = [NSMutableDictionary dictionary];
    [chatMsgDict setObject:@"" forKey:msgId];
    [chatDataStore putObject:chatMsgDict withId:key intoTable:chatMsgIdTableName];
    return NO;
}

//清除消息id数据库
- (void)clearMsgIdTable
{
    [chatDataStore clearTable:chatMsgIdTableName];
}

//获取一个朋友的通讯录操作时间
- (NSDate *)getContactOperationTimeWith:(NSString *)peerUid
{
    NSString *str = [dict4ContactOperationTime objectForKey:peerUid];
    if (str.length == 0)
        return nil;
    else
        return [BiChatGlobal parseDateString:str];
}

//设置一个朋友的通讯录操作时间
- (void)setContactOperationTimeWith:(NSString *)peerUid
{
    NSString *str = [BiChatGlobal getCurrentDateString];
    [dict4ContactOperationTime setObject:str forKey:peerUid];
    
    //马上保存一下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *contactOperationTimeInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"contactOperationTimeInfo_%@.dat", uid]];

    //保存
    [dict4ContactOperationTime writeToFile:contactOperationTimeInfoFile atomically:NO];
}

//设置一个红包是否已经被领取，或者已经被领光
- (void)setRedPacketFinished:(NSString *)redPacketId status:(NSInteger)status;
{
    if (redPacketId == nil)
        return;
    
    //保存数据库
    [chatDataStore putNumber:[NSNumber numberWithInteger:status] withId:redPacketId intoTable:redPacketStatusTableName];
}

//返回一个红包的状态
- (NSInteger)isRedPacketFinished:(NSString *)redPacketId
{
    if (redPacketId == nil)
        return 0;
    
    //获取数据
    return [[chatDataStore getNumberById:redPacketId fromTable:redPacketStatusTableName]integerValue];
}

//设置一笔转账是否已经完成
- (void)setTransferMoneyFinished:(NSString *)transactionId status:(NSInteger)status
{
    if (transactionId == nil)
        return;
    
    //保存数据
    [chatDataStore putNumber:[NSNumber numberWithInteger:status] withId:transactionId intoTable:transferStatusTableName];
}

//返回一笔转账是否已经完成
- (NSInteger)isTransferMoneyFinished:(NSString *)transactionId
{
    if (transactionId == nil)
        return 0;
    
    //获取数据
    return [[chatDataStore getNumberById:transactionId fromTable:transferStatusTableName]integerValue];
}

//设置一笔交换是否已经完成
- (void)setExchangeMoneyFinished:(NSString *)transactionId status:(NSInteger)status
{
    if (transactionId == nil)
        return;
    
    //保存数据
    [chatDataStore putNumber:[NSNumber numberWithInteger:status] withId:transactionId intoTable:exchangeStatusTableName];
}

//返回一笔转账是否已经完成
- (NSInteger)isExchangeMoneyFinished:(NSString *)transactionId
{
    if (transactionId == nil)
        return 0;
    
    //获取数据
    return [[chatDataStore getNumberById:transactionId fromTable:exchangeStatusTableName]integerValue];
}


@end
