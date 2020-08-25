//
//  DFAttStringManager.m
//  BiChat Dev
//
//  Created by chat on 2018/10/27.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "DFAttStringManager.h"

@implementation DFAttStringManager
SingletonImplementation(DFAttStringManager)

//获取首页评论富文本
+(NSMutableAttributedString *)getCommentAttStr:(CommentModel *)comment
{
    
    NSString *resultStr;
    if (comment.replyUser.uid == 0) {
        resultStr = [NSString stringWithFormat:@"%@: %@",comment.commentUser.remark, comment.content];
    }else{
        resultStr = [NSString stringWithFormat:@"%@ %@ %@: %@",comment.commentUser.remark,LLSTR(@"104014") ,comment.replyUser.remark, comment.content];
    }
    
    NSMutableAttributedString * commentStrold = [resultStr DFTransEmotionWithFont:DFFont_Comment_14];
    NSMutableAttributedString * commUserRemark = [comment.commentUser.remark DFTransEmotionWithFont:DFFont_Comment_14];
    NSMutableAttributedString * commReplRemark = [comment.replyUser.remark DFTransEmotionWithFont:DFFont_Comment_14];
    
    NSMutableAttributedString * commentStr = [DFAttStringManager getUrlAttOnAtt:commentStrold];

    [commentStr addAttributes:@{NSLinkAttributeName:[NSString stringWithFormat:@"userId%@",comment.commentUser.uid],NSFontAttributeName:DFFont_LikeLabelFont_14B} range:NSMakeRange(0, commUserRemark.length)];
    
    if (comment.replyUser.uid) {
        NSUInteger localPos = commUserRemark.length + LLSTR(@"104014").length+2;
        [commentStr addAttributes:@{NSLinkAttributeName:[NSString stringWithFormat:@"userId%@",comment.replyUser.uid],NSFontAttributeName:DFFont_LikeLabelFont_14B} range:NSMakeRange(localPos, commReplRemark.length)];
    }
    return commentStr;
}

//获取详情评论
+(NSMutableAttributedString *)getNSAttributedStringWithModel:(CommentModel *)model{
    NSString * comStr = @"";
    if (model.replyUser) {
        comStr = [NSString stringWithFormat:@"%@ %@: %@",LLSTR(@"104014"),model.replyUser.remark, model.content];
    }else{
        comStr = model.content;
    }
    NSMutableAttributedString * commentStrold = [comStr DFTransEmotionWithFont:DFFont_Comment_14];
    
    NSMutableAttributedString * commentStr = [DFAttStringManager getUrlAttOnAtt:commentStrold];

    NSMutableAttributedString * replyUserAtt = [model.replyUser.remark DFTransEmotionWithFont:DFFont_Comment_14];
    
    if (model.replyUser) {
        //        NSMutableAttributedString * repRemark = [model.replyUser.remark DFTransEmotionWithFont:DFFont_Comment_14];
//        NSRange otherRange = [comStr rangeOfString:model.replyUser.remark];
        [commentStr addAttributes:@{NSLinkAttributeName:[NSString stringWithFormat:@"userId%@",model.replyUser.uid],NSFontAttributeName:DFFont_LikeLabelFont_14B} range:NSMakeRange(LLSTR(@"104014").length+1, replyUserAtt.length)];
    }
    return commentStr;
}

+(NSMutableAttributedString * )getUrlAttOnAtt:(NSMutableAttributedString *)att{
    if (!att || !att.string) {
        return nil;
    }
    NSMutableArray * urlArr = [DFAttStringManager getUrlArrWithSr:att.string];
//    NSMutableArray * urlRangArr = [DFAttStringManager getUrlRangArrWithSr:str];
    if (urlArr.count > 0 ) {
        for (int i = 0; i < urlArr.count; i++) {
            NSRange url1Rang = [att.string rangeOfString:urlArr[i]];
            //                //    NSLog(@"url1Rang_%@",NSStringFromRange(url1Rang));
            //                //    NSLog(@"urlRangArr-i_%@",[NSString stringWithFormat:@"%@",urlRangArr[i]]);
            if ((url1Rang.location + url1Rang.length) > att.length) {
                if (url1Rang.location > att.length) {
                    url1Rang = NSMakeRange(0, 0);
                }else{
                    url1Rang.length = att.length - url1Rang.location;
                }
            }
            [att addAttributes:@{NSLinkAttributeName:[NSString stringWithFormat:@"url%@",urlArr[i]],NSFontAttributeName:DFFont_LikeLabelFont_14B} range:url1Rang];
        }
    }
    return att;
}

