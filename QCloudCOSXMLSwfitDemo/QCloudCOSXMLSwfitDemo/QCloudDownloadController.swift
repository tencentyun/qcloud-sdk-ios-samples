//
//  QCloudDownloadController.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by karisli(李雪) on 2019/11/28.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import UIKit
import QCloudCOSXML
class  QCloudDownloadController: UIViewController,UITableViewDelegate,UITableViewDataSource{
   
    
    
    
    
    var tableView:UITableView!;
    var fileLists = Array<Any>.init();
    var indicatorView:UIActivityIndicatorView!;
   
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.setUpContent();
        self.view.backgroundColor = .white;
        self.indicatorView.startAnimating();
        let getBucketRequest = QCloudGetBucketRequest.init();
        getBucketRequest.maxKeys = 1000;
        getBucketRequest.bucket = QCloudCOSXMLServiceConfiguration.shared.currentBucket();
        getBucketRequest.setFinish { (result, error) in
            DispatchQueue.main.async {
            self.indicatorView.stopAnimating();
                for item in result.contents {
                self.fileLists.append(item.key);
                }
                self.tableView.reloadData();
            }
        };
        QCloudCOSXMLServiceConfiguration.shared.currentCOSXMLService().getBucket(getBucketRequest);
    }
   
    func setUpContent()  {
        self.tableView = UITableView.init(frame: view.bounds, style: .plain);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.view.addSubview(self.tableView);
        self.indicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.medium);
        self.indicatorView.frame = CGRect.init(x: (kSCREEN_WIDTH-40)/2.0, y: 300, width: 60, height: 60);
        self.indicatorView.hidesWhenStopped = true;
        self.indicatorView.color = .lightGray;
        self.indicatorView.backgroundColor  = .clear;
        self.view.addSubview(indicatorView);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fileLists.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "downloadCell";
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier);
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifier);
        }
        cell?.textLabel?.text = self.fileLists[indexPath.row] as! String;
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = self.fileLists[indexPath.row];
        let beforeDate = NSDate.now;
        let getObjectReq = QCloudGetObjectRequest.init();
        getObjectReq.bucket = QCloudCOSXMLServiceConfiguration.shared.currentBucket();
        getObjectReq.object = name as! String;
        getObjectReq.downloadingURL = self.tempFilePath(fileName: name as! String);
        getObjectReq.finishBlock = {(result,error) in
            let afterDate = NSDate.now;
             let downLoadTime = Double(afterDate .timeIntervalSince(beforeDate));
            if error == nil {
               
                let fileInfo =  QCloudDownloadedFileInfo();
                fileInfo.fileURL = getObjectReq.downloadingURL as NSURL;
                fileInfo.fileName = (name as! String);
                fileInfo.timeSpent = downLoadTime;
                DispatchQueue.main.async {
                    let fileDEtailVc = QCloudFileDetailController.init();
                    fileDEtailVc.fileInfo = fileInfo;
                
                    self.navigationController?.pushViewController(fileDEtailVc, animated: true);
                }
//                self.openFile(fileURL: getObjectReq.downloadingURL);
            }
        }
        QCloudCOSXMLServiceConfiguration.shared.currentCOSXMLService().getObject(getObjectReq);
    }
    
   
    func tempFilePath(fileName:String) -> URL {
        return URL.init(string: NSTemporaryDirectory())!.appendingPathComponent(fileName);
    }
}
