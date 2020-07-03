import XCTest
import QCloudCOSXML

class DeleteObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 删除对象
    func deleteObject() {
      let exception = XCTestExpectation.init(description: "deleteObject");
      
      //.cssg-snippet-body-start:[swift-delete-object]
      let deleteObject = QCloudDeleteObjectRequest.init();
      deleteObject.bucket = "examplebucket-1250000000";
      deleteObject.object = "exampleobject";
      deleteObject.finishBlock = {(result,error)in
          if error != nil{
              print(error!);
          }else{
              print(result!);
          }}
      QCloudCOSXMLService.defaultCOSXML().deleteObject(deleteObject);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    // 删除多个对象
    func deleteMultiObject() {
      let exception = XCTestExpectation.init(description: "deleteMultiObject");
      
      //.cssg-snippet-body-start:[swift-delete-multi-object]
      let mutipleDel = QCloudDeleteMultipleObjectRequest.init();
      mutipleDel.bucket = "examplebucket-1250000000";
      
      let info1 = QCloudDeleteObjectInfo.init();
      info1.key = "exampleobject";
      let info2 = QCloudDeleteObjectInfo.init();
      
      
      let deleteInfos = QCloudDeleteInfo.init();
      deleteInfos.objects = [info1];
      deleteInfos.quiet = false;
      mutipleDel.deleteObjects = deleteInfos;
      
      mutipleDel.setFinish { (result, error) in
          if error != nil{
              print(error!);
          }else{
              print(result!);
          }}
      QCloudCOSXMLService.defaultCOSXML().deleteMultipleObject(mutipleDel);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    func testDeleteObject() {
      // 删除对象
      self.deleteObject();
      // 删除多个对象
      self.deleteMultiObject();
    }
}