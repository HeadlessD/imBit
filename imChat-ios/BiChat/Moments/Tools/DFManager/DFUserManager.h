//
//  DFUserManager.h
//  BiChat Dev
//
//  Created by chat on 2018/8/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFBaseMomentModel.h"

@interface DFUserManager : NSObject
SingletonInterface(DFUserManager)

typedef void (^ userUpdateSuccess)(NSString * successStr);
@property (nonatomic , copy) updateSuccess successBlock;

@property (nonatomic,strong) NSMutableDictionary * moment_dict;
@property (nonatomic,strong) NSMutableArray      * moment_arr;

@property (nonatomic,strong) NSMutableDictionary * user_dict;
@property (nonatomic,strong) NSMutableArray      * user_arr;

@property (nonatomic,assign) NSInteger  loadNewIndex;
@property (nonatomic,assign) NSInteger  loadMoreIndex;

@property (nonatomic,assign) BOOL isNewMoment;

//存缓存
+(void)insertModel:(DFBaseMomentModel *)momentModel atTopOrBottom:(NSString *)ToB;
//取缓存
+(DFBaseMomentModel *)getModelWithMomentId:(NSString *)momentId;
//删缓存
+(void)deleteModelWithMomentId:(NSString *)momentId;
//改缓存
+(void)updateModelWithMomentId:(NSString *)momentId success:(userUpdateSuccess)success;

//点赞
+(void)addlikeTestWithModel:(DFBaseMomentModel *)model IsPrais:(BOOL)isPrais;
//发评论
+(void)sendCommentWithReplyUser:(Commentuser *)replyUser momentModel:(DFBaseMomentModel *)momentModel Content:(NSString *)content;
//删评论
+(void)deleteCommentWithMomentId:(NSString*)momentId commentId:(NSString*)commentId;
//发布动态


+(void)getLikeOrNotLike:(DFBaseMomentModel *) item;
+(void)addMediasFromeModel:(DFBaseMomentModel *)model;

+(void)momentClear;

+(NSMutableAttributedString *)getLikeAttSstr:(DFBaseMomentModel *) item;
+(NSMutableAttributedString *)getCommentAttStr:(CommentModel *)comment;

@end
