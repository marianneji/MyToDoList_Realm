//
//  CategoryViewController.swift
//  MyToDoList
//
//  Created by Graphic Influence on 09/12/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()

    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navBar = navigationController?.navigationBar else { return }
        if let textColor = UIColor(hexString: "83BEED") {
            let textContrast = UIColor(contrastingBlackOrWhiteColorOn: textColor, isFlat: true)
            navBar.backgroundColor = textColor
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: textContrast]
            navBar.tintColor = textContrast
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            if let currentCellColor = UIColor(hexString: (category.cellColor)) {
                cell.backgroundColor = currentCellColor
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: currentCellColor, isFlat: true)
            }
        }
        return cell
    }

    fileprivate func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error saving the datas \(error)")
        }
        tableView.reloadData()
    }

    fileprivate func loadCategories() {

        categoryArray = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)

        tableView.reloadData()
    }


    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueID, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new category of toDo list", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add Category", style: .default, handler: { (action) in
            guard let textField = textField.text else { return }
            let newCategory = Category()
            newCategory.name = textField
            newCategory.cellColor = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
        }))
        alert.addTextField { (actionTextField) in
            actionTextField.placeholder = "Create a new Category"
            textField = actionTextField
        }
        present(alert, animated: true)
    }

    override func updateModel(at indexPath: IndexPath) {
        if let category = categoryArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category.items)
                    realm.delete(category)
                }
            } catch {
                print("error deleting category, \(error)")
            }
        }
    }
}
