//
//  Post.swift
//  devslopes-social
//
//  Created by zeakian on 1/11/17.
//  Copyright © 2017 zeakian. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postId: String!
    private var _caption: String!
    private var _imageURL: String!
    private var _likes: Int!
    private var _userLikes: Bool!
    private var _postRef: FIRDatabaseReference!
    
    var postId: String {
        return _postId
    }
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var userLikes: Bool {
        get {
            return _userLikes
        } set {
            _userLikes = newValue
        }
    }
    
    init(caption: String, imageURL: String, likes: Int) {
        self._caption = caption
        self._imageURL = imageURL
        self._likes = likes
    }
    
    init(postId: String, postData: Dictionary<String, AnyObject>, userLikes: Bool) {
        self._postId = postId
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        self._userLikes = userLikes
        
        _postRef = DataService.ds.REF_POSTS.child(_postId) // reference to this post in database
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(likes)
    }
}









