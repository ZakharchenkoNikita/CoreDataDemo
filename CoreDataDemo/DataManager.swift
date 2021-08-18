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

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() { }
    
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
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
