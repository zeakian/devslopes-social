//
//  SignInVC.swift
//  devslopes-social
//
//  Created by zeakian on 1/10/17.
//  Copyright © 2017 zeakian. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Authenticate with Facebook when FB button is tapped
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("JDH: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("JDH: User cancelled Facebook authentication")
            } else {
                print("JDH: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("JDH: Unable to authenticate with Firebase - \(error)")
            } else {
                print("JDH: Successfully authenticated with Firebase")
            }
        })
    }
}

