//
//  WTZHTTPConnection.h
//  FileServer
//
//  Created by willonboy on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#define UPLOAD_FILE_PROGRESS @"uploadfileprogress"

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@interface WTZHTTPConnection : HTTPConnection
{
	int             dataStartIndex;
	NSMutableArray  *multipartData;
	BOOL            postHeaderOK;
}


- (BOOL) isBeginOfOctetStream;

@end
