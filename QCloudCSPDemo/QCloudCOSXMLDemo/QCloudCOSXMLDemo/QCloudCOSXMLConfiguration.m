//
//  QCloudCOSXMLConfiguration.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 26/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudCOSXMLConfiguration.h"
#import "TestCommonDefine.h"
@implementation QCloudCOSXMLConfiguration
+ (instancetype)sharedInstance  {
    
    static QCloudCOSXMLConfiguration* instacne;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instacne = [[QCloudCOSXMLConfiguration alloc] init];
    });
    return instacne;
}

- (NSArray *)availableRegions {
    return @[@"wh"];
}

- (NSString *)currentBucket {
    return [self bucketInRegion:self.currentRegion];
}


- (QCloudCOSXMLService *)currentService {
    return [QCloudCOSXMLService cosxmlServiceForKey:self.currentRegion];
}

- (QCloudCOSTransferMangerService *)currentTransferManager {
    return [QCloudCOSTransferMangerService costransfermangerServiceForKey:self.currentRegion];
}

- (NSString *)currentRegion {
    if (!_currentRegion) {
        _currentRegion = @"wh";
    }
    return _currentRegion;
}

- (NSString*)bucketInRegion:(NSString*)region {
    return kTestBucket;
}
@end
