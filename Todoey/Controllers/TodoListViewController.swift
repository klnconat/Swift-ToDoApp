import UIKit
import CoreData

// MARK: - TodoListViewController
class TodoListViewController: UITableViewController {

    // MARK: - Properties
    var itemArray = [Item]()
    var selectedCategory: ToDoCategory? {
        didSet {
            loadItemList()
        }
    }

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemArray[indexPath.row]
        item.done = !item.done
        updateUI()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            let newItem = Item(context: self.context)
            newItem.title = textField.text ?? ""
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.updateUI()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Data Manipulation Methods
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Saving failed")
        }
    }

    func loadItemList(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        // selectedCategory'ye dayalı kategori predicate'i oluşturuyoruz
        let categoryPredicate = NSPredicate(format: "parentCategory == %@", selectedCategory!)

        // Eğer ek bir predicate verilmişse, onu categoryPredicate ile birleştiriyoruz
        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            request.predicate = compoundPredicate
        } else {
            // Eğer ek predicate yoksa sadece categoryPredicate'i kullanıyoruz
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Fetch Failed")
        }
        
        tableView.reloadData()
    }


    func updateUI() {
        saveItem()
        tableView.reloadData()
    }

    // MARK: - Predicate Creation
    func createCategoryPredicate() -> NSPredicate? {
        if let category = selectedCategory {
            return NSPredicate(format: "parentCategory == %@", category)
        }
        return nil
    }
}

// MARK: - SearchBar Delegate Methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate = createCategoryPredicate()
        
        if searchText.isEmpty {
            request.predicate = categoryPredicate
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadItemList()
        } else {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            
            // Optional categoryPredicate ile arama predicate'ini güvenli bir şekilde birleştiriyoruz.
            if let categoryPredicate = categoryPredicate {
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, categoryPredicate])
                request.predicate = compoundPredicate
            } else {
                request.predicate = searchPredicate
            }
            
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItemList(with: request, predicate: request.predicate)
        }
    }
}
