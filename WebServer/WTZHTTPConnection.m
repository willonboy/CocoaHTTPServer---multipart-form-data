//
//  WTZHTTPConnection.m
//  FileServer
//
//  Created by willonboy on 11-12-7.(qq:962286684)
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WTZHTTPConnection.h"



@implementation WTZHTTPConnection

- (void)dealloc {
    [multipartData release];
    [super dealloc];
}




    //扩展HTTPServer支持的请求类型，默认支持GET，HEAD，不支持POST
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)relativePath
{
	if ([@"POST" isEqualToString:method])
	{
		return YES;
	}
	return [super supportsMethod:method atPath:relativePath];
}

    //处量返回的response数据
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    return [super httpResponseForMethod:method URI:path];
}

    
    //处理POST请求提交的数据流(下面方法是改自 Andrew Davidson的类)
- (void)processDataChunk:(NSData *)postDataChunk
{
    NSLog(@"processDataChunk function called");
        //multipartData初始化不放在init函数中, 当前类似乎不经init函数初始化
    if (multipartData == nil) {
        multipartData = [[NSMutableArray alloc] init];
    }
    
        //处理multipart/form-data的POST请求中Body数据集中的表单值域并创建文件
	if (!postHeaderOK)
	{
            //0x0A0D: 换行符
		UInt16 separatorBytes = 0x0A0D;
		NSData* separatorData = [NSData dataWithBytes:&separatorBytes length:2];
		
		int l = [separatorData length];
		for (int i = 0; i < [postDataChunk length] - l; i++)
		{
                //每次取两个字节 比对下看看是否是换行
			NSRange searchRange = {i, l};
                //如果是换行符则进行如下处理
			if ([[postDataChunk subdataWithRange:searchRange] isEqualToData:separatorData])
			{
                    //获取dataStartIndex标识的上一个换行位置到当前换行符之间的数据的Range
				NSRange newDataRange = {dataStartIndex, i - dataStartIndex};                
                    //dataStartIndex标识的上一个换行位置到移到当前换行符位置 
				dataStartIndex = i + l;
				i += l - 1;
                    //获取dataStartIndex标识的上一个换行位置到当前换行符之间的数据
				NSData *newData = [postDataChunk subdataWithRange:newDataRange];
                    //如果newData不为空或还没有处理完multipart/form-data中表单变量值域则继续处理剩下的表单值域数据
				if ([newData length] || ![self isBeginOfOctetStream])
				{
                    if ([newData length]) {
                        [multipartData addObject:newData];
                    }
				}
				else
				{
                        //将标识处理完multipart/form-data中表单变量值域的postHeaderOK变量设置为TRUE;
					postHeaderOK = TRUE;
                        //这里暂时写成硬编码 弊端:每次增加表单变量都要改这里的数值
                        //获取Content-Disposition: form-data; name="xxx"; filename="xxx"
					NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:4] bytes] 
                                                                  length:[[multipartData objectAtIndex:4] length] 
                                                                encoding:NSUTF8StringEncoding];
                    NSLog(@"postInfo is:%@", postInfo);
					NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
					postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
                    NSLog(@"postInfoComponents0 :%@",postInfoComponents);
                    if ([postInfoComponents count]<2) 
                    {
                        return;
                    }
                    
					postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
                    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
					NSString* filename = [documentPath stringByAppendingPathComponent:[postInfoComponents lastObject]];
                    NSLog(@"filename :%@",filename);
					NSRange fileDataRange = {dataStartIndex, [postDataChunk length] - dataStartIndex};
					[[NSFileManager defaultManager] createFileAtPath:filename contents:[postDataChunk subdataWithRange:fileDataRange] attributes:nil];
					NSFileHandle *file = [[NSFileHandle fileHandleForUpdatingAtPath:filename] retain];
					if (file)
					{
						[file seekToEndOfFile];
						[multipartData addObject:file];
					}
					
					[postInfo release];
					break;
				}
			}
		}
	}
	else //表单值域已经处理过了 这之后的数据全是文件数据流
	{
		[(NSFileHandle*)[multipartData lastObject] writeData:postDataChunk];
	}
    
    float uploadProgress = (double)requestContentLengthReceived / requestContentLength;
		//实际应用时 当前类的实例是相当于单例一样被引用(因为只被实例化一次)
	if (uploadProgress >= 1.0) {
		postHeaderOK = NO;
		[multipartData release];
		multipartData = nil;
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:UPLOAD_FILE_PROGRESS object:[NSNumber numberWithFloat:uploadProgress] userInfo:nil];
}


//检查是否已经处理完了multipart/form-data表单中的表单变量
- (BOOL) isBeginOfOctetStream
{
    NSString *octetStreamFlag = @"Content-Type: application/octet-stream";
    NSString *findData = [[NSString alloc] initWithData:(NSData *)[multipartData lastObject] encoding:NSUTF8StringEncoding];
    
    for (NSData *d in multipartData) {
        NSString *temp = [[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] autorelease] ;
        NSLog(@"multipartData items: %@", temp);
    }
        //如果已经处理完了multipart/form-data表单中的表单变量
    if ( findData != nil && [findData length] > 0 ) 
    {
        NSLog(@"findData is :%@\n octetStreamFlag is :%@", findData, octetStreamFlag);
        if ([octetStreamFlag isEqualToString:findData]) {
            NSLog(@"multipart/form-data 变量值域数据处理完毕");
            [findData release];
            return YES;
        }
        [findData release];
        return NO;
    }
    return NO;
    
}


@end
