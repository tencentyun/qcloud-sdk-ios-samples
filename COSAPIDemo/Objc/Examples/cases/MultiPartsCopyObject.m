#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface MultiPartsCopyObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation MultiPartsCopyObject

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
 * 拷贝一个分片
 */
- (void)uploadPartCopy {
    XCTestExpectation* exp = [self expectationWithDescription:@"uploadPartCopy"];

    //.cssg-snippet-body-start:[objc-upload-part-copy]
    QCloudUploadPartCopyRequest* request = [[QCloudUploadPartCopyRequest alloc] init];
    request.bucket = @"examplebucket-1250000000";
    request.object = @"exampleobject";
    //源文件 URL 路径，可以通过 versionid 子资源指定历史版本
    request.source = @"sourcebucket-1250000000.cos.COS_REGION.myqcloud.com/sourceObject";
    //在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
    request.uploadID = @"exampleUploadId";
    request.partNumber = 1; // 标志当前分块的序号
    
    [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
        QCloudMultipartInfo *part = [QCloudMultipartInfo new];
        //获取所复制分块的 etag
        part.eTag = result.eTag;
        part.partNumber = @"1";
        // 保存起来用于最后完成上传时使用
        self.parts=@[part];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML]UploadPartCopy:request];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 完成分片拷贝任务
 */
- (void)completeMultiUpload {
    XCTestExpectation* exp = [self expectationWithDescription:@"completeMultiUpload"];

    //.cssg-snippet-body-start:[objc-complete-multi-upload]
    QCloudCompleteMultipartUploadRequest *completeRequst = [QCloudCompleteMultipartUploadRequest new];
    completeRequst.object = @"exampleobject";
    completeRequst.bucket = @"examplebucket-1250000000";
    //本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果 QCloudInitiateMultipartUploadResult 中得到
    completeRequst.uploadId = @"exampleUploadId";
    //已上传分块的信息
    QCloudCompleteMultipartUploadInfo *partInfo = [QCloudCompleteMultipartUploadInfo new];
    partInfo.parts = self.parts;
    completeRequst.parts = partInfo;
    
    [completeRequst setFinishBlock:^(QCloudUploadObjectResult * _Nonnull result, NSError * _Nonnull error) {
        //从 result 中获取上传结果
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] CompleteMultipartUpload:completeRequst];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void)testMultiPartsCopyObject {
    // 初始化分片上传
    [self initMultiUpload];
        
    // 拷贝一个分片
    [self uploadPartCopy];
        
    // 完成分片拷贝任务
    [self completeMultiUpload];
        
}

@end