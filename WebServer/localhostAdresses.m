//
//  MainViewController.h
//  WebServer
//
//  Created by willonboy on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "localhostAdresses.h"

#import <ifaddrs.h>
#import <netinet/in.h>
#import <sys/socket.h>

@implementation localhostAdresses

+ (void)list
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary* result = [NSMutableDictionary dictionary];
	struct ifaddrs*	addrs;
	BOOL success = (getifaddrs(&addrs) == 0);
    
	if (success) 
	{
		const struct ifaddrs* cursor = addrs;
		while (cursor != NULL) 
		{
			NSMutableString* ip;
			if (cursor->ifa_addr->sa_family == AF_INET) 
			{
				const struct sockaddr_in* dlAddr = (const struct sockaddr_in*)cursor->ifa_addr;
				const uint8_t* base = (const uint8_t*)&dlAddr->sin_addr;
				ip = [[NSMutableString new] autorelease];
				for (int i = 0; i < 4; i++) 
				{
					if (i != 0) 
						[ip appendFormat:@"."];
					[ip appendFormat:@"%d", base[i]];
				}
				[result setObject:(NSString*)ip forKey:[NSString stringWithFormat:@"%s", cursor->ifa_name]];
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
    
        //获取外网IP 
	NSURL *netIPURL = [NSURL URLWithString:@"http://whatismyip.org"];//http://whatismyip.org/ipimg.php (image)
	NSString *netIP = [NSString stringWithContentsOfURL:netIPURL encoding:NSUTF8StringEncoding error:nil];
    
	if (netIP)
    {
		[result setObject:netIP forKey:@"www"];
    }
    
	NSLog(@"IP addresses: %@", result);
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESOLVED_LOCALHOST_IP_ADDRS object:result];
	
	[pool release];
}

@end
