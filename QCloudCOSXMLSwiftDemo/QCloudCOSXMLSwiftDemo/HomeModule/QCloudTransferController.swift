//
//  QCloudTransferController.swift
//  QCloudCOSXMLSwiftDemo
//
//  Created by karisli(李雪) on 2019/11/28.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import UIKit
class QCloudTransferController: UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad();
        let uploadVc = QCloudUploadController.init();
        uploadVc.title = "上传";
        
        self.addChild(uploadVc);
        let downloadVc = QCloudDownloadController.init();
        downloadVc.title = "下载";
        self.addChild(downloadVc);
        
        
    }
}
