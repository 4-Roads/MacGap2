//
//  WebViewDelegate.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//
#import <JavaScriptCore/JavaScriptCore.h>

#import "WebViewDelegate.h"
#import "WindowController.h"
#import "MacGap.h"

@implementation WebViewDelegate

@synthesize windowController, app, menu, window , scriptObject;

- (id) initWithMenu:(NSMenu*)aMenu
{
    self = [super init];
    if (!self)
        return nil;
    
    mainMenu = aMenu;
    
    return self;
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    WebNavigationType navigationType = [[actionInformation valueForKey:@"WebActionNavigationTypeKey"] integerValue];
    
    if(navigationType == WebNavigationTypeLinkClicked){
        
        NSString *requestPath = [[request URL] absoluteString];
        
        if([requestPath hasPrefix:@"http"])
        {
            if(MAIN_DOMAIN != nil && [requestPath rangeOfString: MAIN_DOMAIN].location == NSNotFound)
            {
                NSURL *externalUrl = [NSURL URLWithString:requestPath];
                [[NSWorkspace sharedWorkspace] openURL:externalUrl];
                [listener ignore];
                return;
            }
        } else if([requestPath hasPrefix:@"mailto:"] || [requestPath hasPrefix:@"skype:"])
        {
            NSURL *externalUrl = [NSURL URLWithString:requestPath];
            [[NSWorkspace sharedWorkspace] openURL:externalUrl];
            [listener ignore];
            return;
        }
        
    }

    [listener use];
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles{
    
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    
    [openDlg beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray * files = [[openDlg URLs] valueForKey: @"relativePath"];
            [resultListener chooseFilenames: files];
        } else {
            [resultListener cancel];
        }
    }];
}

- (void)webView:(WebView *)sender willPerformDragDestinationAction:(WebDragDestinationAction)action forDraggingInfo:(id < NSDraggingInfo >)draggingInfo
{
    NSArray *files = nil;
    if (action == WebDragDestinationActionDHTML) {
        NSPasteboard *pboard = [draggingInfo draggingPasteboard];
      
        if([[pboard types] containsObject:NSURLPboardType] ) {
            
           files = [pboard propertyListForType:NSFilenamesPboardType];
      
        }
    }
    if(files) {
        [app addFiles:files];
    }
}


- (void) webView:(WebView*)webView addMessageToConsole:(NSDictionary*)message
{
	if (![message isKindOfClass:[NSDictionary class]]) {
		return;
	}
	
	NSLog(@"JavaScript console: %@:%@: %@",
		  [[message objectForKey:@"sourceURL"] lastPathComponent],	// could be nil
		  [message objectForKey:@"lineNumber"],
		  [message objectForKey:@"message"]);
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn)
        return YES;
    else
        return NO;
}

/*
 By default the size of a database is set to 0 [1]. When a database is being created
 it calls this delegate method to get an increase in quota size - or call an error.
 PS this method is defined in WebUIDelegatePrivate and may make it difficult, but
 not impossible [2], to get an app accepted into the mac app store.
 
 Further reading:
 [1] http://stackoverflow.com/questions/353808/implementing-a-webview-database-quota-delegate
 [2] http://stackoverflow.com/questions/4527905/how-do-i-enable-local-storage-in-my-webkit-based-application/4608549#4608549
 */
- (void)webView:(WebView *)sender frame:(WebFrame *)frame exceededDatabaseQuotaForSecurityOrigin:(id) origin database:(NSString *)databaseIdentifier
{
    static const unsigned long long defaultQuota = 5 * 1024 * 1024;
    if ([origin respondsToSelector: @selector(setQuotes:)]) {
        [origin performSelector:@selector(setQuotes:) withObject:[NSNumber numberWithLongLong: defaultQuota]];
    } else {
        NSLog(@"could not increase quota for %lld", defaultQuota);
    }
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSMutableArray *webViewMenuItems = [defaultMenuItems mutableCopy];
    
    if (webViewMenuItems)
    {
        NSEnumerator *itemEnumerator = [defaultMenuItems objectEnumerator];
        NSMenuItem *menuItem = nil;
        while ((menuItem = [itemEnumerator nextObject]))
        {
            NSInteger tag = [menuItem tag];
            
            switch (tag)
            {
                case WebMenuItemTagOpenLinkInNewWindow:
                case WebMenuItemTagDownloadLinkToDisk:
                case WebMenuItemTagCopyLinkToClipboard:
                case WebMenuItemTagOpenImageInNewWindow:
                case WebMenuItemTagDownloadImageToDisk:
                case WebMenuItemTagCopyImageToClipboard:
                case WebMenuItemTagOpenFrameInNewWindow:
                case WebMenuItemTagGoBack:
                case WebMenuItemTagGoForward:
                case WebMenuItemTagStop:
                case WebMenuItemTagOpenWithDefaultApplication:
                case WebMenuItemTagReload:
                    [webViewMenuItems removeObjectIdenticalTo: menuItem];
            }
        }
    }
    
    return webViewMenuItems;
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request{
    windowController = [[WindowController alloc] initWithRequest:request];
    return windowController.webView;
}

- (void)webViewShow:(WebView *)sender{
    [windowController showWindow:sender];
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    [listener ignore];
}

- (void) webView: (WebView*) webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    windowController.jsContext = context;
 
    //Initialize "Always On" commands
    if (app == nil) {
        app = [[App alloc] initWithWebView:webView];
    }
    
    if(window == nil) {
        window = [[Window alloc] initWithWindowController:self.windowController andWebview:webView];
    }
    
    if(menu == nil) {
        menu = [Menu menuWithContext:context andMenu:mainMenu ];
    }
    
    context[kWebScriptNamespace] = app;
    context[kWebScriptNamespace][@"Window"] = window;
    context[kWebScriptNamespace][@"Menu"] = menu;
    
    //Init user selected plugins
    for( NSString* plugin in windowController.pluginsMap) {
       
        id obj = [[NSClassFromString(plugin)alloc] initWithWindowController: windowController];
        NSString *exportName = [obj exportName];
        context[kWebScriptNamespace][exportName] = obj;
    }
    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if (notificationRefreshTimmer != nil){
        [notificationRefreshTimmer invalidate];
    }
    
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSString *currenturl = [[[[frame dataSource] response] URL] absoluteString];
        [self.windowController.urlTextBox setStringValue:currenturl];
        
        scriptObject = [sender windowScriptObject];
        
        [scriptObject setValue:self forKey:@"MyApp"];
        
        [scriptObject evaluateWebScript:@"console = { log: function(msg) { MyApp.consoleLog_(msg); } }"       ];
        
        //Use some Jquery to get the notification count
        if ([currenturl containsString: MAIN_DOMAIN]){
            
            notificationRefreshTimmer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                             target: self
                                           selector:@selector(onRefreshCounter:)
                                           userInfo: nil repeats:YES];
        }
    }
    
    [Event triggerEvent:@"MacGap.load.complete" forWebView:sender];
    
  
}
-(void)onRefreshCounter:(NSTimer *)timer {
    NSString *title = [self.windowController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"try{$('.navigation-list.user-links .popup-list-count').text();}catch(err){}"]];
    
    NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    [tile setBadgeLabel:title];
}

- (void)consoleLog:(NSString *)aMessage {
    NSLog(@"JSLog: %@", aMessage);
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector {
    if (aSelector == @selector(consoleLog:)) {
        return NO;
    }
    
    return YES;
}
@end
