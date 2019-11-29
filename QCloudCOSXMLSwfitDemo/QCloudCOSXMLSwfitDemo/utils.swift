//
//  utils.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by karisli(李雪) on 2019/11/29.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//
import UIKit
let kSCREEN_WIDTH = UIScreen.main.bounds.size.width;
let kSCREEN_HEIGHT = UIScreen.main.bounds.size.height;
let keyWindow =  UIApplication.shared.connectedScenes
       .filter({$0.activationState == .foregroundActive})
       .map({$0 as? UIWindowScene})
       .compactMap({$0})
       .first?.windows
       .filter({$0.isKeyWindow}).first
let kNAV_HEIGT = keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height == 44 ? 88 : 64 ;

