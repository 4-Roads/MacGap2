//
//  UrlProtocolHandler.m
//  fourroads.telligent.desktop.app
//
//  Created by Robert Nash on 04/09/2015.
//
//
#import "AppDelegate.h"
#import "UrlProtocolHandler.h"
#import "JSON.h"
@import AppKit;


@interface URLProtocolHandler () <NSURLConnectionDelegate>
@end


@implementation URLProtocolHandler

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    //static NSUInteger requestCount = 0;
    //NSLog(@"Request #%lu: URL = %@", (unsigned long)requestCount++, request.URL.absoluteString);
    //Everything gets routed through here
    //If the URL is to our site then add the header, otherwise fire up safari
    if ([NSURLProtocol propertyForKey:@"OsxNotification" inRequest:request] != nil)
    {
       return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}



- (void)startLoading
{
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    NSString* newStr = [ URLProtocolHandler base64forData  :  appDelegate.token];

    [newRequest setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.13+ (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2" forHTTPHeaderField:@"User-Agent"];
    
    [newRequest addValue:newStr forHTTPHeaderField:@"OsxNotification"];
    
    [NSURLProtocol setProperty:@YES forKey:@"OsxNotification" inRequest:newRequest];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    
    NSString * url = newRequest.URL.absoluteString;
    
    if ( [[url lowercaseString] hasSuffix : @"logout" ]){
    
        [[NSApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)stopLoading
{
    [self.connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    self.connection = nil;
}

@end