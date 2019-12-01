//
//  QCloudTabBarViewController.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 26/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudTabBarViewController.h"
#import "QCloudUploadViewController.h"
#import "QCloudDownloadViewController.h"
@interface QCloudTabBarViewController ()

@end

@implementation QCloudTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    QCloudUploadViewController *uplaodVc = [QCloudUploadViewController new];
    uplaodVc.title = @"上传";
    [self addChildViewController:uplaodVc];
    
    QCloudDownloadViewController *downloadVC = [QCloudDownloadViewController new];
    downloadVC.title = @"下载";
    [self addChildViewController:downloadVC];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
