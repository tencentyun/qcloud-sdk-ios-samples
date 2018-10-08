//
//  QCloudNewCOSV4DemoTests.m
//  QCloudNewCOSV4DemoTests
//
//  Created by erichmzhang(张恒铭) on 31/10/2017.
//  Copyright © 2017 erichmzhang(张恒铭). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QCloudCOS.h"
#import "QCloudTestUtility.h"
#import "QCloudCOSV4UploadObjectRequest.h"
#import "NSObject+HTTPHeadersContainer.h"
static NSString* testBucket = nil;
@interface QCloudNewCOSV4DemoTests : XCTestCase

@end

@implementation QCloudNewCOSV4DemoTests

- (void)setUp {
    [super setUp];
    testBucket = @"testerichmzhang";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreate_Get_List_Delete_Directory {
    XCTestExpectation* expecation = [self expectationWithDescription:@"direcotry-related"];
    __block NSString* testDirectory = [NSString stringWithFormat:@"test-%i",arc4random()%10000];
    QCloudCreateDirectoryRequest* request = [[QCloudCreateDirectoryRequest alloc] init];
    request.bucket = testBucket;
    request.directory = testDirectory;
    __block NSString* bizAttributs = @"directoryAttributes";
    [request setFinishBlock:^(QCloudCreateDirectoryResult* result, NSError* error) {
        XCTAssertNotNil(result);
        XCTAssertNotNil(result.ctime);
        XCTAssertNil(error);
        QCloudListDirectoryRequest* request = [[QCloudListDirectoryRequest alloc] init];
        request.bucket = testBucket;
        request.directory = testDirectory;
        request.number = 1000;
        [request setFinishBlock:^(QCloudListDirectoryResult* result, NSError* error) {
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            QCloudDirectoryAttributesRequest* request = [[QCloudDirectoryAttributesRequest alloc] init];
            request.bucket = testBucket;
            request.directory = testDirectory;
            [request setFinishBlock:^(QCloudDirectoryAttributesResult* result, NSError* error) {
                XCTAssertNil(error);
                XCTAssertNotNil(result);
                XCTAssertNotNil(result.createTime);
                XCTAssertNotNil(result.attributes);
                QCloudDeleteDirectoryRequest* request = [[QCloudDeleteDirectoryRequest alloc] init];
                request.bucket = testBucket;
                request.directory = testDirectory;
                [request setFinishBlock:^(NSDictionary* result, NSError* error) {
                    XCTAssertNil(error);
                    [expecation fulfill];
                }];
                [[QCloudCOSV4Service defaultCOSV4] DeleteDirectory:request];
            }];
            [[QCloudCOSV4Service defaultCOSV4] DirectoryAttributes:request];
        }];
        [[QCloudCOSV4Service defaultCOSV4] ListDirectory:request];
    }];
    [[QCloudCOSV4Service defaultCOSV4] CreateDirectory:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

- (void)testSimpleUpload_Move_DeleteFile {
    NSString* tempFilePath = [QCloudTestUtility tempFileWithSize:500  unit:QCLOUD_TEST_FILE_UNIT_KB];
    __block NSString* testFileName = [NSString stringWithFormat:@"test-file%i",arc4random()%1000];
    QCloudUploadObjectSimpleRequest* request = [[QCloudUploadObjectSimpleRequest alloc] init];
    request.bucket = testBucket;
    request.filePath = tempFilePath;
    request.fileName = testFileName;
    XCTestExpectation* expectation = [self expectationWithDescription:@"simple upload"];
    [request setFinishBlock:^(QCloudUploadObjectResult* result, NSError* error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        QCloudMoveFileRequest* request = [[QCloudMoveFileRequest alloc] init];
        request.bucket = testBucket;
        request.destination = @"testMove.txt";
        request.fileName = testFileName;
        request.finishBlock = ^(id outputObject , NSError* error) {
            XCTAssertNil(error);
                QCloudDeleteFileRequest* request = [[QCloudDeleteFileRequest alloc] init];
                request.bucket = testBucket;
                request.fileName = @"testMove.txt";
                [request setFinishBlock:^(NSDictionary* reuslt, NSError* error) {
                    XCTAssertNil(error);
                    [expectation fulfill];
                }];
                [[QCloudCOSV4Service defaultCOSV4] DeleteFile:request];

        };
        [[QCloudCOSV4Service defaultCOSV4] MoveFile:request];
    }];
    [[QCloudCOSV4Service defaultCOSV4] UploadObjectSimple:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
}

- (void)testUploadExtremelyBigFile {
    QCloudCOSV4UploadObjectRequest* request = [[QCloudCOSV4UploadObjectRequest alloc] init];
    __block NSString* testFileName = [NSString stringWithFormat:@"test-file-name%@",[NSDate date]];
    XCTestExpectation* expectation = [self expectationWithDescription:@"multiple upload"];
    request.bucket = testBucket;
    request.fileName = testFileName;
    request.filePath = [QCloudTestUtility tempFileWithSize:50 unit:QCLOUD_TEST_FILE_UNIT_MB];
    [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSent) {
        QCloudLogDebug(@"bytesSent:%i totalByteSent:%i totalBytesExpectedToSent:%i",bytesSent,totalBytesSent,totalBytesExpectedToSent);
    }];
    [request setFinishBlock:^(QCloudUploadObjectResult* result, NSError* error) {
        XCTAssertNil(error);
        XCTAssert(result.accessURL);
        [expectation fulfill];
    }];
    [[QCloudCOSV4TransferManagerService defaultCOSV4TransferManager] uploadObject:request];
    [self waitForExpectationsWithTimeout:8000 handler:nil];
    
    QCloudDeleteFileRequest* deleteFileRequest = [[QCloudDeleteFileRequest alloc] init];
    deleteFileRequest.bucket = testBucket;
    deleteFileRequest.fileName = testFileName;
    [[QCloudCOSV4Service defaultCOSV4] DeleteFile:deleteFileRequest];
    [[NSFileManager defaultManager] removeItemAtPath:request.filePath error:nil];
}

- (void)testMultipartUpload {
    QCloudCOSV4UploadObjectRequest* request = [[QCloudCOSV4UploadObjectRequest alloc] init];
    __block NSString* testFileName = [NSString stringWithFormat:@"MultipartuploadTest%@",[NSUUID UUID].UUIDString];
    XCTestExpectation* expectation = [self expectationWithDescription:@"multiple upload"];
    request.bucket = testBucket;
    request.fileName = testFileName;
    request.filePath = [QCloudTestUtility tempFileWithSize:512+(arc4random()%100) unit:QCLOUD_TEST_FILE_UNIT_MB];
    
    
    __block int64_t finalBytesSent,finalToalBytes;
    [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSent) {
        NSLog(@"bytesSent:%llu totalByteSent:%llu totalBytesExpectedToSent:%llu",bytesSent,totalBytesSent,totalBytesExpectedToSent);
        finalBytesSent = totalBytesSent;
        finalToalBytes = totalBytesExpectedToSent;
    }];
    [request setFinishBlock:^(QCloudUploadObjectResult* result, NSError* error) {
        XCTAssertNil(error);
        XCTAssert(result.accessURL);
        [expectation fulfill];
    }];
    [[QCloudCOSV4TransferManagerService defaultCOSV4TransferManager] uploadObject:request];
    [self waitForExpectationsWithTimeout:8000 handler:nil];
    double finalProgress = ((double)(finalBytesSent))/(finalToalBytes);
    XCTAssert((finalProgress - 1.0f) < 0.000001 , @"progress not equal to 1!，final progress is %f",finalProgress);
    [[NSFileManager defaultManager] removeItemAtPath:request.filePath error:nil];
    QCloudDeleteFileRequest *deleteFileRequest = [[QCloudDeleteFileRequest alloc] init];
    deleteFileRequest.bucket = testBucket;
    deleteFileRequest.fileName = testFileName;
    [[QCloudCOSV4Service defaultCOSV4] DeleteFile:deleteFileRequest];
}


- (void)testPauseAndResume {
    
    __block QCloudCOSV4UploadObjectRequest* request = [[QCloudCOSV4UploadObjectRequest alloc] init];
    __block NSString* testFileName = [NSString stringWithFormat:@"5GB_Test_File%@%i",[NSDate date],arc4random()%100];
    XCTestExpectation* expectation = [self expectationWithDescription:@"multiple upload"];
    request.bucket = testBucket;
    request.fileName = testFileName;
    request.filePath = [QCloudTestUtility tempFileWithSize:1000+(arc4random()%100) unit:QCLOUD_TEST_FILE_UNIT_MB];
    
    
    __block int64_t totalBytes,bytesSent;
    [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSent) {
        NSLog(@"bytesSent:%llu totalByteSent:%llu totalBytesExpectedToSent:%llu",bytesSent,totalBytesSent,totalBytesExpectedToSent);
        bytesSent = totalBytesSent;
        totalBytes = totalBytesExpectedToSent;
    }];
    [request setFinishBlock:^(QCloudUploadObjectResult* result, NSError* error) {
        XCTAssert(error);
        XCTAssertNil(result);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [request cancel];
        QCloudCOSV4UploadObjectRequest* resumeRequest = [[QCloudCOSV4UploadObjectRequest alloc] init];
        resumeRequest.bucket = testBucket;
        resumeRequest.fileName = request.fileName;
        resumeRequest.filePath = request.filePath;
        [resumeRequest setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSent) {
            NSLog(@"Resume Progress:bytessent:%llu,totalBytesSent:%llu,totalBytesExpectedToSent:%llu",bytesSent,totalBytesSent,totalBytesExpectedToSent);
        }];
        [resumeRequest setFinishBlock:^(QCloudUploadObjectResult* result, NSError* error) {
            XCTAssertNil(error);
            XCTAssert(result);
            XCTAssert(result.url);
            XCTAssert(result.accessURL);
            [expectation fulfill];
        }];
        [[QCloudCOSV4TransferManagerService defaultCOSV4TransferManager] uploadObject:resumeRequest];
    });
    
    [[QCloudCOSV4TransferManagerService defaultCOSV4TransferManager] uploadObject:request];
    [self waitForExpectationsWithTimeout:8000 handler:nil];
    [[NSFileManager defaultManager] removeItemAtPath:request.filePath error:nil];
    
    QCloudDeleteFileRequest *deleteFileRequest = [[QCloudDeleteFileRequest alloc] init];
    deleteFileRequest.bucket = testBucket;
    deleteFileRequest.fileName = testFileName;
    [[QCloudCOSV4Service defaultCOSV4] DeleteFile:deleteFileRequest];
}


