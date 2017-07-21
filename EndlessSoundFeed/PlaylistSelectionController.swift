//
//  PlaylistSelectionController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/17/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class PlaylistSelectionController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var manager:AccountManager!
    var potentialTrack:Track!
    
    @IBOutlet var albumView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager = AccountManager.sharedInstance
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        albumView.image = potentialTrack.thumbnailImage
        albumView.layer.cornerRadius = 3
        titleLabel.text = potentialTrack.title
        subtitleLabel.text = potentialTrack.author
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return manager.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistSelectionCell", for: indexPath)

        let index = indexPath.row
        
        cell.textLabel?.text = manager.playlists[index].name
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = "\(manager.playlists[index].tracks.count)"
        cell.detailTextLabel?.textColor = UIColor.white

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        //add track to playlist
        self.manager.addTrack(toPlaylist: potentialTrack, index: index)
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewPressed(_ sender: Any) {
        print("Create Playlist")
        
        let ac = UIAlertController(title: "Create Playlist", message: "Enter a name for this new playlist", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Canceled Playlist Creation")
        }
        
        let confirmAction = UIAlertAction(title: "Create", style: .default) { (action) in
            if let field = ac.textFields?[0]{
                //print("NEW PLAYLIST NAME:", field.text)
                let manager = AccountManager.sharedInstance
                //manager.createNewPlaylist(name: field.text!)
                manager.create(newPlaylist: field.text!, withTrack: self.potentialTrack)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
        ac.addTextField { (textfield) in
            textfield.placeholder = "Playlist Name"
        }
        
        ac.addAction(cancelAction)
        ac.addAction(confirmAction)
        
        self.present(ac, animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
