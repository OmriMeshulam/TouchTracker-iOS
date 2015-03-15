//
//  OGMDrawViewController.m
//  TouchTracker
//
//  Created by Omri Meshulam on 3/8/15.
//  Copyright (c) 2015 Omri Meshulam. All rights reserved.
//

#import "OGMDrawViewController.h"
#import "OGMDrawView.h"


@implementation OGMDrawViewController

- (void)loadView
{
    self.view = [[OGMDrawView alloc]initWithFrame:CGRectZero];
}

@end
