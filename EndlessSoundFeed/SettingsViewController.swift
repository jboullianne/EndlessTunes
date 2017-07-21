//
//  SettingsViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/3/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController {
    
    
    let options:[String] = ["Profile", "About", "Connect Accounts", "Logout"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return options.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = options[indexPath.row]
        
        if(indexPath.row == options.count-1){
            cell.accessoryType = .none
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Selection Animation
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Transition To Next Screen
        if(indexPath.row == 0){         // Account
            print("To-Do: Show Profile Controller")
        }else if(indexPath.row == 1){   // About
            print("To-Do: Show About Controller")
            self.performSegue(withIdentifier: "ShowAboutPage", sender: self)
            
        }else if(indexPath.row == 2){   // Spotify Login
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPViewController") as! SPViewController
            self.present(vc, animated: true, completion: nil)
        }else if(indexPath.row == 3){   // Logout
            do{
                try FIRAuth.auth()?.signOut()
                AccountManager.sharedInstance.clearAllUserData {
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }catch{
                debugPrint("Error Trying To Sign Out User.")
            }
        }else{
            //Nothing. Shouldn't happen
        }
    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Seguing In SettingsViewController")
    }
    

}
