//
//  FeedVC.swift
//  devslopes-social
//
//  Created by zeakian on 1/11/17.
//  Copyright © 2017 zeakian. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Grab posts data (runs initially, and automatically triggered whenever posts database is updated)
        DataService.ds.REF_POSTS.observe(.value) { (snapshot) in
            print("JDH: \(snapshot.value)")
        }
    }

    // Table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            return cell
        }
        
        return UITableViewCell()
    }

    @IBAction func signOutImageTapped() {
        // Remove login details from keychain
        if let removeSuccessful: Bool = KeychainWrapper.standard.remove(key: KEY_UID) {
            print("Removed login details from keychain? \(removeSuccessful)")
        }
        
        // Sign out from Firebase
        try! FIRAuth.auth()?.signOut()
        
        // Segue back to SignInVC
        performSegue(withIdentifier: "showSignInVC", sender: nil)
    }
}
