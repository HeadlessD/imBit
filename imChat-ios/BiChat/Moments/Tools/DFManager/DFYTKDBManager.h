//
//  DFYTKDBManager.h
//  BiChat Dev
//
//  Created by chat on 2018/9/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFYTKDBManager : NSObject
SingletonInterface(DFYTKDBManager)

@property (nonatomic,strong) YTKKeyValueStore * store;
@property (nonatomic,strong) NSMutableArray * moment_kvArr;

+(void)saveMomentModel:(DFBaseMomentModel *)model;
+(void)saveDFPushModel:(DFPushModel *)model;

+(void)deleteModelWithId:(NSString *)momentId fromeTab:(NSString *)tab;
+(DFBaseMomentModel *)getModelwhitMomentId:(NSString *)momentId;

-(void)getMomentFromUser;
+(void)getArrAndDicFromeMomentTabWhtinIgnoreArr;
+(void)getIndexFromeIndexTab;

-(void)refreshModelArr;
-(void)removeMomentFromeUser;

@end
