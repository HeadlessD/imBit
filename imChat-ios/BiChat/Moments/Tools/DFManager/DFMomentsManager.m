//
//  DFMomentsManager.m
//  BiChat Dev
//
//  Created by chat on 2018/8/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFMomentsManager.h"

@implementation DFMomentsManager
SingletonImplementation(DFMomentsManager)

-(instancetype)init
{
    self = [super init];
    if(self){
        _moment_dict = [[NSMutableDictionary alloc]initWithCapacity: 10];
        _moment_arr  = [[NSMutableArray alloc]initWithCapacity: 10];

        _remind_dict = [[NSMutableDictionary alloc]initWithCapacity: 10];
        _remind_arr  = [[NSMutableArray alloc]initWithCapacity: 10];
       
        _ignoreMomentArr  = [[NSMutableArray alloc]initWithCapacity: 10];
        _blockMeMomentArr = [[NSMutableArray alloc]initWithCapacity: 10];
        
        _userCover_dict = [[NSMutableDictionary alloc]initWithCapacity: 10];
        _allModel_dict = [[NSMutableDictionary alloc]initWithCapacity: 10];
        
        [DFMomentsManager sharedInstance].loadNewIndex = 0;
        [DFMomentsManager sharedInstance].loadMoreIndex = 0;
        
        [DFMomentsManager sharedInstance].isNewMomentRedPoint = NO;
        [DFMomentsManager sharedInstance].newMomentRemindingCount = 0;
    }
    return self;
}

+(void)clearMomentFromUser
{
    [[DFMomentsManager sharedInstance].moment_arr removeAllObjects];
    [[DFMomentsManager sharedInstance].moment_dict removeAllObjects];

    [[DFMomentsManager sharedInstance].remind_arr removeAllObjects];
    [[DFMomentsManager sharedInstance].remind_dict removeAllObjects];
    
    [[DFMomentsManager sharedInstance].ignoreMomentArr removeAllObjects];
    [[DFMomentsManager sharedInstance].blockMeMomentArr removeAllObjects];
    
    [[DFMomentsManager sharedInstance].allModel_dict removeAllObjects];
    
    [DFMomentsManager sharedInstance].loadNewIndex = 0;
    [DFMomentsManager sharedInstance].loadMoreIndex = 0;
    
    [DFMomentsManager sharedInstance].isNewMomentRedPoint = NO;
    [DFMomentsManager sharedInstance].newMomentRemindingCount = 0;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
}

#pragma mark 存MomentModel缓存
+(void)insertMomentModel:(DFBaseMomentModel *)momentModel atTopOrBottom:(NSString *)ToB{
    
    [DFMomentsManager addMediasFromeModel:momentModel];
    [self getLikeOrNotLike:momentModel];
    
    NSString *key = momentModel.message.momentId;
    if ([[DFMomentsManager sharedInstance].moment_dict objectForKey:key]==nil) {
        if ([ToB isEqualToString:@"top"]) {
            [[DFMomentsManager sharedInstance].moment_arr insertObject:momentModel atIndex:0];
            [[DFMomentsManager sharedInstance].moment_dict setObject:momentModel forKey:key];
        }else if ([ToB isEqualToString:@"bottom"]){
            [[DFMomentsManager sharedInstance].moment_arr insertObject:momentModel atIndex:[DFMomentsManager sharedInstance].moment_arr.count];
            [[DFMomentsManager sharedInstance].moment_dict setObject:momentModel forKey:key];
        }else{
            //如果接收的要插入的数据还没有获取过 不作处理
        }
    }else{
        DFBaseMomentModel * preItem = [[DFMomentsManager sharedInstance].moment_dict objectForKey:key];
        if (preItem.message.momentId) {
            NSInteger index = 0;
            
            for (DFBaseMomentModel * blModel in [DFMomentsManager sharedInstance].moment_arr) {
                if ([blModel.message.momentId isEqualToString:preItem.message.momentId]) {
                    index = [[DFMomentsManager sharedInstance].moment_arr indexOfObject:blModel];
                }
            }
            [[DFMomentsManager sharedInstance].moment_arr replaceObjectAtIndex:index withObject:momentModel];
            [[DFMomentsManager sharedInstance].moment_dict setObject:momentModel forKey:key];
        }
    }
        //    NSLog(@"插入结束");
}

