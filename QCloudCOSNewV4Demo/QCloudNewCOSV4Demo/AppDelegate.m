//
//  AppDelegate.m
//  QCloudNewCOSV4Demo
//
//  Created by erichmzhang(张恒铭) on 31/10/2017.
//  Copyright © 2017 erichmzhang(张恒铭). All rights reserved.
//

#import "AppDelegate.h"
#import "QCloudCOSV4TransferManagerService.h"
#import "QCloudCOS.h"
#import "QCloudV4EndPoint.h"
#import "TestCommonDefine.h"
@interface AppDelegate ()<QCloudSignatureProvider>

@end

@implementation AppDelegate

- (void)signatureWithFields:(QCloudSignatureFields *)fileds request:(QCloudBizHTTPRequest *)request urlRequest:(NSMutableURLRequest *)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = kSecretID;
    credential.secretKey = kSecretKey;
    QCloudAuthentationV4Creator* creator = [[QCloudAuthentationV4Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:fileds];
    continueBlock(signature, nil);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initCOS];
    return YES;
}

- (void)initCOS {
    QCloudServiceConfiguration* configuration = [[QCloudServiceConfiguration alloc ] init];
    configuration.appID = kAppID;
    configuration.signatureProvider = self;
    QCloudV4EndPoint* endpoint = [[QCloudV4EndPoint alloc] init];
    endpoint.regionName = kRegion;
    endpoint.serviceHostSubfix = @"file.myqcloud.com";
    configuration.endpoint = endpoint;
    
    [QCloudCOSV4Service registerDefaultCOSV4WithConfiguration:configuration];
    [QCloudCOSV4TransferManagerService registerDefaultCOSV4TransferMangerWithConfiguration:configuration];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
