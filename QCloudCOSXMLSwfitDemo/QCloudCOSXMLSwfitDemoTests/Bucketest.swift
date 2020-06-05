//
//  Bucketest.swift
//  QCloudCOSXMLSwfitDemoTests
//
//  Created by karisli(李雪) on 2019/12/13.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import XCTest
import QCloudCOSXML
class Bucketest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPutBucketLogging() {
        let req = QCloudPutBucketLoggingRequest.init();
        
        let status = QCloudBucketLoggingStatus.init();
        
        let loggingEnabled = QCloudLoggingEnabled.init();
        
        loggingEnabled.targetBucket = "";
        
        loggingEnabled.targetPrefix = "";
        status.loggingEnabled = loggingEnabled;
        req.bucketLoggingStatus = status;
        req.bucket = "";
        req.finishBlock = {(result,error) in
            
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().putBucketLogging(req);
        
        
    }
    func testGetBucketLogging() {
        
        let req = QCloudGetBucketLoggingRequest.init();
        req.bucket = "";
        req.setFinish { (result, error) in

            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        };
        QCloudCOSXMLService.defaultCOSXML().getBucketLogging(req);
    }
    
    
    func testPutBucketTagging() {
        
        let req = QCloudPutBucketTaggingRequest.init();
        req.bucket = "";
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
        
    }
    
    func testGetBucketTagging() {
        
        let req = QCloudGetBucketTaggingRequest.init();
        req.bucket = "";
        req.setFinish { (result, error) in
         
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        };
        QCloudCOSXMLService.defaultCOSXML().getBucketTagging(req);
    }
    
    func testDeleteBucketTagging() {
        
        let req = QCloudDeleteBucketTaggingRequest.init();
        req.bucket = "";
        req.finishBlock =  { (result, error) in
    
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        };
        QCloudCOSXMLService.defaultCOSXML().deleteBucketTagging(req);
    }
    
    
    func testPutBucketDomain() {
        
        let req = QCloudPutBucketDomainRequest.init();
        req.bucket = "";
        
        let config = QCloudDomainConfiguration.init();
        let rule = QCloudDomainRule.init();
        rule.status = .enabled;
        rule.name = "www.baidu.com";
        rule.replace = .txt;
        rule.type = .rest;
        config.rules = [rule];
        req.domain = config;
        req.finishBlock = {(result,error) in

            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
            
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketDomain(req);
        
    }
    
    func testgetBucketDomain() {
        
        let req = QCloudGetBucketDomainRequest.init();
        req.bucket = "";
        
        req.finishBlock = {(result,error) in

            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketDomain(req);
        
    }
    
    func testPutBucketWebsite() {
        
        let req = QCloudPutBucketWebsiteRequest.init();
        req.bucket = "";
        
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
        
    }
    
    func testGetBucketWebsite() {
        
        let req = QCloudGetBucketWebsiteRequest.init();
        req.bucket = "";
        
        req.setFinish {(result,error) in
            
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketWebsite(req);
        
    }
    
    func testDeleteBucketWebsite() {
        
        let delReq = QCloudDeleteBucketWebsiteRequest.init();
        delReq.bucket = "";
        delReq.finishBlock = {(result,error) in
       
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().deleteBucketWebsite(delReq);
        
        
    }
    
    
    func testPutBucketInventory() {
        
        let putReq = QCloudPutBucketInventoryRequest.init();
        putReq.bucket = "1504078136-1253653367";
        putReq.inventoryID = "list1";
        let config = QCloudInventoryConfiguration.init();
        config.identifier = "list1";
        config.isEnabled = "True";
        let des = QCloudInventoryDestination.init();
        let btDes = QCloudInventoryBucketDestination.init();
        btDes.cs = "CSV";
        btDes.account = "1278687956";
        btDes.bucket  = "qcs::cos:ap-guangzhou::1504078136-1253653367";
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
        
    }
    
    func testGetBucketInventory() {
        
        
        let req = QCloudGetBucketInventoryRequest.init();
        req.bucket = "";
        req.inventoryID = "list1";
        req.setFinish {(result,error) in
    
            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketInventory(req);
        
    }
    
    func testdeleteBucketInventory() {
        
        let delReq = QCloudDeleteBucketInventoryRequest.init();
        delReq.bucket = "";
        delReq.inventoryID = "list1";
        delReq.finishBlock = {(result,error) in

            if error != nil{
                print(error!);
            }else{
                print( result!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().deleteBucketInventory(delReq);
        
        
    }
    
    
}
