//
//  RouteUIView.m
//  DrawRoute
//
//  Created by Coming on 13/1/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteUIView.h"

@implementation RouteUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) initSelf
{
    
     routePoints= [NSArray arrayWithObjects:
     [NSValue valueWithCGPoint:CGPointMake(50, 350)],
     [NSValue valueWithCGPoint:CGPointMake(50, 300)],
     [NSValue valueWithCGPoint:CGPointMake(100,250)],
     [NSValue valueWithCGPoint:CGPointMake(150,250)],
     [NSValue valueWithCGPoint:CGPointMake(150,200)],
     [NSValue valueWithCGPoint:CGPointMake(100,200)],
     [NSValue valueWithCGPoint:CGPointMake(80, 250)],

     [NSValue valueWithCGPoint:CGPointMake(50,50)],
     nil];
    
//    NSTimer *theTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTimeout) userInfo:nil repeats:YES];
    // Assume a there's a property timer that will retain the created timer for future reference.
//    timer = theTimer;
    directionAngle = 0;
    carScreenPoint.x = 160;
    carScreenPoint.y = 335;
    carPoint.x = 0;
    carPoint.y = 0;
    locationIndex = 0;
    routeLineM = 0;
    routeLineB = 0;
    isRouteLineMUndefind = false;
    [self nextRouteLine];
    carPoint = routeStartPoint;
}

-(void) timerTimeout
{
    [self updateLocation];
        
    [self setNeedsDisplay];
 
}

-(id)initWithCoder:(NSCoder*)coder
{
    
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code
        
        [self initSelf];
        
    }
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    NSValue *snv = [routePoints objectAtIndex:0];
    CGPoint startPoint;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3.0);
    CGColorSpaceRef  colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, [UIColor cyanColor].CGColor);
    
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    
    CGContextSetLineWidth(context, 10.0);
    
    
    startPoint = [self getDrawPoint:[snv CGPointValue]];
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    
    for(NSValue *nv in routePoints)
    {
        CGPoint curPoint = [self getDrawPoint:[nv CGPointValue]];
//        CGPoint curPoint = [nv CGPointValue];
        CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
    }
    
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    startPoint = [snv CGPointValue];
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    
    for(NSValue *nv in routePoints)
    {
//        CGPoint curPoint = [self getDrawPoint:[nv CGPointValue]];
        CGPoint curPoint = [nv CGPointValue];
        CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
    }
    
    CGContextStrokePath(context);
    
    CGRect startRect;
    
    startRect.origin.x = carScreenPoint.x-10;
    startRect.origin.y = carScreenPoint.y-10;
    startRect.size.width = 20;
    startRect.size.height = 20;
    
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddRect(context, startRect);
    CGContextFillRect(context, startRect);
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

-(CGPoint) getDrawPoint: (CGPoint) p
{
    CGPoint tmpPoint;
    CGPoint translatedPoint;

    tmpPoint.x = p.x - carPoint.x;
    tmpPoint.y = p.y - carPoint.y;
    
    translatedPoint.x = tmpPoint.x*cos(directionAngle) - tmpPoint.y*sin(directionAngle) + carScreenPoint.x;
    translatedPoint.y = tmpPoint.x*sin(directionAngle) + tmpPoint.y*cos(directionAngle) + carScreenPoint.y;
    
    return translatedPoint;
}
-(CGPoint) getNextCarPoint
{
    CGPoint nextCarPoint = carPoint;
    // x = ?
    if(true == isRouteLineMUndefind)
    {
        nextCarPoint.y += directionStep.y;
        nextCarPoint.x = routeStartPoint.x;
    }
    // y = ?
    else if(routeLineM == 0)
    {
        nextCarPoint.y = routeLineB;
        nextCarPoint.x += directionStep.x;
    }
    // y = mx+b;
    else
    {
        nextCarPoint.y += directionStep.y;
        nextCarPoint.x = (nextCarPoint.y - routeLineB)/routeLineM;
    }
    
    return nextCarPoint;
}
-(void) updateLocation
{
    CGPoint nextCarPoint = [self getNextCarPoint];
    
    if(directionStep.y > 0)
    {
        // (1) ++
        if(directionStep.x > 0)
        {
            if (nextCarPoint.x > routeEndPoint.x &&  nextCarPoint.y > routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = [self getNextCarPoint];
            }
        }
        // (2) -+
        else
        {
            if (nextCarPoint.x <= routeEndPoint.x &&  nextCarPoint.y > routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = [self getNextCarPoint];
            }
        }
    }
    else
    {
        // (4) +-
        if(directionStep.x > 0)
        {
            if (nextCarPoint.x > routeEndPoint.x &&  nextCarPoint.y <= routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = [self getNextCarPoint];
            }
        }
        // (3) --
        else
        {
            if (nextCarPoint.x <= routeEndPoint.x &&  nextCarPoint.y <= routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = [self getNextCarPoint];
            }
        }
    }


    
    NSLog(@"car (%.2f, %.2f) -> (%.2f, %.2f)", carPoint.x, carPoint.y, nextCarPoint.x, nextCarPoint.y);
    carPoint = nextCarPoint;
}

