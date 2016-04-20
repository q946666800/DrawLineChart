//
//  LineChartView.m
//  DrawLineChart
//
//  Created by yuyu on 16/4/20.
//  Copyright © 2016年 yuyu. All rights reserved.
//

#import "LineChartView.h"
#import "PointModel.h"

#define SCREENHEIGHT  [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width

@implementation LineChartView{
    CGFloat originX;
    CGFloat originY;
    //虚线纵向间隔
    CGFloat dashlineH;
    //虚线横向间隔
    CGFloat dashWidth;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1.0);
    CGContextSetLineWidth(context, 0.5);
    
    //坐标系
    //左下角起点
    originX = 20.0;
    originY = SCREENHEIGHT-originX;
    //虚线纵向间隔
    dashlineH = self.verticalH;
    //虚线横向间隔
    dashWidth = (SCREENWIDTH-50.0-20)/4;
    
    [self drawBaseWithContext:context];
    [self drawDashLine:context];
    
    CGPoint greenPoint[self.greenPoints.count];
    for (NSInteger i = 0; i<self.greenPoints.count; i++) {
        PointModel *model = self.greenPoints[i];
        greenPoint[i] = CGPointMake(model.x, model.y);
    }
    
    CGPoint redPoint[self.redPoints.count];
    for (NSInteger i = 0; i<self.redPoints.count; i++) {
        PointModel *model = self.redPoints[i];
        redPoint[i] = CGPointMake(model.x, model.y);
    }

    //画红点
    for (NSInteger i = 0; i<5; i++) {
        [self drawPointWithContext:context color:[UIColor redColor] point:redPoint[i] pointDiameter:2.0];
    }
    
    //绿点连线
    NSInteger count = sizeof(greenPoint)/sizeof(greenPoint[0]);
    [self connectLineWithContext:context points:greenPoint count:(NSInteger)count colorR:0.0 colorG:1.0 colorB:0.0];
    
    //红点连线
    NSInteger count1 = sizeof(redPoint)/sizeof(redPoint[0]);
    [self connectLineWithContext:context points:redPoint count:(NSInteger)count1 colorR:1.0 colorG:0.0 colorB:0.0];
    
    //绘制绿色块
    [self drawBottomColorBlockWithContext:context originPoint:CGPointMake(originX, SCREENHEIGHT-originX) points:greenPoint count:count color:[UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:0.12]];
    
    [self drawColorBlockInLinesWithContext:context originPoint:CGPointMake([self transformPoint:redPoint[0]].x, [self transformPoint:redPoint[0]].y) points1:redPoint points2:greenPoint count1:count1 count2:count color:[UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.12]];
    
    //画绿点
    //绿点放到后面,避免被红色块遮挡
    for (NSInteger i = 0; i<5; i++) {
        [self drawPointWithContext:context color:[UIColor greenColor] point:greenPoint[i] pointDiameter:2.0];
    }
}


/**
 *  绘制下方色块
 *
 *  @param context     context
 *  @param originPoint 原点
 *  @param points      线上面的点
 *  @param count       线的点数
 *  @param color       色块的颜色(建议透明)
 */
- (void)drawBottomColorBlockWithContext:(CGContextRef)context originPoint:(CGPoint)originPoint points:(CGPoint *)points count:(NSInteger)count color:(UIColor *)color{
    //原点
    CGContextMoveToPoint(context, originPoint.x, originPoint.y);
    //线上面的点
    for (NSInteger i = 0; i<count; i++) {
        CGContextAddLineToPoint(context, [self transformPoint:points[i]].x, [self transformPoint:points[i]].y);
    }
    //坐标系右下方的店
    CGContextAddLineToPoint(context, [self transformPoint:points[4]].x, SCREENHEIGHT-originX);
    //回到原点(即左下角的店)
    CGContextAddLineToPoint(context, originPoint.x, originPoint.y);
    CGContextClosePath(context);
    [color set];
    CGContextDrawPath(context, kCGPathFillStroke);
}

