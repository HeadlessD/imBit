//
//  SectorProgressView.m
//  BiChat
//
//  Created by imac2 on 2018/7/3.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "SectorProgressView.h"

@implementation SectorProgressView

- (id)init
{
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    return self;
}

//描画
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx, rect);
    CGContextAddEllipseInRect(ctx, CGRectMake(CGRectGetMidX(rect) - 25, CGRectGetMidY(rect) - 25, 50, 50));
    [self.progressColor setFill];
    CGContextDrawPath(ctx, kCGPathEOFill);
    
    //修正数据，避免显示不出来的情况
    if (_progress == 0)
        _progress = 0.000001;
    
    //定义扇形中心
    CGPoint origin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    //定义扇形半径
    CGFloat radius = 23;
    //设定扇形起点位置
    CGFloat startAngle = - M_PI_2;
    //根据进度计算扇形结束位置
    CGFloat endAngle = startAngle + self.progress * M_PI * 2;
    //根据起始点、原点、半径绘制弧线
    UIBezierPath *sectorPath = [UIBezierPath bezierPathWithArcCenter:origin radius:radius startAngle:endAngle endAngle:startAngle clockwise:YES];
    //从弧线结束为止绘制一条线段到圆心。这样系统会自动闭合图形，绘制一条从圆心到弧线起点的线段。
    [sectorPath addLineToPoint:origin];
    //设置扇形的填充颜色
    [self.progressColor set];
    //设置扇形的填充模式
    [sectorPath fill];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

@end
