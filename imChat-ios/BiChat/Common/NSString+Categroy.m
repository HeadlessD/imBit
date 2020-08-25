//
//  NSString+Categroy.m
//  BiChat
//
//  Created by 张迅 on 2018/5/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "NSString+Categroy.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Categroy)
- (BOOL)isInt {
    NSString * regex = @"^[0-9]\\d*|0$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

- (BOOL)isLetter {
    NSString * regex = @"^[a-z]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

- (BOOL)isFloat {
    NSString * regex = @"^[0-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

- (BOOL)judgeWithRegex:(NSString *)regex {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

- (NSDictionary *)judGroupWithRegex:(NSString *)regex {
    
    NSError *error = NULL;
    NSRegularExpression *regexE = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regexE matchesInString:self
                                      options:0
                                        range:NSMakeRange(0, [self length])];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (matches.count>0) {
        //捕获组用以下方法
        if ([[matches firstObject] rangeWithName:@"action"].location != NSNotFound) {
            NSRange matchRange = [[matches firstObject] rangeWithName:@"action"];
            NSString *matchString = [self substringWithRange:matchRange];
            [dict setObject:matchString forKey:@"action"];
        }
        
        if ([[matches firstObject] rangeWithName:@"id"].location != NSNotFound) {
            NSRange matchRange = [[matches firstObject] rangeWithName:@"id"];
            NSString *matchString = [self substringWithRange:matchRange];
            [dict setObject:matchString forKey:@"id"];
        }
        
        if ([[matches firstObject] rangeWithName:@"subid"].location != NSNotFound) {
            NSRange matchRange = [[matches firstObject] rangeWithName:@"subid"];
            NSString *matchString = [self substringWithRange:matchRange];
            [dict setObject:matchString forKey:@"subid"];
        }
        
//        NSRange matchRange2 = [[matches firstObject] rangeWithName:@"id"];
//        NSString *matchString2 = [self substringWithRange:matchRange2];
//        [dict setObject:matchString2 forKey:@"id"];
//
//        NSRange matchRange3 = [[matches firstObject] rangeWithName:@"subid"];
//        NSString *matchString3 = [self substringWithRange:matchRange3];
//        [dict setObject:matchString3 forKey:@"subid"];
        
//        NSRange matchRange4 = [[matches firstObject] rangeAtIndex:4];
//        NSString *matchString4 = [self substringWithRange:matchRange4];
//        [array addObject:matchString4];
    }
    return dict;
}

- (NSDictionary *)getUrlParams{
    NSURLComponents *components = [[NSURLComponents alloc]initWithString:self];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in components.queryItems) {
        [dict setObject:[NSString stringWithFormat:@"%@",item.value] forKey:[NSString stringWithFormat:@"%@",item.name]];
    }
    if (dict.allKeys.count > 0) {
        return dict;
    }
    NSInteger pt = [self rangeOfString:IMCHAT_GROUPLINK_MARK].location;
    NSString *groupId = [self substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
    NSRange range = [groupId rangeOfString:@"&"];
    if (range.length > 0) {
        groupId = [groupId substringToIndex:range.location];
        [dict setObject:groupId forKey:@"groupId"];
    }
    
    NSInteger pt1 = [self rangeOfString:IMCHAT_USERLINK_MARK].location;
    NSString *refCode = [self substringFromIndex:(pt1 + IMCHAT_USERLINK_MARK.length)];
    refCode = [refCode componentsSeparatedByString:@"&"].count > 0 ? [refCode componentsSeparatedByString:@"&"][0] : @"";
    if (refCode.length > 0) {
        [dict setObject:refCode forKey:@"RefCode"];
    }
    return dict;
    
}

- (NSString *)md5Encode {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)getTimeWithTimestamp:(NSString *)timestamp {
    NSTimeInterval interval = [self doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:timestamp];
    return [formatter stringFromDate:date];
}

//- (NSString *)replaceStr {
//    NSString *string = [[BiChatGlobal sharedManager].lastLoginUserName stringByReplacingCharactersInRange:NSMakeRange(0, [BiChatGlobal sharedManager].lastLoginUserName.length - 4) withString:@""];
//    NSMutableString * phoneStr = [NSMutableString string];
//    for (int i = 0; i < string.length; i++) {
//
//    }
//}

- (NSString *)accuracyCheckWithFormatterString:(NSString *)formatterString auotCheck:(BOOL)autoCheck {
    NSInteger floatWidth = [formatterString integerValue];
    //    if ([formatterString rangeOfString:@"."].location == NSNotFound) {
    //        floatWidth = 0;
    //    } else {
    //        floatWidth = formatterString.length - 2;
    //    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.roundingMode = NSNumberFormatterRoundFloor;
    //设置最多保留几位小数
    formatter.maximumFractionDigits = floatWidth;
    //设置最少保留几位小数
    formatter.minimumFractionDigits = autoCheck ? 0 : floatWidth;
    //不分段（千分符）
    formatter.usesGroupingSeparator = NO;
    //分段长度（千分符）
    //formatter.groupingSize = 3;
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
    return result;
}

- (NSString *)getFormatterStringWithBit:(NSString *)bit {
    if ([bit integerValue] == 0) {
        return @"1";
    } else {
        NSMutableString *mutableStr = [[NSMutableString alloc]init];
        for (int i = 0 ; i < [bit integerValue]; i++) {
            [mutableStr appendString:@"0"];
            if (i == 0) {
                [mutableStr appendString:@"."];
            }
        }
        [mutableStr appendString:@"1"];
        return mutableStr;
    }
}

- (NSString *)toPrise {
    NSString *doubleString = [NSString stringWithFormat:@"%lf", [self doubleValue]];
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

//转换表情
- (NSMutableAttributedString *)transEmotionWithFont:(UIFont *)font
{
    NSMutableAttributedString *str = [NSMutableAttributedString new];
    //查找第一个表情出现的地方
    NSInteger ptr = 1000000;
    NSString *emotionName;
    NSString *emotionImage;
    
    NSRange range1 = [self rangeOfString:@"["];
    if (range1.length > 0)
    {
        NSRange range2 = [self rangeOfString:@"]"];
        if (range2.length > 0)
        {
            NSString *str4Emotion = [self substringWithRange:NSMakeRange(range1.location, range2.location - range1.location + 1)];
            NSDictionary *item = [[BiChatGlobal sharedManager].dict4AllDefaultEmotions objectForKey:str4Emotion];
            if (item == nil)
            {
                //没有找到合适的emotion，分两段处理
                [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:[self substringToIndex:range2.location + 1] attributes:@{NSFontAttributeName:font}]];

                //第三段
                [str appendAttributedString:[[self substringFromIndex:range2.location + 1]transEmotionWithFont:font]];
                return str;
            }
            else
            {
                ptr = range1.location;
                emotionName = str4Emotion;
                emotionImage = [item objectForKey:@"name"];
            }
        }
    }
    
    /*
    for (int i = 0; i < [BiChatGlobal sharedManager].array4AllDefaultEmotions.count; i ++)
    {
        NSRange range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"]];
        if (range.location < ptr)
        {
            ptr = range.location;
            emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"];
            emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
        }
        range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"]];
        if (range.location < ptr)
        {
            ptr = range.location;
            emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"];
            emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
        }
    }
    */
            
    //找到没有
    if (ptr == 1000000)
    {
        [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:self attributes:@{NSFontAttributeName:font}]];
    }
    else
    {
        //找到了，分三段，第一段
        if (ptr > 0)
        {
            [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:[self substringToIndex:ptr] attributes:@{NSFontAttributeName:font}]];
        }
        //第二段，表情
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
        textAttachment.image= [UIImage imageNamed:emotionImage];
        textAttachment.bounds=CGRectMake(0, -4, font.lineHeight+3, (font.lineHeight+3) * 52 / 60);
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [str appendAttributedString:imageStr];
        
        //第三段
        [str appendAttributedString:[[self substringFromIndex:ptr + emotionName.length]transEmotionWithFont:font]];
    }
    return str;
}

- (NSInteger) getLength {
    __block NSUInteger asciiLength = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              if (substringRange.length == 1) {
                                  unichar uc = [substring characterAtIndex:0];
                                  if (isascii(uc)) {
                                      asciiLength += 2;
                                      return;
                                  }
                              }
                              asciiLength += 4;
                          }];
    NSUInteger unicodeLength = asciiLength / 2;
    if(asciiLength % 2) {
        unicodeLength++;
    }
    return unicodeLength;
}


