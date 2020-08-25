//
//  NetworkModule.h
//  BiChat
//
//  Created by worm_kc on 2018/3/22.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKPSMTPMessage.h"

typedef void(^NetworkCompletedBlock)(BOOL success, BOOL isTimeOut, NSInteger errorCode, id _Nullable data);

@interface SendMessagePara : NSObject

@property (nonatomic) NSInteger count;
@property (nonatomic, retain) NSString *_Nonnull peerUid;
@property (nonatomic, retain) NSDictionary *_Nonnull message;
@property (nonatomic, copy) NetworkCompletedBlock _Nonnull completedBlock;

@end

@interface getGroupPropertyPara : NSObject

@property (nonatomic, copy) NetworkCompletedBlock _Nonnull completedBlock;

@end

@interface NetworkModule : NSObject<SKPSMTPMessageDelegate>
{
    NetworkCompletedBlock sendReportEmailCompletedBlock;
}

+ (BOOL)reconnect;
+ (BOOL)loginByWeChat:(NSString *_Nonnull)code completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)bindingWeChat:(NSString *_Nonnull)code completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)unBindWeChat:(NSString *_Nonnull)unionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)logout:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)sendVerifyCode4Login:(NSString *_Nonnull)areaCode mobile:(NSString *_Nonnull)mobile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)sendVoiceVerifyCode4Login:(NSString *_Nonnull)areaCode mobile:(NSString *_Nonnull)mobile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)sendVerifyCode4ChangePaymentPassword:(NSString *_Nonnull)areaCode mobile:(NSString *_Nonnull)mobile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)checkVerifyCode:(NSString *_Nonnull)areaCode mobile:(NSString *_Nonnull)mobile verifyCode:(NSString *_Nonnull)verifyCode completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)loginByVerifyCode:(NSString *_Nonnull)areaCode mobile:(NSString *_Nonnull)mobile verifyCode:(NSString *_Nonnull)verifyCode weChatToken:(NSString *_Nonnull)weChatToken completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)changePaymentPassword:(NSString *_Nonnull)areaCode mobile:(NSString *_Nonnull)mobile verifyCode:(NSString *_Nonnull)verifyCode password:(NSString *_Nonnull)password completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)isPaymentPasswordSet:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)reloadContactList:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)getMyPrivacyProfile:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)setMyPrivacyProfile:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)blockUser:(NSString * _Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)unBlockUser:(NSString * _Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)setGroupPublicProfile:(NSString * _Nonnull)groupId profile:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)setGroupPrivateProfile:(NSString * _Nonnull)groupId profile:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)stickItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)unStickItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)foldItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)unFoldItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)muteItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)unMuteItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)addFriend:(NSString * _Nonnull)peerUserName source:(NSString *_Nonnull)source completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//同意一个朋友邀请
+ (BOOL)agreeFriend:(NSString *_Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)delFriend:(NSString * _Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//根据手机号码获取好友信息
+ (BOOL)getFriendByPhone:(NSString *_Nonnull)phone completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//根据refCode获取好友信息
+ (BOOL)getFriendByRefCode:(NSString * _Nonnull)refCode completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//添加我的邀请人
+ (BOOL)addMyInviter:(NSString * _Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)createGroup:(NSString *_Nonnull)groupName userList:(NSArray *_Nonnull)userList relatedGroupId:(NSString *)relatedGroupId relatedGroupType:(NSInteger)relatedGroupType completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)setGroupOwner:(NSString *_Nonnull)groupId owner:(NSString *_Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)addGroupAssistant:(NSString *_Nonnull)groupId assistant:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)delGroupAssistant:(NSString *_Nonnull)groupId assistant:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)addGroupVIP:(NSString *_Nonnull)groupId VIP:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)delGroupVIP:(NSString *_Nonnull)groupId VIP:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//发送一条消息给朋友
+ (BOOL)sendMessageToUser:(NSString *_Nonnull)peerUid message:(NSMutableDictionary *_Nonnull)message completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//发送一条消息到群
+ (BOOL)sendMessageToGroup:(NSString *_Nonnull)groupId message:(NSMutableDictionary *_Nonnull)message completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//发送一条消息到群主和管理员
+ (BOOL)sendMessageToGroupOperator:(NSString *_Nonnull)groupId message:(NSMutableDictionary *_Nonnull)message completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//通过uid获取个人属性
+ (BOOL)getUserProfileByUid:(NSString *_Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//通过手机号码获取个人属性
+ (BOOL)getUserProfileByMobile:(NSString *_Nonnull)mobile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//设置一个朋友的备注名
+ (BOOL)setUserMemoNameByUid:(NSString *_Nonnull)peerUid memoName:(NSString *_Nonnull)memoName completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//上传本地通讯录
+ (BOOL)uploadLocalContact:(NSArray *_Nonnull)contact completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取当前app的版本号
+ (BOOL)getAppVersion:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取当前的钱包信息
+ (BOOL)getWallet:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)getWalletAccount:(NSString *_Nonnull)coinSymbol currPage:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取一个币的流水
+ (BOOL)getCoinHistory:(NSString *_Nonnull)coinFlag completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我的资产
+ (BOOL)setMyWalletAsset:(NSArray *_Nonnull)coinSymbols completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//转账
+ (BOOL)transferCoin:(NSString *_Nonnull)coinSymbol to:(NSString *_Nonnull)peerUid count:(CGFloat)count paymentPassword:(NSString *_Nonnull)paymentPassword completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//确认转账
+ (BOOL)confirmTransferCoin:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)getTransferCoinInfo:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)recallTransferCoin:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//交换
+ (BOOL)exchangeCoin:(NSString *_Nonnull)coinSymbol count:(CGFloat)count paymentPassword:(NSString *_Nonnull)paymentPassword exchangeCoinSymbol:(NSString *_Nonnull)exchangeCoinSymbol exchangeCount:(CGFloat)exchangeCount expire:(CGFloat)expire memo:(NSString *_Nullable)memo completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//确认交换
+ (BOOL)confirmExchangeCoin:(NSString *_Nonnull)transactionId password:(NSString *_Nonnull)password completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)getExchangeCoinInfo:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)recallExchangeCoin:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;