#pragma mark 存remind缓存
+(void)insertDFPushModel:(DFPushModel *)pushModel{
    
    NSString *key = pushModel.dfContent.pushId;
    if ([[DFMomentsManager sharedInstance].remind_dict objectForKey:key]==nil) {
        [[DFMomentsManager sharedInstance].remind_arr insertObject:pushModel atIndex:0];
        
        [[DFMomentsManager sharedInstance].remind_dict setObject:pushModel forKey:key];
    }else{
        DFPushModel * preItem = [[DFMomentsManager sharedInstance].remind_dict objectForKey:key];
        if (preItem.dfContent.pushId) {
            BOOL haveThis = NO;
            
            NSInteger index = 0;
            for (DFBaseMomentModel * blModel in [DFMomentsManager sharedInstance].moment_arr) {
                if ([blModel.message.momentId isEqualToString:preItem.dfContent.pushId]) {
                    haveThis = YES;
                    index = [[DFMomentsManager sharedInstance].remind_arr indexOfObject:blModel];
                }
            }
            if (haveThis) {
                [[DFMomentsManager sharedInstance].remind_arr replaceObjectAtIndex:index withObject:pushModel];
                [[DFMomentsManager sharedInstance].remind_dict setObject:pushModel forKey:key];
            }
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADREMIND object:nil];
    [DFYTKDBManager saveDFPushModel:pushModel];
}
#pragma mark  取缓存
+(DFBaseMomentModel *)getMomentModelWithMomentId:(NSString *)momentId
{
    return [[DFMomentsManager sharedInstance].moment_dict objectForKey:momentId];
}

+(DFPushModel *)getRemindModelWithRemindId:(NSString *)remindId
{
    return [[DFMomentsManager sharedInstance].remind_dict objectForKey:remindId];
}

#pragma mark  删除动态
+(void)deleteModelWithMomentId:(NSString *)momentId{
    [[DFMomentsManager sharedInstance].moment_arr enumerateObjectsUsingBlock:^(DFBaseMomentModel * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.message.momentId isEqualToString:momentId]) {
            *stop = YES;
            if (*stop == YES) {
                [[DFMomentsManager sharedInstance].moment_arr removeObject:obj];
                [[DFMomentsManager sharedInstance].moment_dict removeObjectForKey:momentId];
                [DFYTKDBManager deleteModelWithId:momentId fromeTab:MomentTab];
            }
        }
        if (*stop) {
                //    NSLog(@"array is dataSource");
        }
    }];
}

#pragma mark  更新一条动态
+(void)updateModelWithMomentId:(NSString *)momentId withType:(NSInteger)pushType success:(updateSuccess)success
{
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/getMessage.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":momentId} success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            
            NSDictionary * dataDic = [response objectForKey:@"data"];
            DFBaseMomentModel * pushModel = [DFBaseMomentModel mj_objectWithKeyValues:dataDic];
                //    NSLog(@"——————推送共%lu条",(unsigned long)pushModel.commentList.count);
            
            pushModel.cellHeightChange = YES;
            
            [DFMomentsManager addMediasFromeModel:pushModel];
            [self getLikeOrNotLike:pushModel];

            NSString *key = pushModel.message.momentId;
            if ([[DFMomentsManager sharedInstance].moment_dict objectForKey:key]==nil) {
                if ((pushType == MOMENT_TYPE_NEW)) {
//                    [DFMomentsManager insertMomentModel:pushModel atTopOrBottom:@"top"];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
                    
                    [DFYTKDBManager getArrAndDicFromeMomentTabWhtinIgnoreArr];
                }
            }else{
                DFBaseMomentModel * locationItem = [[DFMomentsManager sharedInstance].moment_dict objectForKey:key];
                
//                if (((pushType == MOMENT_TYPE_ADDCOMMENT)   && (locationItem.commentList.count <= pushModel.commentList.count)) |((pushType == MOMENT_TYPE_DELETECOMMENT)&& (locationItem.commentList.count >= pushModel.commentList.count))||
//                    ((pushType == MOMENT_TYPE_PRAISE)       && (locationItem.praiseList.count  <= pushModel.praiseList.count)) ||
//                    ((pushType == MOMENT_TYPE_PRAISEUNDO)   && (locationItem.praiseList.count  >= pushModel.praiseList.count)))
//                {
                    if (locationItem.message.momentId) {
                        NSInteger index = 0;
                        for (DFBaseMomentModel * blModel in [DFMomentsManager sharedInstance].moment_arr) {
                            if ([blModel.message.momentId isEqualToString:locationItem.message.momentId]) {
                                index = [[DFMomentsManager sharedInstance].moment_arr indexOfObject:blModel];
                            }
                        }
                        [[DFMomentsManager sharedInstance].moment_arr replaceObjectAtIndex:index withObject:pushModel];
                        [[DFMomentsManager sharedInstance].moment_dict setObject:pushModel forKey:key];
                        
                        [DFYTKDBManager saveMomentModel:pushModel];//存库

                        success(pushModel , @"1");
                        NSMutableDictionary * notiDic = [NSMutableDictionary dictionary];
                        [notiDic setObject:pushModel forKey:NOTI_MOMENT_TYPE_UPDATEMOMENT];
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_UPDATEMOMENT object:notiDic];
                    }
//                }else{
//                        //    NSLog(@"数量对应不上，不入库");
//                }
            }
            
            [[DFMomentsManager sharedInstance].allModel_dict setObject:pushModel forKey:pushModel.message.momentId];

            [[DFYTKDBManager sharedInstance].store putObject:[pushModel mj_keyValues] withId:pushModel.message.momentId intoTable:OtherTab];
        }
    } failure:^(NSError *error) {
            //    NSLog(@"%@",error);
    }];
}

