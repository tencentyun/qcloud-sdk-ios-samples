//
//  AppDelegate.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by karisli(李雪) on 2019/11/27.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import UIKit
import QCloudCOSXML
import QCloudCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,
                                QCloudSignatureProvider,
                                QCloudCredentailFenceQueueDelegate {

    
    var window: UIWindow?
    var credentialFenceQueue:QCloudCredentailFenceQueue?
    func fenceQueue(_ queue: QCloudCredentailFenceQueue!, requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        let credential = QCloudCredential.init();
        credential.secretID = SECRET_ID;
        credential.secretKey = SECRET_KEY;
//        credential.experationDate = NSDate.init(timeIntervalSince1970:1575012803) as Date;
        credential.token = "token";
        let creator = QCloudAuthentationV5Creator.init(credential: credential);
        continueBlock(creator,nil);

    }
    
    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        let cre = QCloudCredential.init();
        cre.secretID = SECRET_ID;
        cre.secretKey = SECRET_KEY;
        let auth = QCloudAuthentationV5Creator.init(credential: cre);
        let signature = auth?.signature(forData: urlRequst)
        continueBlock(signature,nil);
    }
    
    func setupCOSXMLService () {
        let config = QCloudServiceConfiguration.init();
        config.signatureProvider = self;
        config.appID = APPID;
        let endpoint = QCloudCOSXMLEndPoint.init();
        endpoint.regionName = "ap-guangzhou";
        endpoint.useHTTPS = true;
        config.endpoint = endpoint;
        QCloudCOSXMLService.registerDefaultCOSXML(with: config);
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: config);
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window?.rootViewController = UINavigationController.init(rootViewController: QCloudCOSXMLRegionsController());
        self.window?.makeKeyAndVisible();
        self.setupCOSXMLService();
        self.credentialFenceQueue = QCloudCredentailFenceQueue.init();
        self.credentialFenceQueue?.delegate = self;
        TACMTAConfig.getInstance()?.debugEnable = true;
        return true
    }

    
  

}

