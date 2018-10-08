//
//  QCloudCOSTransferTests.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TestCommonDefine.h"
#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import "QCloudTestTempVariables.h"
#import "QCloudCOSXMLTestUtility.h"
#define kHTTPServiceKey @"HTTPService"
@interface QCloudCOSTransferTests : XCTestCase <QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSMutableArray* tempFilePathArray;
@end

@implementation QCloudCOSTransferTests

+ (void)setUp {
    [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
    
}


+ (void)tearDown {
    [[QCloudCOSXMLTestUtility sharedInstance]deleteAllTestBuckets];
}

- (void)setUp {
    [super setUp];
    self.tempFilePathArray = [[NSMutableArray alloc] init];
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [QCloudTestTempVariables sharedInstance].testBucket = [[QCloudCOSXMLTestUtility sharedInstance] createTestBucket];
//    });
    self.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    [self registerHTTPTransferManager];
}

- (void)tearDown {
    [super tearDown];
    NSFileManager* manager = [NSFileManager defaultManager];
    
    for (NSString* tempFilePath in self.tempFilePathArray) {
        if ([manager fileExistsAtPath:tempFilePath]) {
            [manager removeItemAtPath:tempFilePath error:nil];
        }
    }
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = kSecretID;
    credential.secretKey = kSecretKey;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);
}

- (NSString*) tempFileWithSize:(int)size
{
    NSString* file4MBPath = QCloudPathJoin(QCloudTempDir(), [NSUUID UUID].UUIDString);
    
    if (!QCloudFileExist(file4MBPath)) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    [handler truncateFileAtOffset:size];
    [handler closeFile];
    [self.tempFilePathArray  addObject:file4MBPath];

    return file4MBPath;
}

- (void)registerHTTPTransferManager {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1253653367";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.useHTTPS = YES;
    endpoint.regionName = @"cn-north";
    configuration.endpoint = endpoint;
    
    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:kHTTPServiceKey];
    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:kHTTPServiceKey];
}

- (void) testRegisterCustomManagerService
{
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1251668577";
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"cn-south";
    configuration.endpoint = endpoint;
    
    NSString* serviceKey = @"test";
    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:serviceKey];
    
    QCloudCOSTransferMangerService* service = [QCloudCOSTransferMangerService costransfermangerServiceForKey:serviceKey];
    XCTAssertNotNil(service);
}

- (void) testMultiUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:150*1024*1024 + randomNumber]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block QCloudUploadObjectResult* result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
    XCTAssertNotNil([result location]);
    
}

- (void) testHTTPSMultipleUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:150*1024*1024 + randomNumber]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService costransfermangerServiceForKey:kHTTPServiceKey] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void) testChineseFileNameBigfileUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:15*1024*1024 + randomNumber]];
    put.object = @"中文名大文件";
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        result = outputObject;
        [exp fulfill];
    }];
    [put setInitMultipleUploadFinishBlock:^(QCloudInitiateMultipartUploadResult* result,QCloudCOSXMLUploadObjectResumeData resumeData) {
        NSString* uploadID = result.uploadId;
        NSLog(@"UploadID%@",uploadID);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}

- (void)testChineseFileNameSmallFileUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:200 + randomNumber]];
    put.object = @"中文名小文件";
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void)testSpecialCharacterFileNameBigFileUpoload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:15*1024*1024 + randomNumber]];
    put.object = @"→↓←→↖↗↙↘! \"#$%&'()*+,-.0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void)testSpecialCharacterFileSmallFileUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:100 + randomNumber]];
    put.object = @"→↓←→↖↗↙↘! \"#$%&'()*+,-.0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void)testIntegerTimesSliceMultipartUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:50*1024*1024 ]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void) testChineseObjectName {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:1024 ]];
    put.object = @"一个文件名→↓←→↖↗↙↘! \"#$%&'()*+,-./0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_";
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        XCTAssertNil(error);
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void)testSmallSizeUpload {
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:1024 ]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
    
}
- (void) testAbortMultiUpload{
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:304*1024*1024 + randomNumber]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudUploadObjectResult* result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];

    [put setInitMultipleUploadFinishBlock:^(QCloudInitiateMultipartUploadResult *multipleUploadInitResult, QCloudCOSXMLUploadObjectResumeData resumeData) {
        XCTAssertNotNil(multipleUploadInitResult.uploadId,@"UploadID is null!");
        
        QCloudCOSXMLUploadObjectRequest* uploadObjectRequest = [QCloudCOSXMLUploadObjectRequest requestWithRequestData:resumeData];
        XCTAssertNotNil([uploadObjectRequest valueForKey:@"uploadId"],@"request produce from resume data is nil!");
        NSLog(@"pause here");
        
    }];
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    XCTestExpectation* hintExp = [self expectationWithDescription:@"abort"];

    __block id abortResult = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [put abort:^(id outputObject, NSError *error) {
            abortResult = outputObject;
            [hintExp fulfill];
        }];
        
    });
    [self waitForExpectationsWithTimeout:80000 handler:nil];
    XCTAssertNotNil(abortResult);
}

