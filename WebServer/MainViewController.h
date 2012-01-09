//
//  MainViewController.h
//  WebServer
//
//  Created by willonboy on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define HTTP_SERVER_PORT (8080)

#import <UIKit/UIKit.h>
#import "HTTPServer.h"
#import "WTZHTTPConnection.h"
#import "localhostAdresses.h"

@interface MainViewController : UIViewController
{
    UISwitch        *switchBar;
    UIProgressView  *progressView;
    HTTPServer      *webServer;
    NSDictionary    *ips;
    UILabel         *en0IpLabel;
    UILabel         *wwwIpLabel;
}

- (void)swithBarChangedValue;
- (void)handleUploadProgressNotification:(NSNotification *) notification;
- (void)changeProgressViewValue:(NSNumber *) value;

#pragma mark - get ips

- (void)bindIps:(NSNotification *) notification;
- (void)displayIps;
- (void)hideIps;

#pragma mark - HTTPSERVER

- (void)initHttpServer;
- (void)startHttpServer;
- (void)stopHttpServer;

- (void)connectionClosed:(NSNotification *) notification;
@end

