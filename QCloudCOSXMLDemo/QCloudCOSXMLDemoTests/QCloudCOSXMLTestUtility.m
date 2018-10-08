//
//  QCloudCOSXMLTestUtility.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 01/12/2017.
//  Copyright © 2017 Tencent. All rights reserved.
//
#import "QCloudCOSXMLVersion.h"
#import "QCloudCOSXMLTestUtility.h"
#import "QCloudCOSXML.h"
#define kTestObejectPrefix @"objectcanbedelete"
#define kTestBucketPrefix  @"bucketcanbedelete"
#import "TestCommonDefine.h"
#import "QCloudTestTempVariables.h"
#import "QCloudCOSXMLVersion.h"
#import "QCloudAbortMultipfartUploadRequest.h"
@interface QCloudCOSXMLTestUtility()
@property (nonatomic, strong) dispatch_semaphore_t  semaphore;
@end

@implementation QCloudCOSXMLTestUtility

- (instancetype) init {
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static QCloudCOSXMLTestUtility* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QCloudCOSXMLTestUtility alloc] init];
    });
    return instance;
}

- (NSString*)createTestBucket {
    
    NSMutableString* bucketName = [[NSMutableString alloc] init];
    [bucketName appendString:kTestBucketPrefix];
    [bucketName  appendFormat:@"%i",arc4random()%3000];
    QCloudPutBucketRequest* putBucket = [[QCloudPutBucketRequest alloc] init];
    putBucket.bucket = bucketName;
    [putBucket setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    
    if ([QCloudCOSXMLService defaultCOSXML] == nil) {
        NSLog(@"sfasf");
    }
    
    [[QCloudCOSXMLService defaultCOSXML] PutBucket:putBucket];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return bucketName;
}


- (void)deleteTestBucket:(NSString*)testBucket {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray<QCloudBucketContents*>* listBucketContents;
    QCloudGetBucketRequest* getBucketRequest = [[QCloudGetBucketRequest alloc] init];
    getBucketRequest.bucket = testBucket;
    getBucketRequest.maxKeys = 500;
    [getBucketRequest setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
        listBucketContents = result.contents;
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:getBucketRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (listBucketContents == nil ) {
        QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
        deleteBucketRequest.bucket = testBucket;
        [deleteBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
        [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:deleteBucketRequest];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    
    QCloudDeleteMultipleObjectRequest* deleteMultipleObjectRequest = [[QCloudDeleteMultipleObjectRequest alloc] init];
    deleteMultipleObjectRequest.bucket = testBucket;
    deleteMultipleObjectRequest.deleteObjects = [[QCloudDeleteInfo alloc] init];
    NSMutableArray* deleteObjectInfoArray = [[NSMutableArray alloc] init];
    for (QCloudBucketContents* bucketContents in listBucketContents) {
        QCloudDeleteObjectInfo* objctInfo = [[QCloudDeleteObjectInfo alloc] init];
        objctInfo.key = bucketContents.key;
        [deleteObjectInfoArray addObject:objctInfo];
    }
    deleteMultipleObjectRequest.deleteObjects.objects = [deleteObjectInfoArray copy];
    [deleteMultipleObjectRequest setFinishBlock:^(QCloudDeleteResult * _Nonnull result, NSError * _Nonnull error) {
        if (error == nil) {
            NSLog(@"Delete ALL Object Success!");
        } else {
            NSLog(@"Delete all object fail! error:%@",error);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:deleteMultipleObjectRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
    deleteBucketRequest.bucket = testBucket;
    [deleteBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:deleteBucketRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (NSString*)uploadTempObjectInBucket:(NSString *)bucket {
    
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = bucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    return put.object;
}
- (NSString*)createCanbeDeleteTestObject {
    NSMutableString* object = [[NSMutableString alloc] init];
    [object appendString:kTestObejectPrefix];
    [object  appendFormat:@"%i",arc4random()%1000];
    QCloudPutObjectRequest* putObject = [[QCloudPutObjectRequest alloc] init];
    putObject.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    putObject.object = object;
    [putObject setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:putObject];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return object;
}
-(void)deleteAllTestObjects{
    [self deleteAllObjectsWithPrefix:kTestObejectPrefix];
}
- (void)deleteAllObjectsWithPrefix:(NSString*)prefix {
    
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray<QCloudBucketContents*>* listBucketContents;
    QCloudGetBucketRequest* getBucketRequest = [[QCloudGetBucketRequest alloc] init];
    getBucketRequest.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    getBucketRequest.maxKeys = 1000;
    [getBucketRequest setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
        listBucketContents = result.contents;
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:getBucketRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (nil == listBucketContents) {
        return;
    }
    NSMutableArray* deleteObjectInfoArray = [[NSMutableArray alloc] init];
    NSUInteger prefixLength = prefix.length;
    for (QCloudBucketContents* bucketContents in listBucketContents) {
        NSLog(@"tetsttst   ----- %@",bucketContents.key);
        if (bucketContents.key.length < prefixLength) {
            continue;
        }
        NSString* objectNamePrefix = [bucketContents.key substringToIndex:prefixLength];
        
        if ([objectNamePrefix isEqualToString:prefix]) {
            QCloudDeleteObjectInfo* objctInfo = [[QCloudDeleteObjectInfo alloc] init];
            objctInfo.key = bucketContents.key;
            [deleteObjectInfoArray addObject:objctInfo];
        }
    }
    
    QCloudDeleteMultipleObjectRequest* deleteMultipleObjectRequest = [[QCloudDeleteMultipleObjectRequest alloc] init];
    deleteMultipleObjectRequest.bucket = [QCloudTestTempVariables sharedInstance].testBucket;
    deleteMultipleObjectRequest.deleteObjects = [[QCloudDeleteInfo alloc] init];
    deleteMultipleObjectRequest.deleteObjects.objects = [deleteObjectInfoArray copy];
    [deleteMultipleObjectRequest setFinishBlock:^(QCloudDeleteResult * _Nonnull result, NSError * _Nonnull error) {
        if (error == nil) {
            NSLog(@"Delete ALL Object Success!");
        } else {
            NSLog(@"Delete all object fail! error:%@",error);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:deleteMultipleObjectRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

#if QCloudCOSXMLModuleVersionNumber >= 502000
- (void)deleteAllTestBuckets {
    [self deleteAllBucketsWithPrefix:kTestBucketPrefix];
}

- (void)deleteAllBucketsWithPrefix:(NSString*)prefix {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray* allBuckets;
    QCloudGetServiceRequest* getServiceRequest = [[QCloudGetServiceRequest alloc] init];
    [getServiceRequest setFinishBlock:^(QCloudListAllMyBucketsResult * _Nonnull result, NSError * _Nonnull error) {
        if (nil == error) {
            allBuckets = result.buckets;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetService:getServiceRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (allBuckets == nil) {
        return ;
    }
    NSUInteger prefixLength = prefix.length;
    for (QCloudBucket* bucket in allBuckets) {
        if (bucket.name.length < prefixLength) {
            continue;
        }
        NSString* bucketNamePrefix = [bucket.name substringToIndex:prefixLength];
        if ([bucketNamePrefix isEqualToString:prefix]) {
            //This is the bucket should be deleted
            [self cleanFilesInBucket:bucket.name];
            [self cleanMultipleUploadsInBucket:bucket.name];
            [self cleanMultipleVersionFilesInBucket:bucket.name];
            
            QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
            deleteBucketRequest.bucket = bucket.name;
            [deleteBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
                dispatch_semaphore_signal(semaphore);
            }];
            [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:deleteBucketRequest];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }
}


- (void)cleanFilesInBucket:(NSString*)bucket {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSArray<QCloudBucketContents*>* listBucketContents;
    QCloudGetBucketRequest* getBucketRequest = [[QCloudGetBucketRequest alloc] init];
    getBucketRequest.bucket = bucket;
    getBucketRequest.maxKeys = 500;
    [getBucketRequest setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
        listBucketContents = result.contents;
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:getBucketRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (listBucketContents == nil ) {
        QCloudDeleteBucketRequest* deleteBucketRequest = [[QCloudDeleteBucketRequest alloc] init];
        deleteBucketRequest.bucket = bucket;
        [deleteBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
        [[QCloudCOSXMLService defaultCOSXML] DeleteBucket:deleteBucketRequest];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    
    QCloudDeleteMultipleObjectRequest* deleteMultipleObjectRequest = [[QCloudDeleteMultipleObjectRequest alloc] init];
    deleteMultipleObjectRequest.bucket = bucket;
    deleteMultipleObjectRequest.deleteObjects = [[QCloudDeleteInfo alloc] init];
    NSMutableArray* deleteObjectInfoArray = [[NSMutableArray alloc] init];
    for (QCloudBucketContents* bucketContents in listBucketContents) {
        QCloudDeleteObjectInfo* objctInfo = [[QCloudDeleteObjectInfo alloc] init];
        objctInfo.key = bucketContents.key;
        [deleteObjectInfoArray addObject:objctInfo];
    }
    deleteMultipleObjectRequest.deleteObjects.objects = [deleteObjectInfoArray copy];
    [deleteMultipleObjectRequest setFinishBlock:^(QCloudDeleteResult * _Nonnull result, NSError * _Nonnull error) {
        if (error == nil) {
            NSLog(@"Delete ALL Object Success!");
        } else {
            NSLog(@"Delete all object fail! error:%@",error);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:deleteMultipleObjectRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)cleanMultipleUploadsInBucket:(NSString*)bucket {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray<QCloudListMultipartUploadContent*>* currentUploads;
    QCloudListBucketMultipartUploadsRequest* listBucketMultipartUploadRequest = [[QCloudListBucketMultipartUploadsRequest alloc] init];
    listBucketMultipartUploadRequest.bucket = bucket;
    listBucketMultipartUploadRequest.maxUploads = 1000;
    [listBucketMultipartUploadRequest setFinishBlock:^(QCloudListMultipartUploadsResult * _Nonnull result, NSError * _Nonnull error) {
        if (nil == error) {
            currentUploads = result.uploads;
        } else {
            NSLog(@"Copy object fail! Error description is %@",error.description);
            
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] ListBucketMultipartUploads:listBucketMultipartUploadRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    for (QCloudListMultipartUploadContent* content in currentUploads) {
        QCloudAbortMultipfartUploadRequest* abortMultipartUploadRequest = [[QCloudAbortMultipfartUploadRequest alloc] init];
        abortMultipartUploadRequest.bucket = bucket;
        abortMultipartUploadRequest.uploadId = content.uploadID;
        abortMultipartUploadRequest.object = content.key;
        [abortMultipartUploadRequest setFinishBlock:^(id outputObject, NSError *error) {
            if (nil == error) {
                
            } else {
                QCloudLogDebug(@"Abort Multipart upload fail!,error is %@",error.description);
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        [[QCloudCOSXMLService defaultCOSXML] AbortMultipfartUpload:abortMultipartUploadRequest];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}


- (void)cleanMultipleVersionFilesInBucket:(NSString*)bucket {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    
    QCloudPutBucketVersioningRequest* putBucketVersioningRequest = [[QCloudPutBucketVersioningRequest alloc] init];
    QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
    configuration.status = QCloudCOSBucketVersioningStatusSuspended;
    putBucketVersioningRequest.bucket = bucket;
    putBucketVersioningRequest.configuration = configuration;
    [putBucketVersioningRequest setFinishBlock:^(id outputObject, NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:putBucketVersioningRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    
    
    __block NSArray<QCloudDeleteMarker*> *deleteMarkerArray;
    __block NSArray<QCloudVersionContent*> *versionContentArray;
    QCloudListObjectVersionsRequest* listObjectVersionsRequest = [[QCloudListObjectVersionsRequest alloc] init];
    listObjectVersionsRequest.bucket = bucket;
    listObjectVersionsRequest.maxKeys = 1000;
    [listObjectVersionsRequest setFinishBlock:^(QCloudListVersionsResult * _Nonnull result, NSError * _Nonnull error) {
        if (error) {
            QCloudLogDebug(error.description);
        } else {
            deleteMarkerArray = result.deleteMarker;
            versionContentArray = result.versionContent;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [[QCloudCOSXMLService defaultCOSXML] ListObjectVersions:listObjectVersionsRequest];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    
    for (QCloudDeleteMarker* deleteMarker in deleteMarkerArray) {
        QCloudDeleteObjectRequest* deleteObjectRequest = [QCloudDeleteObjectRequest new];
        deleteObjectRequest.bucket = bucket;
        deleteObjectRequest.object = deleteMarker.object;
        deleteObjectRequest.versionID = deleteMarker.versionID?deleteMarker.versionID:@"null";
        [deleteObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
            if (nil == error) {
                
            } else {
                QCloudLogDebug(error.description);
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        [[QCloudCOSXMLService defaultCOSXML] DeleteObject:deleteObjectRequest];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    for (QCloudVersionContent* version in versionContentArray) {
        QCloudDeleteObjectRequest* deleteObjectRequest = [QCloudDeleteObjectRequest new];
        deleteObjectRequest.bucket = bucket;
        deleteObjectRequest.object = version.object;
        deleteObjectRequest.versionID = version.versionID?version.versionID:@"null";
        [deleteObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
            if (nil == error) {
                
            } else {
                QCloudLogDebug(error.description);
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        [[QCloudCOSXMLService defaultCOSXML] DeleteObject:deleteObjectRequest];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
}
#endif
@end