//转换表情
- (NSMutableAttributedString *)YYTransEmotionWithFont:(UIFont *)font
{
    NSMutableAttributedString *str = [NSMutableAttributedString new];
    //查找第一个表情出现的地方
    NSInteger ptr = 1000000;
    NSString *emotionName;
    NSString *emotionImage;
    for (int i = 0; i < [BiChatGlobal sharedManager].array4AllDefaultEmotions.count; i ++)
    {
        NSRange range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"]];
        if (range.location < ptr)
        {
            ptr = range.location;
            emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"];
            emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
        }
        range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"]];
        if (range.location < ptr)
        {
            ptr = range.location;
            emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"];
            emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
        }
    }
    //找到没有
    if (ptr == 1000000)
    {
        [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:self attributes:@{NSFontAttributeName:font}]];
    }
    else
    {
        //找到了，分三段，第一段
        if (ptr > 0)
        {
            [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:[self substringToIndex:ptr] attributes:@{NSFontAttributeName:font}]];
        }
        //第二段，表情
        
        //        NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
        //        textAttachment.image= [UIImage imageNamed:emotionImage];
        //        textAttachment.bounds=CGRectMake(0, -4, font.lineHeight+3, (font.lineHeight+3) * 52 / 60);
        //        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        
        NSAttributedString *imageStr = [NSAttributedString yy_attachmentStringWithEmojiImage:[UIImage imageNamed:emotionImage] fontSize:font.lineHeight];
        [str appendAttributedString:imageStr];
        //第三段
        [str appendAttributedString:[[self substringFromIndex:ptr + emotionName.length]YYTransEmotionWithFont:font]];
    }
    return str;
}


