//
//  DFYTKDBManager.m
//  BiChat Dev
//
//  Created by chat on 2018/9/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFYTKDBManager.h"

@implementation DFYTKDBManager
SingletonImplementation(DFYTKDBManager)

-(instancetype)init
{
    self = [super init];
    if(self){

    }
    return self;
}

//增加
+(void)saveMomentModel:(DFBaseMomentModel *)model
{
    NSDictionary * dic = [model mj_keyValues];
    [[DFYTKDBManager sharedInstance].store putObject:dic withId:model.message.momentId intoTable:MomentTab];
}

+(void)saveDFPushModel:(DFPushModel *)model
{
    NSDictionary * dic = [model mj_keyValues];
    [[DFYTKDBManager sharedInstance].store putObject:dic withId:model.dfContent.pushId intoTable:RemindTab];
}

//删除
+(void)deleteModelWithId:(NSString *)momentId fromeTab:(NSString *)tab
{
    [[DFYTKDBManager sharedInstance].store deleteObjectById:momentId fromTable:tab];
}

//获取
+(DFBaseMomentModel *)getModelwhitMomentId:(NSString *)momentId
{
    NSDictionary * modelDic = [[DFYTKDBManager sharedInstance].store getObjectById:momentId fromTable:MomentTab];
    DFBaseMomentModel * model = [DFBaseMomentModel mj_objectWithKeyValues:modelDic];
    return model;
}

//初次加载
-(void)getMomentFromUser
{
    _store = [[YTKKeyValueStore alloc] initDBWithName:[NSString stringWithFormat:@"%@.db",[BiChatGlobal sharedManager].uid]];
    [_store createTableWithName:MomentTab];
    [_store createTableWithName:RemindTab];
    [_store createTableWithName:IndexTab];
    [_store createTableWithName:OtherTab];
    
    [DFMomentsManager sharedInstance].ignoreMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
    
    NSArray * blockMeArr = [[DFYTKDBManager sharedInstance].store getObjectById:TabKey_BlockMeMomentArr fromTable:OtherTab];
    [DFMomentsManager sharedInstance].blockMeMomentArr = [NSMutableArray arrayWithArray:blockMeArr];
    
    
    NSArray * ytkArr = [[DFYTKDBManager sharedInstance].store getAllItemsFromTable:OtherTab];
    for (YTKKeyValueItem * item in ytkArr) {
        NSDictionary * objDic = item.itemObject;
        DFBaseMomentModel * model = [DFBaseMomentModel mj_objectWithKeyValues:objDic];
        if (model.message.momentId) {
            [[DFMomentsManager sharedInstance].allModel_dict setObject:model forKey:model.message.momentId];
        }
    }
    
    [DFYTKDBManager getArrAndDicFromeMomentTabWhtinIgnoreArr];
    [DFYTKDBManager getArrAndDicFromeRemindTab];
    [DFYTKDBManager getIndexFromeIndexTab];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ADD_REDNUM object:nil];
}

-(void)removeMomentFromeUser{
    _store = [[YTKKeyValueStore alloc] initDBWithName:[NSString stringWithFormat:@"%@.db",[BiChatGlobal sharedManager].uid]];
    [_store clearTable:MomentTab];
    [_store clearTable:RemindTab];
    [_store clearTable:IndexTab];
    [_store clearTable:OtherTab];
    [self getMomentFromUser];
}

//更新数据源
-(void)refreshModelArr{
    [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [DFMomentsManager sharedInstance].ignoreMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
        [DFYTKDBManager getArrAndDicFromeMomentTabWhtinIgnoreArr];
    }];
}

