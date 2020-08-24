//
//  QCloudCOSXMLServiceConfiguration.swift
//  QCloudCOSXMLSwiftDemo
//
//  Created by karisli(李雪) on 2019/11/29.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import Foundation
import QCloudCOSXML
class QCloudCOSXMLServiceConfiguration: NSObject {
    
    static let shared = QCloudCOSXMLServiceConfiguration();
    
    var currentRegion:String = "ap-guangzhou"
    
    var currentBucket:String?
    
    func currentTransferManagerService() -> QCloudCOSTransferMangerService {
        return QCloudCOSTransferMangerService.costransfermangerService(forKey: self.currentRegion);
    }
    func currentCOSXMLService () -> QCloudCOSXMLService {
        return QCloudCOSXMLService.init(forKey: self.currentRegion);
    }
}
