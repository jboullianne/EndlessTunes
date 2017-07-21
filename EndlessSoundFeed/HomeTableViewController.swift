//
//  HomeTableViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/15/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var categories:[String] = ["Profile", "Trending Parties", "Active Friends", "Recently Played", "Actions"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.tableFooterView = UIView()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? RecentsRow {
            cell.collectionView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 { //Don't Display a title for the profile
            return nil
        }
        return self.categories[section]
    }
    
    //Customize the Header For Each Section
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section != 0 {
            let view = view as! UITableViewHeaderFooterView
            view.backgroundView?.backgroundColor = UIColor.clear
            view.textLabel?.textColor = UIColor.white
            view.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableCell") as! ProfileTableCell
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PartiesRow") as! PartiesRow
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UsersRow") as! UsersRow
            
            return cell
        } else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsRow") as! RecentsRow
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryRow") as! CategoryRow
            
            return cell
        }
        /*
         let cell = tableView.dequeueReusableCell(withIdentifier: "ActionsRow") as! ActionsRow
 
         */
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200 // Profile Height
        case 1:
            return 160 //Parties Row
        case 2:
            return 75  //Users Row
        case 3:
            return 130 // Recents Row
        default:
            return 100 // For Everything Else
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
