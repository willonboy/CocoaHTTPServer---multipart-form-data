//
//  main.m
//  WebServer
//
//  Created by willonboy on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WTZAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = UIApplicationMain(argc, argv, nil, NSStringFromClass([WTZAppDelegate class]));
    [pool release];
    return result;
}