//转换表情
- (NSMutableAttributedString *)DFTransEmotionWithFont:(UIFont *)font

{
    NSMutableAttributedString *str = [NSMutableAttributedString new];
    //查找第一个表情出现的地方
    NSInteger ptr = 1000000;
    NSString *emotionName;
    NSString *emotionImage;
    
    
    NSRange range1 = [self rangeOfString:@"["];
    if (range1.length > 0)
    {
        NSRange range2 = [self rangeOfString:@"]"];
        if (range2.length > 0)
        {
            NSString *str4Emotion = [self substringWithRange:NSMakeRange(range1.location, range2.location - range1.location + 1)];
            NSDictionary *item = [[BiChatGlobal sharedManager].dict4AllDefaultEmotions objectForKey:str4Emotion];
            if (item == nil)
            {
                //没有找到合适的emotion，分两段处理
                [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:[self substringToIndex:range2.location + 1] attributes:@{NSFontAttributeName:font}]];
                
                //第三段
                [str appendAttributedString:[[self substringFromIndex:range2.location + 1]transEmotionWithFont:font]];
                return str;
            }
            else
            {
                ptr = range1.location;
                emotionName = str4Emotion;
                emotionImage = [item objectForKey:@"name"];
            }
        }
    }
    
    /*
     for (int i = 0; i < [BiChatGlobal sharedManager].array4AllDefaultEmotions.count; i ++)
     {
     NSRange range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"]];
     if (range.location < ptr)
     {
     ptr = range.location;
     emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"];
     emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
     }
     range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"]];
     if (range.location < ptr)
     {
     ptr = range.location;
     emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"];
     emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
     }
     }
     */
    
    //找到没有
    if (ptr == 1000000)
    {
        [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:self attributes:@{NSFontAttributeName:font}]];
    }
    else
    {
        //找到了，分三段，第一段
        if (ptr > 0)
        {
            [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:[self substringToIndex:ptr] attributes:@{NSFontAttributeName:font}]];
        }
        //第二段，表情
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
        textAttachment.image= [UIImage imageNamed:emotionImage];
        //        textAttachment.bounds=CGRectMake(0, -4, font.lineHeight+3, (font.lineHeight+3) * 52 / 60);
        textAttachment.bounds=CGRectMake(0, -3, font.lineHeight+3, (font.lineHeight+3) * 52 / 60);
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [str appendAttributedString:imageStr];

        

        
        
        //第三段
        [str appendAttributedString:[[self substringFromIndex:ptr + emotionName.length]DFTransEmotionWithFont:font]];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:1.5];
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    [str addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, str.length)];

    return str;
}


