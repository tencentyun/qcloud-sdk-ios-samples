//
//  ViewController.m
//  QCloudNewCOSV4Demo
//
//  Created by erichmzhang(张恒铭) on 31/10/2017.
//  Copyright © 2017 erichmzhang(张恒铭). All rights reserved.
//

#import "ViewController.h"
#import "QCloudCOS.h"
#import "QCloudCOSV4UploadObjectRequest.h"
#import "QCloudTestUtility.h"
#import "TestCommonDefine.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)onHandleStartUploadClick:(id)sender {
    NSString* uploadPath = [QCloudTestUtility tempFileWithSize:100 unit:QCLOUD_TEST_FILE_UNIT_MB];
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:uploadPath error:nil];
    QCloudLogDebug(@"fileAttributes:%@",fileAttributes);
    QCloudCOSV4UploadObjectRequest* request = [[QCloudCOSV4UploadObjectRequest alloc] init];
    request.bucket = kTestBucket;
    
    [QCloudTestUtility removeFileAtPath:uploadPath];
}


- (IBAction)onHandleCancelButtonClicked:(id)sender {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
