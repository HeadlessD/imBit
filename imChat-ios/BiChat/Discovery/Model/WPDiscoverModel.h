//
//  WPDiscoverModel.h
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPDiscoverModel : NSObject

@property (nonatomic,strong)NSString *score;
@property (nonatomic,strong)NSArray *imgs;
@property (nonatomic,strong)NSString *author;
@property (nonatomic,strong)NSArray *words;
@property (nonatomic,strong)NSString *weight;
@property (nonatomic,strong)NSString *ctime;
//新闻id
@property (nonatomic,strong)NSString *newsid;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,assign)NSString *type;
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *desc;
@property (nonatomic,strong)NSString *tag;
//公号
@property (nonatomic,strong)NSString *pubname;
//公号名称
@property (nonatomic,strong)NSString *pubnickname;
//公号id32位
@property (nonatomic,strong)NSString *pubid;
@property (nonatomic,strong)NSString *subtype;

@property (nonatomic,strong)NSString *htmlString;
//已读
@property (nonatomic,assign)BOOL hasRead;

//缩略图
@property (nonatomic,strong)NSString *thumbnail;
//描述，用于分享，不可通过网络获取
@property (nonatomic,strong)NSString *desString;
//分享类型
@property (nonatomic,strong)NSString *shareType;
//广告链接
@property (nonatomic,strong)NSString *link;

@end
