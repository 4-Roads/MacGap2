//
//  UrlProtocolHandler.h
//  fourroads.telligent.desktop.app
//
//  Created by Robert Nash on 04/09/2015.
//
//

#import <Foundation/Foundation.h>

@interface URLProtocolHandler : NSURLProtocol

@property (nonatomic, strong) NSURLConnection *connection;
+ (NSString*)base64forData:(NSData*) theData;
@end