+ (BOOL)getWeChatBindingList:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)pauseNetwork:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)resumeNetwork:(NetworkCompletedBlock _Nonnull)completedBlock;
//本人申请入群
+ (BOOL)apply4Group:(NSString *_Nonnull)groupId source:(NSString *_Nonnull)source completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取公号的详细信息
+ (BOOL)getPublicProperty:(NSString *_Nonnull)publicId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取一个群组的详细信息
+ (BOOL)getGroupProperty:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)getGroupPropertyLite:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//钉一条信息
+ (BOOL)pinMessage:(NSDictionary *_Nonnull)message inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//拔钉一条信息
+ (BOOL)unPinMessage:(NSString *_Nonnull)pinId inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取群精选消息列表
+ (BOOL)getPinMessageList:(NSString *_Nonnull)groupId key:(NSString *_Nullable)key completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//设置一个加入精选的属性
+ (BOOL)flagPinMessage:(NSString *_Nonnull)groupId uuid:(NSString *_Nonnull)uuid flag:(NSDictionary *_Nonnull)flag completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//群公告一条消息
+ (BOOL)boardMessage:(NSDictionary *_Nonnull)message inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//删除一条群公告
+ (BOOL)unBoardMessage:(NSString *_Nonnull)boardId inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取群公告消息列表
+ (BOOL)getBoardMessageList:(NSString *_Nonnull)groupId key:(NSString *_Nullable)key completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//收藏一条消息
+ (BOOL)favoriteMessage:(NSDictionary *_Nonnull)message msgId:(NSString *_Nonnull)msgId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//取消收藏一条消息
+ (BOOL)unFavoriteMessage:(NSString *_Nonnull)pinId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我收藏的消息列表
+ (BOOL)getFavoriteMessageList:(NSString *_Nonnull)key currPage:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//关注一个公号
+ (BOOL)followPublicAccount:(NSString *_Nonnull)accountId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//取关一个公号
+ (BOOL)unfollowPublicAccount:(NSString *_Nonnull)accountId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//使用公号名称搜索公号列表
+ (BOOL)searchPublicAccountByName:(NSString *_Nonnull)accountName completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取可抢红包列表
+ (BOOL)getRedAvailableInfo:(NSString *_Nonnull)name completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取已经领过的红包
+ (BOOL)getReceivedRedList:(NSString *_Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//移除一批人出群
+ (BOOL)removeUsersFromGroup:(NSString *_Nonnull) groupId userList:(NSArray *_Nonnull)userList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//群主/管理员批准入群申请
+ (BOOL)approveGroupApplication:(NSString *_Nonnull)groupId userList:(NSArray *_Nonnull)userList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//群主/管理员拒绝入群申请
+ (BOOL)rejectGroupApplication:(NSString *_Nonnull)groupId userList:(NSArray *_Nonnull)userList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//申请人取消入群申请
+ (BOOL)cancelGroupApplication:(NSString *_Nonnull)groupId userList:(NSArray *_Nonnull)userList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取一个群的有效的入群审批列表
+ (BOOL)getGroupApproveList:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取一个用户在某群中的状态
+ (BOOL)getUserStatusInGroup:(NSString *_Nonnull)groupId userId:(NSString *_Nonnull)userId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//创建一个客服交流群，用于客户和群管理员交流
+ (BOOL)createGroupServiceGroup:(NSString *_Nonnull)groupId userId:(NSString *_Nonnull)userId relatedGroupId:(NSString *_Nonnull)relatedGroupId relatedGroupType:(NSInteger)relatedGroupType  completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//扫码登录文件传输助手
+ (BOOL)scanLoginWithstring:(NSString *_Nonnull)string completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//创建一个虚拟群
+ (BOOL)createVirtualGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//创建一个虚拟群广播子群
+ (BOOL)createVirtualGroupBroadCastGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取一个虚拟群有几个子群
+ (BOOL)getVirtualGroupList:(NSString *_Nonnull)virtualGroupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取一个虚拟群的主群id
+ (BOOL)getMainGroupIdByVirtualGroup:(NSString *_Nonnull)virtualGroupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//创建一个虚拟群子群
+ (BOOL)createVirtualSubGroup:(NSString *_Nonnull)virtualGroupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//根据昵称搜索一个虚拟群里面的用户
+ (BOOL)searchVirtualGroupByNickName:(NSString *_Nonnull)nickName groupId:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//拉人进入群
+ (BOOL)addGroupMember:(NSArray *_Nonnull)contacts groupId:(NSString *_Nonnull)groupId source:(NSDictionary *_Nonnull)source  completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//拉人进入虚拟群
+ (BOOL)addVirtualGroupMember:(NSArray *_Nonnull)contacts virtualGroupId:(NSString *_Nonnull)virtualGroupId groupId:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//扫码登录公号管理平台
+ (BOOL)scanPublicManaemengLogingWithstring:(NSString *_Nonnull)string completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取不能自动入群的人员列表
+ (BOOL)getAutoRejectApplyList:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//红包、扫码、发现等 入群
+ (BOOL)joinGroupWithGroupId:(NSString *_Nonnull)groupId jsonData:(NSDictionary *_Nonnull)jsonData completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//升级普通群为大大群
+ (BOOL)upgradeToBigGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//订阅大大群的消息
+ (BOOL)subscribeBigGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//取消订阅大大群的消息
+ (BOOL)unSubscribeBigGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取大大群特定返回的消息
+ (BOOL)getBigGroupMessage:(NSString *_Nonnull)groupId from:(NSInteger)fromIndex to:(NSInteger)toIndex completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//搜索大大群的群用户
+ (BOOL)searchBigGroupMember:(NSString *_Nonnull)groupId keyWord:(NSString *_Nonnull)keyWord completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//报告我的ios client environmeng
+ (BOOL)reportMyEnvironment:(NetworkCompletedBlock _Nonnull)completedBlock;
//报告最近的群组访问
+ (BOOL)reportMyGroupAccess:(NSArray *_Nonnull)groupList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//报告我的ios notification device id
+ (BOOL)reportMyNotificationId:(NSString *_Nonnull)notificationId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//报告我的当前未读消息个数
+ (BOOL)reportMyUnreadMessageCount:(NSInteger)count completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//创建直播群
+ (BOOL)liveGroupCreate:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//群黑名单
+ (BOOL)blockGroupMember:(NSString *_Nonnull)groupId userId:(NSString *_Nonnull)userId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)blockGroupMembers:(NSString *_Nonnull)groupId userIds:(NSArray *_Nonnull)userIds completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)unBlockGroupMember:(NSString *_Nonnull)groupId userId:(NSString *_Nonnull)userId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//禁言
+ (BOOL)forbidGroupMember:(NSString *_Nonnull)groupId userIds:(NSArray *_Nonnull)userIds completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)unForbidGroupMember:(NSString *_Nonnull)groupId userIds:(NSArray *_Nonnull)userIds completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)getTokenInfo:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取充币地址，如果没有返回空
+ (BOOL)getRechargeAddress:(NSString *_Nonnull)coinType completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//生成充币地址
+ (BOOL)createRechargeAddress:(NSString *_Nonnull)coinType completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//提币
+ (BOOL)withdrawCoin:(NSString *_Nonnull)coinType address:(NSString *_Nonnull)address password:(NSString *_Nonnull)password amount:(NSString *_Nonnull)amount completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我的原力奖励情况
+ (BOOL)getMyForceReward:(NetworkCompletedBlock _Nonnull)completedBlock;
//赚积分
+ (BOOL)reportPoint:(NSString *_Nonnull)type completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取appconfig
+ (BOOL)getAppConfig:(NSString *_Nonnull)versionNum completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//收割气泡
+ (BOOL)getBubble:(NSString *_Nonnull)type uuid:(NSString *_Nonnull)uuid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我的好友列表
+ (BOOL)getMyFriendList:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我推荐的用户列表
+ (BOOL)getMyInvitedUserList:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//点赞我推荐的用户
+ (BOOL)likeMyInvitedUser:(NSString *_Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我的解锁日历
+ (BOOL)getMyUnlockHistory:(NetworkCompletedBlock _Nonnull)completedBlock;
///朋友圈
+ (BOOL)sendMomentWithType:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)MomentJurisdictionWhitId:(NSArray *_Nonnull)userList withType:(short)commandType completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取按日期和按用户排列的推荐奖励的详情页
+ (BOOL)getUserInviteeListByDate:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)getUserInviteeListByUser:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取奖池流水
+ (BOOL)getPoolAccount:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取奖池流水（新）
+ (BOOL)getPoolHistory:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//报告ack消息
+ (BOOL)reportActMessage:(NSString *_Nonnull)msgId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//报告文件删除
+ (BOOL)reportFileDelete:(NSString *_Nonnull)msgId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//报告文件上传
+ (BOOL)reportFileSave:(NSString *_Nonnull)fileName uploadName:(NSString *_Nonnull)uploadName length:(long)length uuid:(NSString *_Nonnull)uuid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//设置大V的第二邀请码
+ (BOOL)updateVipRefCode:(NSString *_Nonnull)refCode completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取附近的人列表
+ (BOOL)getNearbyListWithLatitude:(double)latitude longitude:(double)longitude gender:(NSString *_Nullable)gender completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//清除位置信息
+ (BOOL)clearNearbyInfoCompletedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取共同群聊列表
+ (BOOL)getSameGroupList:(NSString *_Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//解散群聊
+ (BOOL)dismissGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
+ (BOOL)copyGroupMemberFrom:(NSString *_Nonnull)fromGroupId To:(NSString *_Nonnull)toGroupId members:(NSArray *_Nonnull)members completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//登录群管理平台
+ (BOOL)scanGroupManagement:(NSString *_Nonnull)string completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我所在的群列表
+ (BOOL)getMyGroupListCompletedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//领取token
+ (BOOL)unLockToken:(NetworkCompletedBlock _Nonnull)completedBlock;
//领取point
+ (BOOL)receivePoint:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取任务列表
+ (BOOL)getTaskList:(NetworkCompletedBlock _Nonnull)completedBlock;
//领取任务红包
+ (BOOL)receiveTaskReward:(NSString *_Nonnull)taskId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//网络测试
+ (BOOL)networkTest:(NetworkCompletedBlock _Nonnull)completedBlock;
//发送邮件
- (void)sendEmailToServiceCenter:(NSString *_Nonnull)title content:(NSString *_Nonnull)content completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;

+ (BOOL)getLanguageJsonWithDic:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//批量获取收件箱消息
+ (BOOL)batchGetMessage:(NSInteger)messageCount ackBatchId:(NSString *_Nonnull)ackBatchId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//升级收费群
+ (BOOL)upgradeToChargeGroup:(NSString *_Nonnull)groupId newGroupName:(NSString *_Nonnull)newGroupName coinType:(NSString *_Nonnull)coinType payValue:(NSString *_Nonnull)payValue trailTime:(NSInteger)trailTime oldGroupUserTrail:(BOOL)oldGroupUserTrail oldGroupUserExpiredTime:(NSInteger)oldGroupUserExpiredTime onePayUserExpiredTime:(NSInteger)onePayUserExpiredTime completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//收费群创建支付订单
+ (BOOL)createChargeGroupOrder:(NSString *_Nonnull)groupId remark:(NSString *_Nonnull)remark completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//删除收费群已经存在的订单
+ (BOOL)deleteChargeGroupOrder:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//支付入群
+ (BOOL)payChargeGroupOrder:(NSString *_Nonnull)groupId paymentPassword:(NSString *_Nonnull)paymentPassword completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//延展收费群Trail用户的过期时间
+ (BOOL)extentChargeGroupTrailTimeStamp:(NSString *_Nonnull)groupId uids:(NSArray *_Nonnull)uids extendTimeStamp:(NSInteger)extendTimeStamp completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//计算一下解散群需要的花费
+ (BOOL)getDismissChargeGroupFee:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//计算一下踢人需要的花费
+ (BOOL)getKickFromChargeGroupFee:(NSString *_Nonnull)groupId uids:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取我当前的竞价提示
+ (BOOL)getBidActiveTips:(NetworkCompletedBlock _Nonnull)completedBlock;
//设置短链接
+ (BOOL)setShortUrlWithType:(NSString *_Nonnull)type customId:(NSString *_Nonnull)customId chatId:(NSString *_Nonnull)chatId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
//获取短链接对应的内容
+ (BOOL)getShortUrlWithType:(NSString *_Nonnull)type chatId:(NSString *_Nonnull)chatId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
@end