#pragma mark  点赞
+(void)addlikeTestWithModel:(DFBaseMomentModel *)model IsPrais:(BOOL)isPrais{
    
    if (model.message.isPrais) {
        //改为未点赞状态
        model.message.isPrais = NO;
        //移除点赞
        [model.praiseList enumerateObjectsUsingBlock:^(PraiseModel * pra, NSUInteger idx, BOOL *stop) {
            
            if ([pra.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
                *stop = YES;
                if (*stop == YES)[model.praiseList removeObject:pra];
            }
            if (*stop) {
                    //    NSLog(@"array is dataSource");
            }
        }];
    }else{
        //改为点赞状态
        model.message.isPrais = YES;
        PraiseModel *likeItem = [[PraiseModel alloc] init];
        likeItem.uid = [BiChatGlobal sharedManager].uid;
        likeItem.nickName = [BiChatGlobal sharedManager].nickName;
        likeItem.avatar = [BiChatGlobal sharedManager].avatar;
        [model.praiseList insertObject:likeItem atIndex:model.praiseList.count];
    }
    model.cellHeightChange = YES;
}

#pragma mark  删除评论
+(void)deleteCommentWithMomentId:(NSString*)momentId commentId:(NSString*)commentId
{
    DFBaseMomentModel * model = [self getMomentModelWithMomentId:momentId];
    
    [model.commentList enumerateObjectsUsingBlock:^(CommentModel * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.commentId isEqualToString:commentId]) {
            *stop = YES;
            if (*stop == YES) {
                [model.commentList removeObject:obj];
                model.cellHeightChange = YES;
                [DFYTKDBManager saveMomentModel:model];//删除评论
            }
        }
        if (*stop) {
                //    NSLog(@"array is arr");
        }
    }];
}

#pragma mark  工具方法
+(void)getLikeOrNotLike:(DFBaseMomentModel *) item{
    //点赞查询处理
    if (item.praiseList.count) {
        for (PraiseModel * pra in item.praiseList) {
            if ([pra.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
                item.message.isPrais = YES;
            }
        }
    }
}

+(void)addMediasFromeModel:(DFBaseMomentModel *)model{
    
    if (model.message.type != MomentSendType_Image) {
        return;
    }
    
    if (model.itthumbImages.count != 0 && model.itsrcImages.count != 0) {
        return;
    }
    NSMutableArray * medias_displayArr = [NSMutableArray array];
    NSMutableArray * medias_thumbArr = [NSMutableArray array];
    
    //图片赋值处理
    if (model.message.mediasList.count && model.message.type == MomentSendType_Image) {
        for (NSDictionary * imgDic in model.message.mediasList) {
            [medias_displayArr addObject:[DFLogicTool getImgWithStr:[imgDic objectForKey:@"medias_display"]]];
            [medias_thumbArr addObject:[DFLogicTool getImgWithStr:[imgDic objectForKey:@"medias_thumb"]]];
        }
    }
//    else if (model.message.mediasList.count && model.message.type == MomentSendType_Video){
//        NSDictionary * videoDic = model.message.mediasList[0];
//        [medias_displayArr addObject:[DFLogicTool getImgWithStr:[videoDic objectForKey:@"medias_display"]]];
//        [medias_thumbArr addObject:[DFLogicTool getImgWithStr:[videoDic objectForKey:@"medias_thumb"]]];
//    }
    
    //点击查看大图
    model.itsrcImages = medias_displayArr;
    //略缩图
    model.itthumbImages = medias_thumbArr;
}

-(void)relayNetworkState:(NSInteger)networkState
{
    //网络联通
    if (networkState == 200)
        _networkDisconnected = NO;
    
    //网络断开
    else if (networkState == 500 ||
             networkState == 300)
        _networkDisconnected = YES;
}

+(void)saveIndexWith:(NSInteger)index{
    NSInteger new = [DFMomentsManager sharedInstance].loadNewIndex;
    NSInteger more = [DFMomentsManager sharedInstance].loadMoreIndex;
    
    if (new == 0 || new < index) {
        [DFMomentsManager sharedInstance].loadNewIndex = index;
    }
    if (more == 0 || more > index) {
        [DFMomentsManager sharedInstance].loadMoreIndex = index;
    }
}

@end