- (void) testPauseAndResume {
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:30*1024*1024]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    
    __block QCloudUploadObjectResult* result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
    }];
    
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    
    
    __block QCloudCOSXMLUploadObjectResumeData resumeData = nil;
    XCTestExpectation* resumeExp = [self expectationWithDescription:@"delete2"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError* error;
        resumeData = [put cancelByProductingResumeData:&error];
        if (resumeData) {
            QCloudCOSXMLUploadObjectRequest* request = [QCloudCOSXMLUploadObjectRequest requestWithRequestData:resumeData];
            [request setFinishBlock:^(QCloudUploadObjectResult* outputObject, NSError *error) {
                result = outputObject;
                [resumeExp fulfill];
            }];
            
            [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
            }];
            [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
        } else {
            [resumeExp fulfill];
        }
    });


    [self waitForExpectationsWithTimeout:80000 handler:nil];
    XCTAssertNotNil(result);
    XCTAssertNotNil(result.location);
    XCTAssertNotNil(result.eTag);
}

- (void)testSimpleUploadObjectWithServerSideEncryption {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:1*1024]];
    __block NSString* object = [NSUUID UUID].UUIDString;
    put.object = object;
    put.bucket = self.bucket;
    put.body =  url;
    NSString* originalMD5 = QCloudEncrytFileMD5(url.path);
    put.customHeaders = @{@"x-cos-server-side-encryption":@"AES256"};
    XCTestExpectation* expectation = [self expectationWithDescription:@"simple upload object with server side encryption"];
    [put setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
        XCTAssertNotNil(result, @"upload result is nil!");
        XCTAssertNotNil(result.__originHTTPURLResponse__,@"original responsee data is nil!");
        XCTAssertNotNil(result.__originHTTPURLResponse__.allHeaderFields[@"x-cos-server-side-encryption"],@"cannot found x-cos-server-side-encryption header in reponse");
        XCTAssert([result.__originHTTPURLResponse__.allHeaderFields[@"x-cos-server-side-encryption"] isEqualToString:@"AES256"]);
        
        QCloudGetObjectRequest* getObjectRequest = [[QCloudGetObjectRequest alloc] init];
        getObjectRequest.bucket = self.bucket;
        getObjectRequest.object = object;
        NSURL* downloadPath = [NSURL fileURLWithPath:[QCloudTempDir() stringByAppendingPathComponent:@"temp"]];
        getObjectRequest.downloadingURL = downloadPath;
        [getObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
            XCTAssertNil(error,@"download object fail, error is %@",error);
            XCTAssertNotNil(outputObject[@"x-cos-server-side-encryption"]);
            NSString* downloadedMD5 = QCloudEncrytFileMD5(downloadPath.path);
            XCTAssert([downloadedMD5 isEqualToString:originalMD5],@"downloaded md5 is not equal to original md5!");
            [expectation fulfill];
        }];
        [[QCloudCOSXMLService defaultCOSXML] GetObject:getObjectRequest];
        
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

//- (void)testMultipartUploadObjectWithServerSideEncryption {
//    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
//    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:10*1024*1024]];
//    __block NSString* object = [NSUUID UUID].UUIDString;
//    put.object = object;
//    put.bucket = self.bucket;
//    put.body =  url;
//    NSString* originalMD5 = QCloudEncrytFileMD5(url.path);
//    put.customHeaders = @{@"x-cos-server-side-encryption":@"AES256"};
//    XCTestExpectation* expectation = [self expectationWithDescription:@"simple upload object with server side encryption"];
//    [put setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
//        XCTAssertNotNil(result, @"upload result is nil!");
//        XCTAssertNotNil(result.__originHTTPURLResponse__,@"original responsee data is nil!");
//        XCTAssertNotNil(result.__originHTTPURLResponse__.allHeaderFields[@"x-cos-server-side-encryption"],@"cannot found x-cos-server-side-encryption header in reponse");
//        XCTAssert([result.__originHTTPURLResponse__.allHeaderFields[@"x-cos-server-side-encryption"] isEqualToString:@"AES256"]);
//        
//        QCloudGetObjectRequest* getObjectRequest = [[QCloudGetObjectRequest alloc] init];
//        getObjectRequest.bucket = self.bucket;
//        getObjectRequest.object = object;
//        NSURL* downloadPath = [NSURL fileURLWithPath:[QCloudTempDir() stringByAppendingPathComponent:@"temp"]];
//        getObjectRequest.downloadingURL = downloadPath;
//        [getObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
//            XCTAssertNil(error,@"download object fail, error is %@",error);
//            NSString* downloadedMD5 = QCloudEncrytFileMD5(downloadPath.path);
//            XCTAssert([downloadedMD5 isEqualToString:originalMD5],@"downloaded md5 is not equal to original md5!");
//        }];
//        [expectation fulfill];
//    }];
//    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//}

@end
