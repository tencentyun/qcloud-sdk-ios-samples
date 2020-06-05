//
//  COS.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by karisli(李雪) on 2019/11/28.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//
import QCloudCOSXML
import Foundation
class COS {
    //bucket
    let bucket = "";
    
    func getService() {
       
    }
    func putBucket(bucket:String) {
        let putBucketReq = QCloudPutBucketRequest.init();
        putBucketReq.bucket = bucket;
        putBucketReq.finishBlock = {(result,error) in
            if error != nil {
                print(error!);
            } else {
                print(result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucket(putBucketReq);
    }

    func getBucket(bucket:String) {
        let getBucketReq = QCloudGetBucketRequest.init();
        getBucketReq.bucket = bucket;
        getBucketReq.setFinish { (result, error) in
            if error != nil{
                print(error!);
            }else{
                print( result!.commonPrefixes);
            }
            
           
        }
        QCloudCOSXMLService.defaultCOSXML().getBucket(getBucketReq);
    }
    
     func headBucket(bucket:String) {
        let headBucketReq = QCloudHeadBucketRequest.init();
        headBucketReq.bucket = bucket;
        headBucketReq.finishBlock = {(result,error) in
            
            if error != nil{
                print(error!);
             }else{
                print( result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().headBucket(headBucketReq);
        
    }
    func deleteBucket(bucket:String) {
        let deleteBucketReq = QCloudDeleteBucketRequest.init();
        deleteBucketReq.bucket = bucket;
        deleteBucketReq.finishBlock = {(result,error) in
            if error != nil{
                print(error!);
             }else{
                print(result!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().deleteBucket(deleteBucketReq);

    }

    func putBucketACL(bucket:String) {
        let putBucketACLReq = QCloudPutBucketACLRequest.init();
        putBucketACLReq.bucket = bucket;
        putBucketACLReq.grantWrite = "";
        putBucketACLReq.finishBlock = {(result,error) in
             if error != nil{
                  print(error!);
             }else{
                  print(result!);
             }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketACL(putBucketACLReq);

    }
//
//    func getBucketACL(bucket:String) {
//        let getBucketACLReq = QCloudGetBucketACLRequest.init();
//        getBucketACLReq.bucket = bucket;
//        getBucketACLReq.setFinish { (QCloudACLPolicy, Error) in
//
//        }
//        QCloudCOSXMLService.defaultCOSXML()?.getBucketACL(getBucketACLReq)
//
//    }
//
//    func putBucketCors(bucket:String) {
//        let putBucketCorsReq = QCloudPutBucketCORSRequest.init();
//        putBucketCorsReq.bucket = bucket;
//        putBucketCorsReq.finishBlock = {
//
//        }
//        QCloudCOSXMLService.defaultCOSXML()?.getBucketACL(getBucketACLReq)
//
//    }
//

}
