//
//  ViewController.swift
//  MyToDoList
//
//  Created by Graphic Influence on 03/12/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    //MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!

    let realm = try! Realm()
    var toDoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
//MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let categoryTitle = selectedCategory?.name else { return }
        self.title = categoryTitle
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navBar = navigationController?.navigationBar else { return }
        if let colorHex = selectedCategory?.cellColor {
            navBar.backgroundColor = UIColor(hexString: colorHex)
            if let navBarColor = UIColor(hexString: colorHex) {
                let textContrast = UIColor(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true)
                navBar.tintColor = textContrast
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: textContrast]
                searchBar.barTintColor = navBarColor
                if #available(iOS 13.0, *) {
                    searchBar.searchTextField.backgroundColor = .white
                } else {
                    // Fallback on earlier versions
                }
                searchBar.tintColor = .black
            }
        }
    }
//MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = toDoItems?[indexPath.row]  {
            cell.textLabel?.text = item.title
            if let currentCategoryColor = UIColor(hexString: selectedCategory!.cellColor) {
                if let colour = currentCategoryColor.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                    cell.backgroundColor = colour
                    cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: colour, isFlat: true)
                }
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items added"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = toDoItems?[indexPath.row] else { return }
        do {
            try realm.write {
                item.done = !item.done
            }
        } catch {
            print("error saving done status, \(error)")
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
//MARK: - Update Model
    override func updateModel(at indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("error deleting item, \(error)")
            }
        }
    }

    fileprivate func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
//MARK: - Action
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new toDo list", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add item", style: .default) { (action) in
            guard let textField = textField.text else { return }
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("error saving the datas \(error)")
                }
            }
            self.tableView.reloadData()
        })
        alert.addTextField { (actionTextField) in
            actionTextField.placeholder = "Create new item"
            textField = actionTextField
        }
        present(alert, animated: true)
    }
}
//MARK: - Search Bar Delegate
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
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
