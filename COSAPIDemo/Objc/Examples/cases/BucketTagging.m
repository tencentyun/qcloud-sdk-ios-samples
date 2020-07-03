#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketTagging : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketTagging

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
 * 设置存储桶标签
 */
- (void)putBucketTagging {
    XCTestExpectation* exp = [self expectationWithDescription:@"putBucketTagging"];

    //.cssg-snippet-body-start:[objc-put-bucket-tagging]
    QCloudPutBucketTaggingRequest *putReq = [QCloudPutBucketTaggingRequest new];
    putReq.bucket = @"examplebucket-1250000000";
    
    QCloudBucketTagging *taggings = [QCloudBucketTagging new];
    QCloudBucketTag *tag1 = [QCloudBucketTag new];
    QCloudBucketTagSet *tagSet = [QCloudBucketTagSet new];
    taggings.tagSet = tagSet;
    tag1.key = @"age";
    tag1.value = @"20";
    QCloudBucketTag *tag2 = [QCloudBucketTag new];
    tag2.key = @"name";
    tag2.value = @"karis";
    tagSet.tag = @[tag1,tag2];
    putReq.taggings = taggings;
    
    [putReq setFinishBlock:^(id outputObject, NSError *error) {
    
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketTagging:putReq];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 获取存储桶标签
 */
- (void)getBucketTagging {
    XCTestExpectation* exp = [self expectationWithDescription:@"getBucketTagging"];

    //.cssg-snippet-body-start:[objc-get-bucket-tagging]
    QCloudGetBucketTaggingRequest *getReq = [QCloudGetBucketTaggingRequest new];
           getReq.bucket = @"examplebucket-1250000000";
           [getReq setFinishBlock:^(QCloudBucketTagging * result, NSError * error) {
           }];
           [[QCloudCOSXMLService defaultCOSXML] GetBucketTagging:getReq];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 删除存储桶标签
 */
- (void)deleteBucketTagging {
    XCTestExpectation* exp = [self expectationWithDescription:@"deleteBucketTagging"];

    //.cssg-snippet-body-start:[objc-delete-bucket-tagging]
    QCloudDeleteBucketTaggingRequest *delReq = [QCloudDeleteBucketTaggingRequest new];
    delReq.bucket =  @"examplebucket-1250000000";
    [delReq setFinishBlock:^(id outputObject, NSError *error) {
    
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketTagging:delReq];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void)testBucketTagging {
    // 设置存储桶标签
    [self putBucketTagging];
        
    // 获取存储桶标签
    [self getBucketTagging];
        
    // 删除存储桶标签
    [self deleteBucketTagging];
        
}

@end