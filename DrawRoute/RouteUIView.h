//
//  RouteUIView.h
//  DrawRoute
//
//  Created by Coming on 13/1/24.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteUIView : UIView
{
    NSArray *routePoints;
    NSTimer *timer;
    CGPoint carScreenPoint;
    CGPoint carPoint;
    float directionAngle;
    float routeLineM;
    bool isRouteLineMUndefind;
    float routeLineB;
    int locationIndex;
    
    CGPoint routeStartPoint;
    CGPoint routeEndPoint;
    CGPoint directionStep;

    
}

-(float) getLength: (CGPoint) p1 ToPoint:(CGPoint) p2;
-(float) getAngle: (CGPoint) c Point1:(CGPoint) p1 Point2:(CGPoint) p2;
-(void) timerTimeout;

@end
