#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketVersioning : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketVersioning

- (void)setUp {
    // 注册默认的 COS 服务
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1250000000";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";//服务地域名称，可用的地域请参考注释
    configuration.endpoint = endpoint;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

    // 脚手架用于获取临时密钥
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
}

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
    credential.secretID = @"COS_SECRETID";
    credential.secretKey = @"COS_SECRETKEY";
    credential.token = @"COS_TOKEN";
    /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
    credential.startDate = [[[NSDateFormatter alloc] init] dateFromString:@"startTime"]; // 单位是秒
    credential.experationDate = [[[NSDateFormatter alloc] init] dateFromString:@"expiredTime"];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
        initWithCredential:credential];
    continueBlock(creator, nil);
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}

/**
 * 设置存储桶多版本
 */
- (void)putBucketVersioning {
    XCTestExpectation* exp = [self expectationWithDescription:@"putBucketVersioning"];

    //.cssg-snippet-body-start:[objc-put-bucket-versioning]
    //开启版本控制
    QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
    request.bucket =@"examplebucket-1250000000";
    QCloudBucketVersioningConfiguration* versioningConfiguration =
        [[QCloudBucketVersioningConfiguration alloc] init];
    request.configuration = versioningConfiguration;
    versioningConfiguration.status = QCloudCOSBucketVersioningStatusEnabled;
    
    [request setFinishBlock:^(id outputObject, NSError* error) {
        //可以从 outputObject 中获取服务器返回的 header 信息
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 获取存储桶多版本状态
 */
- (void)getBucketVersioning {
    XCTestExpectation* exp = [self expectationWithDescription:@"getBucketVersioning"];

    //.cssg-snippet-body-start:[objc-get-bucket-versioning]
    QCloudGetBucketVersioningRequest* request = [[QCloudGetBucketVersioningRequest alloc] init];
    request.bucket = @"examplebucket-1250000000";
    [request setFinishBlock:^(QCloudBucketVersioningConfiguration* result, NSError* error) {
        //可以从 result 中获取返回信息
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucketVersioning:request];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void)testBucketVersioning {
    // 设置存储桶多版本
    [self putBucketVersioning];
        
    // 获取存储桶多版本状态
    [self getBucketVersioning];
        
}

@end