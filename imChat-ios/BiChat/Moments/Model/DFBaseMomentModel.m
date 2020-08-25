//
//  DFBaseMomentModel.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFBaseMomentModel.h"

@implementation DFBaseMomentModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _praiseList = [NSMutableArray array];
        _commentList = [NSMutableArray array];
        
//        _mmContent = @"";
        _itthumbImages = [NSArray array];
        _itsrcImages = [NSArray array];
    }
    return self;
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"commentList":@"CommentModel",
             @"praiseList":@"PraiseModel"};//前边是字典中的Key名，后边是创建的类名
}

-(long long)sorteTime{
    return self.message.ctime;
}

@end

@implementation Message
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"momentId":@"id"};//前边是你写的属性名，后边是字典中的取的Key名
}
@end

@implementation CommentModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"commentId":@"id"
             };//前边是你写的属性名，后边是字典中的取的Key名
}
@end

@implementation PraiseModel
-(NSString *)remark{
    NSString * memoName = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
    NSString * nickName = [[BiChatGlobal sharedManager]getFriendNickName:self.uid];
    
    if (memoName.length > 0) {
        return memoName;
    }else if (nickName.length > 0) {
        return nickName;
    }else{
        return self.nickName;
    }
}

-(NSString *)avatar
{
    NSString * friendAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager]getFriendAvatar:self.uid]];
    NSString * cacheAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:self.uid]];
    
//        //    NSLog(@"friendAvatar_\n%@\n--cacheAvatar_\n好友Avatar,cacheAvatar);
    
    if(self.uid != nil && cacheAvatar.length > 0)
    {
        return cacheAvatar;
    }
    else if (self.uid != nil && friendAvatar.length > 0)
    {
        return friendAvatar;
    }else{
        return _avatar;
    }
}
@end

@implementation Createuser

-(NSString *)remark{
    NSString * memoName = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
    NSString * nickName = [[BiChatGlobal sharedManager]getFriendNickName:self.uid];
    
    if (memoName.length > 0) {
        return memoName;
    }else if (nickName.length > 0) {
        return nickName;
    }else{
        return self.nickName;
    }
}

-(NSString *)avatar
{
    NSString * friendAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager]getFriendAvatar:self.uid]];
    NSString * cacheAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:self.uid]];
    
//        //    NSLog(@"friendAvatar_\n%@\n--cacheAvatar_\n好友Avatar,cacheAvatar);
    
    if(self.uid != nil && cacheAvatar.length > 0)
    {
        return cacheAvatar;
    }
    else if (self.uid != nil && friendAvatar.length > 0)
    {
        return friendAvatar;
    }else{
        return _avatar;
    }
}
@end

@implementation Commentuser
-(NSString *)remark{
    NSString * memoName = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
    NSString * nickName = [[BiChatGlobal sharedManager]getFriendNickName:self.uid];
    
    if (memoName.length > 0) {
        return memoName;
    }else if (nickName.length > 0) {
        return nickName;
    }else{
        return self.nickName;
    }
}

-(NSString *)avatar
{
    NSString * friendAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager]getFriendAvatar:self.uid]];
    NSString * cacheAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:self.uid]];
    
//        //    NSLog(@"friendAvatar_\n%@\n--cacheAvatar_\n好友Avatar,cacheAvatar);
    
    if(self.uid != nil && cacheAvatar.length > 0)
    {
        return cacheAvatar;
    }
    else if (self.uid != nil && friendAvatar.length > 0)
    {
        return friendAvatar;
    }else{
        return _avatar;
    }
}
@end

@implementation ReplyUser
-(NSString *)remark{
    NSString * memoName = [[BiChatGlobal sharedManager]getFriendMemoName:self.uid];
    NSString * nickName = [[BiChatGlobal sharedManager]getFriendNickName:self.uid];
    
    if (memoName.length > 0) {
        return memoName;
    }else if (nickName.length > 0) {
        return nickName;
    }else{
        return self.nickName;
    }
}

-(NSString *)avatar
{
    NSString * friendAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager]getFriendAvatar:self.uid]];
    NSString * cacheAvatar = [DFLogicTool getImgWithStr:[[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:self.uid]];
    
//        //    NSLog(@"friendAvatar_\n%@\n--cacheAvatar_\n好友Avatar,cacheAvatar);
    
    if(self.uid != nil && cacheAvatar.length > 0)
    {
        return cacheAvatar;
    }
    else if (self.uid != nil && friendAvatar.length > 0)
    {
        return friendAvatar;
    }else{
        return _avatar;
    }
}
@end
