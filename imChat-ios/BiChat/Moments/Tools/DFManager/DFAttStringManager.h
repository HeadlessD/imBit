//
//  DFAttStringManager.h
//  BiChat Dev
//
//  Created by chat on 2018/10/27.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFAttStringManager : NSObject
SingletonInterface(DFAttStringManager)

+(NSMutableAttributedString *)getCommentAttStr:(CommentModel *)comment;

+(NSMutableAttributedString *)getNSAttributedStringWithModel:(CommentModel *)model;

+(NSMutableAttributedString *)getLikeAttSstr:(DFBaseMomentModel *) item;

+(CGRect)getHeightWithContent:(NSMutableAttributedString *)str withWidth:(CGFloat)width;


+(NSMutableAttributedString*)subStr:(NSString *)string;
+(NSMutableArray*)getUrlArrWithSr:(NSString *)string;
+(NSMutableArray*)getUrlRangArrWithSr:(NSString *)string;
+(NSMutableAttributedString * )getUrlAttOnAtt:(NSMutableAttributedString *)att;


@end
