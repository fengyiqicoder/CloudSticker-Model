//////
//////  DataCenter.swift
//////  Vibe
//////
//////  Created by Edmund Feng on 2021/4/14.
//////
//
//import Foundation
//
//typealias DataHandler = ([StickerData]?) -> Void
//
////唯二的外部方法
//extension DataCenter {
//
//    //在这里订阅更改
//
//    func load(handler: @escaping DataHandler) {
////        cloudSaver.download { cloudData, err in
////            guard err == nil else {
////                print("DataCenter load \(err!)")
////                handler(self.localSaver.stickers)
////                return
////            }
////            self.localSaver.stickers = cloudData ?? []
////            handler(cloudData)
////        }
//    }
//
//    func save(stickers: [StickerData]) {
////        localSaver.stickers = stickers
////        //save to cloud logic
////        let request = UploadingRequest {
////            self.cloudSaver.download { cloudData, err in
////                guard let cloudData = cloudData, err == nil else {
////                    print("cloudSaver download \(err!)")
////
////                    return
////                }
////
////                let changes = DataDifferentiator.differ(old: cloudData, new: self.localSaver.stickers)
////
////                let id = UUID().uuidString
////                print("\(id) \(Date().timeIntervalSince1970) start request \(changes)")
////                let recordChangedHandler: (() -> Void) = { [weak self] in
////                    //if buffer has request then execute it
////                    self?.buffer.executeRequest()
////                    print("\(id) \(Date().timeIntervalSince1970) end request")
////                }
////                changes.forEach { (cloudData, currentData) in
////                    //performing change
////                    if let deletedData = cloudData, currentData == nil {
////                        self.cloudSaver.deleteOldRecord(element: deletedData, complete: recordChangedHandler)
////                    }
////                    if let _ = cloudData,let localData = currentData {
////                        self.cloudSaver.changeRecord(element: localData, complete: recordChangedHandler)
////                    }
////                    if let newData = currentData, cloudData == nil {
////                        self.cloudSaver.saveNewRecord(element: newData, complete: recordChangedHandler)
////                    }
////                }
////            }
////        }
////
////        if case .noUpdating = cloudSaver.state, !buffer.hasRequest {
////            request.execute()
////        } else {
////            buffer.request = request
////        }
//    }
//}
//
//class DataCenter {
//
////    private let localSaver = LocalDataCenter()
////    private let cloudSaver = CloudServer()
////    private let buffer = CloudServerBuffer()
//    private let dataSaver = DataSaver()
//}
////
////#if os(iOS)
////extension DataCenter {
////    var localStickers: [StickerData] {
////        get {
////            dataSaver.stickerDatas
////        }
////        set {
////            dataSaver.stickerDatas = newValue
////        }
////    }
////}
////#endif
//
