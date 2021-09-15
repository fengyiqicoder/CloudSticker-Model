////
////  CloudServer.swift
////  Vibe
////
////  Created by Edmund Feng on 2021/4/14.
////

import Foundation
import CloudKit

class CloudServer {
    
    var state: CloudState = .noUpdating
    
    // iCloud Containers
    private var container: CKContainer
    private var privateDB: CKDatabase
    private var zone: CKRecordZone = CKRecordZone(zoneName: "Note")
    
    init() { // 初始化
        container = CKContainer(identifier: "iCloud.com.fengyiqi.PostItnoteForMac")
        privateDB = container.database(with: .private)
        
        initOperation()
    }
    
    private func initOperation() {
        // Create cloud kit subcription
        let subscription = CKRecordZoneSubscription(zoneID: zone.zoneID, subscriptionID: "note")
        let notifictionInfo = CKSubscription.NotificationInfo()
        notifictionInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notifictionInfo
        
        // 检查这个Zone能不能使用
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { _, _, err in
            print("modifySubscriptionsComplete \(String(describing: err))")
            if err != nil { // 无法就自己创建新的
                self.privateDB.save(self.zone) { _, _ in
                    print("createNewZone")
                }
            }
        }
        operation.qualityOfService = .utility
        privateDB.add(operation)
    }
    
    // ☁️ -> 🖥️
    
    func download(_ handler: ( @escaping ([StickerData]?, Error?) -> Void) ) {
        state = .updating
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        privateDB.perform(query, inZoneWith: zone.zoneID) { result, err in
            guard err == nil, let result = result else {
                DispatchQueue.main.async {
                    // change state
                    self.state = .noUpdating
                    // 无网络操作
                    handler(nil, err)
                }
                return
            }
            // 获取的result转换为NoteData
            let noteArrayData = result.map { StickerData(record: $0) }
            DispatchQueue.main.async {
                // change state
                self.state = .noUpdating
                handler(noteArrayData, nil)
            }
        }
    }
    
    // 🖥️ -> ☁️ Record Actions
    
    func deleteOldRecord(element: StickerData, complete: (() -> Void)? = nil ){
        let id = CKRecord.ID(recordName: element.uuid, zoneID: zone.zoneID)
        privateDB.delete(withRecordID: id) { _, error in
            if let error = error {
                print("Delete record error \(error)")
            } else {
                print("Delete record \(element.content) 保存成功")
            }
            
            self.state = .noUpdating
            complete?()
        }
    }
    
    func changeRecord(element: StickerData, complete: (() -> Void)? = nil) {
        let id = CKRecord.ID(recordName: element.uuid, zoneID: zone.zoneID)
        privateDB.fetch(withRecordID: id) { oldRecord, err in
            guard let record = oldRecord, err == nil else {
                print("Change record error \(err!)")
                self.state = .noUpdating
                return
            }
            self.save(sticker: element, to: record, complete: complete)
        }
    }
    
    private func save(sticker: StickerData, to record: CKRecord, complete: (() -> Void)? = nil ){
        record["uuid"] = sticker.uuid as String
        record["fontSize"] = Double(sticker.fontSize) as Double
        record["colorInt"] = sticker.colorInt as Int
        record["content"] = sticker.content as String
        privateDB.save(record) { _, error in
            if let error = error {
                print("Save record error \(error)")
            } else {
                print("Save record \(sticker.content) 保存成功")
            }
            complete?()
        }
    }
    
    func saveNewRecord(element: StickerData, complete: (() -> Void)? = nil) {
        let recordID = CKRecord.ID(recordName: element.uuid, zoneID: zone.zoneID)
        let newRecord = CKRecord(recordType: "Note", recordID: recordID)
        save(sticker: element, to: newRecord, complete: complete)
    }
    
    
}



enum CloudState {
    case updating
    case noUpdating
}
//MARK: - New shit

struct UploadingRequest {
    let block: ()->Void
    func execute() {
        block()
    }
}

class CloudServerBuffer {
    var hasRequest: Bool {
        request != nil
    }
    //储存一个request
    var request: UploadingRequest?
    func executeRequest() {
        request?.execute()
        request = nil
    }
}

