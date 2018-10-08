//
//  AppDelegate.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/2/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "QCloudCore.h"
#import <QCloudCOSXML/QCloudCOSXML.h>
#import "TestCommonDefine.h"
#import "QCloudCOSXMLVersion.h"
#import "TestCommonDefine.h"

//#define  USE_TEMPERATE_SECRET

@interface AppDelegate () <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>
@property (nonatomic, strong) QCloudCredentailFenceQueue* credentialFenceQueue;
@end

@interface AppDelegate () <QCloudSignatureProvider>

@end


@implementation AppDelegate


- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    NSString *url;
    if (url) {
        NSMutableURLRequest *requestToSigned = urlRequst;
        
        [[COSXMLGetSignatureTool sharedNewtWorkTool]PutRequestWithUrl:@"服务器地址" request:urlRequst successBlock:^(NSString * _Nonnull sign) {
            QCloudSignature *signature = [[QCloudSignature alloc] initWithSignature:sign expiration:nil];
            continueBlock(signature, nil);
        }];
    }else{
        QCloudCredential* credential = [QCloudCredential new];
        credential.secretID = kSecretID;
        credential.secretKey = kSecretKey;
        QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
        QCloudSignature* signature =  [creator signatureForData:urlRequst];
        continueBlock(signature, nil);
    }
}

- (void) setupCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [[QCloudServiceConfiguration alloc] init];
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = kRegion;
    //设置bucket是前缀还是后缀，默认是yes为前缀（bucket.cos.wh.yun.ccb.com），设置为no即为后缀（cos.wh.yun.ccb.com/bucket）
    //    endpoint.isPrefixURL = NO;
    //开启https服务
//        endpoint.useHTTPS = YES;
    configuration.appID = kAppID;
    endpoint.serviceName = testserviceName;
    configuration.endpoint = endpoint;
    configuration.signatureProvider = self;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupCOSXMLShareService];
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
    return YES;
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
