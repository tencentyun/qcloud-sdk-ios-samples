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
    for (UIViewController* viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[QCloudUploadViewController class]]) {
            viewController.title = @"上传";
        }
        if ([viewController isKindOfClass:[QCloudDownloadViewController class]]) {
            viewController.title = @"下载";
        }
    }
    // Do any additional setup after loading the view.
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