- (void)testUploadChineseFileNameFile {
    QCloudCOSV4UploadObjectRequest* request = [[QCloudCOSV4UploadObjectRequest alloc] init];
    __block NSString* testFileName = [NSString stringWithFormat:@"测试中文名文件test-file-name%@",[NSDate date]];
    XCTestExpectation* expectation = [self expectationWithDescription:@"multiple upload"];
    request.bucket = testBucket;
    request.fileName = testFileName;
    request.filePath = [QCloudTestUtility tempFileWithSize:100 unit:QCLOUD_TEST_FILE_UNIT_MB];
    [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSent) {
        QCloudLogDebug(@"bytesSent:%i totalByteSent:%i totalBytesExpectedToSent:%i",bytesSent,totalBytesSent,totalBytesExpectedToSent);
    }];
    [request setFinishBlock:^(QCloudUploadObjectResult* result, NSError* error) {
        XCTAssertNil(error);
        XCTAssert(result.accessURL);
        [expectation fulfill];
    }];
    [[QCloudCOSV4TransferManagerService defaultCOSV4TransferManager] uploadObject:request];
    [self waitForExpectationsWithTimeout:8000 handler:nil];
    
    QCloudDeleteFileRequest* deleteFileRequest = [[QCloudDeleteFileRequest alloc] init];
    deleteFileRequest.bucket = testBucket;
    deleteFileRequest.fileName = testFileName;
    [[QCloudCOSV4Service defaultCOSV4] DeleteFile:deleteFileRequest];
    [[NSFileManager defaultManager] removeItemAtPath:request.fileName error:nil];

}

