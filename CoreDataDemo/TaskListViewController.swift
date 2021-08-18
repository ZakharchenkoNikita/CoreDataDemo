//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 16.08.2021.
//

import UIKit
import CoreData

enum Status {
    case save, editing
}

class TaskListViewController: UITableViewController {

    // MARK: Private properties
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let dataManager =  DataManager.shared
    private let cellID = "cell"
    
    private var taskList: [Task] = []
    
    private var status = Status.save
    
    // MARK: override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        taskList = dataManager.fetchData()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { _, _, _ in
            self.dataManager.deleteTask(index: indexPath.row, taskList: self.taskList)
            self.taskList.remove(at: indexPath.row)
            
            let cellIndex = IndexPath(row: indexPath.row, section: 0)
            tableView.deleteRows(at: [cellIndex], with: .automatic)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        status = .editing
        showAlert(with: "New Task", and: "What do you want to do?", indexPath: indexPath.row)
    }

    // MARK: private methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        status = .save
        showAlert(with: "New Task", and: "What do you want to do?", indexPath: nil)
    }
    
    private func showAlert(with title: String, and massage: String, indexPath: Int?) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            
            switch self.status {
            case .save:
                self.dataManager.save(task) { task in
                    self.taskList.append(task)
                    let cellIndex = IndexPath(row: self.taskList.count - 1, section: 0)
                    self.tableView.insertRows(at: [cellIndex], with: .automatic)
                }
            case .editing:
                guard let indexPath = indexPath else { return }
                self.dataManager.editingTask(taskName: task, task: self.taskList[indexPath])
                
                let cellIndex = IndexPath(row: indexPath, section: 0)
                self.tableView.reloadRows(at: [cellIndex], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            switch self.status {
            case .save: textField.placeholder = "New Task"
            case .editing: textField.text = self.taskList[indexPath ?? 0].name
            }
        }
        
        present(alert, animated: true)
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
}

