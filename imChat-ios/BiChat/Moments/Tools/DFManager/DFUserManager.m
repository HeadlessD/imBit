//
//  DFUserManager.m
//  BiChat Dev
//
//  Created by chat on 2018/8/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFUserManager.h"

@implementation DFUserManager
SingletonImplementation(DFUserManager)


-(instancetype)init
{
    self = [super init];
    if(self){

        _user_dict = [[NSMutableDictionary alloc]initWithCapacity: 10];
        _user_arr  = [[NSMutableArray alloc]initWithCapacity: 10];
        
        _isNewMoment = NO;
        
        [DFUserManager sharedInstance].loadNewIndex = 0;
        [DFUserManager sharedInstance].loadMoreIndex = 0;
    }
    return self;
}

+(void)momentClear
{
    [[DFUserManager sharedInstance].user_arr removeAllObjects];
    [[DFUserManager sharedInstance].user_dict removeAllObjects];
    
    [DFUserManager sharedInstance].loadNewIndex = 0;
    [DFUserManager sharedInstance].loadMoreIndex = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MomentReloadData" object:nil];
}

#pragma mark  存缓存
+(void)insertModel:(DFBaseMomentModel *)momentModel atTopOrBottom:(NSString *)ToB{
    
    [DFUserManager addMediasFromeModel:momentModel];
    [self getLikeOrNotLike:momentModel];
    
    NSString *key = momentModel.message.momentId;
    if ([[DFUserManager sharedInstance].user_dict objectForKey:key]==nil) {
        if ([ToB isEqualToString:@"top"]) {
            [[DFUserManager sharedInstance].user_arr insertObject:momentModel atIndex:0];
            [[DFUserManager sharedInstance].user_dict setObject:momentModel forKey:key];
        }else if ([ToB isEqualToString:@"bottom"]){
            [[DFUserManager sharedInstance].user_arr insertObject:momentModel atIndex:[DFUserManager sharedInstance].user_arr.count];
            [[DFUserManager sharedInstance].user_dict setObject:momentModel forKey:key];
        }else{
            //如果接收的要插入的数据还没有获取过 不作处理
        }
    }else{
        DFBaseMomentModel * preItem = [[DFUserManager sharedInstance].user_dict objectForKey:key];
        NSUInteger index = [[DFUserManager sharedInstance].user_arr indexOfObject:preItem];
        [[DFUserManager sharedInstance].user_arr replaceObjectAtIndex:index withObject:momentModel];
        [[DFUserManager sharedInstance].user_dict setObject:momentModel forKey:key];
    }
}
#pragma mark  取缓存
+(DFBaseMomentModel *)getModelWithMomentId:(NSString *)momentId
{
    return [[DFUserManager sharedInstance].user_dict objectForKey:momentId];
}

#pragma mark  删除动态
+(void)deleteModelWithMomentId:(NSString *)momentId{
    [[DFUserManager sharedInstance].user_arr enumerateObjectsUsingBlock:^(DFBaseMomentModel * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.message.momentId isEqualToString:momentId]) {
            *stop = YES;
            if (*stop == YES) {
                [[DFUserManager sharedInstance].user_arr removeObject:obj];
            }
        }
        if (*stop) {
            NSLog(@"array is dataSource");
        }
    }];
}

#pragma mark  更新一条动态
+(void)updateModelWithMomentId:(NSString *)momentId success:(userUpdateSuccess)success
{
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/getMessage.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":momentId} success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            NSDictionary * dataDic = [response objectForKey:@"data"];
            DFBaseMomentModel * itModel = [DFBaseMomentModel mj_objectWithKeyValues:dataDic];
            if (itModel.message.mediasList.count == 1) {
                NSDictionary * imgDic = itModel.message.mediasList[0];
                if ([imgDic objectForKey:@"oneImgWidth"] && [imgDic objectForKey:@"oneImgHeight"]) {
                    itModel.mmwidth =  [[imgDic objectForKey:@"oneImgWidth"] integerValue];
                    itModel.mmheight = [[imgDic objectForKey:@"oneImgHeight"] integerValue];
                }
            }
            [DFUserManager insertModel:itModel atTopOrBottom:nil];
            [DFYTKDBManager saveModel:itModel];//获取
            success(@"1");
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
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
                NSLog(@"array is dataSource");
            }
        }];
    }else{
        //改为点赞状态
        model.message.isPrais = YES;
        
        PraiseModel *likeItem = [[PraiseModel alloc] init];
        likeItem.uid = [BiChatGlobal sharedManager].uid;
        likeItem.nickName = [BiChatGlobal sharedManager].nickName;
        likeItem.avatar = [BiChatGlobal sharedManager].avatar;
        [model.praiseList insertObject:likeItem atIndex:0];
    }
    model.cellHeight = 0;
    [self getLikeOrNotLike:model];
}

