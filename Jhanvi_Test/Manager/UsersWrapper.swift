//
//  UserWrapper.swift
//
//  Created by Jhanvi on 24/03/19.
//  Copyright © 2019 Jhanvi. All rights reserved.
//
import Foundation
import Alamofire

enum BackendError: Error {
  case urlError(reason: String)
  case objectSerialization(reason: String)
}

enum UsersFields: String {
  case Name = "name"
  case Title = "title"
  case First = "first"
  case Last = "last"
  case UserName = "username"
  case Email = "email"
  case DateOfBirth = "dob"
  case Date = "date"
  case Cell = "cell"
  case Login = "login"
  case Picture = "picture"
  case Medium = "medium"
  case Id = "id"
}

class UsersWrapper {
  var users: [Users]?
  var count: Int?
  var next: String?
  var previous: String?
}

class Users {
  var idN: Int64?
  var name: String?
  var email: String?
  var cell: String?
  var username: String?
  var imageURL: String?
  var dateOfBirth: String?
  
    init(id: Int64, name: String, phone: String, dob: String, email: String, imageUrl: String, username: String) {
        self.idN = id
        self.name = name
        self.cell = phone
        self.dateOfBirth = dob
        self.email = email
        self.username = username
        self.imageURL = imageUrl
    }
    
  init(json: [String: Any]) {
    self.cell = json[UsersFields.Cell.rawValue] as? String
    self.email = json[UsersFields.Email.rawValue] as? String
    
    let loginData: [String: Any] = (json[UsersFields.Login.rawValue] as? Dictionary)!
    self.username = loginData[UsersFields.UserName.rawValue] as? String
    
    let imageData: [String: Any] = (json[UsersFields.Picture.rawValue] as? Dictionary)!
    self.imageURL = imageData[UsersFields.Medium.rawValue] as? String
    
    let nameData: [String: Any] = (json[UsersFields.Name.rawValue] as? Dictionary)!
    let title = nameData[UsersFields.Title.rawValue] as? String ?? ""
    let firstname: String = nameData[UsersFields.First.rawValue] as? String ?? ""
    let lastname: String = nameData[UsersFields.Last.rawValue] as? String ?? ""
    self.name = title + " " + firstname + " " + lastname
    
    let birthDateData: [String: Any] = (json[UsersFields.DateOfBirth.rawValue] as? Dictionary)!
    self.dateOfBirth = birthDateData[UsersFields.Date.rawValue] as? String
    
    // TODO: more fields!
  }
  
  // MARK: Endpoints
  class func endpointGetUsers() -> String {
    return "​https://randomuser.me/api/?"
  }
  
 
  fileprivate class func getUsersAtPath(_ path: String, completionHandler: @escaping (Result<UsersWrapper>) -> Void) {

        guard let url = URL(string:"https://randomuser.me/api/?") else {
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            completionHandler(.failure(error))
            return
        }
        Alamofire.request(url,
                          method: .get,
                          parameters: ["page": "10"])
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                      let error = BackendError.urlError(reason: "Tried to load an invalid URL")

                        completionHandler(.failure(error))
                    return
                }
                let UsersWrapperResult = Users.usersArrayFromResponse(response)
                completionHandler(UsersWrapperResult)
        }
    }

  class func getUsers(_ completionHandler: @escaping (Result<UsersWrapper>) -> Void) {
    getUsersAtPath(Users.endpointGetUsers(), completionHandler: completionHandler)
  }
  
  class func getMoreUsers(_ wrapper: UsersWrapper?, completionHandler: @escaping (Result<UsersWrapper>) -> Void) {
    guard let nextURL = wrapper?.next else {
      let error = BackendError.objectSerialization(reason: "Did not get wrapper for more users")
      completionHandler(.failure(error))
      return
    }
    getUsersAtPath(nextURL, completionHandler: completionHandler)
  }
  
  private class func usersFromResponse(_ response: DataResponse<Any>) -> Result<Users> {
    guard response.result.error == nil else {
      // got an error in getting the data, need to handle it
      print(response.result.error!)
      return .failure(response.result.error!)
    }
    
    // make sure we got JSON and it's a dictionary
    guard let json = response.result.value as? [String: Any] else {
      print("didn't get users object as JSON from API")
      return .failure(BackendError.objectSerialization(reason:
        "Did not get JSON dictionary in response"))
    }
    
    let users = Users(json: json)
    return .success(users)
  }
  
  private class func usersArrayFromResponse(_ response: DataResponse<Any>) -> Result<UsersWrapper> {
    guard response.result.error == nil else {
      // got an error in getting the data, need to handle it
      return .failure(response.result.error!)
    }
    
    // make sure we got JSON and it's a dictionary
    guard let json = response.result.value as? [String: Any] else {
      print("didn't get users object as JSON from API")
      return .failure(BackendError.objectSerialization(reason:
        "Did not get JSON dictionary in response"))
    }
    print(json)
    let wrapper:UsersWrapper = UsersWrapper()
//    wrapper.next = json["next"] as? String
    wrapper.count = 1
    
    var allUsers: [Users] = []
    if let results = json["results"] as? [[String: Any]] {
      for jsonUsers in results {
        let users = Users(json: jsonUsers)
        allUsers.append(users)
      }
    }
    wrapper.users = allUsers
    return .success(wrapper)
  }
}
