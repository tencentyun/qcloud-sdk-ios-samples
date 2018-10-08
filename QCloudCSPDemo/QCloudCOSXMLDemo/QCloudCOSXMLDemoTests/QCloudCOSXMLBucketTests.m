//
//  QCloudCOSXMLBucketTests.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import <QCloudCore/QCloudCore.h>
#import "TestCommonDefine.h"
#import "QCloudCOSXMLServiceUtilities.h"
#import "QCloudTestTempVariables.h"
#import "QCloudCOSXMLTestUtility.h"
@interface QCloudCOSXMLBucketTests : XCTestCase<QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* authorizedUIN;
@property (nonatomic, strong) NSString* ownerUIN;
@property (nonatomic, strong) NSString* appID;
@end






@implementation QCloudCOSXMLBucketTests


- (void)signatureWithFields:(QCloudSignatureFields *)fileds request:(QCloudBizHTTPRequest *)request urlRequest:(NSMutableURLRequest *)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = @"AKIDTmqfJivoU6XllcsfroX3KNBl7JGzvt0s";
    credential.secretKey = @"mR1eJvUvKi2EDyWu40kHZdYJrBHApGUV";
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);

}

- (void) setupSpecialCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [[QCloudServiceConfiguration alloc] init];
    configuration.appID = kAppID;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";
    configuration.endpoint = endpoint;
    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:@"aclService"];
}

+ (void)setUp {
        [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];

}


+ (void)tearDown {
    [[QCloudCOSXMLTestUtility sharedInstance] deleteAllTestBuckets];
}

- (void)setUp {
    [super setUp];
    [self setupSpecialCOSXMLShareService];
//    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    self.appID = @"1253653367";
    self.authorizedUIN = @"1131975903";
    self.ownerUIN = @"1278687956";
}

