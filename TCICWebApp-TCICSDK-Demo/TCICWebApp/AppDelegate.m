//
//  AppDelegate.m
//  TICWebApp
//
//  Created by AlexiChen on 2020/5/11.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "AppDelegate.h"
#import <TCICSDK/TCICClassController.h>
#import "TICLoginViewController.h"

#import <YYModel/YYModel.h>
#import <Bugly/Bugly.h>
#import "HUDHelper.h"
#import "ComMarco.h"

static NSString * const kBuglyAppID = @"bce0b64be1";

@interface AppDelegate ()




@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Bugly startWithAppId:kBuglyAppID];
    [TCICClassController preloadClass:nil];
    return YES;
}

- (void)onWillLoadClassRoomUrl {
    [[HUDHelper sharedInstance] syncLoading:@"正在加载"];
}

- (void)onDidLoadClassRoomUrl {
    [[HUDHelper sharedInstance] syncStopLoading];
}

- (void)onLoadClassRoomUrlFailed{
    self.hasJoinedClassRoom = NO;
    [[HUDHelper sharedInstance] syncStopLoading];
}

//#pragma mark - UISceneSession lifecycle
//
//
//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    if (kIsIPad) {
//        return [[UISceneConfiguration alloc] initWithName:@"iPad" sessionRole:connectingSceneSession.role];
//    } else {
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [self handleUrlFromWeb:url];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DebugLog(@"applicationDidBecomeActive");
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    [self handleUrlFromWeb:userActivity.webpageURL];
    return YES;
}


- (BOOL)handleUrlFromWeb:(NSURL *)webUrl {
    if ([webUrl.scheme isEqualToString:@"tcicdemo"]) {
        
        // TODO : 业务侧根据需要自行解析参数后作业务逻辑
        NSLog(@"呼起App的URL : %@", webUrl.absoluteString);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"URL呼起" message:webUrl.absoluteString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    
    return NO;
}



@end
