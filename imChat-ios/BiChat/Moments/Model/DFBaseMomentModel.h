//
//  DFBaseMomentModel.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

@class Message,Createuser,CommentModel,Commentuser,PraiseModel,ReplyUser;

@interface DFBaseMomentModel : NSObject
//Base
@property (nonatomic, assign) CGFloat   cellHeight;
@property (nonatomic, assign) BOOL      cellHeightChange;

@property (nonatomic, assign) BOOL      isOpen;
@property (nonatomic, assign) BOOL      isNeedRepSend;
@property (nonatomic, assign) BOOL      isNeedRepComment;

@property (nonatomic, assign) BOOL      dontClick;
@property (nonatomic, assign) CGFloat   openHeight;
@property (nonatomic, assign) long long sorteTime;

//TimeLine
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) NSUInteger month;
@property (nonatomic, assign) NSUInteger day;
@property (nonatomic, assign) BOOL bShowTime;

//Imagetext
@property (nonatomic, strong) NSArray *itthumbImages;
@property (nonatomic, strong) NSArray *itsrcImages;

//video
@property (nonatomic, copy) NSString * videoUrlStr;
@property (nonatomic, copy) NSString * videoImgStr;

@property (nonatomic, copy) NSString * videoUrlStr_copy;
@property (nonatomic, strong) NSString *videoUrlStr_strong;

@property (nonatomic, assign) CGFloat videoImgWidth;
@property (nonatomic, assign) CGFloat videoImgHeight;

@property (nonatomic, strong) NSArray * videoImgArr;

//New
@property (nonatomic, strong) Message     * message;
@property (nonatomic, strong) NSMutableArray * praiseList;
@property (nonatomic, strong) NSMutableArray * commentList;
@end


@interface Message : NSObject
@property (nonatomic, copy) NSArray *mediasList;
@property (nonatomic, copy) NSString * resourceContent;

@property (nonatomic, assign) long long ctime;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *momentId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) Createuser *createUser;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL isPrais;
@property (nonatomic, copy) NSNumber *index;
@property (nonatomic, assign) NSInteger isFriend;

@end

@interface CommentModel : NSObject
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, strong) ReplyUser   * replyUser;
@property (nonatomic, strong) Commentuser * commentUser;
@property (nonatomic, assign) long long ctime;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL   isNeedCommentTwo;

@end

@interface PraiseModel : NSObject
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@end

@interface Createuser : NSObject
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@end

@interface Commentuser : NSObject
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@end

@interface ReplyUser : NSObject
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@end
