//
//  AppDelegate.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/2/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import <QCloudCOSXML/QCloudCOSXML.h>

#import <UserNotifications/UserNotifications.h>
#import "SecretStorage.h"
#import "QCloudMyBucketListCtor.h"
#import "QCloudHTTPDNSLoader.h"
#import "QCloudLoaderManager.h"
#import "QCloudAFLoader.h"

//#import <QCloudCOSXML/QCloudLogManager.h>
//#define  USE_TEMPERATE_SECRET

@interface AppDelegate () <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic, strong) QCloudCredentailFenceQueue* credentialFenceQueue;
@property (nonatomic,strong)QCloudHTTPDNSLoader * dnsloader;
@end

@interface AppDelegate () <QCloudSignatureProvider>

@end


@implementation AppDelegate

- (void) fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{                                                                                                                                      
    // @"http://127.0.0.1:3000/sts" sts 接口地址，实际调用时请换成真是的地址。
//    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000/sts"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//            QCloudCredential* credential = [QCloudCredential new];
////            credential.startDate = [NSDate dateWithTimeIntervalSince1970:[[result objectForKey:@"startTime"] integerValue]];
//            credential.secretID = result[@"credentials"][@"tmpSecretId"];
//            credential.secretKey = result[@"credentials"][@"tmpSecretKey"];
//             //签名过期时间
////            credential.expirationDate = [NSDate dateWithTimeIntervalSince1970:[[result objectForKey:@"expiration"] integerValue]];
//            credential.token = result[@"credentials"][@"sessionToken"];
//            QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
//            continueBlock(creator, nil);
//        }] resume] ;
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
    credential.secretID  = [SecretStorage sharedInstance].secretID;
    credential.secretKey = [SecretStorage sharedInstance].secretKey;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);
#endif
}

- (void) setupCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    //关闭读取系统剪贴板的功能
    configuration.appID = [SecretStorage sharedInstance].appID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = kRegion;
    endpoint.useHTTPS = YES;
    configuration.endpoint = endpoint;
   
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

}

- (void) setupCOSXMLAccelerateService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    //关闭读取系统剪贴板的功能
    configuration.appID = [SecretStorage sharedInstance].appID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint *endpoint = [[QCloudCOSXMLEndPoint alloc]init];
    endpoint.suffix = @"cos.accelerate.myqcloud.com";
    endpoint.useHTTPS = YES;
    configuration.endpoint = endpoint;
   
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

}

- (void) setupCOSXMLEOService {
    NSString * eoDomain  = @"exampledomain.com";
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    //关闭读取系统剪贴板的功能
    configuration.appID = [SecretStorage sharedInstance].appID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] initWithLiteralURL:[NSURL URLWithString:eoDomain]];
    endpoint.useHTTPS = YES;
    configuration.endpoint = endpoint;
   
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

}

- (void) setupCOSXMLQuicService {
    NSString * eoDomain  = @"exampledomain.com";
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    //关闭读取系统剪贴板的功能
    configuration.appID = [SecretStorage sharedInstance].appID;
    configuration.enableQuic = YES;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] initWithLiteralURL:[NSURL URLWithString:eoDomain]];
    endpoint.useHTTPS = YES;
    configuration.endpoint = endpoint;
   
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

}

-(void)setupHTTPDNS{
    QCloudDnsConfig config;
    config.appId = @"******"; // 可选，应用ID，腾讯云控制台申请获得，用于灯塔数据上报（未集成灯塔时该参数无效
    config.dnsIp = @"0.0.0.0"; // HTTPDNS 服务器 IP
    config.dnsId = 1; // 授权ID，腾讯云控制台申请后，通过邮件发送，用于域名解析鉴权
    config.dnsKey = @"*******";// des的密钥
    config.encryptType = QCloudHttpDnsEncryptTypeDES; // 控制加密方式
    config.debug = YES; // 是否开启Debug日志，YES：开启，NO：关闭。建议联调阶段开启，正式上线前关闭
    config.timeout = 5000; // 可选，超时时间，单位ms，如设置0，则设置为默认值2000ms
    self.dnsloader = [[QCloudHTTPDNSLoader alloc] initWithConfig:config];
    [QCloudHttpDNS shareDNS].delegate = self.dnsloader;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupCOSXMLShareService];
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
  
    [[QCloudLoaderManager manager]addLoader: [[QCloudAFLoader alloc]init]];
    [QCloudLoaderManager manager].enable = YES;
    
    [QCloudCOSXMLConfiguration sharedInstance].currentRegion = kRegion;
    QCloudServiceConfiguration* configuration = [[QCloudCOSXMLService defaultCOSXML].configuration copy];
    configuration.endpoint.regionName = kRegion;
    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:kRegion];
    
    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:kRegion];
    
    QCloudMyBucketListCtor * bucketList = [[QCloudMyBucketListCtor alloc]init];
    _window = [[UIWindow alloc]initWithFrame:SCREEN_FRAME];
    [_window makeKeyAndVisible];
    UINavigationController * navRoot = [[UINavigationController alloc]initWithRootViewController:bucketList];
    _window.rootViewController = navRoot;
    
    return YES;
}
//后台上传要实现该方法
-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler{

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
