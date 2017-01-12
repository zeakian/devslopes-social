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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageButtonImage: RoundImageView!
    @IBOutlet weak var captionField: UITextField!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache() // cache to hold post images
    
    var posts = [Post]()
    var usersLikes = [String]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load table view
        // Grab user's likes from database so we can highlight posts they've already liked
        DataService.ds.REF_CURRENT_USER.child("likes").observe(.value, with: { (likesData) in
            self.usersLikes = []
            if let retrievedLikes = likesData.children.allObjects as? [FIRDataSnapshot] {
                for retrievedLike in retrievedLikes {
                    self.usersLikes.append(retrievedLike.key)
                }
            }
            
            // Grab all posts from database
            DataService.ds.REF_POSTS.observe(.value, with: { (postsData) in
                self.posts = [] // clear out posts array when we update so we don't get duplicates
                
                // Grab all posts from database
                if let retrievedPosts = postsData.children.allObjects as? [FIRDataSnapshot] {
                    // For each post
                    for retrievedPost in retrievedPosts {
                        // parse into dictionary
                        if let postDict = retrievedPost.value as? Dictionary<String, AnyObject> {
                            var post: Post!
                            if self.usersLikes.contains(retrievedPost.key) {
                                post = Post(postId: retrievedPost.key, postData: postDict, userLikes: true)
                                self.posts.append(post)
                            } else {
                                post = Post(postId: retrievedPost.key, postData: postDict, userLikes: false)
                                self.posts.append(post)
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            })
        })
    }

    // Table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            if let image = FeedVC.imageCache.object(forKey: NSString(string: post.imageURL)) {
                // If image is cached
                cell.configureCell(post: post, img: image)
                return cell
            } else {
                // If image not cached (configure cell will download image from database)
                cell.configureCell(post: post)
                return cell
            }
        }
        
        return UITableViewCell()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageButtonImage.image = image
            imageSelected = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imageButtonImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: RoundButton) {
        // guard is like opposite of if/let
        // make sure caption and images are set before allowing user to post
        guard let caption = captionField.text, caption != "" else {
            print("JDH: caption must be entered")
            return
        }
        
        guard let img = imageButtonImage.image, imageSelected == true else {
            print("JDH: must upload an image")
            return
        }
        
        // Compress the post image
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString // give it a unique id as its title
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("JDH: error uploading image to Firebase")
                } else {
                    print("JDH: successfully uploaded image to Firebase")
                    if let downloadURL = metadata?.downloadURL()?.absoluteString { // this generates an http link; should we use a gs link instead?
                        self.postToFirebase(imgURL: downloadURL)
                    }
                }
            })
            
        }
    }
    
    func postToFirebase(imgURL: String) {
        let post: Dictionary<String, Any> = [
            "caption": captionField.text!,
            "imageURL": imgURL,
            "likes": 0
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId() // grab a reference to our posts database and generate a new id for our post
        firebasePost.setValue(post) // create the post by passing the dictionary we created above
        
        // Reset post entry fields and reload table view
        captionField.text = ""
        imageSelected = false
        imageButtonImage.image = UIImage(named: "add-image")
        tableView.reloadData() // should we do this in a completion handler to ensure we're reloading table view AFTER post is written to database?
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
