import XCTest
import QCloudCOSXML

class BucketTagging: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 设置存储桶标签
    func putBucketTagging() {
      let exception = XCTestExpectation.init(description: "putBucketTagging");
      
      //.cssg-snippet-body-start:[swift-put-bucket-tagging]
      let req = QCloudPutBucketTaggingRequest.init();
      req.bucket = "examplebucket-1250000000";
      let taggings = QCloudBucketTagging.init();
      let tagSet = QCloudBucketTagSet.init();
      taggings.tagSet = tagSet;
      let tag1 = QCloudBucketTag.init();
      tag1.key = "age";
      tag1.value = "20";
      
      let tag2 = QCloudBucketTag.init();
      tag2.key = "name";
      tag2.value = "karis";
      tagSet.tag = [tag1,tag2];
      req.taggings = taggings;
      req.finishBlock = {(result,error) in
      
          if error != nil{
              print(error!);
          }else{
              print( result!);
          }
      }
      QCloudCOSXMLService.defaultCOSXML().putBucketTagging(req);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    // 获取存储桶标签
    func getBucketTagging() {
      let exception = XCTestExpectation.init(description: "getBucketTagging");
      
      //.cssg-snippet-body-start:[swift-get-bucket-tagging]
      let req = QCloudGetBucketTaggingRequest.init();
      req.bucket = "examplebucket-1250000000";
      req.setFinish { (result, error) in
      
          if error != nil{
              print(error!);
          }else{
              print( result!);
          }
      };
      QCloudCOSXMLService.defaultCOSXML().getBucketTagging(req);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    // 删除存储桶标签
    func deleteBucketTagging() {
      let exception = XCTestExpectation.init(description: "deleteBucketTagging");
      
      //.cssg-snippet-body-start:[swift-delete-bucket-tagging]
      let req = QCloudDeleteBucketTaggingRequest.init();
      req.bucket = "examplebucket-1250000000";
      req.finishBlock =  { (result, error) in
      
          if error != nil{
              print(error!);
          }else{
              print( result!);
          }
      };
      QCloudCOSXMLService.defaultCOSXML().deleteBucketTagging(req);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    func testBucketTagging() {
      // 设置存储桶标签
      self.putBucketTagging();
      // 获取存储桶标签
      self.getBucketTagging();
      // 删除存储桶标签
      self.deleteBucketTagging();
    }
}
