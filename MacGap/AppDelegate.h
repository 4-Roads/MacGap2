//
//  AppDelegate.h
//  MG
//
//  Created by Tim Debo on 5/19/14.
//
//

#import <Cocoa/Cocoa.h>

@class WindowController;


@interface AppDelegate : NSObject <NSApplicationDelegate,NSUserNotificationCenterDelegate>
{
}
- (IBAction) showPrefPanel: (id) sender;

@property (retain, nonatomic) WindowController *windowController;
@property (retain) NSData *token;

@end
