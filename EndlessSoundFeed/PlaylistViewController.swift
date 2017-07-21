//
//  PlaylistViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import SwiftOverlays

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ESFPlaylistDelegate, UISearchBarDelegate{
    

    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noResultsContainer: UIView!
    
    var manager:AccountManager!
    var selectedPlaylist:Playlist!
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        
        manager = AccountManager.sharedInstance
        manager.playlistDelegate = self
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        searchBar.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TABLE VIEW FUNCTIONS
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Toggle No Results Notification
        if(manager.playlists.count > 0){
            noResultsContainer.isHidden = true
        }else{
            noResultsContainer.isHidden = false
        }
        
        return manager.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        
        let index = indexPath.row
        
        cell.accessoryType = .disclosureIndicator
        
        cell.nameLabel.text = manager.playlists[index].name
        cell.detailLabel.text = "\(manager.playlists[index].tracks.count) Tracks"
        
        return cell
    }
    
    @IBAction func editPlaylistsPressed(_ sender: Any) {
        print("Edit Playlists.")
    }
    
    
    
    @IBAction func createPlaylistPressed(_ sender: Any) {
        print("Create Playlist")
        
        let ac = UIAlertController(title: "Create Playlist", message: "Enter a name for this new playlist", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Canceled Playlist Creation")
        }
        
        let confirmAction = UIAlertAction(title: "Create", style: .default) { (action) in
            if let field = ac.textFields?[0]{
                //print("NEW PLAYLIST NAME:", field.text)
                let manager = AccountManager.sharedInstance
                manager.createNewPlaylist(name: field.text!)
            }
        }
        
        
        ac.addTextField { (textfield) in
            textfield.placeholder = "Playlist Name"
        }
        
        ac.addAction(cancelAction)
        ac.addAction(confirmAction)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            print("Deleting Playlist")
            let playlist = AccountManager.sharedInstance.playlists[indexPath.row]
            AccountManager.sharedInstance.deletePlaylist(playlist: playlist)
            
        default:
            print("What Editing Style is this? : \(editingStyle)")
            break
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if(self.tableView.isEditing){
            self.tableView.setEditing(false, animated: true)
        }else{
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    
    
    // ESFPlaylistDelegate Functions
    
    func didReceivePlaylistUpdate() {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        self.selectedPlaylist = AccountManager.sharedInstance.playlists[index]
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.npBarDelegate?.hideBar()
        
        if searchBar.isFirstResponder { //Close Search Keyboard if it's open
            searchBar.resignFirstResponder()
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaylistDetailController") as! PlaylistDetailViewController
        vc.playlist = self.selectedPlaylist
        self.show(vc, sender: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Searching For Playlist: \(searchText)")
        
        
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "ShowPlaylistDetail"){
            
            print("Setting Playlist inside PlaylistDetailViewController")
            let vc = segue.destination as! PlaylistDetailViewController
            
            vc.playlist = self.selectedPlaylist
        }
    }
    
    
}
