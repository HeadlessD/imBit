//
//  WPRedpacketRobRedPacketDetailModel.h
//  BiChat
//
//  Created by 张迅 on 2018/5/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPRedpacketRobRedPacketDetailModel : NSObject
//"20分钟"发红包距离现在时间
@property (nonatomic,strong)NSString *diffTime;
@property (nonatomic,strong)NSString *receiveTime;
//红包类型 101个人点对点 102群普通 103群拉人 104公号点对点 105公号普通 106公号拉人
@property (nonatomic,assign)NSInteger rewardType;
//发红包人uid
@property (nonatomic,strong)NSString *uid;
//过期时间
@property (nonatomic,strong)NSString *expired;
//剩余个数
@property (nonatomic,strong)NSString *residueCount;
//自已是否是发红包人
@property (nonatomic,assign)BOOL isOwner;
//发红包人姓名
@property (nonatomic,strong)NSString *nickname;
//发红包时间
@property (nonatomic,strong)NSString *ctime;
//领取金额
@property (nonatomic,strong)NSString *drawAmount;
//币种
@property (nonatomic,strong)NSString *coinType;
//1领成功，2最后一个领
@property (nonatomic,strong)NSString *isRecive;
//币个数
@property (nonatomic,strong)NSString *amount;
//rewardStatus: 1可抢，2抢完，3领完，4已过期，5红包还未开始抢,6已达活动预算上限
@property (nonatomic,strong)NSString *rewardStatus;
//群id
@property (nonatomic,strong)NSString *groupid;
//群主id
@property (nonatomic,strong)NSString *groupOwnerUid;
//群name
@property (nonatomic,strong)NSString *groupName;
//群头像
@property (nonatomic,strong)NSString *groupAvatar;
//总共被领取金额//已领金额
@property (nonatomic,strong)NSString *residueAmount;
//总共个数//红包个数
@property (nonatomic,strong)NSString *count;
//还有多少个
@property (nonatomic,strong)NSString *lastCount;
//发红包人头像
@property (nonatomic,strong)NSString *avatar;
//红包id
@property (nonatomic,strong)NSString *rewardid;
//本人手机号
@property (nonatomic,strong)NSString *phone;
@property (nonatomic,strong)NSString *appid;
//红包名
@property (nonatomic,strong)NSString *name;
//是否可分享
@property (nonatomic,assign)BOOL isShare;
//币中英文对照
@property (nonatomic,strong)NSArray *coinName;
//红包状态，共用接口参数，上面是红包详情返回，下面是抢红包页面接口
//1未抢完,2已过期,3已领完
//status:1可抢待抢,2已抢待领，3已抢已领，4用户已在红包群，5用户在红包群黑名单，6用户已关注公号 ，7用户在公号黑名单，8已开启群聊邀请确认,9用户已达活动领取次数上限
@property (nonatomic,strong)NSString *status;
//是否要自动跳转到红包详情页面
@property (nonatomic,strong)NSString *isRedirect;

//币信息
//白底2x
@property (nonatomic,strong)NSString *imgWhite;
//微信分享图标
@property (nonatomic,strong)NSString *imgWechat;
//底色2x
@property (nonatomic,strong)NSString *imgColor;
//金色图标
@property (nonatomic,strong)NSString *imgGold;
//位数
@property (nonatomic,strong)NSString *bit;
//显示名
@property (nonatomic,strong)NSString *dSymbol;
//内部id
@property (nonatomic,strong)NSString *symbol;
//分享用url
@property (nonatomic,strong)NSString *url;
//是否已入群
@property (nonatomic,strong)NSString *internalGroup;
//邀请码
@property (nonatomic,strong)NSString *inviteCode;
//是否可转到他群
@property (nonatomic,strong)NSString *canForward;
//是否可分享到微信
@property (nonatomic,strong)NSString *outside;
//是否同步到红包广场
@property (nonatomic,strong)NSString *inFeed;
//本群其他人是否可见
@property (nonatomic,strong)NSString *internalSee;
//本群成员是否可抢
@property (nonatomic,strong)NSString *internal;
//非本群成员是否可抢
@property (nonatomic,strong)NSString *external;
//子类型0:拉人自己转发，1.拉人群友转发，2.分享红包广场
@property (nonatomic,strong)NSString *subType;
//奖励比例
@property (nonatomic,strong)NSString *rate;
//是否同一个群（发红包群和抢红包群）
@property (nonatomic,assign)BOOL isSameGroup;
//是否公号
@property (nonatomic,assign)BOOL isPublic;
//0拼手气，1平均
@property (nonatomic,strong)NSString *drawType;
//公号管理者id
@property (nonatomic,strong)NSString *publicAccountOwnerUid;

//邀请人的昵称
@property (nonatomic,strong)NSString *inviteNickName;
//邀请人的Uid
@property (nonatomic,strong)NSString *inviteUid;
//邀请人的头像
@property (nonatomic,strong)NSString *inviteAvatar;

@property (nonatomic,assign)BOOL isInvite;
//指定收红包人的头像、昵称、id
@property (nonatomic,strong)NSString *receiveAvatar;
@property (nonatomic,strong)NSString *receiveNickName;
@property (nonatomic,strong)NSString *receiveUid;

@end