//获取点赞富文本
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
            result = [NSString stringWithFormat:@"%@",like.remark];
        }else{
            result = [NSString stringWithFormat:@"%@, %@", result, like.remark];
        }
    }
    //    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:result];
    NSMutableAttributedString * attrStr = [result DFTransEmotionWithFont:DFFont_Comment_14];
    
    NSUInteger position = 0;
    
    for (int i=0; i<praiseList.count;i++) {
        PraiseModel *like = [praiseList objectAtIndex:i];
        
        NSMutableAttributedString * likeRemarkAtt = [like.remark DFTransEmotionWithFont:DFFont_Comment_14];
        
        if (likeRemarkAtt.length > attrStr.length) {
            
        }else{
            [attrStr addAttributes:@{NSLinkAttributeName:[NSString stringWithFormat:@"userId%@",like.uid],NSFontAttributeName:DFFont_LikeLabelFont_14B} range:NSMakeRange(position, likeRemarkAtt.length)];
            
            position += likeRemarkAtt.length+2;
        }
    }
    return attrStr;
}

+(CGRect)getHeightWithContent:(NSMutableAttributedString *)str withWidth:(CGFloat)width
{
    //计算文本的大小

    CGRect rect4Content = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect4Content;
}

+(NSMutableAttributedString*)subStr:(NSString *)string
{
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *urlArr=[[NSMutableArray alloc]init];
    NSMutableArray *rangeArr=[[NSMutableArray alloc]init];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [urlArr addObject:substringForMatch];
    }
    NSString *subStr=string;
    for (NSString *str in urlArr) {
        
        NSRange searchRange = NSMakeRange(0, [subStr length]);
        NSRange range;
        if ((range = [subStr rangeOfString:str options:0 range:searchRange]).location != NSNotFound) {
            searchRange = NSMakeRange(NSMaxRange(range), [subStr length] - NSMaxRange(range));
        }
        [rangeArr addObject:[NSValue valueWithRange:range]];
    }
    UIFont *font = [UIFont systemFontOfSize:15];
    
    NSMutableAttributedString *attributedText;
    attributedText=[[NSMutableAttributedString alloc]initWithString:subStr attributes:@{NSFontAttributeName :font}];
    for(NSValue *value in rangeArr)
    {
        NSInteger index=[rangeArr indexOfObject:value];
        NSRange range=[value rangeValue];
        [attributedText addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[urlArr objectAtIndex:index]] range:range];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
    }
    return attributedText;
}

+(NSMutableArray*)getUrlArrWithSr:(NSString *)string;
{
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *urlArr=[[NSMutableArray alloc]init];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch;
        
        substringForMatch = [string substringWithRange:match.range];
//        substringForMatch = [attStr attributedSubstringFromRange:match.range];

        [urlArr addObject:substringForMatch];
    }
    return urlArr;
}

+(NSMutableArray*)getUrlRangArrWithSr:(NSString *)string
{
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *urlArr=[[NSMutableArray alloc]init];
    NSMutableArray *rangeArr=[[NSMutableArray alloc]init];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [urlArr addObject:substringForMatch];
    }
    NSString *subStr=string;
    for (NSString *str in urlArr) {
        
        NSRange searchRange = NSMakeRange(0, [subStr length]);
        NSRange range;
        if ((range = [subStr rangeOfString:str options:0 range:searchRange]).location != NSNotFound) {
            searchRange = NSMakeRange(NSMaxRange(range), [subStr length] - NSMaxRange(range));
        }
        [rangeArr addObject:[NSValue valueWithRange:range]];
        
    }
    return rangeArr;
}

@end
