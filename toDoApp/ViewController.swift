//
//  ViewController.swift
//  toDoApp
//
//  Created by Emre on 26.02.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var tempTF = UITextField()
    var taskList = [String]()
    var taskListDate = [Date]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = "To Do Application"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
    }
    override func viewWillAppear(_ animated: Bool) {
        getItem()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = taskList[indexPath.row]
        content.secondaryText = "\(taskListDate[indexPath.row])"
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskItem = taskList[indexPath.row]
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        fetchRequest.predicate = NSPredicate(format: "name = %@",taskItem)
        fetchRequest.returnsObjectsAsFaults = false
        if editingStyle == .delete{
            do{
                let results = try context!.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    context?.delete(result)
                }
                try context?.save()
                getItem()
            }catch{
                print("error")
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let taskItem = taskList[indexPath.row]
        let alert = UIAlertController(title: "Control Panel", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Write new task name", preferredStyle: .alert)
            alert.addTextField(){(textfield)
                in
                textfield.placeholder = "Edit item"
                self.tempTF = textfield
            }
            alert.textFields?.first?.text = taskItem
            let saveButton = UIAlertAction(title: "Save", style: .default){(action)
                in
                self.editItem(taskItem: taskItem, newName: self.tempTF.text!)
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(saveButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
            self.deleteItem(taskItem: taskItem)
        }))
        present(alert, animated: true)
    }
    
    @objc func addButton(){
        let alert = UIAlertController(title: "Add Item", message: "Write task name", preferredStyle: .alert)
        alert.addTextField(){(textfield)
            in
            textfield.placeholder = "Creat new item"
            self.tempTF = textfield
        }
        let saveButton = UIAlertAction(title: "Save", style: .default){(action)
            in
            self.creatItem(task: self.tempTF.text!)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
    
    func creatItem(task: String){
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: context!)
        let item = NSManagedObject(entity: entity!, insertInto: context)
        item.setValue(task, forKey: "name")
        item.setValue(Date(), forKey: "date")
        do{
            try context?.save()
            getItem()
        }catch{
            print("Error")
        }
    }
    func getItem(){
        taskList.removeAll()
        taskListDate.removeAll()
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        do{
            let fetchRequest = try context?.fetch(fetchRequest)
            for item in fetchRequest as! [NSManagedObject]{
                taskList.append(item.value(forKey: "name") as! String)
                taskListDate.append(item.value(forKey: "date") as! Date)
            }
            tableView.reloadData()
        }catch{
            print("Error Get Item")
        }
    }
    
    func deleteItem(taskItem: String){
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        fetchRequest.predicate = NSPredicate(format: "name = %@",taskItem)
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context!.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                context?.delete(result)
            }
            try context?.save()
            self.getItem()
        }catch{
            print("error")
        }
    }
    
    func editItem(taskItem: String, newName: String){
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        fetchRequest.predicate = NSPredicate(format: "name = %@",taskItem)
        do {
            let results = try context!.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results![0].setValue(newName, forKey: "name")
            }
        } catch {
            print("Error1)")
            
        }
        do {
            try context?.save()
            getItem()
           }
        catch {
            print("Error2")
        }
    }
}

