//
//  DFPushModel.h
//  BiChat Dev
//
//  Created by chat on 2018/9/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFContent,Comment;
@interface DFPushModel : NSObject

@property (nonatomic, assign) CGFloat  pushModelCellHeight;
@property (nonatomic, assign) BOOL   isDeletedMoment;
@property (nonatomic, assign) BOOL   isDeletedRemindComment;

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *receiver;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, assign) BOOL   isNew;
@property (nonatomic, copy) NSString *receiverNickName;
@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, copy) NSString *receiverAvatar;
@property (nonatomic, strong) DFContent * dfContent;
@end

@interface DFContent : NSObject
@property (nonatomic, copy) NSString *pushId;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) long long ctime;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *praiseId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, strong) Comment *comment;
@end

@interface Comment : NSObject
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) long long ctime;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, strong) NSArray<NSString *> *myFriends;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *reply_uid;
@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, assign) NSInteger type;
@end
