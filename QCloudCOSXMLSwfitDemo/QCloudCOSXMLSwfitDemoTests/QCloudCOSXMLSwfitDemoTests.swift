//
//  QCloudCOSXMLSwfitDemoTests.swift
//  QCloudCOSXMLSwfitDemoTests
//
//  Created by karisli(李雪) on 2019/11/27.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import XCTest
import QCloudCOSXML
@testable import QCloudCOSXMLSwfitDemo

class QCloudCOSXMLSwfitDemoTests: XCTestCase {
    let bucket = "swift-test";
    let destinationBucket = "swift-copy"
    let defaultRegion  = "ap-guangzhou"
    let destinationRegion = "ap-chengdu";
    let defaultObject = "123.jpeg";
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func tempFileWithSize(size:NSInteger) -> NSURL {
        let path = QCloudPathJoin(QCloudTempDir(), NSUUID().uuidString);
        if !QCloudFileExist(path) {
            FileManager.default.createFile(atPath: path!, contents: NSData.init() as Data, attributes: nil);
        }
        let handler = FileHandle.init(forWritingAtPath: path!);
        handler?.truncateFile(atOffset: UInt64(size));
        handler?.closeFile();
        return NSURL.init(fileURLWithPath: path!);
        
    }

    func testGetService() {
        let exception = XCTestExpectation.init(description: "get service exception");
        let getServiceReq = QCloudGetServiceRequest.init();
        getServiceReq.setFinish{(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if result == nil {
                print(error!);
            } else {
                      //success;
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.getService(getServiceReq);
        self.wait(for: [exception], timeout: 100);
        
    }
    
    
    func testPutBucket() {
        let exception = XCTestExpectation.init(description: "putBucket exception");
        let putBucketReq = QCloudPutBucketRequest.init();
        putBucketReq.bucket = bucket;
        putBucketReq.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil {
                print(error!);
            } else {
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.putBucket(putBucketReq);
        self.wait(for: [exception], timeout: 100);
    }

  
    
     func testHeadBucket() {
        let exception = XCTestExpectation.init(description: "headBucket exception");
        let headBucketReq = QCloudHeadBucketRequest.init();
        headBucketReq.bucket = bucket;
        headBucketReq.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
             }else{
                print( result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.headBucket(headBucketReq);
        self.wait(for: [exception], timeout: 100);
    }

    func testDeleteBucket() {
        let exception = XCTestExpectation.init(description: "deleteBucket exception");
        let deleteBucketReq = QCloudDeleteBucketRequest.init();
        deleteBucketReq.bucket = bucket;
        deleteBucketReq.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
             }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.deleteBucket(deleteBucketReq);
        self.wait(for: [exception], timeout: 100);
    }

    func testPutBucketACL() {
        let exception = XCTestExpectation.init(description: "putBucketACL exception");
        let putBucketACLReq = QCloudPutBucketACLRequest.init();
        putBucketACLReq.bucket = bucket;
        let ownerIdentifier = "qcs::cam::uin/\(APPID):uin/\(APPID)";
        let grantString = "id=\"\(ownerIdentifier)\"";
        putBucketACLReq.grantWrite = grantString;
        putBucketACLReq.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
             exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.putBucketACL(putBucketACLReq);
        self.wait(for: [exception], timeout: 100);
    }

    func testGetBucketACL() {
        let exception = XCTestExpectation.init(description: "getBucketACL exception");
        let getBucketACLReq = QCloudGetBucketACLRequest.init();
        getBucketACLReq.bucket = bucket;
        getBucketACLReq.setFinish { (result, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
             exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.getBucketACL(getBucketACLReq)
        self.wait(for: [exception], timeout: 100);
    }
    
    
    //存储桶管理
    
    func testPutBucketCors(){
        let exception = XCTestExpectation.init(description: "putBucketCors exception");
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
        putBucketCorsReq.bucket = bucket;
        putBucketCorsReq.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
             exception .fulfill();
        }
        
        QCloudCOSXMLService.defaultCOSXML()?.putBucketCORS(putBucketCorsReq);
        self.wait(for: [exception], timeout: 100);
    }
    func testGetBucketCors(){
        let exception = XCTestExpectation.init(description: "getBucketCors exception");
        let  getBucketCorsRes = QCloudGetBucketCORSRequest.init();
        getBucketCorsRes.bucket = bucket;
        getBucketCorsRes.setFinish { (corsConfig, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(corsConfig);
             if error != nil{
                  print(error!);
             }else{
                  print(corsConfig!);
             }
             exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.getBucketCORS(getBucketCorsRes);
        self.wait(for: [exception], timeout: 100);
      }
    func testDeleteBucketCors(){
        let exception = XCTestExpectation.init(description: "deleteBucketCors exception");
        let deleteBucketCorsRequest = QCloudDeleteBucketCORSRequest.init();
        deleteBucketCorsRequest.bucket = bucket;
        deleteBucketCorsRequest.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
             exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.deleteBucketCORS(deleteBucketCorsRequest);
        self.wait(for: [exception], timeout: 100);
      }
    func testPutBucketLifecycle(){
        let exception = XCTestExpectation.init(description: "putBucketLifecycle exception");
        let putBucketLifecycleReq = QCloudPutBucketLifecycleRequest.init();
        putBucketLifecycleReq.bucket = bucket;
        
        let config = QCloudLifecycleConfiguration.init();
        
        let rule = QCloudLifecycleRule.init();
        rule.identifier = "swift";
        rule.status = .enabled;
        
        let fileter = QCloudLifecycleRuleFilter.init();
        fileter.prefix = "0";
        
        rule.filter = fileter;
        
        let transition = QCloudLifecycleTransition.init();
        transition.days = 100;
        transition.storageClass = .standardIA;
        
        rule.transition = transition;
        
        putBucketLifecycleReq.lifeCycle = config;
        putBucketLifecycleReq.lifeCycle.rules = [rule];
        
        putBucketLifecycleReq.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
             exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.putBucketLifecycle(putBucketLifecycleReq);
        self.wait(for: [exception], timeout: 100);
      }
    func testGetBucketLifecycle(){
        let exception = XCTestExpectation.init(description: "getBucketLifeCycle exception");
        let getBucketLifeCycle = QCloudGetBucketLifecycleRequest.init();
        getBucketLifeCycle.bucket = bucket;
        getBucketLifeCycle.setFinish { (config, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(config);
             if error != nil{
                  print(error!);
             }else{
                  print(config!);
             }
             exception .fulfill();
        };
        QCloudCOSXMLService.defaultCOSXML()?.getBucketLifecycle(getBucketLifeCycle);
        self.wait(for: [exception], timeout: 100);
      }
    func testDeleteBucketLifeCycle(){
        let exception = XCTestExpectation.init(description: "deleteBucketLifeCycle exception");
        let deleteBucketLifeCycle = QCloudDeleteBucketLifeCycleRequest.init();
        deleteBucketLifeCycle.bucket = bucket;
        deleteBucketLifeCycle.finishBlock = { (result, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
             exception.fulfill();
        };
    QCloudCOSXMLService.defaultCOSXML()?.deleteBucketLifeCycle(deleteBucketLifeCycle);
        self.wait(for: [exception], timeout: 100);
      }
    func testPutBucketVersioning(){
        let exception = XCTestExpectation.init(description: "putBucketVersioning exception");
        let putBucketVersioning = QCloudPutBucketVersioningRequest.init();
        putBucketVersioning.bucket = bucket;
        
        let config = QCloudBucketVersioningConfiguration.init();
        config.status = .enabled;
        
        putBucketVersioning.configuration = config;
        
        putBucketVersioning.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
             exception.fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.putBucketVersioning(putBucketVersioning);
        self.wait(for: [exception], timeout: 100);
      }
    func testGetBucketVersioning(){
        let exception = XCTestExpectation.init(description: "testGetBucketVersioning exception");
        let getBucketVersioning = QCloudGetBucketVersioningRequest.init();
        getBucketVersioning.bucket = bucket;
        getBucketVersioning.setFinish { (config, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(config);
             if error != nil{
                  print(error!);
             }else{
                  print(config!);
             }
             exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.getBucketVersioning(getBucketVersioning);
        self.wait(for: [exception], timeout: 100);
      }
    
    func testPutBucketReplication(){
        let exception = XCTestExpectation.init(description: "putBucketReplication exception");
        let putBucketReplication = QCloudPutBucketReplicationRequest.init();
        putBucketReplication.bucket = bucket;
        
        let config = QCloudBucketReplicationConfiguation.init();
        config.role = "qcs::cam::uin/\(APPID):uin/\(APPID)";
        
        let rule = QCloudBucketReplicationRule.init();
        rule.identifier = "swift";
        rule.status = .enabled;
        
        let destination = QCloudBucketReplicationDestination.init();
        destination.bucket = "qcs:id/0:cos:\(destinationRegion):appid/\(APPID):\(destinationBucket)"
        rule.destination = destination
        rule.prefix = "a";
        
        config.rule = [rule];
        
        putBucketReplication.configuation = config;
        
        putBucketReplication.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
                if error != nil{
                    print(error!);
                }else{
                    print(result!);
                }
                exception.fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.putBucketRelication(putBucketReplication);
        self.wait(for: [exception], timeout: 100);
      }
    func testGetBucketReplication(){
        let exception = XCTestExpectation.init(description: "getBucketReplication exception");
        let getBucketReplication = QCloudGetBucketReplicationRequest.init();
        getBucketReplication.bucket = bucket;
        getBucketReplication.setFinish { (config, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(config);
             if error != nil{
                  print(error!);
             }else{
                  print(config!);
             }
             exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.getBucketReplication(getBucketReplication);
        self.wait(for: [exception], timeout: 100);
      }
    func testDeleteBucketReplication(){
        let exception = XCTestExpectation.init(description: "deleteBucketReplication exception");
        let deleteBucketReplication = QCloudDeleteBucketReplicationRequest.init();
        deleteBucketReplication.bucket = bucket;
        deleteBucketReplication.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
                if error != nil{
                    print(error!);
                }else{
                    print(result!);
                }
                exception.fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.deleteBucketReplication(deleteBucketReplication);
        self.wait(for: [exception], timeout: 100);
    }
    
    
    //object
    
    func testGetBucket() {
          let exception = XCTestExpectation.init(description: "getBucket exception");
          let getBucketReq = QCloudGetBucketRequest.init();
          getBucketReq.bucket = bucket;
          getBucketReq.setFinish { (result, error) in
              XCTAssertNil(error);
              XCTAssertNotNil(result);
              if error != nil{
                  print(error!);
              }else{
                  print( result!.commonPrefixes);
              }
              exception .fulfill();
          }
          QCloudCOSXMLService.defaultCOSXML()?.getBucket(getBucketReq);
          self.wait(for: [exception], timeout: 100);
      }
    
    func testPutObject() {
        let exception = XCTestExpectation.init(description: "putObject exception");
        let putObject = QCloudPutObjectRequest<AnyObject>.init();
        putObject.bucket = bucket;
        putObject.body =  self.tempFileWithSize(size: 1*1024*1024);
        putObject.object = NSUUID().uuidString;
        putObject.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML().putObject(putObject);
        self.wait(for: [exception], timeout: 100);
    }
    func testHeadObject() {
        let exception = XCTestExpectation.init(description: "headObject exception");
        let headObject = QCloudHeadObjectRequest.init();
        headObject.bucket = bucket;
        headObject.object  = defaultObject;
        headObject.finishBlock =  {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.headObject(headObject);
        self.wait(for: [exception], timeout: 100);
    }
    func testGetObject() {
        let exception = XCTestExpectation.init(description: "getObject exception");
        let getObject = QCloudGetObjectRequest.init();
        getObject.bucket = bucket;
        getObject.object = defaultObject;
        getObject.downloadingURL = URL.init(string: NSTemporaryDirectory())!.appendingPathComponent(defaultObject);
        getObject.finishBlock = {(result,error) in
            
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        };
        getObject.downProcessBlock = {(bytesDownload, totalBytesDownload,  totalBytesExpectedToDownload) in
            print("totalBytesDownload:\(totalBytesDownload) totalBytesExpectedToDownload:\(totalBytesExpectedToDownload)");
        }
        QCloudCOSXMLService.defaultCOSXML()?.getObject(getObject);
        self.wait(for: [exception], timeout: 100);
    }
    func testOptionsObject() {
        let exception = XCTestExpectation.init(description: "optionsObject exception");
        let optionsObject = QCloudOptionsObjectRequest.init();
        optionsObject.object = defaultObject;
        optionsObject.origin = "http://www.qcloud.com";
        optionsObject.accessControlRequestMethod = "GET";
        optionsObject.accessControlRequestHeaders = "origin";
        optionsObject.bucket = bucket;
        optionsObject.finishBlock = {(result,error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.optionsObject(optionsObject);
        self.wait(for: [exception], timeout: 100);
    }
    func testPutObjectCopyObject() {
        let exception = XCTestExpectation.init(description: "getBucket exception");
        let putObjectCopy = QCloudPutObjectCopyRequest.init();
        putObjectCopy.bucket = bucket;
        putObjectCopy.object = "";
        putObjectCopy.objectCopySource = "";
        putObjectCopy.setFinish { (result, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.putObjectCopy(putObjectCopy);
        self.wait(for: [exception], timeout: 100);
    }
    func testDeleteObject() {
        let exception = XCTestExpectation.init(description: "deleteObject exception");
        let deleteObject = QCloudDeleteObjectRequest.init();
        deleteObject.bucket = bucket;
        deleteObject.object = defaultObject;
        deleteObject.finishBlock = {(result,error)in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.deleteObject(deleteObject);
        self.wait(for: [exception], timeout: 100);
    }
    func testDeleteMutipartObject() {
        let exception = XCTestExpectation.init(description: "mutipleDel exception");
        let mutipleDel = QCloudDeleteMultipleObjectRequest.init();
        mutipleDel.bucket = bucket;
        
        let info1 = QCloudDeleteObjectInfo.init();
        info1.key = "text1.txt";
        let info2 = QCloudDeleteObjectInfo.init();
        info2.key = "text2.txt";
        let info3 = QCloudDeleteObjectInfo.init();
        info3.key = "text3.txt";
        
        let deleteInfos = QCloudDeleteInfo.init();
        deleteInfos.objects = [info1,info2,info3];
        deleteInfos.quiet = false;
        mutipleDel.deleteObjects = deleteInfos;
        
        mutipleDel.setFinish { (result, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML().deleteMultipleObject(mutipleDel);
        self.wait(for: [exception], timeout: 100);
    }
    func testListMutiPartUploads() {
        let exception = XCTestExpectation.init(description: "listParts exception");
        let listParts = QCloudListBucketMultipartUploadsRequest.init();
        listParts.bucket = bucket;
        listParts.maxUploads = 100;
        listParts.setFinish { (result, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                print(result!);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.listBucketMultipartUploads(listParts);
        self.wait(for: [exception], timeout: 100);
    }
    func testInitMutiPartUploads() {
        let exception = XCTestExpectation.init(description: "initRequest exception");
        let initRequest = QCloudInitiateMultipartUploadRequest.init();
        initRequest.bucket = bucket;
        initRequest.object = defaultObject;
        initRequest.setFinish { (result, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                //获取分片上传的 uploadId，后续的上传都需要这个 id，请保存起来后续使用
                print(result!.uploadId);
            }
            exception .fulfill();
        }
        QCloudCOSXMLService.defaultCOSXML()?.initiateMultipartUpload(initRequest);
        self.wait(for: [exception], timeout: 100);
    }
    func testUploadPart() {
        let exception = XCTestExpectation.init(description: "uploadPart exception");
        
        let uploadPart = QCloudUploadPartRequest<AnyObject>.init();
        uploadPart.bucket = bucket;
        uploadPart.object = NSUUID().uuidString;
        uploadPart.partNumber = 1;
        //标识本次分块上传的 ID；使用 Initiate Multipart Upload 接口初始化分块上传时会得到一个 uploadId
        // 该 ID 不但唯一标识这一分块数据，也标识了这分块数据在整个文件内的相对位置
        uploadPart.uploadId = "";
        uploadPart.body = self.tempFileWithSize(size: 20*1024*1024);
        uploadPart.setFinish { (result, error) in
            XCTAssertNil(error);
            XCTAssertNotNil(result);
            if error != nil{
                print(error!);
            }else{
                let mutipartInfo = QCloudMultipartInfo.init();
                //获取所上传分片的 etag
                mutipartInfo.eTag = result!.eTag;
                mutipartInfo.partNumber = "1";
            }
           
        }
        uploadPart.sendProcessBlock = {(bytesSent,totalBytesSent,totalBytesExpectedToSend) in
            //上传进度信息
            print("totalBytesSent:\(totalBytesSent) totalBytesExpectedToSend:\(totalBytesExpectedToSend)");
            
        }
        QCloudCOSXMLService.defaultCOSXML()?.uploadPart(uploadPart);
        self.wait(for: [exception], timeout: 100);
    }
    func testUploadPartCopy() {
        let exception = XCTestExpectation.init(description: "uploadPartCopy exception");
        let req = QCloudUploadPartCopyRequest.init();
        req.bucket = bucket;
        req.object = defaultObject;
        //  源文件 URL 路径，可以通过 versionid 子资源指定历史版本
        req.source = "source-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject";
        // 在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
        req.uploadID = "example-uploadId";
        //// 标志当前分块的序号
        req.partNumber = 1;
        req.setFinish { (result, error) in
              XCTAssertNil(error);
              XCTAssertNotNil(result);
              if error != nil{
                  print(error!);
              }else{
                  let mutipartInfo = QCloudMultipartInfo.init();
                  //获取所复制分片的 etag
                  mutipartInfo.eTag = result!.eTag;
                  mutipartInfo.partNumber = "1";
              }
            
        }
        QCloudCOSXMLService.defaultCOSXML()?.uploadPartCopy(req);
        self.wait(for: [exception], timeout: 100);
    }
    func testListParts() {
        let exception = XCTestExpectation.init(description: "listParts exception");
        let req = QCloudListMultipartRequest.init();
        req.object = "exampleobject";
        req.bucket = "example-1250000000";
        // 在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID
        req.uploadId = "example-uploadId";
        req.setFinish { (result, error) in
           
            if error != nil{
                print(error!);
            }else{
                //从 result 中获取已上传分片信息
                print(result!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML()?.listMultipart(req);
        self.wait(for: [exception], timeout: 100);
    }
    func testCompleteMutipartUpload() {
        let exception = XCTestExpectation.init(description: "complete exception");
        let  complete = QCloudCompleteMultipartUploadRequest.init();
        complete.bucket = "example-1250000000";
        complete.object = "exampleobject";
        ////本次要查询的分块上传的uploadId,可从初始化分块上传的请求结果QCloudInitiateMultipartUploadResult中得到
        complete.uploadId = "example-uploadId";
        
        let part1 = QCloudMultipartInfo.init();
        part1.eTag = "";
        part1.partNumber = "1";
        
        
        let part2 = QCloudMultipartInfo.init();
        part2.eTag = "";
        part2.partNumber = "1";
        // 已上传分片的信息
        let completeInfo = QCloudCompleteMultipartUploadInfo.init();
        completeInfo.parts = [part1,part2];
        
        complete.parts = completeInfo;
        complete.setFinish { (result, error) in
            if error != nil{
                print(error!)
            }else{
                //从 result 中获取上传结果
                print(result!);
            }
            
        }
        QCloudCOSXMLService.defaultCOSXML()?.completeMultipartUpload(complete);
        self.wait(for: [exception], timeout: 100);
    }
    
    
    func testAbortMutipartUpload() {
        let exception = XCTestExpectation.init(description: "abort exception");
        let abort = QCloudAbortMultipfartUploadRequest.init();
        abort.bucket = "example-1250000000";
        abort.object = "exampleobject";
       //本次要查询的分块上传的uploadId,可从初始化分块上传的请求结果QCloudInitiateMultipartUploadResult中得到
        abort.uploadId = "example-uploadId";
        abort.finishBlock = {(result,error)in
            if error != nil{
                print(error!)
            }else{
                //可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
                print(result!);
            }
            
        }
        QCloudCOSXMLService.defaultCOSXML()?.abortMultipfartUpload(abort);
        self.wait(for: [exception], timeout: 100);
    }
    func testPostObjectRestore() {
        let exception = XCTestExpectation.init(description: "restore exception");
        let restore = QCloudPostObjectRestoreRequest.init();
        restore.bucket = "example-1250000000";
        restore.object = "exampleobject";
        restore.restoreRequest.days = 10;
        restore.finishBlock = {(result,error)in
            if error != nil{
                print(error!)
            }else{
                //可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
                print(result!);
            }
            
        }
        QCloudCOSXMLService.defaultCOSXML()?.postObjectRestore(restore);
        
        self.wait(for: [exception], timeout: 100);
    }
    func testPutObjectACL() {
        let exception = XCTestExpectation.init(description: "putObjectACl exception");
        let putObjectACl = QCloudPutObjectACLRequest.init();
        putObjectACl.bucket = "example-1250000000";
        putObjectACl.object = "exampleobject";
        let ownerIdentifier = "qcs::cam::uin/\(APPID):uin/\(APPID)";
        let grantString = "id=\"\(ownerIdentifier)\"";
        putObjectACl.grantFullControl = grantString;
        putObjectACl.finishBlock = {(result,error)in
            if error != nil{
                print(error!)
            }else{
                //可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
                print(result!);
            }
            
        }
        QCloudCOSXMLService.defaultCOSXML()?.putObjectACL(putObjectACl);
        self.wait(for: [exception], timeout: 100);
    }
    
    func testGetObjectACL() {
        let exception = XCTestExpectation.init(description: "getObjectACL exception");
        let getObjectACL = QCloudGetObjectACLRequest.init();
        getObjectACL.bucket = "example-1250000000";
        getObjectACL.object = "exampleobject";
        getObjectACL.setFinish { (result, error) in
            if error != nil{
                print(error!)
            }else{
                //可以从 result的accessControlList中获取对象的 acl
                print(result!.accessControlList);
            }
            
        }
        QCloudCOSXMLService.defaultCOSXML()?.getObjectACL(getObjectACL);
        self.wait(for: [exception], timeout: 100);
    }

    
    
}
