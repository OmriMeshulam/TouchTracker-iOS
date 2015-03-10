//
//  OGMDrawView.m
//  TouchTracker
//
//  Created by Omri Meshulam on 3/8/15.
//  Copyright (c) 2015 Omri Meshulam. All rights reserved.
//

#import "OGMDrawView.h"
#import "OGMLine.h"
#import "OGMCircle.h"

@interface OGMDrawView ()

@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *circlesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;
@property (nonatomic, strong) NSMutableArray *finishedCircles;

@end

@implementation OGMDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        self.linesInProgress = [[NSMutableDictionary alloc]init];
        self.circlesInProgress = [[NSMutableArray alloc]init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.finishedCircles = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Let's put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if([touches count] != 2){
        for (UITouch *t in touches){
            CGPoint location  = [t locationInView:self];
            
            OGMLine *line = [[OGMLine alloc]init];
            line.begin = location;
            line.end = location;
            
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            self.linesInProgress[key] = line;
        }
    }else{
        NSArray *touchArray = [touches allObjects];
        UITouch *t1 = [touchArray objectAtIndex:0];
        UITouch *t2 = [touchArray objectAtIndex:1];
        OGMCircle *circle = [[OGMCircle alloc]init];
        
        circle.point1 = [t1 locationInView:self];
        circle.point2 = [t2 locationInView:self];
        
        if (circle){
            [self.circlesInProgress addObject:circle];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if([touches count] != 2){
        for (UITouch *t in touches){
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            OGMLine *line = self.linesInProgress[key];
            
            line.end = [t locationInView:self];
        }
    }else{
        NSArray *touchArray = [touches allObjects];
        OGMCircle *circle;
        UITouch *t1 = [touchArray objectAtIndex:0];
        if([self.circlesInProgress count]!=0){
            circle = [self.circlesInProgress objectAtIndex:([self.circlesInProgress count] - 1)];
        }else{
            circle =[[OGMCircle alloc]init];
        }
        UITouch *t2 = [touchArray objectAtIndex:1];
        circle.point1 = [t1 locationInView:self];
        circle.point2 = [t2 locationInView:self];
        
        if([self.circlesInProgress count] == 0){
            NSValue *key1 = [NSValue valueWithNonretainedObject:t1];
            NSValue *key2 = [NSValue valueWithNonretainedObject:t2];
            [self.linesInProgress removeObjectForKey:key1];
            [self.linesInProgress removeObjectForKey:key2];
            [self.circlesInProgress addObject:circle];
        }else{
            [self.circlesInProgress replaceObjectAtIndex:([self.circlesInProgress count] - 1) withObject:circle];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if([touches count] != 2){
        OGMLine *line;
        for(UITouch *t in touches){
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            line = self.linesInProgress[key];
            
            [self.finishedLines addObject:line];
            [self.linesInProgress removeObjectForKey:key];
        }
    }else{
        NSArray *touchArray = [touches allObjects];
        OGMCircle *circle = [self.circlesInProgress objectAtIndex:([self.circlesInProgress count] - 1)];
        OGMCircle *circle2 = [[OGMCircle alloc]init];
        UITouch *t1 = [touchArray objectAtIndex:0];
        UITouch *t2 = [touchArray objectAtIndex:1];
        circle2.point1 = [t1 locationInView:self];
        circle2.point2 = [t2 locationInView:self];

        if (circle){
            [self.finishedCircles addObject:circle2];
            [self.circlesInProgress removeObjectAtIndex:([self.circlesInProgress count] - 1)];
        }
    }

    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if([touches count] != 2){
        for (UITouch *t in touches){
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            [self.linesInProgress removeObjectForKey:key];
        }
    }else{
        [self.circlesInProgress removeAllObjects];
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

    for (OGMLine *line in self.finishedLines){
        float xDiff = line.end.x - line.begin.x;
        float yDiff = line.end.y - line.begin.y;
        float angle = fabs(atan2(yDiff,xDiff) * (180 / M_PI));
        float colorSet = fabs((angle-100.0)/100.0);
        [[UIColor colorWithHue:colorSet saturation:1.0 brightness:1.0 alpha:1.0]set];
        [self strokeLine:line];
    }
    
    // Draw finished circles in black
    [[UIColor blackColor] set];
    for (OGMCircle *circle in self.finishedCircles)
    {
        [self strokeCircle:circle];
    }
    
    [[UIColor redColor]set];
    for(NSValue *key in self.linesInProgress){
        [self strokeLine:self.linesInProgress[key]];
    }
    for(OGMCircle *circle in self.circlesInProgress){
        [self strokeCircle:circle];
    }

}

- (void)strokeCircle:(OGMCircle *)circle
{
    float w = fabs(circle.point1.x - circle.point2.x);
    float h = fabs(circle.point1.y - circle.point2.y);
    
    CGRect r = CGRectMake(circle.point1.x, circle.point1.y, w, h);
    
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:r];
    bp.lineWidth = 10.0;
    
    [bp stroke];
    
}

@end