- (void)createTestBucket {
    QCloudPutBucketRequest* request = [QCloudPutBucketRequest new];
    __block NSString* bucketName = [NSString stringWithFormat:@"bucketcanbedelete%i",arc4random()%1000];
    request.bucket = bucketName;
    XCTestExpectation* exception = [self expectationWithDescription:@"Put new bucket exception"];
    __block NSError* responseError ;
    __weak typeof(self) weakSelf = self;
    [request setFinishBlock:^(id outputObject, NSError* error) {
        XCTAssertNil(error);
        self.bucket = bucketName;
        [QCloudTestTempVariables sharedInstance].testBucket = bucketName;
        responseError = error;
        [exception fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucket:request];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [[QCloudCOSXMLTestUtility sharedInstance] deleteTestBucket:self.bucket];
    [super tearDown];
}


- (void)testGetService {
    QCloudGetServiceRequest* request = [[QCloudGetServiceRequest alloc] init];
    XCTestExpectation* expectation = [self expectationWithDescription:@"Get service"];
    [request setFinishBlock:^(QCloudListAllMyBucketsResult* result, NSError* error) {
        XCTAssertNil(error);
        XCTAssert(result);
        XCTAssertNotNil(result.owner);
        XCTAssertNotNil(result.buckets);
        XCTAssert(result.buckets.count > 0,@"buckets not more than zero, it is %lu",(unsigned long)result.buckets.count);
        XCTAssertNotNil(result.buckets.firstObject.name);
        XCTAssertNotNil(result.buckets.firstObject.location);
        XCTAssertNotNil(result.buckets.firstObject.createDate);
        [expectation fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetService:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

- (void)testPutAndDeleteBucket {
    XCTestExpectation* exception = [self expectationWithDescription:@"Delete bucket exception"];
    __block NSError* responseError ;
    QCloudPutBucketRequest* putBucketRequest = [[QCloudPutBucketRequest alloc] init];
    NSString* bucketName = [NSString stringWithFormat:@"bucketshouldbedelete%ld",arc4random()%10000];
    putBucketRequest.bucket = bucketName;
    [putBucketRequest setFinishBlock:^(id outputObject, NSError* error) {
        XCTAssertNil(error);
        if (!error) {
            QCloudDeleteBucketRequest* request = [[QCloudDeleteBucketRequest alloc ] init];
            request.bucket = bucketName;
            [request setFinishBlock:^(id outputObject,NSError*error) {
                responseError = error;
                [exception fulfill];
            }];
            [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:request];
        } else {
            [exception fulfill];
        }
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucket:putBucketRequest];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNil(responseError);
}


//- (void)testPutBucket {
//    QCloudPutBucketRequest* putBucketRequest = [[QCloudPutBucketRequest alloc] init];
//    putBucketRequest.bucket = @"v4-yfb-bucket";
//    XCTestExpectation* expectation = [self expectationWithDescription:@"putBucket"];
//
//    [putBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
//        [expectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] PutBucket:putBucketRequest];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//
//}

- (void) testGetBucket {
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    request.bucket = self.bucket;
    request.maxKeys = 1000;
    request.prefix = @"0";
    request.delimiter = @"0";
    request.encodingType = @"url";
    
    request.prefix = request.delimiter = request.encodingType = nil;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block QCloudListBucketResult* listResult;
    [request setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
        listResult = result;
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    XCTAssertNotNil(listResult);
    NSString* listResultName = listResult.name;
    NSString* expectListResultName = [NSString stringWithFormat:@"%@-%@",self.bucket,self.appID];
    XCTAssert([listResultName isEqualToString:expectListResultName]);
}

- (void) testCORS1_PutBucketCORS {
    QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
    QCloudCORSConfiguration* cors = [QCloudCORSConfiguration new];
    
    QCloudCORSRule* rule = [QCloudCORSRule new];
    rule.identifier = @"sdk";
    rule.allowedHeader = @[@"origin",@"host",@"accept",@"content-type",@"authorization"];
    rule.exposeHeader = @"ETag";
    rule.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
    rule.maxAgeSeconds = 3600;
    rule.allowedOrigin = @"*";
    
    cors.rules = @[rule];
    
    putCORS.corsConfiguration = cors;
    putCORS.bucket = self.bucket;
    __block NSError* localError;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [putCORS setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(localError);
}

- (void) testCORS2_GetBucketCORS {
    
    QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
    QCloudCORSConfiguration* putCors = [QCloudCORSConfiguration new];
    
    QCloudCORSRule* rule = [QCloudCORSRule new];
    rule.identifier = @"sdk";
    rule.allowedHeader = @[@"origin",@"accept",@"content-type",@"authorization"];
    rule.exposeHeader = @"ETag";
    rule.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
    rule.maxAgeSeconds = 3600;
    rule.allowedOrigin = @"*";
    
    putCors.rules = @[rule];
    
    putCORS.corsConfiguration = putCors;
    putCORS.bucket = self.bucket;
    __block NSError* localError1;
    
    
    __block QCloudCORSConfiguration* cors;
    __block XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    
    [putCORS setFinishBlock:^(id outputObject, NSError *error) {
        
        
        
        QCloudGetBucketCORSRequest* corsReqeust = [QCloudGetBucketCORSRequest new];
        corsReqeust.bucket = self.bucket;
        
        [corsReqeust setFinishBlock:^(QCloudCORSConfiguration * _Nonnull result, NSError * _Nonnull error) {
            XCTAssertNil(error);
            cors = result;
            [exp fulfill];
        }];
        
        [[QCloudCOSXMLService defaultCOSXML] GetBucketCORS:corsReqeust];

        
    }];
    
    
    [[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(cors);
    XCTAssert([[[cors.rules firstObject] identifier] isEqualToString:@"sdk"]);
    XCTAssertEqual(1, cors.rules.count);
    XCTAssertEqual([cors.rules.firstObject.allowedMethod count], 5);
    XCTAssert([cors.rules.firstObject.allowedMethod containsObject:@"PUT"]);
    XCTAssert([cors.rules.firstObject.allowedHeader count] == 4);
    XCTAssert([cors.rules.firstObject.exposeHeader isEqualToString:@"ETag"]);
}


- (void)testCORS3_OpetionObject {
    QCloudOptionsObjectRequest* request = [[QCloudOptionsObjectRequest alloc] init];
    request.bucket = self.bucket;
    request.origin = @"http://www.qcloud.com";
    request.accessControlRequestMethod = @"GET";
    request.accessControlRequestHeaders = @"origin";
    request.object = [[QCloudCOSXMLTestUtility sharedInstance] uploadTempObjectInBucket:self.bucket];
    XCTestExpectation* exp = [self expectationWithDescription:@"option object"];
    
    __block id resultError;
    [request setFinishBlock:^(id outputObject, NSError* error) {
        resultError = error;
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] OptionsObject:request];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    XCTAssertNil(resultError);

    
}

- (void) testCORS4_DeleteBucketCORS {
    QCloudDeleteBucketCORSRequest* deleteCORS = [QCloudDeleteBucketCORSRequest new];
    deleteCORS.bucket = self.bucket;
    
    NSLog(@"test");
    
    
    __block NSError* localError;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
//    [deleteCORS setFinishBlock:^(id outputObject, NSError *error) {
//        localError = error;
//        [exp fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketCORS:deleteCORS];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"after");
        [exp fulfill];
    });
    [self waitForExpectationsWithTimeout:80 handler:nil];
    XCTAssertNil(localError);
}


- (void) testGetBucketLocation {
    QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
    locationReq.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudBucketLocationConstraint* location;
    
    
    [locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
        location = result;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(location);
    NSString* currentLocation;
    
#ifdef CNNORTH_REGION
    currentLocation = @"ap-beijing-1";
#else 
    currentLocation = @"ap-guangzhou";
#endif
    XCTAssert([location.locationConstraint isEqualToString:kRegion]);
}

- (void) testPut_And_Get_BucketACL {
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    putACL.runOnService = [QCloudCOSXMLService cosxmlServiceForKey:@"aclService"];
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", self.authorizedUIN,self.authorizedUIN];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.grantFullControl = grantString;
    putACL.grantRead = grantString;
    putACL.grantWrite = grantString;
    putACL.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    __block NSError* localError;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        QCloudGetBucketACLRequest* getBucketACLRequest = [[QCloudGetBucketACLRequest alloc] init];
        getBucketACLRequest.bucket = self.bucket;
        [getBucketACLRequest setFinishBlock:^(QCloudACLPolicy* result, NSError* error) {
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            NSString* ownerIdentifiler = [NSString identifierStringWithID:self.ownerUIN :self.ownerUIN];
            XCTAssert([result.owner.identifier isEqualToString:ownerIdentifiler],@"result Owner Identifier is%@",result.owner.identifier);
            [exp fulfill];
        }];
        [[QCloudCOSXMLService  defaultCOSXML] GetBucketACL:getBucketACLRequest];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNil(localError);

}








- (void)testHeadBucket {
    QCloudHeadBucketRequest* request = [QCloudHeadBucketRequest new];
    request.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    __block NSError* resultError;
    [request setFinishBlock:^(id outputObject, NSError* error) {
        resultError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] HeadBucket:request];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(resultError);
}



- (void)testListMultipartUpload {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    QCloudCOSXMLUploadObjectRequest* uploadObjectRequest = [[QCloudCOSXMLUploadObjectRequest alloc] init];
    uploadObjectRequest.bucket = self.bucket;
    uploadObjectRequest.object = @"object-aborted";
    uploadObjectRequest.body = [NSURL URLWithString:[QCloudTestUtility tempFileWithSize:5 unit:QCLOUD_TEST_FILE_UNIT_MB]];
    __weak QCloudCOSXMLUploadObjectRequest* weakRequest = uploadObjectRequest;
    __block NSString* uploadID ;
    [uploadObjectRequest setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        if (totalBytesSent > totalBytesExpectedToSend*0.5 ) {
            [weakRequest cancel];
        }
    }];
    uploadObjectRequest.initMultipleUploadFinishBlock = ^(QCloudInitiateMultipartUploadResult *multipleUploadInitResult, QCloudCOSXMLUploadObjectResumeData resumeData) {
        uploadID = multipleUploadInitResult.uploadId;
    };
    [uploadObjectRequest setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:uploadObjectRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    
    QCloudListMultipartRequest* request = [[QCloudListMultipartRequest alloc] init];
    request.bucket = self.bucket;
    request.object = uploadObjectRequest.object;
    request.uploadId = uploadID;

    XCTestExpectation* expectation = [self expectationWithDescription:@"test" ];
    [request setFinishBlock:^(QCloudListPartsResult * _Nonnull result, NSError * _Nonnull error) {
        XCTAssertNil(error);
        XCTAssert(result);
        [expectation fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] ListMultipart:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}


- (void) testListBucketUploads {
    QCloudListBucketMultipartUploadsRequest* uploads = [QCloudListBucketMultipartUploadsRequest new];
    uploads.bucket = self.bucket;
    uploads.maxUploads = 1000;
    __block NSError* localError;
    __block QCloudListMultipartUploadsResult* multiPartUploadsResult;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [uploads setFinishBlock:^(QCloudListMultipartUploadsResult* result, NSError *error) {
        multiPartUploadsResult = result;
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] ListBucketMultipartUploads:uploads];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    
    XCTAssertNil(localError);
    XCTAssert(multiPartUploadsResult.maxUploads==1000);
    NSString* expectedBucketString = [NSString stringWithFormat:@"%@-%@",self.bucket,self.appID];
    XCTAssert([multiPartUploadsResult.bucket isEqualToString:expectedBucketString]);
    XCTAssert(multiPartUploadsResult.maxUploads == 1000);
    if (multiPartUploadsResult.uploads.count) {
        QCloudListMultipartUploadContent* firstContent = [multiPartUploadsResult.uploads firstObject];
        XCTAssert([firstContent.owner.displayName isEqualToString:@"1278687956"]);
        XCTAssert([firstContent.initiator.displayName isEqualToString:@"1278687956"]);
        XCTAssertNotNil(firstContent.uploadID);
        XCTAssertNotNil(firstContent.key);
    }
}

- (void)testaPut_Get_Delete_BucketLifeCycle {
    QCloudPutBucketLifecycleRequest* request = [QCloudPutBucketLifecycleRequest new];
    request.bucket = self.bucket;
   __block QCloudLifecycleConfiguration* configuration = [[QCloudLifecycleConfiguration alloc] init];
    QCloudLifecycleRule* rule = [[QCloudLifecycleRule alloc] init];
    rule.identifier = @"id1";
    rule.status = QCloudLifecycleStatueEnabled;
    QCloudLifecycleRuleFilter* filter = [[QCloudLifecycleRuleFilter alloc] init];
    filter.prefix = @"0";
    rule.filter = filter;
    
    QCloudLifecycleTransition* transition = [[QCloudLifecycleTransition alloc] init];
    transition.days = 100;
    transition.storageClass = QCloudCOSStorageStandardIA;
    rule.transition = transition;
    request.lifeCycle = configuration;
    request.lifeCycle.rules = @[rule];
    XCTestExpectation* exception = [self expectationWithDescription:@"Put Bucket Life cycle exception"];
    [request setFinishBlock:^(id outputObject, NSError* putLifecycleError) {
        XCTAssertNil(putLifecycleError);
        //Get Configuration
        XCTAssertNil(putLifecycleError);
        
        QCloudGetBucketLifecycleRequest* request = [QCloudGetBucketLifecycleRequest new];
        request.bucket = self.bucket;
        [request setFinishBlock:^(QCloudLifecycleConfiguration* getLifecycleReuslt,NSError* getLifeCycleError) {
            XCTAssertNil(getLifeCycleError);
            XCTAssertNotNil(getLifecycleReuslt);
            XCTAssert(getLifecycleReuslt.rules.count==configuration.rules.count);
            XCTAssert([getLifecycleReuslt.rules.firstObject.identifier isEqualToString:configuration.rules.firstObject.identifier]);
            XCTAssert(getLifecycleReuslt.rules.firstObject.status==configuration.rules.firstObject.status);
            
            //delete configuration
            QCloudDeleteBucketLifeCycleRequest* request = [[QCloudDeleteBucketLifeCycleRequest alloc ] init];
            request.bucket = self.bucket;
            [request setFinishBlock:^(QCloudLifecycleConfiguration* deleteResult, NSError* deleteError) {
                XCTAssert(deleteResult);
                XCTAssertNil(deleteError);
                [exception fulfill];
            }];
            [[QCloudCOSXMLService defaultCOSXML] DeleteBucketLifeCycle:request];
            //delete configuration end
            
        }];
        [[QCloudCOSXMLService defaultCOSXML] GetBucketLifecycle:request];
        //Get configuration end
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketLifecycle:request];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}



- (void)testPut_And_Get_BucketVersioning {
    QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
    request.bucket = @"xiaodaxiansource";
    QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
    request.configuration = configuration;
    configuration.status = QCloudCOSBucketVersioningStatusEnabled;
    XCTestExpectation* expectation = [self expectationWithDescription:@"Put Bucket Versioning"];
    [request setFinishBlock:^(id outputObject, NSError* error) {
            XCTAssertNil(error);
        
        
            QCloudGetBucketVersioningRequest* request = [[QCloudGetBucketVersioningRequest alloc] init];
            request.bucket = self.bucket;
            [request setFinishBlock:^(QCloudBucketVersioningConfiguration* result, NSError* error) {
                XCTAssert(result);
                XCTAssertNil(error);
                [expectation fulfill];
            }];
            [[QCloudCOSXMLService defaultCOSXML] GetBucketVersioning:request];
        
             
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    //
    QCloudPutBucketVersioningRequest* suspendRequest = [[QCloudPutBucketVersioningRequest alloc] init];
    suspendRequest.bucket = self.bucket;
    QCloudBucketVersioningConfiguration* suspendConfiguration = [[QCloudBucketVersioningConfiguration alloc] init];
    request.configuration = suspendConfiguration;
    suspendConfiguration.status = QCloudCOSBucketVersioningStatusSuspended;
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
}

- (void)testPut_Get_Delte_BucketReplication {
    
    __block NSString* sourceBucket = @"xiaodaxiansource";
    __block NSString* destinationBucket = @"replication-destination";
    __block NSString* destinationRegion = @"ap-guangzhou";

    //enable bucket versioning first
    QCloudPutBucketVersioningRequest* destinationPutBucketVersioningRequest = [[QCloudPutBucketVersioningRequest alloc] init];
    destinationPutBucketVersioningRequest.bucket = destinationBucket;
    QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
    destinationPutBucketVersioningRequest.configuration = configuration;
    configuration.status = QCloudCOSBucketVersioningStatusEnabled;
    XCTestExpectation* putDestinationBucketVersioningExpectation = [self expectationWithDescription:@"Put Bucket Versioning first "];
    [destinationPutBucketVersioningRequest setFinishBlock:^(id outputObject, NSError* error) {
        [putDestinationBucketVersioningExpectation fulfill];
        XCTAssertNil(error);
    }];
    __block NSString* previousRegion = [QCloudCOSXMLService  defaultCOSXML].configuration.endpoint.regionName;
    [QCloudCOSXMLService  defaultCOSXML].configuration.endpoint.regionName = destinationRegion;
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:destinationPutBucketVersioningRequest];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        [QCloudCOSXMLService  defaultCOSXML].configuration.endpoint.regionName = previousRegion;
    }];
    
    
    
    
    
    QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
    request.bucket = sourceBucket;
//    QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
    request.configuration = configuration;
    configuration.status = QCloudCOSBucketVersioningStatusEnabled;
    XCTestExpectation* expectation = [self expectationWithDescription:@"Put Bucket Versioning"];
    [request setFinishBlock:^(id outputObject, NSError* error) {
        XCTAssertNil(error);
        
        // put bucket replication
        QCloudPutBucketReplicationRequest* request = [[QCloudPutBucketReplicationRequest alloc] init];
        request.bucket = sourceBucket;
        QCloudBucketReplicationConfiguation* configuration = [[QCloudBucketReplicationConfiguation alloc] init];
        configuration.role = [NSString identifierStringWithID:@"1278687956" :@"1278687956"];
        QCloudBucketReplicationRule* rule = [[QCloudBucketReplicationRule alloc] init];
        
        rule.identifier = [NSUUID UUID].UUIDString;
        rule.status = QCloudCOSXMLStatusEnabled;
        
        QCloudBucketReplicationDestination* destination = [[QCloudBucketReplicationDestination alloc] init];
        //qcs:id/0:cos:[region]:appid/[AppId]:[bucketname]
//        NSString* destinationBucket = destinationBucket;
        destination.bucket = [NSString stringWithFormat:@"qcs:id/0:cos:%@:appid/%@:%@",destinationRegion,self.appID,destinationBucket];
        rule.destination = destination;
        configuration.rule = @[rule];
        request.configuation = configuration;
        [request setFinishBlock:^(id outputObject, NSError* error) {
            XCTAssertNil(error);
            // get bucket replication
            QCloudGetBucketReplicationRequest* request = [[QCloudGetBucketReplicationRequest alloc] init];
            request.bucket =sourceBucket;
            [request setFinishBlock:^(QCloudBucketReplicationConfiguation* result, NSError* error) {
                XCTAssertNil(error);
                XCTAssertNotNil(result);
                
                
                //delete bucket replication
                QCloudDeleteBucketReplicationRequest* request = [[QCloudDeleteBucketReplicationRequest alloc] init];
                request.bucket = sourceBucket;
                [request setFinishBlock:^(id outputObject, NSError* error) {
                    XCTAssertNil(error);
                    [expectation fulfill];
                }];
                [[QCloudCOSXMLService defaultCOSXML] DeleteBucketReplication:request];
                //delete bucket replication end
                
                
            }];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_semaphore_wait(semaphore, 5*NSEC_PER_SEC);
            [[QCloudCOSXMLService defaultCOSXML] GetBucketReplication:request];
            
            
            // get bucket replication end
            
            
            
            
            
        }];
        [[QCloudCOSXMLService defaultCOSXML] PutBucketRelication:request];
        // put bucket replication end
        
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    //
//    QCloudPutBucketVersioningRequest* suspendRequest = [[QCloudPutBucketVersioningRequest alloc] init];
//    suspendRequest.bucket = self.bucket;
//    QCloudBucketVersioningConfiguration* suspendConfiguration = [[QCloudBucketVersioningConfiguration alloc] init];
//    request.configuration = suspendConfiguration;
//    suspendConfiguration.status = QCloudCOSBucketVersioningStatusSuspended;
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
 
}
//
//- (void)testNewPut_Get_DeleteBucketReplication {
//    NSString* tempBucket = @"bucketcanbedeleteReplication";
//    NSString* tempRegionName = @"ap-guangzhou";
//    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
//    endpoint.regionName = tempRegionName;
//    QCloudServiceConfiguration* tempServiceConfiguration = [[QCloudServiceConfiguration alloc] init];
//    tempServiceConfiguration.endpoint = endpoint;
//    QCloudCOSXMLService* tempService = [[QCloudCOSXMLService alloc] initWithConfiguration:tempServiceConfiguration];
//    
//    
//    
//    // Put a temp bucket for testing first.
//    XCTestExpectation* putBucketExpectation = [self expectationWithDescription:@"Put temp bucket"];
//    QCloudPutBucketRequest* putBucketRequest = [[QCloudPutBucketRequest alloc] init];
//    putBucketRequest.bucket = tempBucket;
//    [putBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error,@"Put Bucket error!");
//        [putBucketExpectation fulfill];
//    }];
//    [tempService PutBucket:putBucketRequest];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//    
//    
//    // Then enable replication for source bucket;
//    XCTestExpectation* putReplicationExpectation = [self expectationWithDescription:@"put replication expectation"];
//    QCloudPutBucketReplicationRequest* putBucketReplicationRequest = [[QCloudPutBucketReplicationRequest alloc] init];
//    putBucketReplicationRequest.bucket = self.bucket;
//    QCloudBucketReplicationConfiguation* putReplicationConfiguration = [[QCloudBucketReplicationConfiguation alloc] init];
//    putBucketReplicationRequest.configuation = putReplicationConfiguration;
//    putReplicationConfiguration.status = QCloudCOSBucketVersioningStatusEnabled;
//    [putBucketReplicationRequest setFinishBlock:^(id outputObject, NSError *error) {
//        XCTAssertNil(error,@"")
//        [putReplicationExpectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] PutBucketRelication:putBucketReplicationRequest];
//    
//    
//}


//- (void)testBucketReplication2_GetBucektReplication {
//    QCloudGetBucketReplicationRequest* request = [[QCloudGetBucketReplicationRequest alloc] init];
//    request.bucket = @"xiaodaxiansource";
//
//    XCTestExpectation* expectation = [self expectationWithDescription:@"Get bucke replication" ];
//    [request setFinishBlock:^(QCloudBucketReplicationConfiguation* result, NSError* error) {
//        XCTAssertNil(error);
//        XCTAssertNotNil(result);
//        [expectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] GetBucketReplication:request];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//}
//
//- (void)testBucketReplication3_DeleteBucketReplication {
//    QCloudDeleteBucketReplicationRequest* request = [[QCloudDeleteBucketReplicationRequest alloc] init];
//    request.bucket = @"xiaodaxiansource";
//    XCTestExpectation* expectation = [self expectationWithDescription:@"delete bucket replication" ];
//    [request setFinishBlock:^(id outputObject, NSError* error) {
//        XCTAssertNil(error);
//        [expectation fulfill];
//    }];
//    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketReplication:request];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//
//}

@end
