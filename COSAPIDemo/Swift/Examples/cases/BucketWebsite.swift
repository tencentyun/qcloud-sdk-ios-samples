import XCTest
import QCloudCOSXML

class BucketWebsite: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 设置存储桶静态网站
    func putBucketWebsite() {
        let exception = XCTestExpectation.init(description: "putBucketWebsite");
      
        //.cssg-snippet-body-start:[swift-put-bucket-website]
        let req = QCloudPutBucketWebsiteRequest.init();
        req.bucket = "examplebucket-1250000000";
        
        let indexDocumentSuffix = "index.html";
        let errorDocKey = "error.html";
        let derPro = "https";
        let errorCode = 451;
        let replaceKeyPrefixWith = "404.html";
        
        let config = QCloudWebsiteConfiguration.init();
        
        let indexDocument = QCloudWebsiteIndexDocument.init();
        indexDocument.suffix = indexDocumentSuffix;
        config.indexDocument = indexDocument;
        
        let errDocument = QCloudWebisteErrorDocument.init();
        errDocument.key = errorDocKey;
        config.errorDocument = errDocument;
        
        
        let redir = QCloudWebsiteRedirectAllRequestsTo.init();
        redir.protocol  = "https";
        config.redirectAllRequestsTo = redir;
        
        
        let rule = QCloudWebsiteRoutingRule.init();
        let contition = QCloudWebsiteCondition.init();
        contition.httpErrorCodeReturnedEquals = Int32(errorCode);
        rule.condition = contition;
        
        let webRe = QCloudWebsiteRedirect.init();
        webRe.protocol = "https";
        webRe.replaceKeyPrefixWith = replaceKeyPrefixWith;
        rule.redirect = webRe;
        
        let routingRules = QCloudWebsiteRoutingRules.init();
        routingRules.routingRule = [rule];
        config.rules = routingRules;
        req.websiteConfiguration  = config;
        
        req.finishBlock = {(result,error) in
        
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketWebsite(req);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 获取存储桶静态网站
    func getBucketWebsite() {
        let exception = XCTestExpectation.init(description: "getBucketWebsite");
      
        //.cssg-snippet-body-start:[swift-get-bucket-website]
        let req = QCloudGetBucketWebsiteRequest.init();
        req.bucket = "examplebucket-1250000000";
        
        req.setFinish {(result,error) in
        
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketWebsite(req);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 删除存储桶静态网站
    func deleteBucketWebsite() {
        let exception = XCTestExpectation.init(description: "deleteBucketWebsite");
      
        //.cssg-snippet-body-start:[swift-delete-bucket-website]
        let delReq = QCloudDeleteBucketWebsiteRequest.init();
        delReq.bucket = "examplebucket-1250000000";
        delReq.finishBlock = {(result,error) in
        
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().deleteBucketWebsite(delReq);
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    func testBucketWebsite() {
        // 设置存储桶静态网站
        self.putBucketWebsite();
        // 获取存储桶静态网站
        self.getBucketWebsite();
        // 删除存储桶静态网站
        self.deleteBucketWebsite();
    }
}