#pragma mark  添加评论
+(void)sendCommentWithReplyUser:(Commentuser *)replyUser momentModel:(DFBaseMomentModel *)momentModel Content:(NSString *)content
{
    CommentModel *commentItem = [[CommentModel alloc] init];
    commentItem.ctime = [[NSDate date] timeIntervalSince1970]*1000;
    commentItem.commentId = [NSString stringWithFormat:@"%d",arc4random()%100000];
    commentItem.commentUser = [[Commentuser alloc]init];
    commentItem.commentUser.uid = [BiChatGlobal sharedManager].uid;
    commentItem.commentUser.nickName = [BiChatGlobal sharedManager].nickName;
    commentItem.commentUser.avatar = [BiChatGlobal sharedManager].avatar;
    commentItem.content = content;
    
    if (replyUser.uid > 0) {
        commentItem.replyUser = [[ReplyUser alloc]init];
        commentItem.replyUser.uid = replyUser.uid;
        commentItem.replyUser.nickName = replyUser.nickName;
    }
    [momentModel.commentList addObject:commentItem];
    momentModel.cellHeight = 0;
}

#pragma mark  删除评论
+(void)deleteCommentWithMomentId:(NSString*)momentId commentId:(NSString*)commentId
{
    DFBaseMomentModel * model = [self getModelWithMomentId:momentId];
    
    [model.commentList enumerateObjectsUsingBlock:^(CommentModel * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.commentId isEqualToString:commentId]) {
            *stop = YES;
            if (*stop == YES) {
                [model.commentList removeObject:obj];
                model.cellHeightChange = YES;
                [DFYTKDBManager saveModel:model];//删除评论
            }
        }
        if (*stop) {
            NSLog(@"array is arr");
        }
    }];
}

#pragma mark  发布动态


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
    
    if (model.itthumbImages.count != 0 && model.itsrcImages.count != 0) {
        return;
    }
    NSMutableArray * medias_displayArr = [NSMutableArray array];
    NSMutableArray * medias_thumbArr = [NSMutableArray array];
    
    //图片赋值处理
    if (model.message.mediasList.count) {
        for (NSDictionary * imgDic in model.message.mediasList) {
            [medias_displayArr addObject:[DFLogicTool getImgWithStr:[imgDic objectForKey:@"medias_display"]]];
            [medias_thumbArr addObject:[DFLogicTool getImgWithStr:[imgDic objectForKey:@"medias_thumb"]]];
        }
    }
    
    //原图（未用）
    model.itthumbPreviewImages  = medias_displayArr;
    //点击查看大图
    model.itsrcImages = medias_displayArr;
    //略缩图
    model.itthumbImages = medias_thumbArr;
}

+(NSMutableAttributedString *)getLikeAttSstr:(DFBaseMomentModel *) item
{
    if (item.praiseList.count == 0) {
        return nil;
    }
    
    NSMutableArray *praiseList = item.praiseList;
    NSString *result = @"";
    
    for (int i=0; i<praiseList.count;i++) {
        PraiseModel *like = [praiseList objectAtIndex:i];
        if (i == 0) {
            result = [NSString stringWithFormat:@"%@",like.nickName];
        }else{
            result = [NSString stringWithFormat:@"%@, %@", result, like.nickName];
        }
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:result];
    NSUInteger position = 0;
    for (int i=0; i<praiseList.count;i++) {
        PraiseModel *like = [praiseList objectAtIndex:i];
        [attrStr addAttribute:NSLinkAttributeName value:like.uid range:NSMakeRange(position, like.nickName.length)];
        position += like.nickName.length+2;
    }
    return attrStr;
}

+(NSMutableAttributedString *)getCommentAttStr:(CommentModel *)comment
{
    NSString *resultStr;
    if (comment.replyUser.uid == 0) {
        resultStr = [NSString stringWithFormat:@"%@: %@",comment.commentUser.nickName, comment.content];
    }else{
        resultStr = [NSString stringWithFormat:@"%@回复%@: %@",comment.commentUser.nickName, comment.replyUser.nickName, comment.content];
    }
    
    NSMutableAttributedString *commentStr = [[NSMutableAttributedString alloc]initWithString:resultStr];
    if (comment.replyUser.uid == 0) {
        [commentStr addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"%@",comment.commentUser.uid] range:NSMakeRange(0, comment.commentUser.nickName.length)];
        
        NSRange otherRange = [resultStr rangeOfString:comment.commentUser.nickName];
        
        [commentStr yy_setFont:DFFont_LikeLabelFont_14B range:otherRange];
        
    }else{
        NSUInteger localPos = 0;
        [commentStr addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"%@",comment.commentUser.uid] range:NSMakeRange(localPos, comment.commentUser.nickName.length)];
        localPos += comment.commentUser.nickName.length + 2;
        [commentStr addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"%@",comment.replyUser.uid] range:NSMakeRange(localPos, comment.replyUser.nickName.length)];
        
        NSRange otherRange = [resultStr rangeOfString:comment.commentUser.nickName];
        NSRange otherRange2 = [resultStr rangeOfString:comment.replyUser.nickName];
        
        [commentStr yy_setFont:DFFont_LikeLabelFont_14B range:otherRange];
        [commentStr yy_setFont:DFFont_LikeLabelFont_14B range:otherRange2];
    }
    return commentStr;
}

@end
