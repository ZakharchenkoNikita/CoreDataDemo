//
//  DataManager.swift
//  CoreDataDemo
//
//  Created by Nikita on 17.08.21.
//

import UIKit
import CoreData

class DataManager {
    
    static let shared = DataManager()

    private var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
 
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() { }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        var taskList: [Task] = []
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        
        return taskList
    }
    
    func save(_ taskName: String, completionHandler: (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            return
        }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        
        task.name = taskName
        completionHandler(task)

        saveContext()
    }
    
    func editingTask(taskName: String, task: Task) {
        task.name = taskName
        saveContext()
    }
    
    func deleteTask(index: Int, taskList: [Task]) {
        context.delete(taskList[index] as NSManagedObject)
        saveContext()
    }
}
