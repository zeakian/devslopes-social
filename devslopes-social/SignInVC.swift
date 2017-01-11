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
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: SignInTextFields!
    @IBOutlet weak var passwordField: SignInTextFields!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        // If user has login details in keychain, auto-login and segue to Feed (must be called in viewDidAppear, as viewDidLoad is too early to call segues)
        // When user opens app, they see the SignInVC for a split second before being segued to FeedVC. Possible to just show FeedVC directly by setting to initial VC?
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "showFeedVC", sender: nil)
        }
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
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // If there is text in the email and password fields
        if let email = emailField.text, let password = passwordField.text {
            // Try to sign user in
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("JDH: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    // If error (user doesn't exist) then create new account
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("JDH: Unable to authenticate email user with Firebase")
                        } else {
                            print("JDH: Successfully created email user  with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    // Authenticate with credential (e.g., Facebook)
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("JDH: Unable to authenticate Facebook user with Firebase - \(error)")
            } else {
                print("JDH: Successfully authenticated Facebook user with Firebase")
                if let user = user { // if Firebase user exists and is returned successfully
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        // Create user in database if doesn't exist
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        
        // Store login details in keychain so user doesn't have to re-auth everytime he opens app
        let saveSuccessful: Bool = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("JDH: Saved login details to keychain? \(saveSuccessful)")
        
        // Segue to Feed
        performSegue(withIdentifier: "showFeedVC", sender: nil)
    }
}

