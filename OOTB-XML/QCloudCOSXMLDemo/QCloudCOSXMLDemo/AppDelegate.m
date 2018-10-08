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

#define  USE_TEMPERATE_SECRET

@interface AppDelegate () <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>
@property (nonatomic, strong) QCloudCredentailFenceQueue* credentialFenceQueue;
@end

@interface AppDelegate () <QCloudSignatureProvider>

@end


@implementation AppDelegate

- (void) fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudHTTPRequest* request = [QCloudHTTPRequest new];
    request.requestData.serverURL = kTempSkServerURL;
    [request setConfigureBlock:^(QCloudRequestSerializer *requestSerializer, QCloudResponseSerializer *responseSerializer) {
        responseSerializer.serializerBlocks = @[QCloudAcceptRespnseCodeBlock([NSSet setWithObjects:@(200), nil], nil),
                                                QCloudResponseJSONSerilizerBlock];
    }];
    void(^NetworkCall)(id response, NSError* error) = ^(id response, NSError* error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            NSInteger code  = [response[@"code"] integerValue];
            if (response[@"code"] && code == 0) {
                QCloudCredential* crendential = [[QCloudCredential alloc] init];
                crendential.secretID = response[@"data"][@"credentials"][@"tmpSecretId"];
                crendential.secretKey = response[@"data"][@"credentials"][@"tmpSecretKey"];
                crendential.experationDate = [NSDate dateWithTimeIntervalSince1970:[response[@"data"][@"expiredTime"] intValue]];
                NSLog(@"\n过期时间 %@\n当前时间%@",crendential.experationDate,[NSDate date]);
                crendential.token = response[@"data"][@"credentials"][@"sessionToken"];
                QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:crendential];
                continueBlock(creator, nil);
            } else {
                error = [NSError errorWithDomain:@"com.tac.test" code:-1111 userInfo:@{NSLocalizedDescriptionKey:@"没有获取到临时密钥"}];
                continueBlock(nil, error);
            }
            
        }
    };
    
    [request setFinishBlock:NetworkCall];
    [[QCloudHTTPSessionManager shareClient] performRequest:request];
}
- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
#ifdef USE_TEMPERATE_SECRET
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);    
        }
    }];
#else
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID  = kSecretID;
    credential.secretKey = kSecretKey;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);
#endif
}

- (void) setupCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = kAppID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    configuration.endpoint = endpoint;
    
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
