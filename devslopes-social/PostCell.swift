//
//  PostCell.swift
//  devslopes-social
//
//  Created by zeakian on 1/11/17.
//  Copyright © 2017 zeakian. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    var myPost: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add tap recognizer to like button image - need to do this since it's an image view (not a button)
        // Must be done programatically since multiple cells
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        tap.numberOfTapsRequired = 1
        likeImageView.addGestureRecognizer(tap)
        likeImageView.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) { // img is an optional UIImage with a default value of nil
        myPost = post
        
        captionTextView.text = post.caption
        likesLabel.text = String(post.likes)
        
        // Config image
        if img != nil {
            // If image is cached, set the image
            postImageView.image = img
        } else {
            // If image not cached, download from database, set image, and store in cache
            let ref = FIRStorage.storage().reference(forURL: post.imageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("JDH: error downloading image from Firebase storage")
                } else {
                    print("JDH: image downloaded from Firebase storage")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.postImageView.image = image
                            FeedVC.imageCache.setObject(image, forKey: post.imageURL as NSString)
                        }
                    }
                }
            })
        }
        
        // Config like image
        if post.userLikes {
            likeImageView.image = UIImage(named: "filled-heart")
        } else {
            likeImageView.image = UIImage(named: "empty-heart")
        }
    }
    
    func likeButtonTapped() {
        if let post = myPost {
            if post.userLikes {
                // If user already likes this post, then unlike it
                likeImageView.image = UIImage(named: "empty-heart") // change image to unliked
                post.adjustLikes(addLike: false) // update posts database by decrementing the post's like count
                DataService.ds.REF_CURRENT_USER.child("likes").child(post.postId).removeValue() // update current user's list of liked posts
                post.userLikes = false // update local post model (may not need to do this)
            } else {
                likeImageView.image = UIImage(named: "filled-heart")
                post.adjustLikes(addLike: true)
                DataService.ds.REF_CURRENT_USER.child("likes").child(post.postId).setValue(true)
                post.userLikes = true
            }
//            likesLabel.text = String(post.likes) // update likes label (wouldn't need to do this if we had live connection to database, but currently only observing single event and not auto-refreshing)
        }
    }
}



















