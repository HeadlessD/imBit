//
//  BiChatDataModule.h
//  BiChat
//
//  Created by worm_kc on 2018/2/22.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKKeyValueStore.h"

@interface BiChatDataModule : NSObject
{
    NSString *uid;
    NSMutableArray *array4ChatList;
    
    //内部缓存
    YTKKeyValueStore *chatDataStore;
    NSString *chatLastIndexTableName;
    NSString *chatMsgIdTableName;
    NSString *redPacketStatusTableName;
    NSString *transferStatusTableName;
    NSString *exchangeStatusTableName;
    
    NSMutableDictionary *dict4ChatContentCache;                 //普通聊天内容cache
    NSMutableDictionary *dict4ContactOperationTime;
    NSMutableDictionary *dict4ChatLastTimeInfo;                 //存储我的聊天最后记录的时间
    NSMutableDictionary *dict4UnsentMessageInfo;                //存储我的未发送成功的msgId
    NSMutableDictionary *dict4SendingMessageInfo;               //存储我的正在发出的msgId
    NSMutableDictionary *dict4ReceivingMessageInfo;             //存储我的正在接受的msgId
    NSMutableDictionary *dict4GroupPropertyCache;               //暂存我的群组属性信息
    NSMutableDictionary *dict4GroupExchangeCache;               //暂存我的群组的交换信息
    NSMutableDictionary *dict4BigGroupChatCache;                //大大群聊天信息cache
    NSMutableDictionary *dict4BigGroupChatContentCache;         //大大群聊天内容cache
    NSMutableDictionary *dict4BigGroupChatContentTmp;           //大大群聊天内容暂存
    NSMutableDictionary *dict4BigGroupLastReadMessageIndex;     //大大群最后读到的消息的index
    NSMutableDictionary *dict4BigGroupTopMessageIndex;          //大大群最上方消息的index
    NSMutableDictionary *dict4DraftMessageInfo;                 //存储我在各个聊天中的草稿
    NSMutableDictionary *dict4VirtualGroupCountInChatList;      //暂存同一个虚拟群内有几个虚拟子群的信息
    
    NSTimer *timer4SaveChatListInfo;                            //延迟保存聊天列表
    NSString *currentSaveChatContentMsgInfoKey;                 //当前需要保存的chat content消息的key
}

+ (BiChatDataModule *)sharedDataModule;
- (void)loadGlobalInfo;
- (void)clearCurrentUserData;
- (void)setuid:(NSString *)uid;
- (void)freshTotalNewMessageCount;
- (void)clearMsgIdTable;

//聊天信息列表相关
- (void)addChatItem:(NSString *)peerUid
       peerNickName:(NSString *)peerNickName
         peerAvatar:(NSString *)peerAvatar
            isGroup:(BOOL)isGroup;
- (BOOL)isChatExist:(NSString *)peerUid;
- (void)changePeerUid:(NSString *)peerUid to:(NSString *)newPeerUid;
- (void)setLastMessage:(NSString *)peerUid
          peerUserName:(NSString *)peerUserName
          peerNickName:(NSString *)peerNickName
            peerAvatar:(NSString *)peerAvatar
               message:(NSString *)message
           messageTime:(NSString *)messageTime
                 isNew:(BOOL)isNew
               isGroup:(BOOL)isGroup            //群组
              isPublic:(BOOL)isPublic           //公号
             createNew:(BOOL)createNew;
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
             createNew:(BOOL)createNew;
- (void)setNewMessageCountWith:(NSString *)peerUid count:(NSInteger)count;
- (NSInteger)getNewMessageCountWith:(NSString *)peerUid;
- (void)clearNewMessageCountWith:(NSString *)peerUid;
- (void)addAtMeInGroup:(NSString *)peerUid;
- (void)setAtMeInGroup:(NSString *)peerUid count:(NSInteger)count;
- (NSInteger)getAtMe2InGroup:(NSString *)peerUid;
- (void)clearAtMeInGroup:(NSString *)peerUid;
- (void)clearAtMe2InGroup:(NSString *)peerUid;
- (void)addReplyMeInGroup:(NSString *)peerUid;
- (void)setReplyMeInGroup:(NSString *)peerUid count:(NSInteger)count;
- (NSInteger)getReplyMe2InGroup:(NSString *)peerUid;
- (void)clearReplyMeInGroup:(NSString *)peerUid;
- (void)clearReplyMe2InGroup:(NSString *)peerUid;
- (void)setNewBoardInfoInGroup:(NSString *)peerUid;
- (BOOL)getNewBoardInfoInGroup:(NSString *)peerUid;
- (void)clearNewBoardInfoInGroup:(NSString *)peerUid;
- (void)setNewApplyGroup:(NSString *)peerUid;
- (BOOL)getNewApplyGroup:(NSString *)peerUid;
- (void)clearNewApplyGroup:(NSString *)peerUid;
- (void)setGroupHomeNoticeInGroup:(NSString *)peerUid groupHomeId:(NSString *)groupHomeId groupHomeNotice:(NSString *)groupHomeNotice;
- (NSDictionary *)getGroupHomeNoticeInGroup:(NSString *)peerUid;
- (void)clearGroupHomeNoticeInGroup:(NSString *)peerUid;
- (void)setGroupHomeHighlightInGroup:(NSString *)peerUid groupHomeId:(NSString *)groupHomeId;
- (NSArray *)getGroupHomeHighlightInGroup:(NSString *)peerUid;
- (void)clearGroupHomeHighlightInGroup:(NSString *)peerUid groupHomeId:(NSString *)groupHomeId;

