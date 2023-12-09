//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    var items: Results<Item>?
//    let defaults = UserDefaults.standard
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let toDoList = defaults.array(forKey: "ToDoList") as? [Item] {
//            items = toDoList
//        }
        loadItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let hexString = selectedCategory?.categoryCellBackgroundColor {
            title = selectedCategory!.name
            guard let nav = navigationController?.navigationBar else {
                fatalError("nav does not exist.")
            }
            nav.barTintColor = UIColor(hexString: hexString)
            nav.backgroundColor = UIColor(hexString: hexString)
            nav.tintColor = ContrastColorOf(UIColor(hexString: hexString)!, returnFlat: true)
            nav.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor :  ContrastColorOf(UIColor(hexString: hexString)!, returnFlat: true)]
            searchBar.barTintColor = UIColor(hexString: hexString)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let toDoItemCell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let toDoItemCell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            toDoItemCell.textLabel?.text = item.title
            toDoItemCell.accessoryType = item.check ? .checkmark : .none
            if let toDoItemCellBackgroundColor = UIColor(hexString: selectedCategory!.categoryCellBackgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
                toDoItemCell.backgroundColor = toDoItemCellBackgroundColor
                toDoItemCell.textLabel?.textColor = ContrastColorOf(toDoItemCellBackgroundColor, returnFlat: true)
            }
            
        } else {
            toDoItemCell.textLabel?.text = "No items added yet."
        }
        return toDoItemCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        items[indexPath.row].check = !items[indexPath.row].check
//        saveItems()
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.check = !item.check
                }
            } catch {
                print(error)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let parentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        parentCategory.items.append(newItem)
                    }
                } catch {
                    print(error)
                }
            }
//            self.defaults.set(self.items, forKey: "ToDoList")
//            self.saveItems()
            self.loadItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new todoey item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
//    func saveItems(item: Item) {
//        let encoder = PropertyListEncoder()
//      do {
//            let data = try encoder.encode(items)
//           try data.write(to: dataFilePath!)
//        } catch {
//           print(error)
//       }
//        do {
//           try context.save()
//       } catch {
//            print(error)
//       }
//        self.tableView.reloadData()
//    }
    
    func loadItems() {
//        if let dataFile = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                items = try decoder.decode([Item].self, from: dataFile)
//            } catch {
//                print(error)
//            }
//        }
        
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        do {
//            items = try context.fetch(request)
//        } catch {
//            print(error)
//        }
        
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = self.items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print(error)
            }
        }
        self.tableView.reloadData()
    }
    
}

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        loadItems(predicate: predicate)
        
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

