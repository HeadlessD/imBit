//
//  DFEnumDefines.h
//  BiChat
//
//  Created by chat on 2018/9/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#ifndef DFEnumDefines_h
#define DFEnumDefines_h


#define MomentTab  @"MomentTab"
#define IndexTab   @"IndexTab"
#define RemindTab  @"RemindTab"
#define OtherTab   @"OtherTab"

#define TabKey_BlockMeMomentArr         @"TabKey_BlockMeMomentArr"   //不让我看的数组
#define TabKey_NewMomentRemindingCount  @"newMomentRemindingCount"   //未读消息
#define TabKey_UserCover                @"userCover"   //用户背景


#define NOTI_MOMENT_TYPE_ADD_REDPOINT       @"MOMENT_TYPE_ADD_REDPOINT"       //红点提示
#define NOTI_MOMENT_TYPE_ADD_REMINDINGVIEW  @"MOMENT_TYPE_ADD_REMINDINGVIEW"  //新动态提醒
#define NOTI_MOMENT_TYPE_UPDATEMOMENT       @"MOMENT_TYPE_UPDATEMOMENT"       //更新一条动态
#define NOTI_MOMENT_TYPE_RELOADDATA         @"MOMENT_TYPE_RELOADDATA"         //全局刷新
#define NOTI_MOMENT_TYPE_ADD_REDNUM         @"MOMENT_TYPE_ADD_REDNUM"         //红点提示

#define NOTI_MOMENT_TYPE_ChangeRemind  @"MOMENT_TYPE_ChangeRemind" //删除评论消息

#define NOTI_MOMENT_TYPE_RELOADREMIND         @"MOMENT_TYPE_RELOADREMIND"         //消息通知列表刷新


typedef NS_ENUM(NSUInteger, MOMENTTYPE) {
    MOMENT_TYPE_NEW = 1,              //新建朋友圈
    MOMENT_TYPE_DELETE = 2,           //删除朋友圈
    MOMENT_TYPE_ADDCOMMENT = 3,       //添加评论
    MOMENT_TYPE_DELETECOMMENT = 4,    //删除评论
    MOMENT_TYPE_PRAISE = 5,           //点赞
    MOMENT_TYPE_PRAISEUNDO = 6,       //取消点赞
    MOMENT_TYPE_PROHIBITLOOK = 7,     //不让某人看朋友圈
    MOMENT_TYPE_PROHIBITLOOKUNDO = 8, //取消不让某人看朋友圈
    MOMENT_TYPE_COMMENTREDPOINT = 9,  //好友评论红点提示
    MOMENT_TYPE_PRAISEREDPOINT = 10   //好友点赞红点提示
};


typedef NS_ENUM(NSUInteger, MomentJurisdictionType) {
    MomentJurisdictionType_BlockUser = 122,      //不让对方看我的朋友圈
    MomentJurisdictionType_NotBlockUser = 123,   //取消不让对方看我的朋友
    MomentJurisdictionType_IgnoreUser = 124,     //不看对方的朋友圈
    MomentJurisdictionType_NotIgnoreUser = 125   //取消不看对方的朋友圈
};


typedef NS_ENUM(NSUInteger, MomentSendType) {
    MomentSendType_Text  = 1,   //文本
    MomentSendType_Image = 2,   //图片
    MomentSendType_Video = 3,   //视频
    MomentSendType_Mic   = 4,   //语音
    MomentSendType_News  = 5    //新闻
};


typedef NS_ENUM(NSUInteger, MomentChoosePic) {
    SendMoment_Camera = 11,       //动态拍照
    Cover_camero = 12,            //背景拍照
    Cover_library = 13,           //背景图片库
    SendMoment_library = 14,      //动态拍照
};


#endif /* DFEnumDefines_h */
