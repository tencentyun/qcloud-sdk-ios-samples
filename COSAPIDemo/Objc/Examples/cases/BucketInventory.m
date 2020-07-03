#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketInventory : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketInventory

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
 * 设置存储桶清单任务
 */
- (void)putBucketInventory {
    XCTestExpectation* exp = [self expectationWithDescription:@"putBucketInventory"];

    //.cssg-snippet-body-start:[objc-put-bucket-inventory]
    QCloudPutBucketInventoryRequest *putReq = [QCloudPutBucketInventoryRequest new];
       putReq.bucket= @"examplebucket-1250000000";
       putReq.inventoryID = @"list1";
       QCloudInventoryConfiguration *config = [QCloudInventoryConfiguration new];
       config.identifier = @"list1";
       config.isEnabled = @"True";
       QCloudInventoryDestination *des = [QCloudInventoryDestination new];
       QCloudInventoryBucketDestination *btDes =[QCloudInventoryBucketDestination new];
       btDes.cs = @"CSV";
       btDes.account = @"1278687956";
       btDes.bucket  = @"qcs::cos:ap-guangzhou::examplebucket-1250000000";
       btDes.prefix = @"list1";
       QCloudInventoryEncryption *enc = [QCloudInventoryEncryption new];
       enc.ssecos = @"";
       btDes.encryption = enc;
       des.bucketDestination = btDes;
       config.destination = des;
       QCloudInventorySchedule *sc = [QCloudInventorySchedule new];
       sc.frequency = @"Daily";
       config.schedule = sc;
       QCloudInventoryFilter *fileter = [QCloudInventoryFilter new];
       fileter.prefix = @"myPrefix";
       config.filter = fileter;
       config.includedObjectVersions = QCloudCOSIncludedObjectVersionsAll;
       QCloudInventoryOptionalFields *fields = [QCloudInventoryOptionalFields new];
       fields.field = @[ @"Size",@"LastModifiedDate",@"ETag",@"StorageClass",@"IsMultipartUploaded",@"ReplicationStatus"];
       config.optionalFields = fields;
       putReq.inventoryConfiguration = config;
       [putReq setFinishBlock:^(id outputObject, NSError *error) {
    
    
       }];
       [[QCloudCOSXMLService defaultCOSXML] PutBucketInventory:putReq];
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 获取存储桶清单任务
 */
- (void)getBucketInventory {
    XCTestExpectation* exp = [self expectationWithDescription:@"getBucketInventory"];

    //.cssg-snippet-body-start:[objc-get-bucket-inventory]
    QCloudGetBucketInventoryRequest *getReq = [QCloudGetBucketInventoryRequest new];
    getReq.bucket = @"examplebucket-1250000000";
    getReq.inventoryID = @"list1";
    [getReq setFinishBlock:^(QCloudInventoryConfiguration * _Nonnull result, NSError * _Nonnull error) {
    
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketInventory:getReq];
    
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}

/**
 * 删除存储桶清单任务
 */
- (void)deleteBucketInventory {
    XCTestExpectation* exp = [self expectationWithDescription:@"deleteBucketInventory"];

    //.cssg-snippet-body-start:[objc-delete-bucket-inventory]
    QCloudDeleteBucketInventoryRequest *delReq = [QCloudDeleteBucketInventoryRequest new];
    delReq.bucket = @"examplebucket-1250000000";
    delReq.inventoryID = @"list1";
    [delReq setFinishBlock:^(id outputObject, NSError *error) {
    
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketInventory:delReq];
    
    
    //.cssg-snippet-body-end

    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void)testBucketInventory {
    // 设置存储桶清单任务
    [self putBucketInventory];
        
    // 获取存储桶清单任务
    [self getBucketInventory];
        
    // 删除存储桶清单任务
    [self deleteBucketInventory];
        
}

@end