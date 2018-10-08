//
//  QCloudUploadViewController.h
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/6/11.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QCloudUploadViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIImageView* imagePreviewView;
@property (nonatomic, weak) IBOutlet UIProgressView* progressView;
@property (nonatomic, weak) IBOutlet UITextView* resultTextView;
@property (nonatomic, weak)  id uploadResultObserver;
@end
