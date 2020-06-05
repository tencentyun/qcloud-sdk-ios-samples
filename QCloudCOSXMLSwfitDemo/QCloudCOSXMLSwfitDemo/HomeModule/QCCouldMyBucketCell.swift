//
//  QCCouldMyBucketCell.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by garenwang on 2020/5/20.
//  Copyright © 2020 tencentyun.com. All rights reserved.
//

import UIKit
import QCloudCOSXML

class QCCouldMyBucketCell: UITableViewCell {
    
    var cellContent : QCloudBucket? = nil;
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier);
        
        self.selectionStyle = UITableViewCell.SelectionStyle.none;
        
        self.textLabel?.font = UIFont.systemFont(ofSize: 18);
        
        self.textLabel?.numberOfLines = 0;
        
        self.textLabel?.textColor = HEXColor(rgbValue: 0x333333);
        
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 13);
        
        self.detailTextLabel?.textColor = HEXColor(rgbValue: 0x999999);
        
        self.detailTextLabel?.numberOfLines = 0;
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    func setupContent(content : QCloudBucket)  {
        cellContent = content;
        self.textLabel?.text = "名称：" + content.name;
        
        let date = NSDate.qcloud_date(fromRFC3339String: cellContent!.createDate);
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let nowDateString = dateFormatter.string(from: date!);
        
        self.detailTextLabel?.text = "创建时间：" + nowDateString + "\n地区：" + content.location;
    }

}
