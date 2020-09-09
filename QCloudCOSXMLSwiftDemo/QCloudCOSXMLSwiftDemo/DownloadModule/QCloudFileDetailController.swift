//
//  QCloudFileDetailController.swift
//  QCloudCOSXMLSwiftDemo
//
//  Created by karisli(李雪) on 2019/11/29.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import UIKit
import QCloudCOSXML
class QCloudFileDetailController: UIViewController {
    var fileInfo:QCloudDownloadedFileInfo!
    var textView:UITextView!
    override func viewDidLoad() {
        super.viewDidLoad();
        self.setUpItem();
        self.setUpContent();
        self.setUpData();
    }
    
    func setUpItem() {
        let shareItem = UIBarButtonItem.init(title: "分享", style: .plain, target: self, action: #selector(onHandleShareFile));
        shareItem.tintColor = .black;
        self.navigationItem.rightBarButtonItem = shareItem;
    }

    func setUpContent() {
        self.textView = UITextView.init(frame: view.bounds);
        self.view.addSubview(self.textView!);
         
    }
    
    func setUpData() {
        let fileSize  = self.fileInfo.fileURL.fileSizeWithUnit();
        let fileSizeSmallerThan1024 = self.fileInfo.fileURL.fileSizeSmallerThan1024();
        let fileCount = self.fileInfo.fileURL.fileSizeCount();
        let speed = fileSizeSmallerThan1024/self.fileInfo.timeSpent;
        var  text:String!;
        text = "  文件大小: \(String(fileSize!))\n\n";
        text = text + "  下载时间: \(String(self.fileInfo.timeSpent))\n\n";
        text = text + "  下载速度: \(speed)/s \(fileCount!)";

        self.textView.text = text;
    }
    
    @objc func onHandleShareFile(){
        let activity = UIActivityViewController.init(activityItems: [self.fileInfo.fileURL as Any], applicationActivities: nil);
        activity.excludedActivityTypes = [.print,.assignToContact];
        activity.completionWithItemsHandler = {(activityType ,completed,returnedItems,activityError) in
            print("Share via system result");
        }
        self.present(activity, animated: true, completion: nil);
    }
    
}
