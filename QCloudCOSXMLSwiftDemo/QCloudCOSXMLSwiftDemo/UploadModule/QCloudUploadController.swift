//
//  QCloudUploadController.swift
//  QCloudCOSXMLSwiftDemo
//
//  Created by karisli(李雪) on 2019/11/28.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import UIKit
import QCloudCOSXML



class QCloudUploadController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var imageView:UIImageView!;
    var imagePicker:UIImagePickerController!;
    var progressView:UIProgressView!;
    var operationViews:UIView!;
    var textView:UITextView!;
    var uploadRequest:QCloudCOSXMLUploadObjectRequest<AnyObject>!;
    var uploadFilePath:URL!;
    var resumedData:QCloudCOSXMLUploadObjectResumeData!;
    var bucket:String = "demo-ap-guangzhou";
    override func viewDidLoad() {
        super.viewDidLoad();
        self.bucket = QCloudCOSXMLServiceConfiguration.shared.currentBucket!;
        self.view.backgroundColor = .white;
        let item = UIBarButtonItem(title: "相册", style:.plain, target: self, action:#selector(selectImage))
        item.tintColor = .black;
        self.tabBarController?.navigationItem.rightBarButtonItem = item;
        self.setUpSubViews();
    }
  
    
    func setUpSubViews() {
        self.imageView = UIImageView.init();
        self.imageView.contentMode = .scaleAspectFit;
        self.view .addSubview(self.imageView);
        
        self.progressView = UIProgressView.init();
        self.progressView.backgroundColor = .lightGray;
        self.progressView.progressTintColor = .blue;
        self.view.addSubview(self.progressView);
        
        self.operationViews = UIView.init();
        let buttonTitles = ["上传","暂停","续传","中断"];
        
        for (index,item) in buttonTitles.enumerated() {
            let button = UIButton.init(type: .custom);
            button.setTitle(item, for: .normal);
            button.setTitleColor(.black, for: .normal);
            button.setTitleColor(.blue, for: .highlighted);
            button.tag = index;
            switch index {
            case 0:
                button .addTarget(self, action: #selector(startUpload), for: .touchUpInside);
                break;
            case 1:
                button .addTarget(self, action: #selector(pauseUpload), for: .touchUpInside);
                 break;
            case 2:
                button .addTarget(self, action: #selector(resumeUpload), for: .touchUpInside);
                 break;
            case 3:
                button .addTarget(self, action: #selector(abortUpload), for: .touchUpInside);
                 break;
            default:
                break;
            }
            self.operationViews.addSubview(button);
        }
        self.view.addSubview(self.operationViews);
        
        self.textView = UITextView.init();
        self.textView.text = "  上传的结果显示";
        self.view.addSubview(self.textView);
    }
    
    //开始上传
    @objc func startUpload(){
        

        print("start upload");
        self.uploadRequest = QCloudCOSXMLUploadObjectRequest.init();
        self.uploadRequest.body = self.uploadFilePath as AnyObject
        self.uploadRequest.bucket = self.bucket;
        self.uploadRequest.object = NSUUID().uuidString;
        if self.uploadRequest == nil {
            self.showErrorMessage(message: "不存在上传请求");
            return;
        }
        if (self.uploadFilePath == nil) {
            self.showErrorMessage(message: "请选择要上传的图片");
            return;
        }
        self.uploadFile(uploadRequest: self.uploadRequest);
        
    }
    
    //暂停上传
    @objc func pauseUpload(){
        var error:NSError?;
        print("pause upload");
        self.resumedData =  self.uploadRequest.cancel(byProductingResumeData: &error) as QCloudCOSXMLUploadObjectResumeData;
        if self.resumedData != nil {
            let request = QCloudCOSXMLUploadObjectRequest<AnyObject>.init(request: self.resumedData as Data?);
        }
    }
    
    //续传
    @objc func resumeUpload(){
        
        print("resume upload");
        let resumeUploadRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>.init(request: self.resumedData as Data?);
        self.uploadFile(uploadRequest: resumeUploadRequest);
    }
    
    //取消上传
    @objc func abortUpload(){
        print("abort upload");
        if  self.uploadRequest !== nil {
            self.uploadRequest.abort({ (result, error) in
                self.uploadRequest = nil;
            })
        }else{
            
            self.showErrorMessage(message: "不存在上传请求，无法完全中断上传");
        }
        
    }
    
    func uploadFile(uploadRequest:QCloudCOSXMLUploadObjectRequest<AnyObject>) {
        let beforeDate = NSDate.now;
        let fileSize = uploadRequest.body.fileSizeWithUnit();
        let fileSizeSmallerThan1024 = uploadRequest.body.fileSizeSmallerThan1024();
        let fileSizeCount = uploadRequest.body.fileSizeCount();
        
        uploadRequest.setFinish { (result, error) in
            self.uploadRequest = nil;
            DispatchQueue.main.async {
                if (error != nil){
                    self.showErrorMessage(message: error?.localizedDescription ?? "");
                }else{
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
                    self.textView.text = text;
                    
                    
                }
            }
        }
             
        uploadRequest.sendProcessBlock = {(bytesSent , totalBytesSent , totalBytesExpectedToSend) in
            DispatchQueue.main.async {
                self.progressView.progress = Float(Float(totalBytesSent)/Float(totalBytesExpectedToSend));
            }
                   
        }
               
        QCloudCOSXMLServiceConfiguration.shared.currentTransferManagerService().uploadObject(uploadRequest);
    }
    
    func showErrorMessage(message:String) {
        if self.textView == nil {
            return;
        }
        self.textView.text = message;
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
     
        self.imageView.frame = CGRect(x: 20,y: kNAV_HEIGT,width: Int(kSCREEN_WIDTH)-40,height: 300);
        self.progressView.frame = CGRect(x: 20,y:self.imageView.frame.maxY+20 ,width: view.frame.size.width-40,height: 10);
        
        self.operationViews.frame = CGRect(x: 20,y:self.progressView.frame.maxY+20 ,width: view.frame.size.width-40,height: 40);
        let space  = 10.0;
        var width:Double;
        width =  Double((kSCREEN_WIDTH-40-30)/CGFloat(self.operationViews.subviews.count));
        for (index,item) in self.operationViews.subviews.enumerated() {
            item.frame = CGRect(x: index*(Int(space + width)),y:0 ,width:Int(width),height: 40);
        }
        
        self.textView.frame =  CGRect(x: 20,y:self.operationViews.frame.maxY+20 ,width: view.frame.size.width-40,height: 200);
    }
    @objc func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            self.imagePicker = UIImagePickerController.init();
            self.imagePicker.delegate = self;
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true;
            imagePicker.modalPresentationStyle = .fullScreen;
            self.present(imagePicker, animated: true);
            
        }
    }

    
   //选中图片，保存图片或视频到系统相册
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info);
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage;
        self.imageView.image = image;
        self.uploadFilePath = info[UIImagePickerController.InfoKey.imageURL] as? URL;
        picker.dismiss(animated: true, completion: nil);
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    deinit {
        if self.uploadRequest !==  nil {
            self.uploadRequest.cancel();
        }else{
            self.showErrorMessage(message: "不存在上传请求，无法取消上传");
        }
      
    }
    
}
