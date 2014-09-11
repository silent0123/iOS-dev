//
//  HTTPHelper.m
//  QuickPoll
//
//  Created by dennis young on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTTPHelper.h"

@implementation HTTPHelper
@synthesize responseContentType;
@synthesize delegate;


- (HTTPHelper*) initWithDelegate:(id)del {
	if (self = [super init]) {
		delegate = del;
	}
	return self;
}
- (void) get: (NSString*)url {
	NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString: url]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	//NSLog(@"get: url: %@, conn:%d", url, conn);
	
	if (conn) {
		dataBuffer = [NSMutableData dataWithCapacity:512];
	} else {
		NSLog(@"connection failed!");
	}
}
- (void) post: (NSString*)url data:(NSData*)data contentType:(NSString*)contentType {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:60.0];
	
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:data];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	//[data ]
      
	// DY
	//NSLog(@"post: url: %@, conn:%d", url, conn);
	
	if (conn) {
		dataBuffer = [NSMutableData dataWithCapacity:512];
	} else {
		NSLog(@"connection failed!");
	}
}
- (void) put: (NSString*)url data:(NSData*)data contentType:(NSString*)contentType {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:60.0];
	
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"PUT"];
	[request setHTTPBody:data];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	//NSLog(@"put: url: %@, conn:%d", url, conn);
	
	if (conn) {
		dataBuffer = [NSMutableData dataWithCapacity:512];
	} else {
		NSLog(@"connection failed!");
	}
}
- (void) del: (NSString*)url {
	NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:60.0];
	[request setHTTPMethod:@"DELETE"];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	//NSLog(@"del: url: %@, conn:%d", url, conn);
	
	if (conn) {
		dataBuffer = [NSMutableData dataWithCapacity:512];
	} else {
		NSLog(@"connection failed!");
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	
	responseContentType = [response MIMEType];
	[dataBuffer setLength:0];
	
	//DY -- test the HTTP response code:
	int responseStatusCode = [response statusCode];
	
	// NSLog(@"HTTP responseStatusCode %d, connection: %d, response: %@", responseStatusCode, connection, response.allHeaderFields);
    //NSLog(@"HTTP responseStatusCode %d, connection: %d", responseStatusCode, connection);
    
	if ((nil != delegate) && (200 != responseStatusCode)) {
		[delegate httpHelper:self httpResponseError:responseStatusCode];
	}	
	
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	
    [dataBuffer appendData:data];
}
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	if (nil != delegate) {
		[delegate httpHelper:self error:@"error"];
	}

	dataBuffer = nil;
	
    NSLog(@"connection failed! - %d %@",
          // [error localizedDescription],
		  [error code],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (nil != delegate) {
		[delegate httpHelper:self data:dataBuffer contentType: responseContentType];
	}
	dataBuffer = nil;
}

@end
