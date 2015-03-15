//
//  OGMLine.m
//  TouchTracker
//
//  Created by Omri Meshulam on 3/8/15.
//  Copyright (c) 2015 Omri Meshulam. All rights reserved.
//

#import "OGMLine.h"

@implementation OGMLine

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:self.begin forKey:@"begin"];
    [aCoder encodeCGPoint:self.end forKey:@"end"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        _begin = [aDecoder decodeCGPointForKey:@"begin"];
        _end = [aDecoder decodeCGPointForKey:@"end"];
    }
    return self;
}

@end
