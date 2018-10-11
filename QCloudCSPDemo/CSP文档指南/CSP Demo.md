
该文档提供了两种测试demo：区别在于
 demo1 在官网的基础上做的修改，除此之外新增加了一个测试ut，该测试ut包含了csp支持的功能的接口的测试，运行方法如下
## demo1: 运行提供的demo（对官网demo做的改动，运行时只需要做小部分修改）
#### 如何成功运行官网demo

* cd 到podfile所在的文件夹， pod update --verbose --no-repo-update，确保安装的是5.5.6或者5.5.6以上的QCloudCOSXML
* 需要修改的文件：
  1. 修改TestCommonDefine.h文件，输入 kAppID， kRegionk、TestBucket（确保该testBucket在kAppID下是存在的，如果是测试环境确保该bucket的本地配置了host）,testserviceName等信息
  2. 修改AppDelegate.m中获取签名的方式:将服务器地址替换为签名服务器的地址即可

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
#### 运行官网demo中关于csp接口的单元测试（注意这个测试文件官网demo的测试ut中是没有的）

在官网demo 的基础上增加了对于csp支持的每一个接口的测试UT，在QCloudCOSCSPTest.m中，该文件需要做的修改
* 该文件宏定义了几个bucket，分别用于不同的接口测试

  1. #define ktestCSPBucket @"bukcetName-appID"//这是一个测试文件的一个全局bucket，请确保该bucket存在，测试环境请确认配置了hosts（可以使用不用创建新的bucket，使用demo中的宏定义的kTestBucket也可以）置了hosts,因为这个bucket要用来测试跨域访问接口，所以需要在控制台配置好规则，规则
    * 来源 Origin：http://www.yun.ccb.com
    * 操作 Method: GET
    * Allow-Headers: *
  2. ktestCopyDesBucket：//这是一个测试copy的目的的bucket，请确保该bucket存在，测试环境请确认配置了hosts
  3. #define kTestPutBucket @"bucketcanbedelete",//这个bucket是要测试创建bucket的接口的，所以宏定义该bucket的时候不要加appid，同时请确保该bucket不存在， 否则无法创建成功，测试环境请确认配置了hosts
  4. #define kTestMuti_Del_Object_Bucket @"testmutidelobjectsbucket",//这个bucket是用来测试批量删除对象接口的，请确保该bucket存在，测试环境请确认配置了hosts
* 修改QCloudCOSCSPTest.m中获取签名的方式即可
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

## demo2 : 运行官网demo，根据官网以下方法进行修改
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
