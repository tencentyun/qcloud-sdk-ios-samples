//
//  QCloudSelectBUcketTableViewController.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 04/07/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudSelectBUcketTableViewController.h"
#import "QCloudCOSXMLConfiguration.h"
@import QCloudCOSXML;
NSString *kReuseIdentifier = @"reuse_bucket_tableview_identifier";
@interface QCloudSelectBUcketTableViewController ()
@property (nonatomic, strong) NSMutableArray <QCloudBucket *>* bucketsArray;
@end

@implementation QCloudSelectBUcketTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _bucketsArray = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
    

}



- (void)onHandleCreateBucketClicked:(id)sender {
    __block UITextField *alertTextField;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建Bucket" message:@"输入Bucket名称" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        alertTextField = textField;
    }];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *bucketName = alertTextField.text;
        if (bucketName && bucketName.length ) {
            [self createBucketWithName:bucketName CompletionHandler:^(NSError *error) {
                QCloudLogDebug(@"创建Bucket错误%@",error);
                [self retrieveBucketsWithRegion:[QCloudCOSXMLConfiguration sharedInstance].currentRegion completionHandler:^(NSArray *buckets) {
                    self.bucketsArray = [buckets mutableCopy];
                    [self.tableView reloadData];
                }];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       //do nothing
    }];
    
    [alertController addAction:createAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)createBucketWithName:(NSString *)name CompletionHandler:(void(^)(NSError *error))completion {
    QCloudPutBucketRequest *putBucketRequest = [[QCloudPutBucketRequest alloc] init];
    putBucketRequest.bucket = name;
    [putBucketRequest setFinishBlock:^(id outputObject, NSError *error) {
        completion(error);
    }];
    [[QCloudCOSXMLConfiguration sharedInstance].currentService PutBucket:putBucketRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建Bucket" style:UIBarButtonItemStylePlain target:self action:@selector(onHandleCreateBucketClicked:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    NSString *currentRegion = [QCloudCOSXMLConfiguration sharedInstance].currentRegion;
    [self retrieveBucketsWithRegion:currentRegion completionHandler:^(NSArray *buckets) {
        NSLog(@"ALl buckets :%@",buckets);
        if (buckets != nil) {
            self.bucketsArray = [buckets mutableCopy];
        } else {
            [self.bucketsArray removeAllObjects];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    
    self.title = [QCloudCOSXMLConfiguration  sharedInstance].currentRegion;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)retrieveBucketsWithRegion:(NSString *)region completionHandler:(void(^)(NSArray *buckets))completion {
    QCloudGetServiceRequest* request = [[QCloudGetServiceRequest alloc] init];
    [request setFinishBlock:^(QCloudListAllMyBucketsResult* result, NSError* error) {
        if (nil == error) {
            __block NSMutableArray *resultBuckets = [NSMutableArray array];
            [result.buckets enumerateObjectsUsingBlock:^(QCloudBucket * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.location isEqualToString:region]) {
                    [resultBuckets addObject:obj];
                }
            }];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                completion(resultBuckets);
                });
            }
        } else {
            QCloudLogDebug(@"获取bucket失败，错误%@",error);
        }
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetService:request];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bucketsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    cell.textLabel.text = self.bucketsArray[indexPath.row].name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [QCloudCOSXMLConfiguration  sharedInstance].currentBucket = self.bucketsArray[indexPath.row].name ;
    UIStoryboard *defaultStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:[defaultStoryboard instantiateViewControllerWithIdentifier:@"QCloudTabBarViewController"] animated:YES];
}

@end
