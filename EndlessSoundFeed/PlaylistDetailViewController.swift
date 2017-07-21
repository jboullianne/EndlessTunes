//
//  PlaylistDetailViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 6/16/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class PlaylistDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var playlist:Playlist!
    
    @IBOutlet var playlistTitleLabel: UILabel!
    @IBOutlet var playlistDetailLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var playlistEmptyContainer: UIView!
    @IBOutlet var playButtonContainer: UIView!
    @IBOutlet var playlistImage: UIImageView!
    
    @IBOutlet var headerContainer: UIView!
    
    @IBOutlet var headerContainerTop: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    
    var npIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if(playlist.tracks.count == 0){
            playlistEmptyContainer.isHidden = false
        }
        else{
            playlistTitleLabel.text = playlist.name
            playlistDetailLabel.text = "\(playlist.tracks.count) Tracks"
            
            if(playlist.tracks.count > 0){
                //playlistThumbnailView.image = playlist.tracks[0].thumbnailImage
                
                headerImageView.image = playlist.tracks[0].thumbnailImage
            }
            
            ownerLabel.text = "Jboullianne"
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = headerImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            headerImageView.addSubview(blurEffectView)
            
            if(playlist.tracks.count > 0 && playlist.tracks[0].thumbnailURL != "" && playlist.tracks[0].thumbnailImage == nil){
                
                Alamofire.request(playlist.tracks[0].thumbnailURL).responseImage { response in
                    
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        
                        DispatchQueue.main.async {
                            //self.playlistThumbnailView.image = image
                            self.headerImageView.image = image
                        }
                        self.playlist.tracks[0].thumbnailImage = image
                    }
                }
            }
            
            
            let topAccent = CALayer()
            topAccent.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
            topAccent.backgroundColor = UIColor.white.cgColor
            self.tableView.layer.addSublayer(topAccent)
            
            self.playlistImage.layer.cornerRadius = 5.0
            
        }
        
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
        print("PLAYLIST?? : ", self.playlist)
        return self.playlist.tracks.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCellSmall", for: indexPath) as! TrackCellSmall

        let index = indexPath.row
        let track = playlist.tracks[index]
        
        cell.titleLabel.text = track.title
        cell.detailLabel.text = track.author + " · " + track.sourceString
        cell.titleLabel.textColor = UIColor.white
        
        cell.numberLabel.text = "\(index + 1)"
        
        //Round Track Icon
        //cell.trackIcon.layer.cornerRadius = cell.trackIcon.frame.height / 2
        
        //Rounded Corner Track Icon
        cell.trackIcon.layer.cornerRadius = 3
        
        if let row = npIndexPath?.row {
            if indexPath.row == row {
                cell.titleLabel.textColor = UIColor(red: 80/255, green: 148/255, blue: 228/255, alpha: 1.0)
            }
            
        }
        
        //Load Small External Thumbnail if it Exists
        if(track.smallThumbnailURL != nil && track.smallThumbnailImage == nil){
            
            Alamofire.request(track.smallThumbnailURL!).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    DispatchQueue.main.async {
                        let updatedCell = tableView.cellForRow(at: indexPath) as! TrackCellSmall
                        updatedCell.trackIcon.contentMode = .scaleAspectFill
                        updatedCell.trackIcon.image = image
                        
                    }
                    //TO-DO: Attach Image To Original Playlist
                    self.playlist.tracks[index].smallThumbnailImage = image
                    //self.manager.attachImageToTrack(image: image, url: response.request!.url!.absoluteString)
                }
            }
        }
        
        //Load External Thumbnail if it Exists
        else if(track.thumbnailURL != "" && track.thumbnailImage == nil){
            
            Alamofire.request(track.thumbnailURL).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    DispatchQueue.main.async {
                        let updatedCell = tableView.cellForRow(at: indexPath) as! TrackCellSmall
                        updatedCell.trackIcon.contentMode = .scaleAspectFill
                        updatedCell.trackIcon.image = image
                        
                    }
                    //TO-DO: Attach Image To Original Playlist
                    self.playlist.tracks[index].thumbnailImage = image
                    //self.manager.attachImageToTrack(image: image, url: response.request!.url!.absoluteString)
                }
            }
        }
        
        if(track.thumbnailImage != nil){
            cell.trackIcon.contentMode = .scaleAspectFill
            cell.trackIcon.image = track.thumbnailImage!
        }
        
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let track = self.playlist.tracks[indexPath.row]
        MediaManager.sharedInstance.playTrack(track: track)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        
        let cell = tableView.cellForRow(at: indexPath) as! TrackCellSmall
        cell.titleLabel.textColor = UIColor(red: 80/255, green: 148/255, blue: 228/255, alpha: 1.0)
        
        if(npIndexPath != nil){
            if let cell = tableView.cellForRow(at: npIndexPath!) as? TrackCellSmall {
                cell.titleLabel.textColor = UIColor.white
            }
            
        }
        
        self.npIndexPath = indexPath
        
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        print("TO-DO: Start Playlist")
        MediaManager.sharedInstance.playPlaylist(playlist: self.playlist)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = self.tableView.contentOffset.y
        
        //Move HeaderContainer up as TableView Scrolls
        UIView.animate(withDuration: 0) {
            // 180 = the total amount of vertical movement
            if(offset > 60){
                self.headerContainerTop.constant = -60
            }else if (offset > 0){
                self.headerContainerTop.constant = -1 * offset
            }else{
                self.headerContainerTop.constant = 0
            }
            
            //Fade Out Header As TableView Scrolls
            let alpha = 1.0 - (offset/60)
            self.headerContainer.alpha = alpha
            
            self.headerContainer.layoutIfNeeded()
            self.tableView.layoutIfNeeded()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
