//
//  WPPublicSearchResultModel.h
//  BiChat
//
//  Created by 张迅 on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPPublicSearchResultModel : NSObject

@property (nonatomic,strong)NSString *avatar;
@property (nonatomic,strong)NSString *desc;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *groupId;
@property (nonatomic,strong)NSString *groupName;
@property (nonatomic,strong)NSString *ownerUid;

//@property (nonatomic,strong)NSString *nickName;
//@property (nonatomic,strong)NSString *sort;
@property (nonatomic,strong)NSString *chatId;
@property (nonatomic,strong)NSString *groupUserCount;
@property (nonatomic,strong)NSString *publicAccountGroup;

@end
