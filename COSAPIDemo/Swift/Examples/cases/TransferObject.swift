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
        //.cssg-snippet-body-start:[swift-transfer-upload-file]
        let put:QCloudCOSXMLUploadObjectRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        put.object = "exampleobject";
        put.bucket = "examplebucket-1250000000";
        //需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
        put.body = NSURL.fileURL(withPath: "") as AnyObject;
        
        //监听上传结果
        put.setFinish { (result, error) in
            // 获取上传结果
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
        }

        //监听上传进度
        put.sendProcessBlock = { (bytesDownload, totalBytesDownload,
            totalBytesExpectedToDownload) in
            //      bytesSent       一次上传的字节数，
            //      totalBytesSent  总共上传的字节数
            //      totalBytesExpectedToSend 文件一共多少字节
        };
        //设置上传参数
        put.initMultipleUploadFinishBlock = {(multipleUploadInitResult, resumeData) in
            //在初始化分块上传完成以后会回调该 block，在这里可以获取 resumeData
            //并且可以通过 resumeData 生成一个分块上传的请求
            let resumeUploadRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>
                .init(request: resumeData as Data?);
        }
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put);
        //.cssg-snippet-body-end
    }
    
    
    // 高级接口上传二进制数据
    func transferUploadBytes() {
        //.cssg-snippet-body-start:[swift-transfer-upload-bytes]
        let put:QCloudCOSXMLUploadObjectRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        put.object = "exampleobject";
        put.bucket = "examplebucket-1250000000";
        //需要上传的对象内容
        let dataBody:NSData = "wrwrwrwrwrw".data(using: .utf8)! as NSData;
        put.body = dataBody;
        
        //监听上传结果
        put.setFinish { (result, error) in
            // 获取上传结果
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
        }

        //监听上传进度
        put.sendProcessBlock = { (bytesDownload, totalBytesDownload,
            totalBytesExpectedToDownload) in
            //      bytesSent       一次上传的字节数，
            //      totalBytesSent  总共上传的字节数
            //      totalBytesExpectedToSend 文件一共多少字节
        };
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put);
        //.cssg-snippet-body-end
        
        
    }
    
    
    // 高级接口流式上传
    func transferUploadStream() {
        
        //.cssg-snippet-body-start:[swift-transfer-upload-stream]
        
        
        //.cssg-snippet-body-end
        
        
    }
    
    
    // 高级接口下载对象
    func transferDownloadObject() {
        //.cssg-snippet-body-start:[swift-transfer-download-object]
        let request : QCloudCOSXMLDownloadObjectRequest = QCloudCOSXMLDownloadObjectRequest();
        
        // 文件所在桶
        request.bucket = "examplebucket-1250000000";
        // 对象键
        request.object = "exampleobject";
        
        //设置下载的路径 URL，如果设置了，文件将会被下载到指定路径中
        //如果未设置该参数，那么文件将会被下载至内存里，存放在在 finishBlock 的 outputObject 里
        request.downloadingURL = NSURL.init(string: QCloudTempFilePathWithExtension("downding"))
            as URL?;
        
        //本地已下载的文件大小，如果是从头开始下载，请不要设置
        request.localCacheDownloadOffset = 100;

        //监听下载进度
        request.sendProcessBlock = { (bytesDownload, totalBytesDownload,
            totalBytesExpectedToDownload) in
            //      bytesDownload       一次下载的字节数，
            //      totalBytesDownload  总过接受的字节数
            //      totalBytesExpectedToDownload 文件一共多少字节
        }

        //监听下载结果
        request.finishBlock = { (copyResult, error) in
            //下载完成
            if error != nil{
                print(error!);
            }else{
                print(copyResult!);
            }
        }
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().downloadObject(request);
        
        //.cssg-snippet-body-end
        
        // 取消下载
        request.cancel();
    }
    
    
    // 高级接口拷贝对象
    func transferCopyObject() {
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
    }
    
    
    // 批量上传任务
    func batchUploadObjects() {
        
        
        //.cssg-snippet-body-start:[swift-batch-upload-objects]
        
        //.cssg-snippet-body-end
        
        
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
