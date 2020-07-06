import XCTest
import QCloudCOSXML

class MultiPartsCopyObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 拷贝一个分片
    func uploadPartCopy() {
        let exception = XCTestExpectation.init(description: "uploadPartCopy");
      
        //.cssg-snippet-body-start:[swift-upload-part-copy]
        let req = QCloudUploadPartCopyRequest.init();
        req.bucket = "examplebucket-1250000000";
        req.object = "exampleobject";
        //源文件 URL 路径，可以通过 versionid 子资源指定历史版本
        req.source = "sourcebucket-1250000000.cos.COS_REGION.myqcloud.com/sourceObject";
        //在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
        req.uploadID = "exampleUploadId";
        if self.uploadId != nil {
            req.uploadID = self.uploadId!;
        }
        
        //标志当前分块的序号
        req.partNumber = 1;
        req.setFinish { (result, error) in
            if error != nil{
                print(error!);
            }else{
                let mutipartInfo = QCloudMultipartInfo.init();
                //获取所复制分块的 etag
                mutipartInfo.eTag = result!.eTag;
                mutipartInfo.partNumber = "1";
                self.parts = [mutipartInfo];
            }}
        QCloudCOSXMLService.defaultCOSXML().uploadPartCopy(req);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 完成分片拷贝任务
    func completeMultiUpload() {
        let exception = XCTestExpectation.init(description: "completeMultiUpload");
      
        //.cssg-snippet-body-start:[swift-complete-multi-upload]
        let  complete = QCloudCompleteMultipartUploadRequest.init();
        complete.bucket = "examplebucket-1250000000";
        complete.object = "exampleobject";
        //本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果 QCloudInitiateMultipartUploadResult 中得到
        complete.uploadId = "exampleUploadId";
        if self.uploadId != nil {
            complete.uploadId = self.uploadId!;
        }
        
        
        //已上传分块的信息
        let completeInfo = QCloudCompleteMultipartUploadInfo.init();
        if self.parts == nil {
            print("没有要完成的分块");
            return;
        }
        
        completeInfo.parts = self.parts!;
        complete.parts = completeInfo;
        complete.setFinish { (result, error) in
            if error != nil{
                print(error!)
            }else{
                //从 result 中获取上传结果
                print(result!);
            }}
        QCloudCOSXMLService.defaultCOSXML().completeMultipartUpload(complete);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    func testMultiPartsCopyObject() {
        // 初始化分片上传
        self.initMultiUpload();
        // 拷贝一个分片
        self.uploadPartCopy();
        // 完成分片拷贝任务
        self.completeMultiUpload();
    }
}
