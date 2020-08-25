//
//  QuotationViewLit.m
//  BiChat
//
//  Created by Admin on 2018/4/13.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "QuotationViewLit.h"

@implementation QuotationViewLit

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
    
    if (_quotationData.count < 2)
        return;
    
    //1.获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path=CGPathCreateMutable();
    
    //开始画图
    path=CGPathCreateMutable();
    
    //把绘图信息添加到路径里
    for (int i = 0; i <_quotationData.count; i ++)
    {
        CGFloat x = i * self.bounds.size.width / _quotationData.count;
        CGFloat y = self.bounds.size.height - ([[[_quotationData objectAtIndex:i]objectForKey:@"end"]doubleValue] - minQuotition) * self.bounds.size.height / (maxQuotition - minQuotition);
        
        if (i == 0)
            CGPathMoveToPoint(path, NULL, x, y);
        else
            CGPathAddLineToPoint(path, NULL, x, y);
    }
    
    //把绘制直线的绘图信息保存到图形上下文中
    CGContextAddPath(ctx, path);
    
    //渲染
    if ([[[_quotationData firstObject]objectForKey:@"end"]doubleValue] > [[[_quotationData lastObject]objectForKey:@"end"]doubleValue])
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    else
        CGContextSetStrokeColorWithColor(ctx, THEME_GREEN.CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    
    //设置虚线类型
    CGFloat lengths[] = {1,2};
    CGContextSetLineDash(ctx, 0, lengths,2);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height - ([[[_quotationData firstObject]objectForKey:@"end"]doubleValue] - minQuotition) * self.bounds.size.height / (maxQuotition - minQuotition));
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height - ([[[_quotationData firstObject]objectForKey:@"end"]doubleValue] - minQuotition) * self.bounds.size.height / (maxQuotition - minQuotition));
    CGContextStrokePath(ctx);
    
    //释放前面创建的路径
    CGPathRelease(path);
}

@end
