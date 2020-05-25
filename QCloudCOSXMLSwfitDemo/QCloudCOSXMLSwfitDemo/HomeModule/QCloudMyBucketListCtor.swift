//
//  QCloudMyBucketListCtor.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by garenwang on 2020/5/20.
//  Copyright © 2020 tencentyun.com. All rights reserved.
//

import UIKit
import QCloudCOSXML

class QCloudMyBucketListCtor: UITableViewController {
    
    let Rowheight : CGFloat = 80.0;
    
    var bucketLists = NSMutableArray.init();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }
    
    func setupUI() {
        self.title = "我的存储桶";
        self.view.backgroundColor = UIColor.white;
        self.navigationController?.navigationBar.isTranslucent = true;
        
        self.view.addSubview(self.indicatorView);
        let rightItem = UIBarButtonItem.init(title: "新建桶", style: UIBarButtonItem.Style.plain, target: self, action:#selector(createBucket));
        self.navigationItem.rightBarButtonItem = rightItem;
        self.view.addSubview(self.indicatorView);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = Rowheight;
        self.tableView.register(QCCouldMyBucketCell.self, forCellReuseIdentifier: "QCCouldMyBucketCell");
        
        
        
    }
    
    func fetchData()  {
        self.indicatorView.startAnimating();
        let getBucketListReq = QCloudGetServiceRequest.init()
        getBucketListReq.setFinish { (result, error) in
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating();
                if error == nil{
                    self.bucketLists.addObjects(from: result!.buckets);
                    self.tableView .reloadData();
                }
            }
        }
        QCloudCOSXMLServiceConfiguration.shared.currentCOSXMLService().getService(getBucketListReq);
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bucketLists.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "QCCouldMyBucketCell";
        let cell : QCCouldMyBucketCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! QCCouldMyBucketCell;
        cell.setupContent(content: self.bucketLists[indexPath.row] as! QCloudBucket);
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bucket : QCloudBucket = self.bucketLists[indexPath.row] as! QCloudBucket;
        
        let regionName : String = bucket.location;
        
        var configuration:QCloudServiceConfiguration?
        configuration = QCloudCOSXMLService.defaultCOSXML().configuration.copy() as? QCloudServiceConfiguration;
        
        configuration?.endpoint.regionName = regionName;
        QCloudCOSXMLServiceConfiguration.shared.currentRegion = regionName;
        QCloudCOSXMLServiceConfiguration.shared.currentBucket = bucket.name;
        QCloudCOSTransferMangerService.registerCOSTransferManger(with: configuration!, withKey: regionName)
        QCloudCOSXMLService.registerCOSXML(with: configuration!, withKey: regionName);

        self.navigationController?.pushViewController(QCloudFileListCtor(), animated: true);
    }
    
    @objc func createBucket() {
        self.navigationController?.pushViewController(QCloudCreateBucketCtor(), animated: true);
    }
}
