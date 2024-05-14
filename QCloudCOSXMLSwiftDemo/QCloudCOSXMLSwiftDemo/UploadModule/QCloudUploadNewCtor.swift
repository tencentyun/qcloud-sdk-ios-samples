//
//  QCloudUploadNewCtor.swift
//  QCloudCOSXMLSwiftDemo
//
//  Created by garenwang on 2020/5/21.
//  Copyright © 2020 tencentyun.com. All rights reserved.
//

import UIKit

class QCloudUploadNewCtor: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let allAcl = ["default","private","public-read"];
    
    var image:UIImage?
    var filePath:URL?
    
    /// 上传图预览
    let imgPreviewView = UIImageView()
    
    /// 上传进度
    let progressView = UIProgressView();
    
    /// 上传状态 1 ：上传中 + 进度； 2：暂停 + 进度  3：上传成功
    let labUploadState = UILabel();
    
    
    let btnStartUpload = UIButton();
    
    
    let btnPauseOrGoonUpload = UIButton();
    
    let btnCancelUpload = UIButton();
    
    
    let tvResult = UITextView();
    
    var uploadResumeData : NSData?;
    
    var advancedRequest : QCloudCOSXMLUploadObjectRequest<AnyObject>?;
    
    var sgcSetAcl : UISegmentedControl?;
    
    var labAclTitle : UILabel = UILabel();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI();
        self.fetchData();
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let height : CGFloat = 30;
        
        let margin : CGFloat = 12;
        
        imgPreviewView.frame = CGRect.init(x:margin, y:margin, width:kSCREEN_WIDTH - margin * 2, height:160.0);
        
        progressView.frame = CGRect.init(x:margin, y:imgPreviewView.frame.origin.y + imgPreviewView.frame.size.height + margin * 3, width:kSCREEN_WIDTH - 120 - margin * 3, height: height);
        
        labUploadState.frame = CGRect.init(x: progressView.frame.size.width + progressView.frame.origin.x + margin, y: 0 , width: kSCREEN_WIDTH - progressView.frame.size.width - 3 * margin, height: height);
        
        labUploadState.center = CGPoint.init(x: labUploadState.center.x, y: progressView.center.y);
        
        labAclTitle.frame = CGRect.init(x: margin, y: labUploadState.frame.origin.y + labUploadState.frame.size.height + margin * 3, width: 60, height: height);
        
        sgcSetAcl?.frame = CGRect.init(x:labAclTitle.frame.origin.x + labAclTitle.frame.size.width + margin, y: labAclTitle.frame.origin.y, width:kSCREEN_WIDTH - labAclTitle.frame.origin.x + labAclTitle.frame.size.width + margin * 2 , height: height);
        
        btnStartUpload.frame = CGRect.init(x:margin, y:labAclTitle.frame.origin.y + labAclTitle.frame.size.height + margin * 3,width:  80, height:height);
        
        btnPauseOrGoonUpload.frame = CGRect.init(x: margin + btnStartUpload.frame.size.width + btnStartUpload.frame.origin.x ,y: btnStartUpload.frame.origin.y, width: 80, height: height);
        
        btnCancelUpload.frame = CGRect.init(x: margin + btnPauseOrGoonUpload.frame.size.width + btnPauseOrGoonUpload.frame.origin.x , y: btnStartUpload.frame.origin.y, width: 80,  height:height);
        
        tvResult.frame = CGRect.init(x:margin, y:btnCancelUpload.frame.origin.y + btnCancelUpload.frame.size.height + margin * 2, width:kSCREEN_WIDTH - margin * 2,height:300.0);
        
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white;
        self.title = "上传文件";
        self.navigationController?.navigationBar.isTranslucent = false;
        
        imgPreviewView.backgroundColor = HEXColor(rgbValue: 0xf1f1f1);
        self.view.addSubview(imgPreviewView);
        
        progressView.backgroundColor = UIColor.lightGray;
        progressView.progressTintColor = UIColor.systemBlue;
        self.view.addSubview(progressView);
        
        labUploadState.textColor = UIColor.systemBlue;
        labUploadState.text = "等待上传";
        labUploadState.font = UIFont.systemFont(ofSize: 15);
        self.view.addSubview(labUploadState);
        
        btnStartUpload.setTitle("开始", for: UIControl.State.normal);
        btnStartUpload.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal);
        self.view.addSubview(btnStartUpload);
        btnStartUpload.addTarget(self, action: #selector(actionStartUpload), for: UIControl.Event.touchUpInside);
        
        
        btnPauseOrGoonUpload.setTitle("暂停", for: UIControl.State.normal);
        btnPauseOrGoonUpload.setTitle("继续", for: UIControl.State.selected);
        btnPauseOrGoonUpload.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal);
        self.view.addSubview(btnPauseOrGoonUpload);
        btnPauseOrGoonUpload.addTarget(self, action: #selector(actionPauseOrGoon), for: UIControl.Event.touchUpInside);
        
        btnCancelUpload.setTitle("取消", for: UIControl.State.normal);
        btnCancelUpload.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal);
        self.view.addSubview(btnCancelUpload);
        btnCancelUpload.addTarget(self , action: #selector(actionCancelUpload), for: UIControl.Event.touchUpInside);
        
        
        tvResult.font = UIFont.systemFont(ofSize: 14);
        tvResult.textColor = HEXColor(rgbValue: 0x666666);
        self.view.addSubview(tvResult);
        
        
        sgcSetAcl = UISegmentedControl.init(items: self.allAcl);
        sgcSetAcl?.tintColor = UIColor.systemBlue;
        sgcSetAcl?.selectedSegmentIndex = 0;
        self.view.addSubview(sgcSetAcl!);
        
        
        labAclTitle.text = "设置权限";
        labAclTitle.textColor = HEXColor(rgbValue: 0x666666);
        labAclTitle.font = UIFont.systemFont(ofSize: 14);
        self.view.addSubview(labAclTitle);
        
        let rightItem : UIBarButtonItem = UIBarButtonItem.init(title: "选择照片", style: UIBarButtonItem.Style.plain, target: self, action: #selector(uploadFileToBucket));
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //    简单上传 ： 上传 + 取消      高级上传： 上传  + 暂停/继续 + 取消
        
        //    设置acl
        
        //    文件列表页右上角可以调用图库上传文件，上传同样需要展示上传进度与结果，上传支持暂停继续，支持选择用简单上传、分片上传或者高级上传接口，支持设置ACL
        //    图片预览
        
        //    进度与结果
        
        //    暂停继续
        
        //    简单上传      QCloudPutObjectRequest
        
        //    分片上传      QCloudListBucketMultipartUploadsRequest
        //                    上传：
        //                            新的上传 初始化（QCloudInitiateMultipartUploadRequest）-> 上传 —> 完成
        //                            续传 ： 查询 -> 上传
        //                    终止：QCloudAbortMultipfartUploadRequest
        //                    删除：
        
        //    高级上传      QCloudCOSXMLUploadObjectRequest
        
        //    支持设置ACL   QCloudPutObjectACLRequest
        //                   accessControlList ： private，public-read，default（继承桶的权限）
        //                   grantRead grantWrite grantFullControl
        //    设置acl两种方式1 : 上传文件时：在上传请求中设置，然后跟文件一起上传，2：上传完成，用QCloudPutObjectACLRequest类，根据文件名设置，
        
    }
    
    func fetchData() {
        
    }
    
    @objc func actionStartUpload(){
        self.showErrorMessage(message: "")
        self.advancedBeginUpload();
    }
    
    func advancedBeginUpload() {
        
        //    新的上传
        if (self.advancedRequest != nil) {
            self.showErrorMessage(message: "正在上传，请稍等")
            return;
        }
        
        if (self.filePath == nil) {
            self.showErrorMessage(message: "请选择文件")
            return;
        }
        
    //    实例化 QCloudCOSXMLUploadObjectRequest
    //    调用 QCloudCOSTransferMangerService 实例的 UploadObject 方法 进行文件高级上传
    //    在setSendProcessBlock 回调中 处理上传进度进度
    //    在setFinishBlock 处理上传完成结果
        
        btnPauseOrGoonUpload.isSelected = false;
        
        let advancedRequest : QCloudCOSXMLUploadObjectRequest  = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        
        advancedRequest.accessControlList = self.allAcl[sgcSetAcl!.selectedSegmentIndex];
        
        advancedRequest.bucket = Current_Bucket();
        
        advancedRequest.body = self.filePath as AnyObject;
        let datenow = NSDate()
        advancedRequest.object = NSString.init(format: "image_%.0f", datenow.timeIntervalSince1970) as String;
        self.advancedUpload(uploadRequest: advancedRequest);
    }
    
    
    @objc func actionPauseOrGoon(sender:UIButton)  {
        if (sender.isSelected == false) {
            if (self.advancedRequest == nil) {
                self.showErrorMessage(message: "当前没有可以暂停的上传")
                return;
            }
            
            var error : NSError?;
            
    //        上传暂停：
    //        返回暂停的位置，用于在续传时从当前暂停位置开始，无需重新上传
            self.uploadResumeData = self.advancedRequest!.cancel(byProductingResumeData: &error) as QCloudCOSXMLUploadObjectResumeData;
    
            if (error == nil) {
                sender.isSelected = !sender.isSelected; //选中为 已经暂停 需要继续上传     ；默认为正在上传可以点暂停
                self.labUploadState.text = "已暂停";
                self.showErrorMessage(message: "暂停成功");
            }else{
                self.showErrorMessage(message: "暂停失败");
            }
        }else{
            if (self.uploadResumeData == nil) {
                self.showErrorMessage(message: "当前无没有可以继续上传的请求");
                return;
            }
            self.showErrorMessage(message: "继续上传");
            sender.isSelected = !sender.isSelected;
            let upload = QCloudCOSXMLUploadObjectRequest<AnyObject>.init(request: self.uploadResumeData as Data?);
            self .advancedUpload(uploadRequest: upload);
        }
    }
    
    func advancedUpload(uploadRequest:QCloudCOSXMLUploadObjectRequest<AnyObject>) {
        
        self.labUploadState.text = "正在上传";
        self.showErrorMessage(message: "正在上传");
        self.advancedRequest = uploadRequest;
        
        let beforeDate = NSDate.now;
        let fileSize = uploadRequest.body.fileSizeWithUnit();
        let fileSizeSmallerThan1024 = uploadRequest.body.fileSizeSmallerThan1024();
        let fileSizeCount = uploadRequest.body.fileSizeCount();
        
        uploadRequest.setFinish { (result, error) in
            self.advancedRequest = nil;
            DispatchQueue.main.async {
                if (error != nil) {
                    if (self.uploadResumeData != nil) { // 如果 uploadResumeData不为空 则为用户手动暂停
                        self.labUploadState.text = "上传暂停";
                        self.showErrorMessage(message: "已暂停")
                    }else{
                        
                        self.advancedRequest = nil;
                        self.labUploadState.text = "上传失败";
                        self.progressView.progress = 0;
                        self.showErrorMessage(message: error!.localizedDescription);
                    }
                } else {
                    self.advancedRequest = nil;
                    self.progressView.progress = 1.0;
                    self.labUploadState.text = "上传完成";
                    
                    // 服务端crc64;
                    let dic = result?.__originHTTPURLResponse__.allHeaderFields;
                    let crc64 = dic?["x-cos-hash-crc64ecma"];
                    
                    // 本地crc64
                    let localCrc64 = NSMutableData.init(contentsOfFile: "本地文件")?.qcloud_crc64();
                    let localCrc64Str = String(format: "%llu", localCrc64 ?? 0);
                    
                    let afterDate = NSDate.now;
                    let uploadTime = Double(afterDate .timeIntervalSince(beforeDate));
                    let uploadSpeed = fileSizeSmallerThan1024/uploadTime;
                    var text = "  上传耗时：\(uploadTime)\n\n";
                    text = text + "  文件大小：\(fileSize!)\n\n";
                    text = text + "  上传速度：\(uploadSpeed)/\(uploadTime)/s \( fileSizeCount!)\n\n";
                    
                    text = text + "  下载链接：\(String(result!.location)) \n\n";
                    if ((result?.__originHTTPURLResponse__) != nil){
                        text = text + "  返回HTTP头部\(  result!.__originHTTPURLResponse__.allHeaderFields)\n\n"
                    }
                    
                    if ((result?.__originHTTPResponseData__) != nil) {
                        let bodyStr = String(data: (result!.__originHTTPResponseData__), encoding: String.Encoding.utf8)
                        text = text + "  返回HTTP Body\(bodyStr!)"
                    }
                    self.tvResult.text = text;
                    self.showErrorMessage(message: text)
                }
            }
        }
             
        uploadRequest.sendProcessBlock = {(bytesSent , totalBytesSent , totalBytesExpectedToSend) in
            DispatchQueue.main.async {
                self.progressView.setProgress(Float(totalBytesSent)/Float(totalBytesExpectedToSend), animated:true);
                         
                self.labUploadState.text = NSString.init(format:"上传中（%.0f%%）", CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend) * 100) as String;
            }
        }
               
        Current_Transfer_Manager().uploadObject(uploadRequest);
    }
    
    @objc func actionCancelUpload(sender:UIButton)  {
        
        if self.advancedRequest == nil {
            self.showErrorMessage(message: "当前没有可以取消的上传");
        }else{
            self.advancedRequest?.cancel();
            self.advancedRequest = nil;
            self.progressView.progress = 0.0;
            self.uploadResumeData = nil;
            self.showErrorMessage(message: "上传已取消，请重新上传");
        }

    }
    
    @objc func uploadFileToBucket()  {
        let picker : UIImagePickerController = UIImagePickerController();
        picker.delegate = self;
        self.present(picker, animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage;
        self.image = image;
        self.imgPreviewView.image = image;
        self.filePath = info[UIImagePickerController.InfoKey.imageURL] as? URL;
        picker.dismiss(animated: true, completion: nil);
        
        self.progressView.progress = 0.0;
        self.labUploadState.text = "等待上传";
        
    }
    
    func showErrorMessage(message:String) {
        self.tvResult.text = message;
    }
    
    deinit {
        if self.advancedRequest != nil {
            self.advancedRequest?.cancel();
        }
    }
    
}

