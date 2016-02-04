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
#import "PrefsController.h"

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

- (IBAction) showPrefPanel: (id) sender {
    
    PrefsController* pc = [[PrefsController alloc] init];
    self.windowController = pc;
    [self.windowController showWindow:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    

        self.windowController = [[WindowController alloc] init];
        [((WindowController*)self.windowController) setWindowParams];
        [self.windowController showWindow:self];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        
        // Register for push notifications.
        [NSApp registerForRemoteNotificationTypes:NSRemoteNotificationTypeBadge];
    
        [NSURLProtocol registerClass:URLProtocolHandler.class];

   
      [self handleNotificationRedirect : aNotification.userInfo];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{

    [((WindowController*)self.windowController).webViewDelegate.app notificationActivated :notification];
    
    [self handleNotificationRedirect : notification.userInfo];
}

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken

{
    self.token = deviceToken;
}

- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error

{
    NSLog(@"%@ with error = %@", NSStringFromSelector(_cmd), error);
}

 -(void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleNotificationRedirect : userInfo];
}

-(void) handleNotificationRedirect:(NSDictionary *)data
{
    if (data != nil){
        @try{
        NSString *jsonString =[data valueForKey:@"json-content"];
    
        if ([jsonString length] != 0){
            NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *jsonError;
        
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonError];
        
            if(jsonObject !=nil){
            
                NSString *urlNav =[jsonObject objectForKey:@"ContentUrl"];
            
                self.windowController.url = [[NSURL alloc] initWithString:urlNav];
          
                [self.windowController.webView setMainFrameURL:urlNav];
            }
        }
        }
        @catch(NSException *ex){
          //Do nothing
        }
    }

}


@end
