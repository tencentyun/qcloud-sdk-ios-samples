//
//  QCloudFileListCtor.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by garenwang on 2020/5/21.
//  Copyright © 2020 tencentyun.com. All rights reserved.
//

import UIKit

class QCloudFileListCtor: UITableViewController {
    
    var contentsArray : Array = Array<QCloudBucketContents>();
    
    var prefixeszArray : Array<QCloudCommonPrefixes>?;
    
    var uploadTempFilePath : String?;
    
    var marker : String?;
    
    var prefix : String?;
    
    var tableViewFooter :UILabel = UILabel();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.fetchData()
    }
    
    func setupUI() {
        
        self.title = self.prefix == nil ? "文件列表" : self.prefix;
        self.view.addSubview(self.indicatorView);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.register(BucketFileItemViewCell.self, forCellReuseIdentifier: "BucketFileItemViewCell");
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell");
        self.tableView.tableFooterView  = self.tableViewFooter;
        
        let rightItem: UIBarButtonItem = UIBarButtonItem.init(title: "上传", style: UIBarButtonItem.Style.plain, target: self, action: #selector(uploadFileToBucket));
        self.navigationItem.rightBarButtonItem = rightItem;
        
        
        tableViewFooter = UILabel.init(frame: CGRect.init(x:0, y:0, width: kSCREEN_WIDTH,height:60))
        tableViewFooter.font = UIFont.systemFont(ofSize: 14);
        tableViewFooter.textAlignment = NSTextAlignment.center;
        
        tableViewFooter.textColor = HEXColor(rgbValue: 0x999999);
        
        self.tableView.tableFooterView = tableViewFooter;
        
    }
    
    func fetchData() {
        
        //    获取文件列表
        //      实例化 QCloudGetBucketRequest 类
        //      调用  QCloudCOSXMLService实例的 GetBucket方法
        //      参数：注重说一下 delimiter prefix；
        //                  delimiter:路径分隔符 固定为 /
        //                  prefix:路径起始位置，比如要获取bucket下所有文件以及文件夹 该参数就不传，如果要获取folder文件夹下的所有文件及文件夹 该参数就传 /folder1
        //        假如一个桶的目录如下
        //            |-bucket
        //              |-folder1
        //                |-folder1_1
        //                |-folder1_2
        //                |-file1_1
        //              |-folder2
        //                |-folder2_1
        //                |-folder2_2
        //      结果：在result里 contents里是该路径下所有的文件，注意 里面包含了当前路径，需要手动过滤掉
        //                     commonPrefixes 包含该路径下的所有文件夹， prefix代表当每一个文件夹的路径，如果需要获取里面所有文件，需要将该参数传给 QCloudGetBucketRequest 对象的 prefix
        self.indicatorView.startAnimating();
        let request = QCloudGetBucketRequest();
        request.bucket = Current_Bucket();
        
        if self.prefix != nil {
            request.prefix = self.prefix!;
        }
        
        request.delimiter = "/";
        
        request.maxKeys = 100;
        if self.marker != nil {
            request.marker = self.marker! as String;
        }
        
        request.setFinish { (result, error) in
            
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating();
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.tableViewFooter.text = "数据加载失败";
                    self.tableView.reloadData();
                }
                
            }else{
                
                if self.marker == nil {
                    self.contentsArray.removeAll();
                }
                
                for content in (result! as QCloudListBucketResult).contents {
                    
                    if content.key.hasSuffix("/") {
                        continue;
                    }
                    self.contentsArray.append(content);
                }
                
                if result?.commonPrefixes != nil {
                    self.prefixeszArray = result!.commonPrefixes;
                }
                
                DispatchQueue.main.async {
                    if ((result! as QCloudListBucketResult).isTruncated) {
                        self.marker = (result! as QCloudListBucketResult).nextMarker;
                        self.tableViewFooter.text = "上拉加载更多";
                    }else{
                        self.marker = nil;
                        self.tableViewFooter.text = "无更多数据";
                    }
                    self.tableView.reloadData();
                }
            }
        }
        Current_Service().getBucket(request);
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return self.prefixeszArray?.count ?? 0;
        }else{
            return self.contentsArray.count;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!;
            let prefixe : QCloudCommonPrefixes = (self.prefixeszArray?[indexPath.row])!;
            cell.textLabel?.textColor = UIColor.systemBlue;
            if self.prefix != nil {
                cell.textLabel?.text =  prefixe.prefix.replacingOccurrences(of: self.prefix!, with: "");
            }else{
                cell.textLabel?.text =  prefixe.prefix;
            }
            
            return cell;
        }else{
            let cell : BucketFileItemViewCell = tableView.dequeueReusableCell(withIdentifier: "BucketFileItemViewCell") as! BucketFileItemViewCell;
            cell.setupContent(content: self.contentsArray[indexPath.row])
            if self.prefix != nil {
                cell.setFileTitle(title:self.contentsArray[indexPath.row].key.replacingOccurrences(of: self.prefix!, with: ""));
            }
            
            cell.deleteFile = {(obj )->(Void) in
                self.cellDelete(content: obj as! QCloudBucketContents);
                
            }
            cell.downLoadFile = {(obj) -> (Void) in
                self.cellDownLoadFile(content: obj as! QCloudBucketContents);
            }
            
            return cell;
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let fileList = QCloudFileListCtor();
            let prefixe : QCloudCommonPrefixes = (self.prefixeszArray?[indexPath.row])!;
            fileList.prefix = prefixe.prefix;
            self.navigationController?.pushViewController(fileList, animated: true);
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50;
        }else{
            return 110;
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        var bottomHeight : CGFloat = 0.0;
        bottomHeight = scrollView.adjustedContentInset.bottom;
        if ((scrollView.contentOffset.y - bottomHeight + kSCREEN_HEIGHT >= scrollView.contentSize.height) && self.marker != nil) {
            self.fetchData();
        }
    }
    
    
    @objc func uploadFileToBucket() {
        self.navigationController?.pushViewController(QCloudUploadNewCtor(), animated: true);
    }
    
    func cellDelete(content : QCloudBucketContents)  {
        //    删除存储桶中的文件对象
        //    实例化 QCloudDeleteObjectRequest
        //    调用 QCloudCOSXMLService 实例的 DeleteObject 方法 发起请求
        //    在FinishBlock获取结果
        //    参数： bucket 桶名（要删除的文件在哪个桶，该参数就传该桶名称）
        //            object 文件key （要删除的文件名称 key）
        let deleteRequest : QCloudDeleteObjectRequest = QCloudDeleteObjectRequest();
        deleteRequest.bucket = Current_Bucket();
        deleteRequest.object = content.key;
        
        deleteRequest.finishBlock = {(outputObject,error)->()in
            if error == nil {
                DispatchQueue.main.async {
                    self.fetchData();
                }
            }
        }
        Current_Service().deleteObject(deleteRequest);
    }
    
    func cellDownLoadFile(content : QCloudBucketContents) {
        let downLoadVC : QCloudDownLoadNewCtor = QCloudDownLoadNewCtor();
        downLoadVC.content = content;
        self.navigationController?.pushViewController(downLoadVC, animated: true);
        
    }
    
}
