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

@property (nonatomic, weak) OGMLine *selectedLine;

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
        
        UITapGestureRecognizer *doubleTapRecognizer =
            [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES; // To get rid of touches began dot
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];
        
        UITapGestureRecognizer *pressRecognizer =
            [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
    }
    
    return self;
}

- (void)doubleTap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized Double Tap");
    
    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
}

- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized Tap");
    
    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    
    if(self.selectedLine){
        
        // Make ourselves the target of the menu item action messages
        [self becomeFirstResponder];
        
        // Grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        // Create a new "Delete" UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc]initWithTitle:@"Delete" action:@selector(deleteLine:)];
        
        menu.menuItems = @[deleteItem];
        
        // Tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    }else{
        // Hide the menu if no line is selected
        [[UIMenuController sharedMenuController]setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
    
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    if(gr.state == UIGestureRecognizerStateBegan){
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        
        if(self.selectedLine){
            [self.linesInProgress removeAllObjects];
        }
    }else if(gr.state == UIGestureRecognizerStateEnded){
        self.selectedLine = nil;
    }
    [self setNeedsDisplay];
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

-(OGMLine *)lineAtPoint:(CGPoint)p
{
    // Find a line close to p
    for (OGMLine *l in self.finishedLines){
        CGPoint start = l.begin;
        CGPoint end = l.end;
        
        // Check a few points on the line
        for (float t = 0.0; t <= 1.0; t += 0.05){
            float x = start.x + t * (end.x - start.x);
            float y = end.x + t * (end.y - start.y);
            
            // If the tapped point is within 20 points, let's return this line
            if(hypot(x - p.x, y - p.y) < 20.0){
                return l;
            }
        }
    }
    
    // If nothing is close enough to the tapped point, then  we did not select  a line
    return nil;
}

- (void)deleteLine:(id)sender
{
    // Remove the selected line from the list of _finishedLines
    [self.finishedLines removeObject:self.selectedLine];
    
    // Redraw everything
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Draw finished lines in black
    [[UIColor blackColor] set];
    for (OGMLine *line in self.finishedLines){
        [self strokeLine:line];
    }
    
    [[UIColor redColor]set];
    for(NSValue *key in self.linesInProgress){
        [self strokeLine:self.linesInProgress[key]];
    }
    
    if(self.selectedLine){
        [[UIColor greenColor]set];
        [self strokeLine:self.selectedLine];
    }

}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
