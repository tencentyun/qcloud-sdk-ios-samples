import XCTest
import QCloudCOSXML

class BucketCORS: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 设置存储桶跨域规则
    func putBucketCors() {
        let exception = XCTestExpectation.init(description: "putBucketCors");
      
        //.cssg-snippet-body-start:[swift-put-bucket-cors]
        let putBucketCorsReq = QCloudPutBucketCORSRequest.init();
        
        let corsConfig = QCloudCORSConfiguration.init();
        
        let rule = QCloudCORSRule.init();
        rule.identifier = "swift-sdk";
        rule.allowedHeader = ["origin","host","accept","content-type","authorization"];
        rule.exposeHeader = "Etag";
        rule.allowedMethod = ["GET","PUT","POST", "DELETE", "HEAD"];
        rule.maxAgeSeconds = 3600;
        rule.allowedOrigin = "*";
        
        corsConfig.rules = [rule];
        
        putBucketCorsReq.corsConfiguration = corsConfig;
        putBucketCorsReq.bucket = "examplebucket-1250000000";
        putBucketCorsReq.finishBlock = {(result,error) in
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }}
        
        QCloudCOSXMLService.defaultCOSXML().putBucketCORS(putBucketCorsReq);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 获取存储桶跨域规则
    func getBucketCors() {
        let exception = XCTestExpectation.init(description: "getBucketCors");
      
        //.cssg-snippet-body-start:[swift-get-bucket-cors]
        let  getBucketCorsRes = QCloudGetBucketCORSRequest.init();
        getBucketCorsRes.bucket = "examplebucket-1250000000";
        getBucketCorsRes.setFinish { (corsConfig, error) in
            if error != nil{
                print(error!);
            }else{
                print(corsConfig!);
            }}
        QCloudCOSXMLService.defaultCOSXML().getBucketCORS(getBucketCorsRes);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 实现 Object 跨域访问配置的预请求
    func optionObject() {
        let exception = XCTestExpectation.init(description: "optionObject");
      
        //.cssg-snippet-body-start:[swift-option-object]
        let optionsObject = QCloudOptionsObjectRequest.init();
        optionsObject.object = "exampleobject";
        optionsObject.origin = "http://www.qcloud.com";
        optionsObject.accessControlRequestMethod = "GET";
        optionsObject.accessControlRequestHeaders = "origin";
        optionsObject.bucket = "examplebucket-1250000000";
        optionsObject.finishBlock = {(result,error) in
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }}
        QCloudCOSXMLService.defaultCOSXML().optionsObject(optionsObject);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 删除存储桶跨域规则
    func deleteBucketCors() {
        let exception = XCTestExpectation.init(description: "deleteBucketCors");
      
        //.cssg-snippet-body-start:[swift-delete-bucket-cors]
        let deleteBucketCorsRequest = QCloudDeleteBucketCORSRequest.init();
        deleteBucketCorsRequest.bucket = "examplebucket-1250000000";
        deleteBucketCorsRequest.finishBlock = {(result,error) in
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }}
        QCloudCOSXMLService.defaultCOSXML().deleteBucketCORS(deleteBucketCorsRequest);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    func testBucketCORS() {
        // 设置存储桶跨域规则
        self.putBucketCors();
        // 获取存储桶跨域规则
        self.getBucketCors();
        // 实现 Object 跨域访问配置的预请求
        self.optionObject();
        // 删除存储桶跨域规则
        self.deleteBucketCors();
    }
}
