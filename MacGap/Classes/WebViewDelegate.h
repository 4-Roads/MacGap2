//
//  WebViewDelegate.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NSString *MAIN_DOMAIN;


@class WindowController, Window, Menu, App;

@interface WebViewDelegate : NSObject <WebPolicyDelegate,WebFrameLoadDelegate,WebUIDelegate,WebResourceLoadDelegate,WebDownloadDelegate> {
    NSMenu *mainMenu;
    Window* window;
    Menu* menu;
    App* app;
    WebScriptObject* scriptObject;
    NSTimer *notificationRefreshTimmer;
}

@property (nonatomic, retain) WindowController *windowController;
@property (nonatomic, retain) Window* window;
@property (nonatomic, retain) Menu* menu;
@property (nonatomic, retain) App* app;
@property (nonatomic, retain) WebScriptObject* scriptObject;
- (id) initWithMenu:(NSMenu*)menu;
-(void)onRefreshCounter:(NSTimer *)timer;
- (void)webView:(WebView *)webView
decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName
decisionListener:(id<WebPolicyDecisionListener>)listener;

@end
