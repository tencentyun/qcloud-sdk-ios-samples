import XCTest
import QCloudCOSXML

class TransferObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 高级接口上传对象
    func transferUploadFile() {
        let exception = XCTestExpectation.init(description: "transferUploadFile");
      
        //.cssg-snippet-body-start:[swift-transfer-upload-file]
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 高级接口上传字节数组
    func transferUploadBytes() {
        let exception = XCTestExpectation.init(description: "transferUploadBytes");
      
        //.cssg-snippet-body-start:[swift-transfer-upload-bytes]
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 高级接口流式上传
    func transferUploadStream() {
        let exception = XCTestExpectation.init(description: "transferUploadStream");
      
        //.cssg-snippet-body-start:[swift-transfer-upload-stream]
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 高级接口下载对象
    func transferDownloadObject() {
        let exception = XCTestExpectation.init(description: "transferDownloadObject");
      
        //.cssg-snippet-body-start:[swift-transfer-download-object]
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 高级接口拷贝对象
    func transferCopyObject() {
        let exception = XCTestExpectation.init(description: "transferCopyObject");
      
        //.cssg-snippet-body-start:[swift-transfer-copy-object]
        let copyRequest =  QCloudCOSXMLCopyObjectRequest.init();
        copyRequest.bucket = "examplebucket-1250000000";//目的 <BucketName-APPID>，需要是公有读或者在当前账号有权限
        copyRequest.object = "exampleobject";//目的文件名称
        //文件来源 <BucketName-APPID>，需要是公有读或者在当前账号有权限
        copyRequest.sourceBucket = "sourcebucket-1250000000";
        copyRequest.sourceObject = "sourceObject";//源文件名称
        copyRequest.sourceAPPID = "1250000000";//源文件的 APPID
        copyRequest.sourceRegion = "COS_REGION";//来源的地域
        copyRequest.setFinish { (copyResult, error) in
            if error != nil{
                print(error!);
            }else{
                print(copyResult!);
            }
        }
        //注意如果是跨地域复制，这里使用的 transferManager 所在的 region 必须为目标桶所在的 region
        QCloudCOSTransferMangerService.defaultCOSTransferManager().copyObject(copyRequest);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 批量上传任务
    func batchUploadObjects() {
        let exception = XCTestExpectation.init(description: "batchUploadObjects");
      
        //.cssg-snippet-body-start:[swift-batch-upload-objects]
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    func testTransferObject() {
        // 高级接口上传对象
        self.transferUploadFile();
        // 高级接口上传字节数组
        self.transferUploadBytes();
        // 高级接口流式上传
        self.transferUploadStream();
        // 高级接口下载对象
        self.transferDownloadObject();
        // 高级接口拷贝对象
        self.transferCopyObject();
        // 批量上传任务
        self.batchUploadObjects();
    }
}
