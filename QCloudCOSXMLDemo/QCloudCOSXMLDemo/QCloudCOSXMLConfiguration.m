//
//  QCloudCOSXMLConfiguration.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 26/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudCOSXMLConfiguration.h"

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
  return   @[@"ap-beijing-1",@"ap-beijing",@"ap-shanghai",@"ap-guangzhou",@"ap-chengdu",@"ap-chongqing",@"ap-singapore",@"ap-hongkong",@"eu-frankfurt",@"ap-mumbai",@"ap-seoul",@"na-siliconvalley",@"na-ashburn"];
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
        _currentRegion = @"ap-beijing-1";
    }
    return _currentRegion;
}

- (NSString*)bucketInRegion:(NSString*)region {
    return [NSString stringWithFormat:@"demo-%@",region];
}
@end
