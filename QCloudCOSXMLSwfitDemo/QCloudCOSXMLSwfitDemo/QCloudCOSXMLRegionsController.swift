//
//  QCloudCOSXMLRegionsController.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by karisli(李雪) on 2019/11/28.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import UIKit
import QCloudCOSXML
class QCloudCOSXMLRegionsController:UIViewController,
UITableViewDelegate,UITableViewDataSource{
    
    var selectRegion : BlockOneParams?;
    
    var regions = ["ap-beijing","ap-shanghai","ap-guangzhou","ap-chengdu","ap-chongqing","ap-singapore","ap-hongkong","eu-frankfurt","ap-mumbai","ap-seoul","na-siliconvalley","na-ashburn"];
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "选择region";
        let tableView = UITableView.init(frame: view.bounds, style: .plain);
        tableView.delegate = self;
        tableView.dataSource = self;
        view.addSubview(tableView);
        

        let leftItem : UIBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItem.Style.plain, target: self , action: #selector(cancelSelect));
        self.navigationItem.leftBarButtonItem = leftItem;
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "regionCell";
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier);
        if cell == nil {
            cell =  UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier);
        }
        cell?.textLabel?.text = regions[indexPath.row];
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click");
        
        let region = self.regions[indexPath.row];
        if self.selectRegion != nil{
            self.selectRegion!(region as NSObject);
        }
        self.dismiss(animated: true, completion: nil);
        
    }
    
    @objc func cancelSelect() {
        self.dismiss(animated: true, completion: nil);
    }
    
}
