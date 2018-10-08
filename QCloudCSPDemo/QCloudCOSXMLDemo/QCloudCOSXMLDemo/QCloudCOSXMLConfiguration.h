//
//  QCloudCOSXMLConfiguration.h
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 26/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCloudCOSXMLService.h"
#import "QCloudCOSXML.h"
@interface QCloudCOSXMLConfiguration : NSObject
+ (instancetype)sharedInstance ;

@property (nonatomic, readonly) NSArray* availableRegions;
@property (nonatomic, copy)     NSString*            currentRegion;
@property (nonatomic, weak)     QCloudCOSXMLService*     currentService;
@property (nonatomic, weak)     QCloudCOSTransferMangerService* currentTransferManager;
@property (nonatomic, readonly) NSString* currentBucket;

- (NSString*)bucketInRegion:(NSString*)region;
@end
