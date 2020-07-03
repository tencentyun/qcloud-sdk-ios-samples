#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface MultiPartsUploadObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation MultiPartsUploadObject

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
 * 列出所有未完成的分片上传任务
 */
- (void)listMultiUpload {
    XCTestExpectation* exp = [self expectationWithDescription:@"listMultiUpload"];

    //.cssg-snippet-body-start:[objc-list-multi-upload]
    QCloudListBucketMultipartUploadsRequest* uploads = [QCloudListBucketMultipartUploadsRequest new];
    uploads.bucket = @"examplebucket-1250000000";
    uploads.maxUploads = 100;
    
    [uploads setFinishBlock:^(QCloudListMultipartUploadsResult* result, NSError *error) {
        //可以从 result 中返回分块信息
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] ListBucketMultipartUploads:uploads];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 上传一个分片
 */
- (void)uploadPart {
    XCTestExpectation* exp = [self expectationWithDescription:@"uploadPart"];

    //.cssg-snippet-body-start:[objc-upload-part]
    QCloudUploadPartRequest* request = [QCloudUploadPartRequest new];
    request.bucket = @"examplebucket-1250000000";
    request.object = @"exampleobject";
    request.partNumber = 1;
    //标识本次分块上传的 ID；使用 Initiate Multipart Upload 接口初始化分块上传时会得到一个 uploadId
    //该 ID 不但唯一标识这一分块数据，也标识了这分块数据在整个文件内的相对位置
    request.uploadId = @"exampleUploadId";
    //上传的数据：支持 NSData*，NSURL(本地 URL) 和 QCloudFileOffsetBody * 三种类型
    request.body = [@"testFileContent" dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setSendProcessBlock:^(int64_t bytesSent,
                                   int64_t totalBytesSent,
                                   int64_t totalBytesExpectedToSend) {
        //上传进度信息
    }];
    [request setFinishBlock:^(QCloudUploadPartResult* outputObject, NSError *error) {
        QCloudMultipartInfo *part = [QCloudMultipartInfo new];
        //获取所上传分块的 etag
        part.eTag = outputObject.eTag;
        part.partNumber = @"1";
        // 保存起来用于最好完成上传时使用
        self.parts = @[part];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML]  UploadPart:request];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 列出已上传的分片
 */
- (void)listParts {
    XCTestExpectation* exp = [self expectationWithDescription:@"listParts"];

    //.cssg-snippet-body-start:[objc-list-parts]
    QCloudListMultipartRequest* request = [QCloudListMultipartRequest new];
    request.object = @"exampleobject";
    request.bucket = @"examplebucket-1250000000";
    //在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
    request.uploadId = @"exampleUploadId";
    
    [request setFinishBlock:^(QCloudListPartsResult * _Nonnull result, NSError * _Nonnull error) {
        //从 result 中获取已上传分块信息
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] ListMultipart:request];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 完成分片上传任务
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


- (void)testMultiPartsUploadObject {
    // 初始化分片上传
    [self initMultiUpload];
        
    // 列出所有未完成的分片上传任务
    [self listMultiUpload];
        
    // 上传一个分片
    [self uploadPart];
        
    // 列出已上传的分片
    [self listParts];
        
    // 完成分片上传任务
    [self completeMultiUpload];
        
}

@end