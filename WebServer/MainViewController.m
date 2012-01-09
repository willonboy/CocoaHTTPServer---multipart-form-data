//
//  MainViewController.m
//  WebServer
//
//  Created by willonboy on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    if (switchBar != nil)
    {
        [switchBar release];
        switchBar = nil;
    }
    
    if (progressView != nil) 
    {
        [progressView release];
        progressView = nil;
    }
    if (webServer != nil) {
        [webServer release];
        webServer = nil;
    }
    if (ips != nil) {
        [ips release];
        ips = nil;
    }
    en0IpLabel = nil;
    wwwIpLabel = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 50, 110, 35)];
    switchLabel.text = @"Start Or Stop:";
    [self.view addSubview:switchLabel];
    [switchLabel release];
    
    switchBar = [[UISwitch alloc] initWithFrame:CGRectMake(170, 50, 100, 35)];
    [switchBar addTarget:self action:@selector(swithBarChangedValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchBar];
    
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 160, 110, 35)];
    progressLabel.text = @"Progress...";
    [self.view addSubview:progressLabel];
    [progressLabel release];
    
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(40, 195, 240, 25)];
    progressView.progress = 0.0f;
    [self.view addSubview:progressView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionClosed:) name:HTTPConnectionDidDieNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindIps:) name:NOTIFICATION_RESOLVED_LOCALHOST_IP_ADDRS object:nil];
    [self initHttpServer];
    [localhostAdresses list];
    
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RESOLVED_LOCALHOST_IP_ADDRS object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if (switchBar != nil)
    {
        [switchBar release];
        switchBar = nil;
    }
    
    if (progressView != nil) 
    {
        [progressView release];
        progressView = nil;
    }
}



#pragma mark - 控件事件/函数

- (void)swithBarChangedValue;
{
    if (switchBar.on) {
            //
        NSLog(@"switch on");
        [self startHttpServer];
    }
    else
    {
        NSLog(@"switch off");
        [self stopHttpServer];
    }
}

    //注意这里并不能直接改变progressView.progress的值 因为NSNotification也是运行在非主线程中的!
- (void)handleUploadProgressNotification:(NSNotification *) notification
{
    NSNumber *uploadProgress = (NSNumber *)[notification object];
    [self performSelectorOnMainThread:@selector(changeProgressViewValue:) withObject:uploadProgress waitUntilDone:NO];
}


- (void)changeProgressViewValue:(NSNumber *) value;
{
    progressView.progress = [value floatValue];
    [progressView setNeedsDisplay];
    NSLog(@"current progress value is %f", [value floatValue]);
}



#pragma mark - get ips

- (void)bindIps:(NSNotification *) notification
{
    ips = [(NSDictionary *)[notification object] copy];
	NSLog(@"IPs addresses: %@", ips);
}

- (void)displayIps
{
    NSString *en0Ip = nil;
    NSString *wwwIp = nil;
    
    if (ips != nil) 
    {
        if ([[ips allKeys] containsObject:@"en0"]) {
            en0Ip = (NSString *)[ips objectForKey:@"en0"];
            en0IpLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 260, 25)];
            en0IpLabel.text = [NSString stringWithFormat:@"局域网IP: %@:%d", en0Ip, HTTP_SERVER_PORT];
            [self.view addSubview:en0IpLabel];
            [en0IpLabel release];
        }
        
        if ([[ips allKeys] containsObject:@"www"]) {
            wwwIp = (NSString *)[ips objectForKey:@"www"]; 
            wwwIpLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 130, 260, 25)];
            wwwIpLabel.text = [NSString stringWithFormat:@"万维网IP: %@:%d", wwwIp, HTTP_SERVER_PORT];
            [self.view addSubview:wwwIpLabel];
            [wwwIpLabel release];
        }
    }
    
    NSLog(@"\n en0Ip:%@ \n wwwIp:%@", en0Ip, wwwIp);
}

- (void)hideIps
{
    if (en0IpLabel != nil) {
        [en0IpLabel removeFromSuperview];
        en0IpLabel = nil;
    }
    
    if (wwwIpLabel != nil) {
        [wwwIpLabel removeFromSuperview];
        wwwIpLabel = nil;
    }
}


#pragma mark - HTTPSERVER

- (void)initHttpServer
{
    if (webServer == nil) {
        webServer = [[HTTPServer alloc] init];
        webServer.port = HTTP_SERVER_PORT;
        webServer.documentRoot = [[NSBundle mainBundle] pathForResource:@"web" ofType:nil];
        webServer.type = @"_http._tcp.";
        webServer.connectionClass = [WTZHTTPConnection class];
    }
}

- (void)startHttpServer
{
    if (webServer != nil && ![webServer isRunning]) {
        progressView.progress = 0.0f;
        [self displayIps];
        [webServer start:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUploadProgressNotification:) name:UPLOAD_FILE_PROGRESS object:nil];
    }
}

- (void)stopHttpServer
{
    if (webServer != nil && [webServer isRunning]) {
        [self hideIps];
        [webServer stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UPLOAD_FILE_PROGRESS object:nil];
    }
}


- (void)connectionClosed:(NSNotification *) notification
{
    if (progressView.progress < 1) {
        NSLog(@"上传中止了!");
    }
    
    NSLog(@"connectionClosed");
}

@end
