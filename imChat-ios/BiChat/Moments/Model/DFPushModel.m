//
//  DFPushModel.m
//  BiChat Dev
//
//  Created by chat on 2018/9/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFPushModel.h"

@implementation DFPushModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"content":@"DFContent"};//前边是字典中的Key名，后边是创建的类名
}

@end

@implementation DFContent

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




@implementation Comment
//+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper{
//    return @{@"ID":@"id"};
//}
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id"};//前边是你写的属性名，后边是字典中的取的Key名
}
@end

