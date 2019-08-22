//
//  ViewController.swift
//  EmployeeApp
//
//  Created by Sean Kearney on 20/08/2019.
//  Copyright © 2019 Sean Kearney. All rights reserved.
//

import UIKit

struct Employee: Decodable{
    let id: String
    let employee_name: String
    let employee_salary: String
    let employee_age: String
}

var employeeList = [Employee]()
var searchResults = [Employee]()
var isSearching = false
let dispatchGroup = DispatchGroup()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var TableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityIndicator.isHidden = false
        dispatchGroup.enter()
        fetchEmployeeData()
        TableView.dataSource = self
        TableView.delegate = self
        dispatchGroup.notify(queue: .main){
            self.filterData()
            self.reloadData()
        }
    }
    
    //Gets data from API and stores it in employeeList array
    func fetchEmployeeData(){
        let urlString = "http://dummy.restapiexample.com/api/v1/employees"
        guard let url = URL(string: urlString) else{return}
       
        URLSession.shared.dataTask(with: url){(data, response, error) in
            if let err = error{
                print("Error: \(err)")
                return
            }
            guard response != nil else{
                print("Error: No response")
                return
            }
            guard let data = data else{
                print("Error: No data retrieved")
                return
            }
            do{
                let employees = try JSONDecoder().decode([Employee].self, from: data)
                print("GOT DATA")
                employeeList = employees
                dispatchGroup.leave()
            } catch{
                print("Error: Error parsing json")
            }
        }.resume()
    }
    
    //Refreshes tableview and dismisses loading indicator
    func reloadData(){
        print("Reloading")
        self.TableView.reloadData()
        ActivityIndicator.isHidden = true
    }
    
    //Filters out employees from employeeList array
    func filterData(){
        employeeList.removeAll(where: {Int($0.employee_age) ?? 0 < 15})
        employeeList.removeAll(where: {Int($0.employee_age) ?? 0 > 74})
        employeeList.removeAll(where: {Int($0.employee_salary) ?? 0 < 100})
    }
    
    var selectedEmployee: Employee?
    //Records users selection to pass to segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching{
            selectedEmployee = searchResults[indexPath.row]
        }else{
            selectedEmployee = employeeList[indexPath.row]
        }
        performSegue(withIdentifier: "ShowDetailView", sender: nil)
    }
    
    //Informs tableview of how many cells are needed
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return searchResults.count
        }else{
            return employeeList.count
        }
    }
    
    //Provides tableview with information to include in cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath)
        if isSearching{
            cell.textLabel!.text = searchResults[indexPath.row].employee_name
        } else{
            cell.textLabel!.text = employeeList[indexPath.row].employee_name
        }
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    
    //Swipe to delete
    //Deleting from main view (no search) is fine
    //Deleting from search results deletes by ID, theres proabably a better way to do this
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualActoin, view, actionPerformed:(Bool)-> Void) in
            if isSearching{
                let employeeRemove = searchResults[indexPath.row]
                searchResults.remove(at: indexPath.row)
                employeeList.removeAll(where: {$0.id == employeeRemove.id})
            }else{
                employeeList.remove(at: indexPath.row)
            }
            actionPerformed(true)
            self.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //Sends the selected employee to DetailViewController.swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailView"{
            let detailView = segue.destination as! DetailViewController
            detailView.employee = selectedEmployee
        }
    }
}

//Set up search bar
extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = employeeList.filter{$0.employee_name.prefix(searchText.count) == searchText}
        isSearching = true
        reloadData()
    }
}
