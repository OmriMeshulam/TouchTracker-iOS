//
//  OGMDrawView.m
//  TouchTracker
//
//  Created by Omri Meshulam on 3/8/15.
//  Copyright (c) 2015 Omri Meshulam. All rights reserved.
//

#import "OGMDrawView.h"
#import "OGMLine.h"

@interface OGMDrawView ()

@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;

@end

@implementation OGMDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        self.linesInProgress = [[NSMutableDictionary alloc]init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Let's put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches){
        CGPoint location  = [t locationInView:self];
        
        OGMLine *line = [[OGMLine alloc]init];
        line.begin = location;
        line.end = location;
        
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.linesInProgress[key] = line;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches){
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        OGMLine *line = self.linesInProgress[key];
        
        line.end = [t locationInView:self];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for(UITouch *t in touches){
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        OGMLine *line = self.linesInProgress[key];
        
        [self.finishedLines addObject:line];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches){
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (void)strokeLine:(OGMLine *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10.0;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect
{
    // Draw finished lines in black
    [[UIColor blackColor] set];
    for (OGMLine *line in self.finishedLines){
        UIColor *newColor = [self getColorForLine:line];
        [newColor set];
        [self strokeLine:line];
    }
    
    [[UIColor redColor]set];
    for(NSValue *key in self.linesInProgress){
        [self strokeLine:self.linesInProgress[key]];
    }

}

#pragma mark - For line color based on angle
struct vector
{
    double x;
    double y;
};

double dotProduct(struct vector u, struct vector v)
{
    return u.x * v.x + u.y * v.y;
}

double magnitude(struct vector u)
{
    return sqrt((pow(u.x,2)+pow(u.y,2))*1.0);
}
struct vector createVectorWithPoints(CGPoint first, CGPoint second)
{
    struct vector newVector;
    newVector.x = second.x - first.x;
    newVector.y = second.y - first.y;
    return newVector;
}


- (double)angleBetweenBoundsWidthAndVector:(struct vector)first
{
    double angle = 0.0;
    CGPoint beginPoint;
    CGPoint endPoint;
    beginPoint.x = 0;
    beginPoint.y = self.bounds.size.height;
    endPoint.x = self.bounds.size.width;
    endPoint.y = self.bounds.size.height;
    
    struct vector u = first;
    struct vector v = createVectorWithPoints(beginPoint, endPoint);
    
    angle = acos(dotProduct(u, v)/(magnitude(u)*magnitude(v)))*180/M_PI;
    return angle;
}

- (UIColor *)getColorForLine:(OGMLine *)line
{
    struct vector v = createVectorWithPoints(line.begin, line.end);
    double angle = (int)[self angleBetweenBoundsWidthAndVector:v];
    
    
    NSLog(@"Angle = %f\n", angle);
    if(angle >= 0.0 && angle < 30.0) return [UIColor blueColor];
    if(angle >= 30.0 && angle < 60.0) return [UIColor greenColor];
    if(angle >= 60.0 && angle < 90.0) return [UIColor orangeColor];
    if(angle >= 90.0 && angle < 120.0) return [UIColor purpleColor];
    if(angle >= 120.0 && angle < 150.0) return [UIColor yellowColor];
    if(angle >= 150.0 && angle < 180.0) return [UIColor brownColor];
    else return [UIColor blackColor];
}


@end
