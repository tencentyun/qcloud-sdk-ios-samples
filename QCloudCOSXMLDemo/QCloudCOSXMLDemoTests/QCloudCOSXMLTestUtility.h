//
//  QCloudCOSXMLTestUtility.h
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 01/12/2017.
//  Copyright © 2017 Tencent. All rights reserved.
//

#import "QCloudCOSXMLVersion.h"


//#if QCloudCoreModuleVersionNumber >= 502000
#import <QCloudCore/QCloudTestUtility.h>
#import <QCloudCore/QCloudCore.h>

@interface QCloudCOSXMLTestUtility : QCloudTestUtility

+ (instancetype)sharedInstance;

- (NSString*)createTestBucket;

- (void)deleteTestBucket:(NSString*)bucket;

- (void)deleteAllTestBuckets;


- (NSString*)uploadTempObjectInBucket:(NSString*)bucket;
@end
//#endif

