//
//  QCloudDownLoadNewCtor.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by garenwang on 2020/5/21.
//  Copyright © 2020 tencentyun.com. All rights reserved.
//

import UIKit

class QCloudDownLoadNewCtor: UIViewController {

    var content :QCloudBucketContents?
    /// 进度条
    let progressView : UIProgressView = UIProgressView();

    ///  下载中+进度。完成
    let labDownloadState : UILabel = UILabel();

    /// 文件名
    let labFileName : UILabel = UILabel();

    /// 文件大小
    let labFileSize : UILabel = UILabel();

    /// 下载平均速度
    let labDownloadSpeed : UILabel = UILabel();

    /// 下载耗费时间
    let labDuration : UILabel = UILabel();
    
    
    var request : QCloudGetObjectRequest?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI();
        
        self.fetchData();
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        let heigth : CGFloat  = 30;

        let margin : CGFloat  = 12;
        
        labDownloadState.frame = CGRect.init(x: kSCREEN_WIDTH - (2 * margin) - 120, y: margin ,width: 120 , height: heigth);
        
        progressView.frame = CGRect.init(x: margin, y: margin, width: kSCREEN_WIDTH - (3 * margin) - 120, height: heigth);
        
        progressView.center = CGPoint.init(x: progressView.center.x, y: labDownloadState.center.y);
        
        labFileName.frame = CGRect.init(x: margin, y: progressView.frame.origin.y + heigth + margin, width: kSCREEN_WIDTH - margin * 2, height: heigth);
        
        labFileSize.frame = CGRect.init(x: margin, y: labFileName.frame.origin.y + heigth + margin, width: kSCREEN_WIDTH - margin * 2, height: heigth);
        
        labDownloadSpeed.frame = CGRect.init(x: margin, y: labFileSize.frame.origin.y + heigth + margin, width: kSCREEN_WIDTH - margin * 2, height: heigth);
        
        labDuration.frame = CGRect.init(x: margin, y: labDownloadSpeed.frame.origin.y + heigth + margin, width: kSCREEN_WIDTH - margin * 2, height: heigth);
    }
    

    func setupUI() {
    
        self.title = "下载详情";
        self.navigationController?.navigationBar.isTranslucent = false;
        self.view.backgroundColor = UIColor.white;
    
        progressView.backgroundColor = UIColor.lightGray;
        progressView.progressTintColor = UIColor.systemBlue;
        self.view.addSubview(self.progressView)
        
        labDownloadState.textAlignment = NSTextAlignment.center;
        labDownloadState.textColor = UIColor.systemBlue;
        labDownloadState.font = UIFont.systemFont(ofSize: 14);
        self.view.addSubview(labDownloadState);
        
        labFileName.textColor = HEXColor(rgbValue: 0x333333);
        labFileName.font = UIFont.systemFont(ofSize: 15);
        self.view.addSubview(labFileName)
        
        labFileSize.textColor = HEXColor(rgbValue: 0x333333);
        labFileSize.font = UIFont.systemFont(ofSize: 15);
        self.view.addSubview(labFileSize)
    
        labDownloadSpeed.textColor = HEXColor(rgbValue: 0x333333);
        labDownloadSpeed.font = UIFont.systemFont(ofSize: 15);
        self.view.addSubview(labDownloadSpeed);
        
        labDuration.textColor = HEXColor(rgbValue: 0x333333);
        labDuration.font = UIFont.systemFont(ofSize: 15);
        self.view.addSubview(labDuration);
        
        progressView.progress = 0.0;
        labDownloadState.text = "下载中";
        if content != nil {
            labFileName.text = String.init(format: "文件名称：%@", content!.key);
            labFileSize.text = String.init(format: "文件大小：%@", content!.fileSize());
        }
       
        labDownloadSpeed.text = "";
        labDuration.text = "";
        
    }
    
    func fetchData() {
            if content == nil {
                return;
            }
            let name = content!.key;
            let beforeDate = NSDate.now;
            let getObjectReq = QCloudGetObjectRequest.init();
            getObjectReq.bucket = QCloudCOSXMLServiceConfiguration.shared.currentBucket!;
            getObjectReq.object = name;
            getObjectReq.downloadingURL = self.tempFilePath(fileName: name);
        
            getObjectReq.downProcessBlock = {(bytesDownload,totalBytesDownload,totalBytesExpectedToDownload)-> (Void) in
                
                DispatchQueue.main.async {
                    let progress: CGFloat  = CGFloat(totalBytesDownload) / CGFloat (totalBytesExpectedToDownload);
                    self.progressView.progress = Float(progress > 1.0 ? 1.0 : progress);
                    self.labDownloadState.text = String.init(format: "下载中（%.1f%%）", progress * 100);
                }
            }
        
            getObjectReq.finishBlock = {(result,error) in
                DispatchQueue.main.async {
                            self.request = nil;
                            if (error != nil) {
                                self.labDownloadState.text = "下载失败";
                            }else{
                                
                                let after : Date = Date();
                                let timeSpent : TimeInterval = after.timeIntervalSince(beforeDate);
                                self.labDownloadState.text = "下载完成";
                                let fileUrl : NSURL = self.tempFilePath(fileName: name) as NSURL;
                                self.labFileSize.text = String.init(format: "文件大小：%@", fileUrl.fileSizeWithUnit());
                                self.labDuration.text = String.init(format: "总用时：%.2fs", timeSpent);
                                self.labDownloadSpeed.text = String.init(format: "平均下载速度：%.2f %@/s",fileUrl.fileSizeSmallerThan1024() / timeSpent,fileUrl.fileSizeCount())
                            }
                            
                        }
            }
            Current_Service().getObject(getObjectReq);
        }

    func tempFilePath(fileName:String) -> URL {
        return URL.init(string: NSTemporaryDirectory())!.appendingPathComponent(fileName);
    }
    
    deinit {
        if request != nil {
            request?.cancel();
        }
    }

}
