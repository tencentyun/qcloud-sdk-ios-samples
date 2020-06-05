//
//  QCloudCreateBucketCtor.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by garenwang on 2020/5/21.
//  Copyright © 2020 tencentyun.com. All rights reserved.
//

import UIKit


class QCloudCreateBucketCtor: UIViewController, UITextFieldDelegate {
    
    let marginH : CGFloat = 16.0;
    
    let marginV : CGFloat = 12.0;
    
    private var strRegionName : String = "";
    
    private var tfBucketName : UITextField = UITextField();
    
    private var labTipErrorInfo : UILabel = UILabel();
    
    private var btnSubmit : UIButton = UIButton(type: UIButton.ButtonType.custom);
    
    private var btnSelectRegion : UIButton = UIButton(type: UIButton.ButtonType.custom);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI();
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        tfBucketName.frame = CGRect.init(x:marginH, y:marginV, width:kSCREEN_WIDTH - 2 * marginH,height:44.0);
        
        labTipErrorInfo.frame = CGRect.init(x:marginH, y:tfBucketName.frame.origin.y + tfBucketName.frame.size.height + marginV, width:kSCREEN_WIDTH - 2 * marginH,height:20.0);
        
        btnSelectRegion.frame =  CGRect.init(x:marginH,y: labTipErrorInfo.frame.origin.y + labTipErrorInfo.frame.size.height + marginV, width:  kSCREEN_WIDTH - 2 * marginH,height: 44.0);
        
        btnSubmit.frame = CGRect.init(x:marginH, y:btnSelectRegion.frame.origin.y + btnSelectRegion.frame.size.height + marginV,width:kSCREEN_WIDTH - 2 * marginH,height: 35.0);
    }
    
    
    func setupUI() {

        self.title = "新建存储桶";
        self.view.backgroundColor = UIColor.white;
        self.navigationController?.navigationBar.isTranslucent = false;
        
        
        
        self.tfBucketName.textColor = HEXColor(rgbValue: 0x444444);
        self.tfBucketName.backgroundColor = HEXColor(rgbValue: 0xf9f9f9);
        self.tfBucketName.font = UIFont.systemFont(ofSize: 14);
        self.tfBucketName.placeholder = "请输入桶名称";
        self.tfBucketName.delegate = self;
        
        self.view.addSubview(tfBucketName);
        
        labTipErrorInfo.textColor = HEXColor(rgbValue:0xff0000);
        labTipErrorInfo.font = UIFont.systemFont(ofSize: 13);
        self.view.addSubview(labTipErrorInfo);
        
        btnSelectRegion.setTitle("请选择地区", for: UIControl.State.normal);
        btnSelectRegion.addTarget(self , action: #selector(actionSelectRegion), for: UIControl.Event.touchUpInside);
        btnSelectRegion.setTitleColor(HEXColor(rgbValue: 0x333333), for: UIControl.State.normal);
        btnSelectRegion.backgroundColor = HEXColor(rgbValue: 0xf1f1f1);
        self.view.addSubview(btnSelectRegion);
        
        btnSubmit.setTitle("创建", for: UIControl.State.normal);
        btnSubmit.addTarget(self, action: #selector(actionCreateBucket), for: UIControl.Event.touchUpInside);
        btnSubmit.setTitleColor(HEXColor(rgbValue: 0xffffff), for: UIControl.State.normal);
        btnSubmit.backgroundColor = HEXColor(rgbValue: 0x56B2F9);
        self.view.addSubview(btnSubmit);
    }

    @objc func actionCreateBucket() {
        if (tfBucketName.text?.isEmpty == true) {
            labTipErrorInfo.text = "请输入名称";
            return;
        }else{
            labTipErrorInfo.text = "";
        }
       
        if (strRegionName.isEmpty == true) {
            labTipErrorInfo.text = "请选择地区";
            return;
        }
        
        self.tfBucketName.resignFirstResponder();
        let bucketName = tfBucketName.text! + "-" + APPID
        
    //  创建存储桶
    //    实例化 QCloudPutBucketRequest
    //    调用 QCloudCOSXMLService 实例的 PutBucket 方法 发起请求
    //    在FinishBlock获取结果
    //  设置访问控制权限有两种方式：1：创建时在QCloudPutBucketRequest类种设置好，在创建桶的同时设置权限；
    //                         2：创建完成后：使用QCloudPutBucketACLRequest类 根据桶名称为已有的桶设置访问控制全新啊；
    //    参数 1：bucket               桶名称 (必填)；
    //        2：accessControlList    定义ACL属性，有效值 private，public-read-write，public-read（选填）
    //        3：grantRead            赋予被授权者读的权限
    //        4：grantWrite           授予被授权者写的权限
    //        5：grantFullControl     授予被授权者读写权限
            
        let putBucket = QCloudPutBucketRequest();
        putBucket.bucket = bucketName;
        putBucket.regionName = self.strRegionName;
        putBucket.finishBlock = {(result,error) in
            DispatchQueue.main.async {
                if (error == nil) {
                    self.labTipErrorInfo.text = "创建成功";
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true);
                        }
                    };
                }else{
                    let msgDic = (error! as NSError).userInfo;
                    let errorMsg : String  = msgDic["message"] as! String;
                    self.labTipErrorInfo.text = "创建失败:" +  errorMsg;
                }
            }
        }
        
        Current_Service().putBucket(putBucket);
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        labTipErrorInfo.text = "";
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true;
        }
        return self.isValid(string: string);
    }
    
    func isValid(string:String) -> Bool {
        let str  = "[a-z0-9]";
        let tempPredicate = NSPredicate.init(format: "SELF MATCHES %@", str);
        if tempPredicate.evaluate(with: string) {
            return true;
        }
        return false;
    }
    
    @objc func actionSelectRegion() {
        let selectRegion : QCloudCOSXMLRegionsController   = QCloudCOSXMLRegionsController();
        
        selectRegion.selectRegion = {(obj : NSObject? ) -> (Void) in
            if obj == nil {
                return;
            }
            self.btnSelectRegion.setTitle(obj as? String, for: UIControl.State.normal);
            self.strRegionName = obj as! String;
        }
        self.present(UINavigationController.init(rootViewController: selectRegion), animated: true, completion: nil);
        
    }
    
}
