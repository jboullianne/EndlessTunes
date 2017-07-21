//
//  LoadingViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 6/17/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoadingViewController: UIViewController, LoadingScreenDelegate {
    
    var activeUser:FIRUser? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("LoadingViewController: View Will Appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if let user = user{
                
                print("FIRAUTH: LOGIN STATE LISTENER")
                let manager = AccountManager.sharedInstance
                if(self.activeUser != user){
                    self.activeUser = user
                    manager.loginUser(user: user)
                    self.performSegue(withIdentifier: "UserLoggedIn", sender: self)
                }
                
            }else{
                
                self.performSegue(withIdentifier: "UserLoggedOut", sender: self)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func didFinishLoadingData() {
        print("Did Finish Loading Data")
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

protocol LoadingScreenDelegate {
    func didFinishLoadingData()
}
