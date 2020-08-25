//
//  QuotationView.m
//  BiChat
//
//  Created by worm_kc on 2018/4/12.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "QuotationView.h"

@implementation QuotationView

- (void)setQuotationData:(NSArray *)quotationData
{
    _quotationData = quotationData;
    
    //计算最大值和最小值
    maxQuotition = 0;
    minQuotition = 999999999;
    for (int i = 0; i < _quotationData.count; i ++)
    {
        if ([[[_quotationData objectAtIndex:i]objectForKey:@"end"]doubleValue] > maxQuotition) maxQuotition = [[[_quotationData objectAtIndex:i]objectForKey:@"end"]doubleValue];
        if ([[[_quotationData objectAtIndex:i]objectForKey:@"end"]doubleValue] < minQuotition) minQuotition = [[[_quotationData objectAtIndex:i]objectForKey:@"end"]doubleValue];
    }

    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if (_quotationData.count == 0)
        return;
    
    //1.获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //设置裁剪区域
    //创建裁剪路径
    CGContextBeginPath(ctx);
    CGMutablePathRef path=CGPathCreateMutable();
    
    //把绘图信息添加到路径里
    for (int i = 0; i <_quotationData.count; i ++)
    {
        CGFloat x = i * self.bounds.size.width / _quotationData.count;
        CGFloat y = self.bounds.size.height - ([[[_quotationData objectAtIndex:i]objectForKey:@"end"]doubleValue] - minQuotition) * self.bounds.size.height / (maxQuotition - minQuotition) - 2;
        
        if (i == 0)
            CGPathMoveToPoint(path, NULL, x, y);
        else
            CGPathAddLineToPoint(path, NULL, x, y);
    }

    CGPathAddLineToPoint(path, NULL, self.bounds.size.width, self.bounds.size.height);
    CGPathAddLineToPoint(path, NULL, 0, self.bounds.size.height);
    CGContextAddPath(ctx, path);
    CGContextClosePath(ctx);
    CGContextClip(ctx);

    //开始画图
    path=CGPathCreateMutable();

    //把绘图信息添加到路径里
    for (int i = 0; i <_quotationData.count; i ++)
    {
        CGFloat x = i * self.bounds.size.width / _quotationData.count;
        CGFloat y = self.bounds.size.height - ([[[_quotationData objectAtIndex:i]objectForKey:@"end"]doubleValue] - minQuotition) * self.bounds.size.height / (maxQuotition - minQuotition) - 2;

        if (i == 0)
            CGPathMoveToPoint(path, NULL, x, y);
        else
            CGPathAddLineToPoint(path, NULL, x, y);
    }

    //把绘制直线的绘图信息保存到图形上下文中
    CGContextAddPath(ctx, path);
    
    //渲染
    CGContextSetStrokeColorWithColor(ctx, THEME_COLOR.CGColor);
    CGContextSetLineWidth(ctx, 1.5);
    CGContextStrokePath(ctx);
    
    //释放前面创建的路径
    CGPathRelease(path);

    //将一个图片画进去
    CGContextDrawImage(ctx, self.bounds, [UIImage imageNamed:@"quotitionbk"].CGImage);
    
    //是否进入了select mode
    if (selectMode)
    {
        CGContextBeginPath(ctx);
        CGContextResetClip(ctx);
        
        CGContextMoveToPoint(ctx, selectPoint.x, 12);
        CGContextAddLineToPoint(ctx, selectPoint.x, self.bounds.size.height);
        CGContextSetLineWidth(ctx, 1);
        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
        CGFloat lengths[] = {2,4};
        CGContextSetLineDash(ctx, 0, lengths,2);
        CGContextStrokePath(ctx);
        
        double quotation = [self calcSelectedQuotation];
        CGFloat y = self.bounds.size.height - (quotation - minQuotition) * self.bounds.size.height / (maxQuotition - minQuotition) - 2;
        CGContextMoveToPoint(ctx, 0, y);
        CGContextAddLineToPoint(ctx, self.bounds.size.width, y);
        CGContextStrokePath(ctx);
        
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(selectPoint.x - 3, y - 3, 6, 6));
        CGContextSetFillColorWithColor(ctx, THEME_COLOR.CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(selectPoint.x - 2, y - 2, 4, 4));
        
        //描画时间
        NSDate *date = [self getSelectedTime];
        NSDateFormatter *fmt = [NSDateFormatter new];
        [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        if (self.showTime)
            fmt.dateFormat = @"MM/dd HH:mm";
        else
            fmt.dateFormat = @"yy/MM/dd";
        NSString *str4Time = [fmt stringFromDate:date];
        CGRect rect = [str4Time boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}
                                             context:nil];
        
        CGRect drawRect = CGRectMake(selectPoint.x - rect.size.width / 2, y - rect.size.height - 3, rect.size.width, rect.size.height);
        drawRect.origin.y = 0;
        drawRect.size.width += 4;
        if (drawRect.origin.x < 0) drawRect.origin.x = 0;
        if (drawRect.origin.x + drawRect.size.width > self.bounds.size.width) drawRect.origin.x = self.bounds.size.width - drawRect.size.width;
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.3].CGColor);
        [str4Time drawAtPoint:CGPointMake(drawRect.origin.x + 2, drawRect.origin.y) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor grayColor]}];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *aTouch = [touches anyObject];
    
    if (aTouch.tapCount == 1) {
        touchMode = YES;
        selectMode = NO;
        selectPoint = [aTouch locationInView:self];
        
        //定时进入select mode
        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            
            if (self->touchMode && !self->selectMode)
            {
                self->selectMode = YES;
               
                //通知
                if (self.delegate && [self.delegate respondsToSelector:@selector(enterShowQuotationSelectionMode:atTime:)])
                {
                    [self.delegate enterShowQuotationSelectionMode:[NSNumber numberWithDouble:[self calcSelectedQuotation]] atTime:[self getSelectedTime]];
                }
               
                //需要重新描画
                [self setNeedsDisplay];
            }
        }];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *aTouch = [touches anyObject];
    selectPoint = [aTouch locationInView:self];
    if (selectMode)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(quotationSelected:atTime:)])
            [self.delegate quotationSelected:[NSNumber numberWithDouble:[self calcSelectedQuotation]] atTime:[self getSelectedTime]];
        
        //需要重新描画
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self->touchMode = NO;
    self->selectMode = NO;
    
    //通知
    if (self.delegate && [self.delegate respondsToSelector:@selector(exitShowQuotationSelectionMode)])
        [self.delegate exitShowQuotationSelectionMode];
    
    //需要重新描画
    [self setNeedsDisplay];
}

- (double)calcSelectedQuotation
{
    NSInteger index = self.quotationData.count * selectPoint.x / self.bounds.size.width;
    if (index < 0) index = 0;
    if (index >= self.quotationData.count) index = self.quotationData.count - 1;
    return [[[self.quotationData objectAtIndex:index]objectForKey:@"end"]doubleValue];
}

- (NSDate *)getSelectedTime
{
    NSInteger index = self.quotationData.count * selectPoint.x / self.bounds.size.width;
    if (index < 0) index = 0;
    if (index >= self.quotationData.count) index = self.quotationData.count - 1;
    return [[self.quotationData objectAtIndex:index]objectForKey:@"timeStamp"];
}

@end
