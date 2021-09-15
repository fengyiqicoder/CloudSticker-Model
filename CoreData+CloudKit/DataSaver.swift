//
//  CloudDataCenter.swift
//  Cloud Sticker
//
//  Created by Edmund Feng on 2021/7/14.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif
import CoreData

extension DataSaver {
    //唯一的外部接口 全量更新sticker
    var stickerDatas: [StickerData] {
        set { store(stickers: newValue) }
        get { currentStickerData }
    }
}

//CoreData + CloudKit 自动云同步
class DataSaver: NSObject {
    
    //使用之前先设置Action
    var dataDidChangeAction: (() -> Void)!

    static let shared = DataSaver()
    
    fileprivate var currentStickerData: [StickerData] {
        fetch().map{ $0.stickerData }
    }
   
    
    fileprivate func store(stickers: [StickerData]) {
        let changes = DataDifferentiator.differ(old: currentStickerData, new: stickers)
        changes.forEach { (old, new) in
            //performing change
            if let deletedData = old, new == nil {
                delete(sticker: deletedData)
            }
            if let _ = old,let newData = new {
                change(sticker: newData)
            }
            if let newData = new, old == nil {
                saveNew(sticker: newData)
            }
        }
    }
    
    
    fileprivate func saveNew(sticker: StickerData) {
        let newSticker = StickerCoreData(context: viewContext)
        newSticker.stickerData = sticker
        save()
    }
    
    
    fileprivate func delete(sticker: StickerData) {
        guard let stickerCoreData = find(sticker: sticker) else { return }
        viewContext.delete(stickerCoreData)
        save()
    }
    
    fileprivate func change(sticker: StickerData) {
        guard let stickerCoreData = find(sticker: sticker) else { return }
        stickerCoreData.stickerData = sticker
        save()
    }
    
    fileprivate func find(sticker: StickerData) -> StickerCoreData? {
        guard let index = currentStickerData.firstIndex(where: { $0.uuid == sticker.uuid }) else { return nil }
        return fetch()[index]
    }
    
    fileprivate func save() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
    
    //MARK: - Core Data
    fileprivate lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "StickerCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()
    
    fileprivate var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<StickerCoreData>! = {
        let fetchRequest: NSFetchRequest<StickerCoreData> = StickerCoreData.fetchRequest()
        //检索顺序 ColorInt
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \StickerCoreData.colorInt, ascending: false)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)

        controller.delegate = self
        return controller
    }()
    
    fileprivate func fetch() -> [StickerCoreData] {
        try? fetchedResultsController?.performFetch()
        return fetchedResultsController.fetchedObjects ?? []
    }

}


extension DataSaver: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DataSaver.shared.dataDidChangeAction!()
    }
}
//MARK: - Make core data class more easy to use

extension StickerCoreData {
    
    private var context: NSManagedObjectContext {
        DataSaver.shared.viewContext
    }
    
    var stickerData: StickerData {
        set { write(sticker: newValue) }
        get { read() }
    }
   
    private func read() -> StickerData {
        var stickerData: StickerData!
        context.performAndWait {
            stickerData = StickerData(uuid: self.uuid!,
                                      fontSize: CGFloat(self.fontSize),
                                      colorInt: Int(self.colorInt),
                                      content: self.content!)
        }
        return stickerData
    }
    
    private func write(sticker: StickerData) {
        //Don't use performAndWait it works
        self.colorInt = Int16(sticker.colorInt)
        self.fontSize = Double(sticker.fontSize)
        self.content = sticker.content
        self.uuid = sticker.uuid
        
        if context.hasChanges {
            try? context.save()
        }
    }
    
}



//这里添加CloudKit schema
//放在container里面
//ONLY WORKS IN FUCKING iOS

//        let cloudStoreLocation = URL(fileURLWithPath: "/path/to/cloud.store")
//        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
//
//        cloudStoreDescription.configuration = "Cloud"
//        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.fengyiqi.PostItnoteForMac")
//
//        container.persistentStoreDescriptions = [cloudStoreDescription]
//
//        #if DEBUG
//        do {
//            // Use the container to initialize the development schema.
//            try container.initializeCloudKitSchema(options: [])
//        } catch {
//            // Handle any errors.
//            fatalError(error.localizedDescription)
//        }
//        #endif