-(float) isOnPath: (CGPoint) c Point1:(CGPoint) p1 Point2:(CGPoint) p2
{
    float angleCP1P2 = [self getAngle:p1 Point1:c Point2:p2];
    float angleCP2P1 = [self getAngle:p2 Point1:c Point2:p2];
    
    return angleCP1P2 <= 90 && angleCP2P1 <= 90;
}

-(float) getAngle: (CGPoint) c Point1:(CGPoint) p1 Point2:(CGPoint) p2
{
    float cp1Lengh, cp2Lengh, p1p2Length;
    double angle = 0;
    float cr = 0;
    cp1Lengh = [self getLength:c ToPoint:p1];
    cp2Lengh = [self getLength:c ToPoint:p2];
    p1p2Length = [self getLength:p1 ToPoint:p2];
    
    
    cr = (pow(cp1Lengh, 2) + pow(cp2Lengh, 2) - pow(p1p2Length, 2))/(2*cp1Lengh*cp2Lengh);
    angle = acos(cr);
    NSLog(@"angle: %.2f (%.2f, %.2f, %.2f)", (angle/M_PI)*180, cp1Lengh, cp2Lengh, p1p2Length);
    return angle;
}

-(float) getLength: (CGPoint) p1 ToPoint:(CGPoint) p2
{
    float length = 0;
    float r1 = pow((p1.x - p2.x), 2);
    float r2 = pow((p1.y - p2.y), 2);
    length = sqrtf((r1+r2));
    NSLog(@"p1(%.2f, %.2f), p2(%.2f, %.2f)", p1.x, p1.y, p2.x, p2.y);
    NSLog(@"r1: %.2f, r2: %.2f, r1+r2: %.2f", r1, r2, r1+r2);
    return sqrt(r1+r2);
}

-(void) nextRouteLine
{
        CGPoint tmpPoint;
        routeStartPoint = [[routePoints objectAtIndex:locationIndex] CGPointValue];
        routeEndPoint = [[routePoints objectAtIndex:locationIndex+1] CGPointValue];
        
        // x = ??
        if((routeStartPoint.x - routeEndPoint.x) == 0)
        {
            routeLineM = 0;
            isRouteLineMUndefind = true;
        }
        // y = mx+b
        else
        {
            routeLineM = (routeStartPoint.y - routeEndPoint.y)/(routeStartPoint.x - routeEndPoint.x);
            routeLineB = routeEndPoint.y - routeLineM*routeEndPoint.x;
            isRouteLineMUndefind = false;
        }
        
        tmpPoint = routeStartPoint;
        tmpPoint.y--;
        directionAngle = [self getAngle:routeStartPoint Point1:tmpPoint Point2:routeEndPoint];

        if(carPoint.x < routeEndPoint.x)
        {
            directionAngle *= -1;
        }
    
        NSLog(@"route: (%.2f, %.2f) -> (%.2f, %.2f)", routeStartPoint.x, routeStartPoint.y, routeEndPoint.x, routeEndPoint.y);
        NSLog(@"y = %.2fx + %.2f", routeLineM, routeLineB);
    
    
    locationIndex++;
    if(locationIndex >= routePoints.count -1)
        locationIndex = 0;
    
    directionStep.x = routeEndPoint.x - routeStartPoint.x > 0 ? 5:-5;
    directionStep.y = routeEndPoint.y - routeStartPoint.y > 0 ? 5:-5;
    
}

@end
