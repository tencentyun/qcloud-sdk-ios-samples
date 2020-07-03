#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketWebsite : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketWebsite

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
 * 设置存储桶静态网站
 */
- (void)putBucketWebsite {
    XCTestExpectation* exp = [self expectationWithDescription:@"putBucketWebsite"];

    //.cssg-snippet-body-start:[objc-put-bucket-website]
    NSString *bucket = @"examplebucket-1250000000";
       NSString * regionName = @"ap-chengdu";
    
       NSString *indexDocumentSuffix = @"index.html";
       NSString *errorDocKey = @"error.html";
       NSString *derPro = @"https";
       int errorCode = 451;
       NSString * replaceKeyPrefixWith = @"404.html";
       QCloudPutBucketWebsiteRequest *putReq = [QCloudPutBucketWebsiteRequest new];
       putReq.bucket = bucket;
    
       QCloudWebsiteConfiguration *config = [QCloudWebsiteConfiguration new];
    
       QCloudWebsiteIndexDocument *indexDocument = [QCloudWebsiteIndexDocument new];
       indexDocument.suffix = indexDocumentSuffix;
       config.indexDocument = indexDocument;
    
       QCloudWebisteErrorDocument *errDocument = [QCloudWebisteErrorDocument new];
       errDocument.key = errorDocKey;
       config.errorDocument = errDocument;
    
    
       QCloudWebsiteRedirectAllRequestsTo *redir = [QCloudWebsiteRedirectAllRequestsTo new];
       redir.protocol  = @"https";
       config.redirectAllRequestsTo = redir;
    
    
       QCloudWebsiteRoutingRule *rule = [QCloudWebsiteRoutingRule new];
       QCloudWebsiteCondition *contition = [QCloudWebsiteCondition new];
       contition.httpErrorCodeReturnedEquals = errorCode;
       rule.condition = contition;
    
       QCloudWebsiteRedirect *webRe = [QCloudWebsiteRedirect new];
       webRe.protocol = @"https";
       webRe.replaceKeyPrefixWith = replaceKeyPrefixWith;
       rule.redirect = webRe;
    
       QCloudWebsiteRoutingRules *routingRules = [QCloudWebsiteRoutingRules new];
       routingRules.routingRule = @[rule];
       config.rules = routingRules;
       putReq.websiteConfiguration  = config;
    
    
       [putReq setFinishBlock:^(id outputObject, NSError *error) {
    
       }];
    
       [[QCloudCOSXMLService defaultCOSXML] PutBucketWebsite:putReq];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 获取存储桶静态网站
 */
- (void)getBucketWebsite {
    XCTestExpectation* exp = [self expectationWithDescription:@"getBucketWebsite"];

    //.cssg-snippet-body-start:[objc-get-bucket-website]
    QCloudGetBucketWebsiteRequest *getReq = [QCloudGetBucketWebsiteRequest new];
    getReq.bucket = @"examplebucket-1250000000";
    [getReq setFinishBlock:^(QCloudWebsiteConfiguration *  result, NSError * error) {
    
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketWebsite:getReq];
    
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 删除存储桶静态网站
 */
- (void)deleteBucketWebsite {
    XCTestExpectation* exp = [self expectationWithDescription:@"deleteBucketWebsite"];

    //.cssg-snippet-body-start:[objc-delete-bucket-website]
    QCloudDeleteBucketWebsiteRequest *delReq = [QCloudDeleteBucketWebsiteRequest new];
    delReq.bucket = "examplebucket-1250000000";
    [delReq setFinishBlock:^(id outputObject, NSError *error) {
    
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketWebsite:delReq];
    
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void)testBucketWebsite {
    // 设置存储桶静态网站
    [self putBucketWebsite];
        
    // 获取存储桶静态网站
    [self getBucketWebsite];
        
    // 删除存储桶静态网站
    [self deleteBucketWebsite];
        
}

@end