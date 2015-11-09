//
//  AppDelegate.m
//  MG
//
//  Created by Tim Debo on 5/19/14.
//
//

#import "WindowController.h"
#import "UrlProtocolHandler.h"
#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

}

-(BOOL)applicationShouldHandleReopen:(NSApplication*)application
                   hasVisibleWindows:(BOOL)visibleWindows{
    if(!visibleWindows){
        [self.windowController.window makeKeyAndOrderFront: nil];
    }
    return YES;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.windowController = [[WindowController alloc] init];
    [self.windowController setWindowParams];
    [self.windowController showWindow:self];
 
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // Register for push notifications.
    [NSApp registerForRemoteNotificationTypes:NSRemoteNotificationTypeBadge];
    
    NSString *name = [aNotification name];

    [NSURLProtocol registerClass:URLProtocolHandler.class];
    
    //NSLog(@"didFinishLaunchingWithOptions: notification name %@", name);
    
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    // NSLog(@"Notification - Clicked");
    
    [self.windowController.webViewDelegate.app notificationActivated :notification];
}

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken

{
    
    //NSLog(@"%@ with token = %@", NSStringFromSelector(_cmd), deviceToken);
    
    // store the token, the javascript wrapper will send it when the application starts using the index.html
    
    self.token = deviceToken;
    
}

- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error

{
    
    NSLog(@"%@ with error = %@", NSStringFromSelector(_cmd), error);
    
}


- (void)downloadDataFromProvider

{
    
    // Real apps would connect to the provider and download any waiting data.
    
    // Apps typically check in with the provider when first launched and
    
    // again when a push notification is received.
    
}


- (void)showNotificationAlert:(NSDictionary *)apsDictionary

{
    // Only handles the simple case of the alert property having a simple string value.
    
    NSString *message = (NSString *)[apsDictionary valueForKey:(id)@"alert"];
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"OK"];
    
    [alert setMessageText:message];
    
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        
        // Do any desired processing here when the OK button is clicked.
        
    }
}


- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo

{
    
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSDictionary *apsDictionary = [userInfo valueForKey:@"aps"];
    
    if (apsDictionary != nil) {
        
        // Show the alert.
        [self showNotificationAlert:apsDictionary];
        

        // Get updated content from provider.
        [self downloadDataFromProvider];
        
    }
    
}



@end