- (void)testGetUploadSliceList {
    QCloudListUploadSliceRequest* request = [[QCloudListUploadSliceRequest alloc] init];
    request.bucket = testBucket;
    request.fileName = @"MultipartuploadTest683A8F50-53E8-4C79-A21D-ACCA7882AF8B";
    XCTestExpectation* expectation = [self expectationWithDescription:@"Get Upload Slice" ];
    [request setFinishBlock:^(QCloudListUploadSliceResult* result, NSError* error) {
        XCTAssertNil(error);
        XCTAssert(result);
        [expectation fulfill];
    }];
    [[QCloudCOSV4Service defaultCOSV4] ListUploadSlice:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

- (void)testGetFileAttribute {
    QCloudFileAttributesRequest* request = [[QCloudFileAttributesRequest alloc] init];
    request.bucket = testBucket;
    request.fileName = @"test1.png";
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"Get file attribute" ];
    [request setFinishBlock:^(QCloudFileInfo* result, NSError* error) {
        XCTAssertNil(error);

        [expectation fulfill];
    }];
    [[QCloudCOSV4Service defaultCOSV4] FileAttributes:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}
- (void)testUpdateFileAttribute {
    QCloudUpdateFileAttributesRequest* request = [[QCloudUpdateFileAttributesRequest alloc] init];
    request.bucket = testBucket;
    request.flag = QCloudUpdateAttributeFlagBizAttr;
    request.fileName = @"test1.png";
    request.attributes = @"test";
    XCTestExpectation* expectation = [self expectationWithDescription:@"Update File Attributes"];
    [request setFinishBlock:^(NSDictionary* result, NSError* error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [[QCloudCOSV4Service defaultCOSV4] UpdateFileAttributes:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
}
- (void)testCopyFile {
    QCloudCopyFileRequest* request = [[QCloudCopyFileRequest alloc] init];
    request.bucket = testBucket;
    request.fileName = @"test1.png";
    request.destination = @"CopyTest";
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"Copy File"];
    [request setFinishBlock:^(NSDictionary* result, NSError* error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [[QCloudCOSV4Service defaultCOSV4] CopyFile:request];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    QCloudDeleteFileRequest* deleteRequest = [[QCloudDeleteFileRequest alloc] init];
    deleteRequest.bucket = testBucket;
    deleteRequest.fileName = request.destination;
    [[QCloudCOSV4Service defaultCOSV4] DeleteFile:deleteRequest];
}

- (void)testDownloadFile {
    QCloudDownloadFileRequest* downloadRequest = [[QCloudDownloadFileRequest alloc] init];
    downloadRequest.fileURL = @"http://testerichmzhang-1253653367.cosgz.myqcloud.com/test1.png";
    __block NSURL* downloadURL = [NSURL URLWithString:QCloudTempFilePathWithExtension(@"downding")];
    downloadRequest.downloadingURL = downloadURL;
    NSLog(@"path:%@",downloadRequest.downloadingURL);
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"Download File"];
    [downloadRequest setFinishBlock:^(id outputObject, NSError* error) {
        XCTAssertNil(error);
        XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:downloadURL.absoluteString]);
        [expectation fulfill];
    }];
    
    [[QCloudCOSV4Service defaultCOSV4] DownloadFile:downloadRequest];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    [[NSFileManager defaultManager] removeItemAtURL:downloadURL error:nil];
}



//- (void)testUploadWithPic_OperationHeader {
//    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    QCloudDownloadFileRequest* downloadFileRequest = [[QCloudDownloadFileRequest alloc] init];
//    downloadFileRequest.fileURL = @"http://123123123-1253653367.costj.myqcloud.com/1.png";
//    NSString* tempDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
//                                                                       NSUserDomainMask,
//                                                                       YES) lastObject];
//    __block NSURL* destinationURL = [[NSURL fileURLWithPath:tempDirectoryPath] URLByAppendingPathComponent:@"temp.png"];
//    downloadFileRequest.downloadingURL = destinationURL;
//    [downloadFileRequest setFinishBlock:^(id outputObject, NSError *error) {
//        dispatch_semaphore_signal(semaphore);
//    }];
//    
//    [[QCloudCOSV4Service defaultCOSV4] DownloadFile:downloadFileRequest];
//    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
//    
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
//    
//    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:destinationURL.absoluteString]);
//    
//    
//    
//    
//    
//    QCloudUploadObjectSimpleRequest* request = [[QCloudUploadObjectSimpleRequest alloc] init];
//    request.bucket = @"dynamictest";
//    request.fileName = @"TPGTest.png";
//    request.filePath = [tempDirectoryPath stringByAppendingString:@"/temp.png"];
//    NSMutableDictionary* extraHeader = [[NSMutableDictionary alloc] init];
//    
//    NSDictionary* rule = @{@"fileid":@"test1.tpg",@"rule":@"imageView2/format/tpg"};
//    NSArray* rulseArray = @[rule];
//    NSDictionary* finalValue = @{@"rules":rulseArray};
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalValue
//                                                       options:nil 
//                                                         error:nil];
//  //  extraHeader[@"Pic-Operations"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    extraHeader[@"Pic-Operations"] = @" {\"rules\":[{\"fileid\":\"test1.tpg\",\"rule\":\"imageView2/format/tpg\"}]}";
//    
//    request.extraHeaders = extraHeader;
//    
//    
//    
//    XCTestExpectation* expectation = [self expectationWithDescription:@"Upload"];
//    
//    [request setFinishBlock:^(QCloudUploadObjectResult * _Nonnull result, NSError * _Nonnull error) {
//        XCTAssertNotNil(result);
//        XCTAssertNil(error);
//        NSLog(result.__originHTTPResponseData__);
//        [expectation fulfill];
//    }];
//    [[QCloudCOSV4Service defaultCOSV4] UploadObjectSimple:request];
//    
//    [self waitForExpectationsWithTimeout:80 handler:nil];
//    
//}
@end

