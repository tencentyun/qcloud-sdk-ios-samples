import XCTest
import QCloudCOSXML

class BucketInventory: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 设置存储桶清单任务
    func putBucketInventory() {
        let exception = XCTestExpectation.init(description: "putBucketInventory");
      
        //.cssg-snippet-body-start:[swift-put-bucket-inventory]
        let putReq = QCloudPutBucketInventoryRequest.init();
        putReq.bucket = "examplebucket-1250000000";
        putReq.inventoryID = "list1";
        let config = QCloudInventoryConfiguration.init();
        config.identifier = "list1";
        config.isEnabled = "True";
        let des = QCloudInventoryDestination.init();
        let btDes = QCloudInventoryBucketDestination.init();
        btDes.cs = "CSV";
        btDes.account = "1278687956";
        btDes.bucket  = "qcs::cos:ap-guangzhou::examplebucket-1250000000";
        btDes.prefix = "list1";
        let enc = QCloudInventoryEncryption.init();
        enc.ssecos = "";
        btDes.encryption = enc;
        des.bucketDestination = btDes;
        config.destination = des;
        let sc = QCloudInventorySchedule.init();
        sc.frequency = "Daily";
        config.schedule = sc;
        let fileter = QCloudInventoryFilter.init();
        fileter.prefix = "myPrefix";
        config.filter = fileter;
        config.includedObjectVersions = .all;
        let fields = QCloudInventoryOptionalFields.init();
        fields.field = [ "Size","LastModifiedDate","ETag","StorageClass","IsMultipartUploaded","ReplicationStatus"];
        config.optionalFields = fields;
        putReq.inventoryConfiguration = config;
        
        putReq.finishBlock = {(result,error) in
        
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().putBucketInventory(putReq);
        
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 获取存储桶清单任务
    func getBucketInventory() {
        let exception = XCTestExpectation.init(description: "getBucketInventory");
      
        //.cssg-snippet-body-start:[swift-get-bucket-inventory]
        let req = QCloudGetBucketInventoryRequest.init();
        req.bucket = "examplebucket-1250000000";
        req.inventoryID = "list1";
        req.setFinish {(result,error) in
        
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketInventory(req);
        
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    // 删除存储桶清单任务
    func deleteBucketInventory() {
        let exception = XCTestExpectation.init(description: "deleteBucketInventory");
      
        //.cssg-snippet-body-start:[swift-delete-bucket-inventory]
        let delReq = QCloudDeleteBucketInventoryRequest.init();
        delReq.bucket = "examplebucket-1250000000";
        delReq.inventoryID = "list1";
        delReq.finishBlock = {(result,error) in
        
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().deleteBucketInventory(delReq);
        
        
        //.cssg-snippet-body-end

        self.wait(for: [exception], timeout: 100);
    }


    func testBucketInventory() {
        // 设置存储桶清单任务
        self.putBucketInventory();
        // 获取存储桶清单任务
        self.getBucketInventory();
        // 删除存储桶清单任务
        self.deleteBucketInventory();
    }
}
