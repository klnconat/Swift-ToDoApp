//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Farmlabs Agriculture Tech on 6.09.2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryList = [ToDoCategory]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoryList()
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let item = categoryList[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }

    
    // MARK: - TableView data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index \(indexPath.row)")
        performSegue(withIdentifier: "goToItemList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryList[indexPath.row]
        }
    }
    
    
    // MARK: - TableView action
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField  = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            let newCategory = ToDoCategory(context: self.context)
            newCategory.name = textField.text!
            
            self.categoryList.append(newCategory)
            self.tableView.reloadData()
            self.saveCategory()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            print("now")
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data manipulation methods
    func saveCategory() {
        do {
            try context.save()
        } catch  {
            print("Saving failed")
        }
        
        self.tableView.reloadData()
    }
    func loadCategoryList(with request: NSFetchRequest<ToDoCategory> = ToDoCategory.fetchRequest()) {
        do {
            categoryList =  try context.fetch(request)
        } catch {
            print("Fetch Failed")
        }
        
        tableView.reloadData()
    }
    
}