//绘制两线之间的色块
- (void)drawColorBlockInLinesWithContext:(CGContextRef)context originPoint:(CGPoint)originPoint points1:(CGPoint *)points1 points2:(CGPoint *)points2 count1:(NSInteger)count1 count2:(NSInteger)count2 color:(UIColor *)color{
    //原点
    CGContextMoveToPoint(context, originPoint.x, originPoint.y);
    //线1上面的点
    for (NSInteger i = 0; i<count1; i++) {
        CGContextAddLineToPoint(context, [self transformPoint:points1[i]].x, [self transformPoint:points1[i]].y);
    }
    //线2上面的店
    for (NSInteger i = 0; i<count2; i++) {
        CGContextAddLineToPoint(context, [self transformPoint:points2[count2-i-1]].x, [self transformPoint:points2[count2-i-1]].y);
    }
    //回到原点(即左下角的店)
    CGContextAddLineToPoint(context, originPoint.x, originPoint.y);
    CGContextClosePath(context);
    [color set];
    CGContextDrawPath(context, kCGPathFillStroke);
}


//画基本坐标
-(void)drawBaseWithContext:(CGContextRef)context{
    CGContextMoveToPoint(context, originX, SCREENHEIGHT-originX);
    CGContextAddLineToPoint(context, SCREENWIDTH-originX, originY);
    CGContextStrokePath(context);
}

//画虚线
-(void)drawDashLine:(CGContextRef)context{
    
    CGFloat dashPhase = 0;
    CGFloat lengths[] = {1,2};
    CGContextSetLineDash(context, dashPhase, lengths, 2);
    //横虚线
    for (NSInteger i = 0; i < 4 ; i++) {
        CGContextMoveToPoint(context, originX, originY-dashlineH - i*dashlineH);
        CGContextAddLineToPoint(context, SCREENWIDTH-originX, originY-dashlineH - i*dashlineH);
    }
    //纵虚线
    for (NSInteger i = 0; i < 5 ; i++) {
        CGContextMoveToPoint(context, originX+i*dashWidth, SCREENHEIGHT-originX*6);
        CGContextAddLineToPoint(context, originX+i*dashWidth, SCREENHEIGHT-originX*1);
    }
    CGContextStrokePath(context);
}

/**
 *  画点
 *
 *  @param context context
 *  @param color          点的颜色
 *  @param pointX         点的X坐标, 为整数1,2,3,4,5 分别代表2月 ~ 6月
 *  @param pointY         点的Y坐标, 范围:0~25
 *  @param pointDiameter  点的直径
 */
-(void)drawPointWithContext:(CGContextRef)context
                      color:(UIColor *)color
                      point:(CGPoint)point
              pointDiameter:(CGFloat)pointDiameter
{
    //    CGFloat X1 = originX + (pointX-1)*dashWidth;
    //    CGFloat Y1 = originY - (pointY*4);
    CGPoint point1 = [self transformPoint:point];
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.0);
    CGContextAddArc(context, point1.x, point1.y, pointDiameter, 0, M_PI*2, 1);
    //设置填充颜色
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

/**
 *  根据点数组连线
 *
 *  @param context context
 *  @param point   点数组,注意这里是C数组
 *
 *  @param R       r
 *  @param G       g
 *  @param B       b
 */
-(void)connectLineWithContext:(CGContextRef)context points:(CGPoint *)point count:(NSInteger)count1 colorR:(CGFloat)R colorG:(CGFloat)G colorB:(CGFloat)B{
    CGContextSetRGBStrokeColor(context, R, G, B, 1.0);
    NSInteger count = count1;
    CGPoint greenLines[count];
    for (NSInteger i = 0; i< count; i++) {
        CGPoint afterPoint = [self transformPoint:point[i]];
        greenLines[i] = afterPoint;
    }
    CGContextSetLineWidth(context, 1.0);
    CGFloat dashPhase = 0;
    CGFloat lengths[] = {1,0};
    CGContextSetLineDash(context, dashPhase, lengths, 2);
    CGContextAddLines(context, greenLines, sizeof(greenLines)/sizeof(greenLines[0]));
    CGContextStrokePath(context);
}

/**
 *  自定义坐标系转换成图表坐标系
 */
-(CGPoint)transformPoint:(CGPoint)point{
    CGPoint afterPoint;
    afterPoint.x = originX + (point.x-1)*dashWidth;
    afterPoint.y = originY - (point.y*6);
    return afterPoint;
}

@end
