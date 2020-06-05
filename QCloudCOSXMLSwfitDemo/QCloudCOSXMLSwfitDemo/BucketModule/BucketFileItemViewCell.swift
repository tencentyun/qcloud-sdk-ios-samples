//
//  BucketFileItemViewCell.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by garenwang on 2020/5/21.
//  Copyright © 2020 tencentyun.com. All rights reserved.
//

import UIKit

class BucketFileItemViewCell: UITableViewCell {
    
    private var cellContent : QCloudBucketContents?
    
    var deleteFile : BlockOneParams?
    
    var downLoadFile :BlockOneParams?

    let labFileName: UILabel = UILabel();
    let labFileCreateTime: UILabel = UILabel();
    let labFileSize: UILabel = UILabel();
    let btnDownload: UIButton = UIButton.init(type: UIButton.ButtonType.custom);
    let btnDelete: UIButton = UIButton.init(type: UIButton.ButtonType.custom);
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = UITableViewCell.SelectionStyle.none;
        
        let margin: CGFloat = 16;
        let height: CGFloat = 30;
        
        labFileName.frame = CGRect.init(x: margin, y: margin, width: kSCREEN_WIDTH - margin * 2, height: height);
        labFileName.textColor = HEXColor(rgbValue: 0x333333);
        labFileName.font = UIFont.systemFont(ofSize: 17);
        self.contentView.addSubview(labFileName);

        labFileCreateTime.frame = CGRect.init(x: margin, y: labFileName.frame.origin.y + labFileName.frame.size.height, width: kSCREEN_WIDTH - margin * 3 - 120, height: 30);
        labFileCreateTime.textColor = HEXColor(rgbValue: 0x999999);
        labFileCreateTime.font = UIFont.systemFont(ofSize: 13);
        self.contentView.addSubview(labFileCreateTime);
     
        labFileSize.frame = CGRect.init(x: labFileCreateTime.frame.size.width + labFileCreateTime.frame.origin.x + margin * 2, y: labFileName.frame.origin.y + labFileName.frame.size.height, width: 120, height: 30);
        labFileSize.textColor = HEXColor(rgbValue: 0x999999);
        labFileSize.font = UIFont.systemFont(ofSize: 13);
        self.contentView.addSubview(labFileSize);
        
        btnDownload.frame = CGRect.init(x: 0, y: labFileSize.frame.origin.y + labFileSize.frame.size.height, width: kSCREEN_WIDTH / 2, height: height);
        btnDownload.setTitle("下载", for: UIControl.State.normal);
        btnDownload.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal);
        btnDownload.addTarget(self , action: #selector(actionDownload), for: UIControl.Event.touchUpInside);
        self.contentView.addSubview(btnDownload);
        
        btnDelete.frame = CGRect.init(x: kSCREEN_WIDTH / 2, y: labFileSize.frame.origin.y + labFileSize.frame.size.height, width: kSCREEN_WIDTH / 2, height: height);
        btnDelete.setTitle("删除", for: UIControl.State.normal);
        btnDelete.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal);
        btnDelete.addTarget(self , action: #selector(actionDelete), for: UIControl.Event.touchUpInside);
        self.contentView.addSubview(btnDelete);
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupContent(content : QCloudBucketContents) {

        self.cellContent = content;
        self.labFileName.text = content.key;
        self.labFileSize.text = "文件大小:" + content.fileSize()
        
        let date = NSDate.qcloud_date(fromRFC3339String: content.lastModified);
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let nowDateString = dateFormatter.string(from: date!);
        
        self.labFileCreateTime.text = "创建时间:" + nowDateString;
    }
    
    func setFileTitle(title:String) {
        self.labFileName.text = title;
    }
    
    @objc func actionDownload(_ sender: UIButton) {
        if self.downLoadFile != nil && self.cellContent != nil{
            self.downLoadFile!(self.cellContent!);
        }
    }
    @objc func actionDelete(_ sender: UIButton) {
        if self.deleteFile != nil && self.cellContent != nil{
            self.deleteFile!(self.cellContent!);
        }
    }
    
    
}
