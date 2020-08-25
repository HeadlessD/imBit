//
//  DFMomentsManager.h
//  BiChat Dev
//
//  Created by chat on 2018/8/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFBaseMomentModel.h"
#import "DFPushModel.h"

@interface DFMomentsManager : NSObject
SingletonInterface(DFMomentsManager)

typedef void (^ updateSuccess)(DFBaseMomentModel * model , NSString * successStr);
@property (nonatomic , copy) updateSuccess successBlock;

@property (nonatomic,strong) NSMutableDictionary * moment_dict;
@property (nonatomic,strong) NSMutableArray      * moment_arr;

@property (nonatomic,strong) NSMutableDictionary * remind_dict;
@property (nonatomic,strong) NSMutableArray      * remind_arr;

@property (nonatomic,strong) NSMutableArray * ignoreMomentArr;
@property (nonatomic,strong) NSMutableArray * blockMeMomentArr;

@property (nonatomic,strong) NSMutableDictionary * userCover_dict;

@property (nonatomic,strong) NSMutableDictionary * allModel_dict;


@property (nonatomic,assign) NSInteger  loadNewIndex;
@property (nonatomic,assign) NSInteger  loadMoreIndex;

@property (nonatomic,assign) NSInteger newMomentRemindingCount;

@property (nonatomic,copy) NSString * momentRedAvatar;
@property (nonatomic,copy) NSString * momentRedName;
@property (nonatomic,assign) BOOL isNewMomentRedPoint;

@property (nonatomic, assign) BOOL networkDisconnected;


//存缓存
+(void)insertMomentModel:(DFBaseMomentModel *)momentModel atTopOrBottom:(NSString *)ToB;
+(void)insertDFPushModel:(DFPushModel *)pushModel;

//取缓存
+(DFBaseMomentModel *)getMomentModelWithMomentId:(NSString *)momentId;
+(DFPushModel *)getRemindModelWithRemindId:(NSString *)remindId;

//删缓存
+(void)deleteModelWithMomentId:(NSString *)momentId;
//改缓存
+(void)updateModelWithMomentId:(NSString *)momentId withType:(NSInteger)pushType success:(updateSuccess)success;
//点赞
+(void)addlikeTestWithModel:(DFBaseMomentModel *)model IsPrais:(BOOL)isPrais;
//删评论
+(void)deleteCommentWithMomentId:(NSString*)momentId commentId:(NSString*)commentId;

+(void)getLikeOrNotLike:(DFBaseMomentModel *) item;
+(void)addMediasFromeModel:(DFBaseMomentModel *)model;

+(void)clearMomentFromUser;

-(void)relayNetworkState:(NSInteger)networkState;



+(void)saveIndexWith:(NSInteger)index;


@end
