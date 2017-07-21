//
//  SearchViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import SwiftOverlays
import Alamofire
import AlamofireImage
import TwicketSegmentedControl

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, TrackMoreDetailsDelegate, TwicketSegmentedControlDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noResultsContainer: UIView!
    
    
    @IBOutlet var filterContainer: UIView!
    @IBOutlet var topFilter: TwicketSegmentedControl!
    @IBOutlet var bottomFilter: TwicketSegmentedControl!
    
    
    var manager:SearchManager!
    var lastTopFilterIndex:Int = 0
    
    var selectedUser:SearchManager.ETUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        //searchBar.tintColor = UIColor.white
        //searchBar.backgroundColor = UIColor.clear
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        
        manager = SearchManager.sharedInstance
        
        //Add Accent To the Top of the TableView
        let topAccent = CALayer()
        topAccent.frame = CGRect(x: 0, y: self.filterContainer.frame.height-1, width: self.view.frame.width, height: 1)
        topAccent.backgroundColor = UIColor.white.cgColor
        self.filterContainer.layer.addSublayer(topAccent)
        
        setupFilters()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch topFilter.selectedSegmentIndex {
        case 2:
            return 50
        default:
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        
        switch topFilter.selectedSegmentIndex {
        case 0:
            if bottomFilter.selectedSegmentIndex == 0 {
                count = manager.soundCloudResults.count
            }else{
                count = manager.spotifyResults.count
            }
        case 1:
            if bottomFilter.selectedSegmentIndex == 0 {
                count = manager.allPartiesResults.count
            }else if bottomFilter.selectedSegmentIndex == 1{
                count = manager.spPartiesResults.count
            }else {
                count = manager.collabPartiesResults.count
            }
        case 2:
            if bottomFilter.selectedSegmentIndex == 0 {
                count = manager.friendResults.count
            }else{
                count = manager.userResults.count
            }
        default:
            break
        }
        
        if count == 0 {
            noResultsContainer.isHidden = false
        } else {
            noResultsContainer.isHidden = true
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch topFilter.selectedSegmentIndex {
        case 0:
            if bottomFilter.selectedSegmentIndex == 0 {
                return buildSoundCloudCell(for: indexPath)
            }else{
                return buildSpotifyCell(for: indexPath)
            }
        case 1:
            if bottomFilter.selectedSegmentIndex == 0 {
                return buildGenericPartyCell(for: indexPath)
            }else if bottomFilter.selectedSegmentIndex == 1{
                return buildSPPartyCell(for: indexPath)
            }else {
                return buildCollabPartyCell(for: indexPath)
            }
        case 2:
            if bottomFilter.selectedSegmentIndex == 0 {
                return buildFriendCell(for: indexPath)
            }else{
                return buildPeopleCell(for: indexPath)
            }
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        return cell
        
        //End Main Cell Building
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch topFilter.selectedSegmentIndex {
        case 0:
            manager.playTrack(atIndex: indexPath.row, section: bottomFilter.selectedSegmentIndex)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 2:
            let user:SearchManager.ETUser?
            
            if bottomFilter.selectedSegmentIndex == 0 {
                user = manager.friendResults[indexPath.row]
            } else {
                user = manager.userResults[indexPath.row]
            }
            //LOAD USER PROFILE PAGE
            tableView.deselectRow(at: indexPath, animated: true)
            selectedUser = user
            self.performSegue(withIdentifier: "ShowProfileController", sender: self)

        default:
            break
        }
    }
    
    // SEARCH BAR FUNCTIONS
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == ""){
            noResultsContainer.isHidden = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.showWaitOverlay()
        
        switch topFilter.selectedSegmentIndex {
        case 0:
            manager.queryTracks(q: searchBar.text!) {
                self.tableView.reloadData()
                self.removeAllOverlays()
            }
            break
        case 1:
            manager.queryParties(q: searchBar.text!) {
                self.tableView.reloadData()
                self.removeAllOverlays()
            }
            break
        case 2:
            manager.queryUsers(q: searchBar.text!) {
                self.tableView.reloadData()
                self.removeAllOverlays()
            }
            break
        default:
            break
        }
        
    }
    
    
    @IBAction func noResultsTapped(_ sender: Any) {
        if(searchBar.isFirstResponder){
            searchBar.resignFirstResponder()
        }
    }

    
    
    func showDetails(track: Track) {
        print("Showing Details For Track: ", track.title)
        
        let ac = UIAlertController(title: track.title, message: track.author, preferredStyle: .actionSheet)
        
        let queueButton = UIAlertAction(title: "Queue Song", style: .default) { (action) in
            let mediaManager = MediaManager.sharedInstance
            mediaManager.queueTrack(track: track)
            
            /*
            ac.dismiss(animated: true, completion: { 
                print("Successfully Queued Track!")
            })
            */
        }
        
        let playlistAddButton = UIAlertAction(title: "Add to Playlist", style: .default) { (action) in
            let playlistController = self.storyboard?.instantiateViewController(withIdentifier: "PlaylistSelectionController") as! PlaylistSelectionController
            playlistController.potentialTrack = track
            self.present(playlistController, animated: true, completion: nil)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Canceled More Details Action Sheet")
        }
        
        ac.addAction(queueButton)
        ac.addAction(playlistAddButton)
        ac.addAction(cancelButton)
        self.present(ac, animated: true, completion: nil)
    }
    
    func setupFilters() {
        
        topFilter.setSegmentItems(["Tracks", "Parties", "People"])
        bottomFilter.setSegmentItems(["SoundCloud", "Spotify"])
        
        colorFilters()
        
        topFilter.move(to: 0)
        bottomFilter.move(to: 0)
        
        topFilter.delegate = self
        bottomFilter.delegate = self
    }
    
    func colorFilters() {
        topFilter.highlightTextColor = UIColor(red: 50/255, green: 175/255, blue: 249/255, alpha: 1.0)
        topFilter.defaultTextColor = UIColor.white
        
        bottomFilter.highlightTextColor = UIColor(red: 50/255, green: 175/255, blue: 249/255, alpha: 1.0)
        bottomFilter.defaultTextColor = UIColor.white
        
        //topFilter.segmentsBackgroundColor = UIColor.white
        topFilter.sliderBackgroundColor = UIColor.white
        topFilter.segmentsBackgroundColor = UIColor.clear
        topFilter.backgroundColor = UIColor.clear
        
        bottomFilter.sliderBackgroundColor = UIColor.white
        bottomFilter.segmentsBackgroundColor = UIColor.clear
        bottomFilter.backgroundColor = UIColor.clear
    }
    
    func didSelect(_ segmentIndex: Int) {
        print("To-Do: Selected Index \(segmentIndex) : \(topFilter.selectedSegmentIndex)")
        
        //Only Set new Segment Titles if the Top Filter Is Changing
        if lastTopFilterIndex != topFilter.selectedSegmentIndex {
            switch topFilter.selectedSegmentIndex {
            case 0:
                bottomFilter.setSegmentItems(["SoundCloud", "Spotify"])
                bottomFilter.move(to: 0)
                self.showWaitOverlay()
                manager.queryTracks(q: searchBar.text!) {
                    self.tableView.reloadData()
                    self.removeAllOverlays()
                }
                break
            case 1:
                bottomFilter.setSegmentItems(["All", "Spotify Enabled", "Collaborative"])
                bottomFilter.move(to: 0)
                self.showWaitOverlay()
                manager.queryParties(q: searchBar.text!) {
                    self.tableView.reloadData()
                    self.removeAllOverlays()
                }
                
                break
            case 2:
                bottomFilter.setSegmentItems(["Friends", "Everyone"])
                bottomFilter.move(to: 0)
                self.showWaitOverlay()
                manager.queryUsers(q: searchBar.text!) {
                    self.tableView.reloadData()
                    self.removeAllOverlays()
                }
                break
            default:
                break
            }
            colorFilters()
            lastTopFilterIndex = segmentIndex
        }else{
            self.tableView.reloadData()
        }
        
        
    }
    
    /* CELL BUILDER FUNCTIONS START */
    
    func buildSoundCloudCell(for indexPath: IndexPath) -> SearchResultCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        
        let index = indexPath.row
        let track = manager.soundCloudResults[index]
        
        cell.mediaTitleLabel.text = track.title
        let source = "SoundCloud"
        cell.mediaDetailLabel.text = track.author + " · " + source
        cell.track = track
        
        //Set Default Thumbnail
        cell.mediaView.contentMode = .center
        cell.mediaView.backgroundColor = UIColor.darkGray
        cell.mediaView.image = UIImage(named: "Blank Track")
        
        //To-Do: Hiding Source Image
        cell.sourceView.isHidden = true;
        //cell.sourceView.image = manager.results[index].source == .SoundCloud ? UIImage(named: "soundcloud")! : UIImage(named: "Spotify_Logo_RGB_Green")!
        
        //Load External Thumbnail if it Exists
        if(track.thumbnailURL != "" && track.thumbnailImage == nil){
            
            Alamofire.request(track.thumbnailURL).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    DispatchQueue.main.async {
                        if let updatedCell = self.tableView.cellForRow(at: indexPath) as? SearchResultCell {
                            updatedCell.mediaView.contentMode = .scaleAspectFill
                            updatedCell.mediaView.image = image
                            
                            self.manager.attachImageToTrack(image: image, url: response.request!.url!.absoluteString)
                        }
                        
                    }
                    
                }
            }
        }
        if(track.thumbnailImage != nil){
            cell.mediaView.contentMode = .scaleAspectFill
            cell.mediaView.image = track.thumbnailImage!
        }
        
        let tapGesture = UITapGestureRecognizer(target: cell, action: #selector(SearchResultCell.resultMorePressed(_:)))
        cell.moreDetailView.addGestureRecognizer(tapGesture)
        
        cell.moreDetailsDelegate = self
        
        return cell
    }
    
    func buildSpotifyCell(for indexPath: IndexPath) -> SearchResultCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        
        let index = indexPath.row
        let track = manager.spotifyResults[index]
        
        cell.mediaTitleLabel.text = track.title
        let source = "Spotify"
        cell.mediaDetailLabel.text = track.author + " · " + source
        cell.track = track
        
        //Set Default Thumbnail
        cell.mediaView.contentMode = .center
        cell.mediaView.backgroundColor = UIColor.darkGray
        cell.mediaView.image = UIImage(named: "Blank Track")
        
        //To-Do: Hiding Source Image
        cell.sourceView.isHidden = true;
        //cell.sourceView.image = manager.results[index].source == .SoundCloud ? UIImage(named: "soundcloud")! : UIImage(named: "Spotify_Logo_RGB_Green")!
        
        //Load External Thumbnail if it Exists
        if(track.thumbnailURL != "" && track.thumbnailImage == nil){
            
            Alamofire.request(track.thumbnailURL).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    DispatchQueue.main.async {
                        if let updatedCell = self.tableView.cellForRow(at: indexPath) as? SearchResultCell {
                            updatedCell.mediaView.contentMode = .scaleAspectFill
                            updatedCell.mediaView.image = image
                            
                            self.manager.attachImageToTrack(image: image, url: response.request!.url!.absoluteString)
                        }
                        
                    }
                    
                }
            }
        }
        if(track.thumbnailImage != nil){
            cell.mediaView.contentMode = .scaleAspectFill
            cell.mediaView.image = track.thumbnailImage!
        }
        
        let tapGesture = UITapGestureRecognizer(target: cell, action: #selector(SearchResultCell.resultMorePressed(_:)))
        cell.moreDetailView.addGestureRecognizer(tapGesture)
        
        cell.moreDetailsDelegate = self
        
        return cell
    }
    
    func buildGenericPartyCell(for indexPath: IndexPath) -> UITableViewCell {
        return buildPartyCell(for: indexPath, party: manager.allPartiesResults[indexPath.row])
    }
    
    func buildSPPartyCell(for indexPath: IndexPath) -> UITableViewCell {
        return buildPartyCell(for: indexPath, party: manager.spPartiesResults[indexPath.row])
    }
    
    func buildCollabPartyCell(for indexPath: IndexPath) -> UITableViewCell {
        return buildPartyCell(for: indexPath, party: manager.collabPartiesResults[indexPath.row])
    }
    
    func buildPartyCell(for indexPath: IndexPath, party: PartyManager.ETParty) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyTableCell", for: indexPath) as! PartyTableCell
        
        //Load External Thumbnail if it Exists
        if(party.npThumbURL != nil && party.image == nil){
            
            Alamofire.request(party.npThumbURL!).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    DispatchQueue.main.async {
                        if let updatedCell = self.tableView.cellForRow(at: indexPath) as? PartyTableCell {
                            updatedCell.npThumbView.contentMode = .scaleAspectFill
                            updatedCell.npThumbView.image = image
                        }
                    }
                    
                    //self.manager.trendingParties[indexPath.row].image = image
                }
            }
        }
        
        if(party.image != nil){
            cell.npThumbView.contentMode = .scaleAspectFill
            cell.npThumbView.image = party.image!
        }
        
        cell.nameLabel.text = party.name
        cell.ownerLabel.text = party.ownername
        
        if party.isCollaborative {
            cell.collabView.alpha = 1.0
        }else{
            cell.collabView.alpha = 0
        }
        
        if party.isSpotifyEnabled {
            cell.spView.alpha = 1.0
        }else{
            cell.spView.alpha = 0.0
        }
        
        cell.userCountLabel.text = "\(party.userCount)"

        return cell
        
    }
    
    func buildFriendCell(for indexPath: IndexPath) -> UITableViewCell {
        return buildUserCell(for: indexPath, user: SearchManager.sharedInstance.friendResults[indexPath.row])
    }
    
    func buildPeopleCell(for indexPath: IndexPath) -> UITableViewCell {
        return buildUserCell(for: indexPath, user: SearchManager.sharedInstance.userResults[indexPath.row])
    }
    
    func buildUserCell(for indexPath: IndexPath, user: SearchManager.ETUser) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserResultCell", for: indexPath) as! UserResultCell
        
        cell.displayNameLabel.text = user.displayName
        cell.usernameLabel.text = user.email
        
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowProfileController" {
            let vc = segue.destination as! ProfileViewController
            vc.rowUser = self.selectedUser
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    

}

protocol TrackMoreDetailsDelegate{
    func showDetails(track: Track)
}
