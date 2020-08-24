//
//  utils.swift
//  QCloudCOSXMLSwiftDemo
//
//  Created by karisli(李雪) on 2019/11/29.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//
import UIKit

let CURRENT_REGION = "ap-guangzhou"

let kSCREEN_WIDTH = UIScreen.main.bounds.size.width
let kSCREEN_HEIGHT = UIScreen.main.bounds.size.height
let kSCREEN_SIZE = UIScreen.main.bounds.size;
let keyWindow =  UIApplication.shared.connectedScenes
       .filter({$0.activationState == .foregroundActive})
       .map({$0 as? UIWindowScene})
       .compactMap({$0})
       .first?.windows
       .filter({$0.isKeyWindow}).first
let kNAV_HEIGT = keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height == 44 ? 88 : 64 ;

func RGBColor(r:CGFloat,g:CGFloat,b:CGFloat) -> UIColor {
    return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0);
}

func HEXColor(rgbValue:uint) -> UIColor {
    let r:uint = rgbValue >> 16
    let g:uint = rgbValue >> 8 & 0xff
    let b:uint = rgbValue & 0xff
    
    return RGBColor(r: CGFloat.init(r), g: CGFloat.init(g), b: CGFloat.init(b));
}

func Current_Service() -> QCloudCOSXMLService{
    return QCloudCOSXMLServiceConfiguration.shared.currentCOSXMLService();
}

func Current_Region() -> String{
    return QCloudCOSXMLServiceConfiguration.shared.currentRegion;
}

func Current_Bucket() -> String{
    if QCloudCOSXMLServiceConfiguration.shared.currentBucket != nil {
        return QCloudCOSXMLServiceConfiguration.shared.currentBucket!;
    }else{
        return "";
    }
}

func Current_Transfer_Manager() -> QCloudCOSTransferMangerService{
    return QCloudCOSXMLServiceConfiguration.shared.currentTransferManagerService();
}



typealias BlockNoParams = () ->(Void)

typealias BlockOneParams = (_ obj : NSObject) ->(Void)

typealias BlockTwoParams = (_ obj1 : NSObject ,_ obj2 : NSObject) ->(Void)

