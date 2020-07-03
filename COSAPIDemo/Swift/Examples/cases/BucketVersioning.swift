import XCTest
import QCloudCOSXML

class BucketVersioning: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 设置存储桶多版本
    func putBucketVersioning() {
      let exception = XCTestExpectation.init(description: "putBucketVersioning");
      
      //.cssg-snippet-body-start:[swift-put-bucket-versioning]
      let putBucketVersioning = QCloudPutBucketVersioningRequest.init();
      putBucketVersioning.bucket = "examplebucket-1250000000";
      
      let config = QCloudBucketVersioningConfiguration.init();
      config.status = .enabled;
      
      putBucketVersioning.configuration = config;
      
      putBucketVersioning.finishBlock = {(result,error) in
          if error != nil{
              print(error!);
          }else{
              print(result!);
          }}
      QCloudCOSXMLService.defaultCOSXML().putBucketVersioning(putBucketVersioning);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    // 获取存储桶多版本状态
    func getBucketVersioning() {
      let exception = XCTestExpectation.init(description: "getBucketVersioning");
      
      //.cssg-snippet-body-start:[swift-get-bucket-versioning]
      let getBucketVersioning = QCloudGetBucketVersioningRequest.init();
      getBucketVersioning.bucket = "examplebucket-1250000000";
      getBucketVersioning.setFinish { (config, error) in
          if error != nil{
              print(error!);
          }else{
              print(config!);
          }}
      QCloudCOSXMLService.defaultCOSXML().getBucketVersioning(getBucketVersioning);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    func testBucketVersioning() {
      // 设置存储桶多版本
      self.putBucketVersioning();
      // 获取存储桶多版本状态
      self.getBucketVersioning();
    }
}
