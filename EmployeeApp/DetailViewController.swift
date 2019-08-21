//
//  DetailViewController.swift
//  EmployeeApp
//
//  Created by Sean Kearney on 21/08/2019.
//  Copyright © 2019 Sean Kearney. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var employee: Employee? = nil
    
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var salaryLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateFields()
    }
    
    func populateFields(){
        idLabel.text = employee?.id
        nameLabel.text = employee?.employee_name
        ageLabel.text = employee?.employee_age
        salaryLabel.text = employee?.employee_salary
    }
}
