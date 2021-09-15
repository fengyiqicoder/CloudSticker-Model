//
//  StorageBridging.swift
//  Cloud Sticker
//
//  Created by Edmund Feng on 2021/7/23.
//

import AppKit

class DataBridging {
    static var shared = DataBridging()
    
    private let cloudSaver = CloudServer()
    private var isUsingCoreData: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isUsingCoreData")
        }
        get {
            (UserDefaults.standard.object(forKey: "isUsingCoreData") as? Bool) ?? false
        }
    }
    
    //使用这个方法检查是否切换成coredata
    func checkBridged() {
        if isUsingCoreData {
            //do nothing
        } else {
            isUsingCoreData = true
            cloudSaver.download { oldDatas, _ in
                StickerCenter.shared.syncOld(datas: oldDatas ?? [])
            }
            UpdateAlertController.shared.requestToUpdate()
        }
    }
}
