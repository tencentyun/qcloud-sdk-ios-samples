#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface AbortMultiPartsUpload : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation AbortMultiPartsUpload

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
 * 初始化分片上传
 */
- (void)initMultiUpload {
    XCTestExpectation* exp = [self expectationWithDescription:@"initMultiUpload"];

    //.cssg-snippet-body-start:[objc-init-multi-upload]
    QCloudInitiateMultipartUploadRequest* initrequest = [QCloudInitiateMultipartUploadRequest new];
    initrequest.bucket = @"examplebucket-1250000000";
    initrequest.object = @"exampleobject";
    
    [initrequest setFinishBlock:^(QCloudInitiateMultipartUploadResult* outputObject, NSError *error) {
        //获取分块上传的 uploadId，后续的上传都需要这个 ID，请保存以备后续使用
        @"exampleUploadId" = outputObject.uploadId;
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] InitiateMultipartUpload:initrequest];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 终止分片上传任务
 */
- (void)abortMultiUpload {
    XCTestExpectation* exp = [self expectationWithDescription:@"abortMultiUpload"];

    //.cssg-snippet-body-start:[objc-abort-multi-upload]
    QCloudAbortMultipfartUploadRequest *abortRequest = [QCloudAbortMultipfartUploadRequest new];
    abortRequest.object = @"exampleobject";
    abortRequest.bucket = @"examplebucket-1250000000";
    //本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果 QCloudInitiateMultipartUploadResult 中得到
    abortRequest.uploadId = @"exampleUploadId";
    
    [abortRequest setFinishBlock:^(id outputObject, NSError *error) {
        //可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
    }];
    
    [[QCloudCOSXMLService defaultCOSXML]AbortMultipfartUpload:abortRequest];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void)testAbortMultiPartsUpload {
    // 初始化分片上传
    [self initMultiUpload];
        
    // 终止分片上传任务
    [self abortMultiUpload];
        
}

@end