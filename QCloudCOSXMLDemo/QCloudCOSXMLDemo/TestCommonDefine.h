//
//  TestCommonDefine.h
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 2017/7/20.
//  Copyright © 2017年 Tencent. All rights reserved.
//


#ifndef TestCommonDefine_h
#define TestCommonDefine_h
#import "NSString+UINCategory.h"
#define CNNORTH_REGION

#define kSecretID [[NSProcessInfo processInfo] environment][@"kSecretID"]
#define kSecretKey [[NSProcessInfo processInfo] environment][@"kSecretKey"]
#define kAppID [[NSProcessInfo processInfo] environment][@"kAppID"]
#define kRegion [[NSProcessInfo processInfo] environment][@"kRegion"]
#define kTestBucket [[NSProcessInfo processInfo] environment][@"kTestBucket"]
#define kTestFromAnotherRegionCopy [[NSProcessInfo processInfo] environment][@"kTestFromAnotherRegionCopy"] 
#endif /* TestCommonDefine_h */
