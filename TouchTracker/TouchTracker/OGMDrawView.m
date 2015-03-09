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

@property (nonatomic, strong) OGMLine *currentLine;
@property (nonatomic, strong) NSMutableArray *finishedLines;

@end

@implementation OGMDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        self.finishedLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    
    // Get location of the touch in view's coordinate system
    CGPoint location =  [t locationInView:self];
    
    self.currentLine = [[OGMLine alloc]init];
    self.currentLine.begin = location;
    self.currentLine.end = location;
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint location = [t locationInView:self];
    
    self.currentLine.end = location;
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.finishedLines addObject:self.currentLine];
    
    self.currentLine = nil;
    
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
        [self strokeLine:line];
    }
    
    if(self.currentLine){
        // If there is a line currently bieng drawn, do it in red
        [[UIColor redColor] set];
        [self strokeLine:self.currentLine];
    }
}

@end