- (NSMutableArray *)getChatListInfo;
- (void)deleteChatItemInList:(NSString *)peerUid;
- (void)changePeerNameFor:(NSString *)peerUid withName:(NSString *)name;
- (NSString *)getPeerNickNameFor:(NSString *)peerUid;
- (void)setPeerAvatar:(NSString *)peerUid withAvatar:(NSString *)avatar;
- (void)setPeerNickName:(NSString *)peerUid withNickName:(NSString *)nickName;
- (NSMutableDictionary *)getGroupProperty:(NSString *)groupId;
- (void)setGroupProperty:(NSString *)groupId property:(NSMutableDictionary *)property;
- (void)saveGroupProperty;

//聊天相关
- (void)logContentOfChatContentWith:(NSString *)peerUid;
- (NSMutableArray *)getLastBundleOfChatContentWith:(NSString *)peerUid hasMore:(BOOL *)hasMore;
- (NSMutableArray *)getTopMoreBundleOfChatContentWith:(NSString *)peerUid topMessage:(NSMutableDictionary *)topMessage hasMore:(BOOL *)hasMore;
- (NSMutableArray *)getLastMessageFromIndexWith:(NSString *)peerUid fromIndex:(NSInteger)fromIndex;
- (void)addChatContentWith:(NSString *)peerUid content:(NSMutableDictionary *)content;
- (void)deleteAllChatContentWith:(NSString *)peerUid;
- (void)deleteAPieceOfChatContentWith:(NSString *)peerUid index:(NSInteger)index;
- (void)replaceAPieceOfChatContentWith:(NSString *)peerUid index:(NSInteger)index message:(NSMutableDictionary *)content;
- (void)replaceAPieceOfChatContentWith:(NSString *)peerUid msgId:(NSString *)msgId message:(NSMutableDictionary *)content;
- (void)setMessageRead:(NSString *)peerUid index:(NSInteger)index;
//- (NSDate *)getLastMessageTime:(NSString *)peerUid;
//- (void)setLastMessageTime:(NSString *)peerUid time:(NSDate *)time;
- (NSInteger)getBigGroupLastMessageIndex:(NSString *)peerUid;
- (void)setBigGroupChatContentMsgIndex:(NSString *)msgId msgIndex:(NSInteger)msgIndex peerUid:(NSString *)peerUid;
- (NSInteger)getBigGroupLastReadMessageIndex:(NSString *)peerUid;
- (void)setBigGroupLastReadMessageIndex:(NSString *)peerUid msgIndex:(NSInteger)msgIndex;
- (NSInteger)getBigGroupTopMessageIndex:(NSString *)peerUid;
- (void)setBigGroupTopMessageIndex:(NSString *)peerUid msgIndex:(NSInteger)msgIndex;
- (void)setUnSentMessage:(NSString *)msgId;
- (void)clearUnSentMessage:(NSString *)msgId;
- (BOOL)isMessageUnSent:(NSString *)msgId;
- (void)setSendingMessage:(NSString *)msgId;
- (void)setResendingMessage:(NSString *)msgId;
- (void)clearSendingMessage:(NSString *)msgId;
- (BOOL)isMessageSending:(NSString *)msgId;
- (NSTimeInterval)getMessageSendingTime:(NSString *)msgId;
- (BOOL)isMessageResending:(NSString *)msgId;
- (void)setReceivingMessage:(NSString *)msgId;
- (void)clearReceivingMessage:(NSString *)msgId;
- (BOOL)isMessageReceiving:(NSString *)msgId;
- (void)setDraftMessage:(NSString *)draftMessage peerUid:(NSString *)peerUid;
- (NSString *)getDraftMessageFor:(NSString *)peerUid;
- (BOOL)isDuplicationMessage:(NSString *)msgId peerUid:(NSString *)peerUid;
- (NSInteger)getSameVirtualGroupCountInChatList:(NSString *)virtualGroupId;
- (void)clearSameVirtualGroupCountInChatListCache;

//红包转账交换状态
- (void)setRedPacketFinished:(NSString *)redPacketId status:(NSInteger)status;
- (NSInteger)isRedPacketFinished:(NSString *)redPacketId;
- (void)setTransferMoneyFinished:(NSString *)transactionId status:(NSInteger)status;
- (NSInteger)isTransferMoneyFinished:(NSString *)transactionId;
- (void)setExchangeMoneyFinished:(NSString *)transactionId status:(NSInteger)status;
- (NSInteger)isExchangeMoneyFinished:(NSString *)transactionId;

//交换信息
- (void)addExchangeMessageForGroup:(NSString *)groupId message:(NSDictionary *)message;
- (void)delExchangeMessageForGroup:(NSString *)groupId msgId:(NSString *)msgId;
- (NSMutableArray *)getExchangeMesssageForGroup:(NSString *)groupId;

//朋友操作相关
- (NSDate *)getContactOperationTimeWith:(NSString *)peerUid;
- (void)setContactOperationTimeWith:(NSString *)peerUid;

@end