//{
//    NSMutableAttributedString * str = [NSMutableAttributedString new];
//    //查找第一个表情出现的地方
//    NSInteger ptr = 1000000;
//    NSString *emotionName;
//    NSString *emotionImage;
//    for (int i = 0; i < [BiChatGlobal sharedManager].array4AllDefaultEmotions.count; i ++)
//    {
//        NSRange range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"]];
//        if (range.location < ptr)
//        {
//            ptr = range.location;
//            emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"chinese"];
//            emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
//        }
//        range = [self rangeOfString:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"]];
//        if (range.location < ptr)
//        {
//            ptr = range.location;
//            emotionName = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"english"];
//            emotionImage = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:i]objectForKey:@"name"];
//        }
//    }
//    //找到没有
//    if (ptr == 1000000)
//    {
//        [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:self attributes:@{NSFontAttributeName:font}]];
//    }
//    else
//    {
//        //找到了，分三段，第一段
//        if (ptr > 0)
//        {
//            [str appendAttributedString:[[NSMutableAttributedString alloc]initWithString:[self substringToIndex:ptr] attributes:@{NSFontAttributeName:font}]];
//        }
//        //第二段，表情
//        NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
//        textAttachment.image= [UIImage imageNamed:emotionImage];
//        //        textAttachment.bounds=CGRectMake(0, -4, font.lineHeight+3, (font.lineHeight+3) * 52 / 60);
//        textAttachment.bounds=CGRectMake(0, -3, font.lineHeight+3, (font.lineHeight+3) * 52 / 60);
//        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
//        [str appendAttributedString:imageStr];
//
//        //第三段
//        [str appendAttributedString:[[self substringFromIndex:ptr + emotionName.length]DFTransEmotionWithFont:font]];
//    }
//
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setLineSpacing:1.5];
//    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
//    [str addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, str.length)];
//
//    return str;
//}

//+ (instancetype)stringWithFormatWithIM:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2){
//    format = LLSTR(format);
//    
//    va_list ap; // C语言的字符指针, 指针根据offset来指向需要的参数,从而读取参数
//    va_start(ap, format); // 设置指针的起始地址为方法的...参数的第一个参数
//    
//    if (format) { // 第一个参数 person totalAge = person.age;
//        NSString * otherString;
//        int strIndex = 0;
//        
//        while((otherString = va_arg(ap, NSString *))){
//            strIndex++;
//            //依次取得所有参数
//            NSString * repStr = [NSString stringWithFormat:@"{{%d}}",strIndex];
//            format = [format stringByReplacingOccurrencesOfString:repStr withString:otherString];
//        }
//    }
//    va_end(ap);// 针对va_start进行的安全处理,将va_list指向Null.
//    //new
//    return format;
//}

- (NSString *) llReplaceWithArray:(NSArray *)array {
    NSMutableString *str = [[NSMutableString alloc]initWithString:self];

    for (int i = 0; i < array.count; i++) {
        str = [NSMutableString stringWithString:[str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{{%d}}",i + 1] withString:[NSString stringWithFormat:@"%@",array[i]]]];
    }
    
    return str;
}

//+ (NSInteger)totalAge: (nonnull Person* )person, ...NS_REQUIRES_NIL_TERMINATION {
//    NSInteger totalAge = 0;
//    va_list people; // C语言的字符指针, 指针根据offset来指向需要的参数,从而读取参数
//    va_start(people, person); // 设置指针的起始地址为方法的...参数的第一个参数
//    if (person) { // 第一个参数 person totalAge = person.age;
//        for(;;) {
//            Person *person = va_arg(people, Person *); // 获取当前va_list指针指向的参数, 并以Person对象内存大小的偏移量移向下一个参数 if (!person) {
//            break; // 当参数取完,跳出循环
//        }
//        totalAge += person.age;
//    }
//
//    va_end(people); // 针对va_start进行的安全处理,将va_list指向Null.
//    return totalAge;
//}


@end
