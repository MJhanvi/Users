//
//  DBManager.swift
//
//  Created by Jhanvi on 24/03/19.
//  Copyright © 2019 Jhanvi. All rights reserved.
//

import Foundation
import SQLite

class DBManager {
    static let instance = DBManager()
    private let db: Connection?
    private let users = Table("users")
    private let id = Expression<Int64>("id")
    private let name = Expression<String?>("name")
    private let phone = Expression<String>("phone")
    private let dob = Expression<String>("dob")
    private let username = Expression<String>("username")
    private let imageUrl = Expression<String>("image_url")
    private let email = Expression<String>("email")

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            print(path)
            db = try Connection("\(path)/users.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(users.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(phone, unique: true)
                table.column(dob)
                table.column(username)
                table.column(imageUrl)
                table.column(email)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func addUser(uname: String, uphone: String, udob: String, uemail: String, uusername: String, uimageUrl: String) -> Int64? {
        do {
            let insert = users.insert(name <- uname, phone <- uphone, dob <- udob, email <- uemail, username <- uusername, imageUrl <- uimageUrl)
            let id = try db!.run(insert)
            
            return id
        } catch {
            print("Insertin failed")
            return -1
        }
    }

    func getUsers() -> [Users] {
        var usersList = [Users]()
        do {
            for user in try db!.prepare(self.users) {

            usersList.append(Users.init(id: user[id], name: user[name]!, phone: user[phone], dob: user[dob], email: user[email], imageUrl: user[imageUrl], username: user[username]))
            }
        } catch {
            print("Selection failed")
        }
        return usersList
    }

}
