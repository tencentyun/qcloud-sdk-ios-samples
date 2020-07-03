import XCTest
import QCloudCOSXML

class BucketLifecycle: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

    var credentialFenceQueue:QCloudCredentailFenceQueue?;

    override func setUp() {
      let config = QCloudServiceConfiguration.init();
      config.signatureProvider = self;
      config.appID = "1253653367";
      let endpoint = QCloudCOSXMLEndPoint.init();
      endpoint.regionName = "ap-guangzhou";//服务地域名称，可用的地域请参考注释
      endpoint.useHTTPS = true;
      config.endpoint = endpoint;
      QCloudCOSXMLService.registerDefaultCOSXML(with: config);
      QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: config);

      // 脚手架用于获取临时密钥
      self.credentialFenceQueue = QCloudCredentailFenceQueue();
      self.credentialFenceQueue?.delegate = self;
    }

    func fenceQueue(_ queue: QCloudCredentailFenceQueue!, requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        let cre = QCloudCredential.init();
        //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
        cre.secretID = "COS_SECRETID";
        cre.secretKey = "COS_SECRETKEY";
        cre.token = "COS_TOKEN";
        /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
        cre.startDate = DateFormatter().date(from: "startTime"); // 单位是秒
        cre.experationDate = DateFormatter().date(from: "expiredTime");
        let auth = QCloudAuthentationV5Creator.init(credential: cre);
        continueBlock(auth,nil);
    }

    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        self.credentialFenceQueue?.performAction({ (creator, error) in
            if error != nil {
                continueBlock(nil,error!);
            }else{
                let signature = creator?.signature(forData: urlRequst);
                continueBlock(signature,nil);
            }
        })
    }


    // 设置存储桶生命周期
    func putBucketLifecycle() {
      let exception = XCTestExpectation.init(description: "putBucketLifecycle");
      
      //.cssg-snippet-body-start:[swift-put-bucket-lifecycle]
      let putBucketLifecycleReq = QCloudPutBucketLifecycleRequest.init();
      putBucketLifecycleReq.bucket = "examplebucket-1250000000";
      
      let config = QCloudLifecycleConfiguration.init();
      
      let rule = QCloudLifecycleRule.init();
      rule.identifier = "swift";
      rule.status = .enabled;
      
      let fileter = QCloudLifecycleRuleFilter.init();
      fileter.prefix = "0";
      
      rule.filter = fileter;
      
      let transition = QCloudLifecycleTransition.init();
      transition.days = 100;
      transition.storageClass = .standardIA;
      
      rule.transition = transition;
      
      putBucketLifecycleReq.lifeCycle = config;
      putBucketLifecycleReq.lifeCycle.rules = [rule];
      
      putBucketLifecycleReq.finishBlock = {(result,error) in
          if error != nil{
              print(error!);
          }else{
              print(result!);
          }}
      QCloudCOSXMLService.defaultCOSXML().putBucketLifecycle(putBucketLifecycleReq);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    // 获取存储桶生命周期
    func getBucketLifecycle() {
      let exception = XCTestExpectation.init(description: "getBucketLifecycle");
      
      //.cssg-snippet-body-start:[swift-get-bucket-lifecycle]
      let getBucketLifeCycle = QCloudGetBucketLifecycleRequest.init();
      getBucketLifeCycle.bucket = "examplebucket-1250000000";
      getBucketLifeCycle.setFinish { (config, error) in
          if error != nil{
              print(error!);
          }else{
              print(config!);
          }};
      QCloudCOSXMLService.defaultCOSXML().getBucketLifecycle(getBucketLifeCycle);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    // 删除存储桶生命周期
    func deleteBucketLifecycle() {
      let exception = XCTestExpectation.init(description: "deleteBucketLifecycle");
      
      //.cssg-snippet-body-start:[swift-delete-bucket-lifecycle]
      let deleteBucketLifeCycle = QCloudDeleteBucketLifeCycleRequest.init();
      deleteBucketLifeCycle.bucket = "examplebucket-1250000000";
      deleteBucketLifeCycle.finishBlock = { (result, error) in
          if error != nil{
              print(error!);
          }else{
              print(result!);
          }};
      QCloudCOSXMLService.defaultCOSXML().deleteBucketLifeCycle(deleteBucketLifeCycle);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    func testBucketLifecycle() {
      // 设置存储桶生命周期
      self.putBucketLifecycle();
      // 获取存储桶生命周期
      self.getBucketLifecycle();
      // 删除存储桶生命周期
      self.deleteBucketLifecycle();
    }
}