//获取所有RemindTab表内容
+(void)getArrAndDicFromeRemindTab{
    
    [[DFMomentsManager sharedInstance].remind_dict removeAllObjects];
    [[DFMomentsManager sharedInstance].remind_arr removeAllObjects];

    NSArray * ytkArr = [[DFYTKDBManager sharedInstance].store getAllItemsFromTable:RemindTab];
    
    NSMutableArray * modelArr = [NSMutableArray array];
    for (YTKKeyValueItem * item in ytkArr) {
        NSDictionary * objDic = item.itemObject;
        DFPushModel * model = [DFPushModel mj_objectWithKeyValues:objDic];

        [modelArr addObject:model];
        
        [[DFMomentsManager sharedInstance].remind_dict setObject:model forKey:model.dfContent.pushId];
    }
    
//    排序
    NSArray *resultArray = [modelArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        DFPushModel * per1 = obj1;
        DFPushModel * per2 = obj2;
        //时间计算
        if (per1.dfContent.ctime > per2.dfContent.ctime) {
            return NSOrderedAscending;//降序
        }
        else if (per1.dfContent.ctime < per2.dfContent.ctime)
        {
            return NSOrderedDescending;//升序
        }
        else
        {
            return NSOrderedSame;//相等
        }
    }];
    [[DFMomentsManager sharedInstance].remind_arr addObjectsFromArray:resultArray];
}

//获取所有MomentTab表内容
+(void)getArrAndDicFromeMomentTabWhtinIgnoreArr{
    
    [[DFMomentsManager sharedInstance].moment_dict removeAllObjects];
    [[DFMomentsManager sharedInstance].moment_arr removeAllObjects];
    
    NSArray * ytkArr = [[DFYTKDBManager sharedInstance].store getAllItemsFromTable:MomentTab];
    
    NSMutableArray * modelArr = [NSMutableArray array];
    
    NSMutableArray * userIdArr = [NSMutableArray arrayWithCapacity:10];
    if ([DFMomentsManager sharedInstance].ignoreMomentArr.count) {
        for (NSDictionary * ignoreDic in [DFMomentsManager sharedInstance].ignoreMomentArr) {
            [userIdArr addObject:[ignoreDic objectForKey:@"uid"]];
        }
    }

    for (YTKKeyValueItem * item in ytkArr) {
        NSDictionary * objDic = item.itemObject;
        DFBaseMomentModel * model = [DFBaseMomentModel mj_objectWithKeyValues:objDic];
        
        if ([userIdArr containsObject: model.message.createUser.uid]) {
//            NSLog(@"被我屏蔽用户，不加入缓存");
        }else{
            if ([[DFMomentsManager sharedInstance].blockMeMomentArr containsObject: model.message.createUser.uid])
            {
//                NSLog(@"屏蔽我的用户，不加入缓存");
            }else{
                [modelArr addObject:model];
            }
        }
        [[DFMomentsManager sharedInstance].moment_dict setObject:model forKey:model.message.momentId];
        [[DFMomentsManager sharedInstance].allModel_dict setObject:model forKey:model.message.momentId];
    }
    
    NSArray *resultArray = [modelArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        DFBaseMomentModel * per1 = obj1;
        DFBaseMomentModel * per2 = obj2;
        
        if (per1.message.ctime > per2.message.ctime) {
            return NSOrderedAscending;//降序
        }
        else if (per1.message.ctime < per2.message.ctime)
        {
            return NSOrderedDescending;//升序
        }
        else
        {
            return NSOrderedSame;//相等
        }
    }];
    
    [[DFMomentsManager sharedInstance].moment_arr addObjectsFromArray:resultArray];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
}

+(void)getIndexFromeIndexTab{
    
    NSInteger MomentnewIndex = [[[DFYTKDBManager sharedInstance].store getNumberById:@"loadNewIndex" fromTable:IndexTab] integerValue];
    [DFMomentsManager sharedInstance].loadNewIndex = (MomentnewIndex >= 0)?MomentnewIndex:0;
    
    NSInteger MomentmoreIndex = [[[DFYTKDBManager sharedInstance].store getNumberById:@"loadMoreIndex" fromTable:IndexTab] integerValue];
    [DFMomentsManager sharedInstance].loadMoreIndex = (MomentmoreIndex >= 0)?MomentmoreIndex:0;
    
    NSInteger newMomentRemindingCount = [[[DFYTKDBManager sharedInstance].store getNumberById:TabKey_NewMomentRemindingCount fromTable:IndexTab] integerValue];
    [DFMomentsManager sharedInstance].newMomentRemindingCount = (newMomentRemindingCount >= 0)?newMomentRemindingCount:0;
}

@end
