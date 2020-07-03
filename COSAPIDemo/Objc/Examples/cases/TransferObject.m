#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface TransferObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation TransferObject

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
 * 高级接口上传对象
 */
- (void)transferUploadFile {
    XCTestExpectation* exp = [self expectationWithDescription:@"transferUploadFile"];

    //.cssg-snippet-body-start:[objc-transfer-upload-file]
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 高级接口上传字节数组
 */
- (void)transferUploadBytes {
    XCTestExpectation* exp = [self expectationWithDescription:@"transferUploadBytes"];

    //.cssg-snippet-body-start:[objc-transfer-upload-bytes]
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 高级接口流式上传
 */
- (void)transferUploadStream {
    XCTestExpectation* exp = [self expectationWithDescription:@"transferUploadStream"];

    //.cssg-snippet-body-start:[objc-transfer-upload-stream]
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 高级接口下载对象
 */
- (void)transferDownloadObject {
    XCTestExpectation* exp = [self expectationWithDescription:@"transferDownloadObject"];

    //.cssg-snippet-body-start:[objc-transfer-download-object]
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 高级接口拷贝对象
 */
- (void)transferCopyObject {
    XCTestExpectation* exp = [self expectationWithDescription:@"transferCopyObject"];

    //.cssg-snippet-body-start:[objc-transfer-copy-object]
    QCloudCOSXMLCopyObjectRequest* request = [[QCloudCOSXMLCopyObjectRequest alloc] init];
    
    request.bucket = @"examplebucket-1250000000";//目的 <BucketName-APPID>，需要是公有读或者在当前账号有权限
    request.object = @"exampleobject";//目的文件名称
    //文件来源 <BucketName-APPID>，需要是公有读或者在当前账号有权限
    request.sourceBucket = @"sourcebucket-1250000000";
    request.sourceObject = @"sourceObject";//源文件名称
    request.sourceAPPID = @"1250000000";//源文件的 APPID
    request.sourceRegion= @"COS_REGION";//来源的地域
    
    [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
        //可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
    }];
    
    //注意如果是跨地域复制，这里使用的 transferManager 所在的 region 必须为目标桶所在的 region
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] CopyObject:request];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 批量上传任务
 */
- (void)batchUploadObjects {
    XCTestExpectation* exp = [self expectationWithDescription:@"batchUploadObjects"];

    //.cssg-snippet-body-start:[objc-batch-upload-objects]
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void)testTransferObject {
    // 高级接口上传对象
    [self transferUploadFile];
        
    // 高级接口上传字节数组
    [self transferUploadBytes];
        
    // 高级接口流式上传
    [self transferUploadStream];
        
    // 高级接口下载对象
    [self transferDownloadObject];
        
    // 高级接口拷贝对象
    [self transferCopyObject];
        
    // 批量上传任务
    [self batchUploadObjects];
        
}

@end
