测试方式有两种：
## 运行提供的demo（对官网demo做的改动，运行时只需要做小部分修改）
* cd 到podfile所在的文件夹， pod update --verbose --no-repo-update，确保安装的是5.5.6或者5.5.6以上的QCloudCOSXML
* 需要修改的文件：
  修改TestCommonDefine.h文件，输入 kAppID， kRegionk、TestBucket（确保该testBucket在kAppID下是存在的，如果是测试环境确保该bucket的本地配置了host）,testserviceName等信息
* 修改AppDelegate.m中获取签名的方式:将服务器地址替换为签名服务器的地址即可
```

  - (void) signatureWithFields:(QCloudSignatureFields*)fileds
                 request:(QCloudBizHTTPRequest*)request
              urlRequest:(NSMutableURLRequest*)urlRequst
               compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock{
          NSMutableURLRequest *requestToSigned = urlRequst;
          [[COSXMLGetSignatureTool sharedNewtWorkTool]PutRequestWithUrl:@"服务器地址" request:requestToSigned successBlock:^(NSString * _Nonnull sign) {
              QCloudSignature *signature = [[QCloudSignature alloc] initWithSignature:sign expiration:nil];
              continueBlock(signature, nil);
          }];
  }

  ```

## 运行官网demo，根据官网以下方法进行修改
* cd 到podfile所在的文件夹， pod update，确保安装的是5.5.6或者5.5.6以上的QCloudCOSXML
* 需要修改的文件：
  1. 修改TestCommonDefine.h文件，设置kAppID、kRegion(wh)、kTestBucket（确保该testBucket在kAppID下是存在的，如果是测试环境确保该bucket的本地配置了host）、testserviceName(yun.ccb.com)
  2. QCloudCOSXMLConfiguration.m文件：
    * 以(#import "TestCommonDefine.h")这种方式导入TestCommonDefine.h文件
    * 将- (NSArray *)availableRegions的返回值修改为 return @[@"wh"];
    * 设置- (NSString *)currentRegion 方法中的_currentRegion = @"wh";
    * 修改- (NSString*)bucketInRegion:(NSString*)region的返回值为return kTestBucket;
  3.  修改AppDelegate.m中获取签名的方式

```
  - (void) signatureWithFields:(QCloudSignatureFields*)fileds
                 request:(QCloudBizHTTPRequest*)request
              urlRequest:(NSMutableURLRequest*)urlRequst
               compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock{
          NSMutableURLRequest *requestToSigned = urlRequst;
          [[COSXMLGetSignatureTool sharedNewtWorkTool]PutRequestWithUrl:@"服务器地址" request:requestToSigned successBlock:^(NSString * _Nonnull sign) {
              QCloudSignature *signature = [[QCloudSignature alloc] initWithSignature:sign expiration:nil];
              continueBlock(signature, nil);
          }];
  }

  ```
setupCOSXMLShareService方法修改如下（复制粘贴即可）
  ```
  - (void) setupCOSXMLShareService {
      QCloudServiceConfiguration* configuration = [[QCloudServiceConfiguration alloc] init];
      QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
      endpoint.regionName = kRegion;
      //设置bucket是前缀还是后缀，默认是yes为前缀（bucket.cos.wh.yun.ccb.com），设置为no即为后缀（cos.wh.yun.ccb.com/bucket）
  //    endpoint.isPrefixURL = NO;
      //开启https服务
  //    endpoint.useHTTPS = YES;
      configuration.appID = kAppID;
      endpoint.serviceName = testserviceName;
      configuration.endpoint = endpoint;
      configuration.signatureProvider = self;
      [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
      [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
  }
  ```
