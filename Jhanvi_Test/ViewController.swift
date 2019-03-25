//
//  ViewController.swift
//  Jhanvi_Test
//
//  Created by Jhanvi on 24/03/19.
//  Copyright © 2019 Jhanvi. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var users: [Users]?
    var UsersWrapper: UsersWrapper? // holds the last wrapper that we've loaded
    var isLoading = false
    let cellReuseIdentifier = "UserDetailsCell"
    
    @IBOutlet weak var tableview: UITableView?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Listens for the connectivity
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUsersFromLocalDB(notification:)), name: NSNotification.Name(rawValue: "Reachable"), object: nil)
        
        if Connectivity.isConnectedToInternet() {
            self.loadUsers()
        }
        else {
            users = DBManager.instance.getUsers()
        }
    }
    
    @objc func getUsersFromLocalDB(notification: NSNotification) {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool {
            self.loadUsers()
        }
        else {
            users = DBManager.instance.getUsers()
        }
        self.tableview?.reloadData()
    }
    
    // MARK: Loading users from API
    @objc func loadUsers() {
        isLoading = true
        Users.getUsers { result in
            if let error = result.error {
                self.isLoading = false
                let alert = UIAlertController(title: "Error", message: "Could not load users List :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let UsersWrapper = result.value
            self.addUsersFromWrapper(UsersWrapper)
            self.isLoading = false
            self.tableview?.reloadData()
        }
    }
    
    func loadMoreUsers() {
        self.isLoading = true
        if let users = self.users,
            let wrapper = self.UsersWrapper,
            let totalUsersCount = wrapper.count,
            users.count < totalUsersCount {
            // there are more users
            Users.getMoreUsers(UsersWrapper) { result in
                if let error = result.error {
                    self.isLoading = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more users :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                let moreWrapper = result.value
                self.addUsersFromWrapper(moreWrapper)
                self.isLoading = false
                self.tableview?.reloadData()
            }
        }
    }
    
    func addUsersFromWrapper(_ wrapper: UsersWrapper?) {
        self.UsersWrapper = wrapper
        if self.users == nil {
            self.users = self.UsersWrapper?.users
        } else if self.UsersWrapper != nil && self.UsersWrapper!.users != nil {
            self.users = self.users! + self.UsersWrapper!.users!
        }
    }
    // MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users == nil {
            return 0
        }
        return self.users!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserDetailsCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! UserDetailsCell
        if self.users != nil && self.users!.count >= indexPath.row {
            let userDetails = self.users![indexPath.row]
            cell.nameLabel?.text = userDetails.name
            cell.emailLabel?.text = userDetails.email
            cell.dobLabel?.text = userDetails.dateOfBirth
            cell.phoneLabel?.text = userDetails.cell
            cell.usernameLabel?.text = userDetails.username
            let downloadURL = URL(string: userDetails.imageURL!)!
            cell.userImage?.load(url: downloadURL)
            
            let id = DBManager.instance.addUser(uname: userDetails.name!, uphone: userDetails.cell!, udob: userDetails.dateOfBirth!, uemail: userDetails.email!, uusername: userDetails.username!, uimageUrl: userDetails.imageURL!)
            // See if we need to load more users
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = self.users!.count
            if (!self.isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)) && Connectivity.isConnectedToInternet()) {
                let totalRows = self.UsersWrapper!.count!
                let remainingUSersToLoad = totalRows - rowsLoaded;
                if (remainingUSersToLoad > 0) {
                    self.loadMoreUsers()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // alternate row colors
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
