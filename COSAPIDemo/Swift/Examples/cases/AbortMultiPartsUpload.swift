import XCTest
import QCloudCOSXML

class AbortMultiPartsUpload: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 初始化分片上传
    func initMultiUpload() {
      let exception = XCTestExpectation.init(description: "initMultiUpload");
      
      //.cssg-snippet-body-start:[swift-init-multi-upload]
      let initRequest = QCloudInitiateMultipartUploadRequest.init();
      initRequest.bucket = "examplebucket-1250000000";
      initRequest.object = "exampleobject";
      initRequest.setFinish { (result, error) in
          if error != nil{
              print(error!);
          }else{
              //获取分块上传的 uploadId，后续的上传都需要这个 ID，请保存以备后续使用
              self.uploadId = result!.uploadId;
              print(result!.uploadId);
          }}
      QCloudCOSXMLService.defaultCOSXML().initiateMultipartUpload(initRequest);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    // 终止分片上传任务
    func abortMultiUpload() {
      let exception = XCTestExpectation.init(description: "abortMultiUpload");
      
      //.cssg-snippet-body-start:[swift-abort-multi-upload]
      let abort = QCloudAbortMultipfartUploadRequest.init();
      abort.bucket = "examplebucket-1250000000";
      abort.object = "exampleobject";
      //本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果 QCloudInitiateMultipartUploadResult 中得到
      abort.uploadId = "exampleUploadId";
      if self.uploadId != nil {
          abort.uploadId = self.uploadId!;
      }
      
      abort.finishBlock = {(result,error)in
          if error != nil{
              print(error!)
          }else{
              //可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
              print(result!);
          }    
      }
      QCloudCOSXMLService.defaultCOSXML().abortMultipfartUpload(abort);
      
      //.cssg-snippet-body-end

      self.wait(for: [exception], timeout: 100);
    }


    func testAbortMultiPartsUpload() {
      // 初始化分片上传
      self.initMultiUpload();
      // 终止分片上传任务
      self.abortMultiUpload();
    }
}