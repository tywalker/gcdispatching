//
//  main.swift
//  gcDispatch
//
//  Created by Tyler Walker on 8/11/18.
//  Copyright © 2018 None. All rights reserved.
//

import Foundation

//{
//    "id": 1,
//    "name": "Leanne Graham",
//    "username": "Bret",
//    "email": "Sincere@april.biz",
//    "address": {
//        "street": "Kulas Light",
//        "suite": "Apt. 556",
//        "city": "Gwenborough",
//        "zipcode": "92998-3874",
//        "geo": {
//            "lat": "-37.3159",
//            "lng": "81.1496"
//        }
//    },
//    "phone": "1-770-736-8031 x56442",
//    "website": "hildegard.org",
//    "company": {
//        "name": "Romaguera-Crona",
//        "catchPhrase": "Multi-layered client-server neural-net",
//        "bs": "harness real-time e-markets"
//    }

struct Geo: Codable {
    let lat: String
    let lng: String
}

struct Address: Codable {
    let city: String
    let zipcode: String
    let geo: Geo
}

struct RawUser: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
}

struct RawTodo: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct User {
    let id: Int
    let name: String
    let username: String
    let email: String
    let todos: [RawTodo]
}

let handlerBlock: (Data) -> Void = { data in
    print(data[0])
}

var users: [RawUser]?
var dataUsers: [User]? = []
var todos: [RawTodo]?
var userTodos: [RawTodo]? = []

let group = DispatchGroup()
let innerGroup = DispatchGroup()

func getUsers() {
    let urlString = "https://jsonplaceholder.typicode.com/users"
    guard let url = URL(string: urlString) else { return }

    //Implementing URLSession
    URLSession.shared.dataTask(with: url) { (data, res, err) in
        if err != nil { print(err!) }
        guard let data = data else { return }
        
        let decoder = JSONDecoder()
        do {
            users = try decoder.decode([RawUser].self, from: data)
        } catch {
            print(error)
        }
        group.leave()
    }.resume()
}

func getTodos() {
    let urlString = "https://jsonplaceholder.typicode.com/todos"
    guard let url = URL(string: urlString) else { return }
    
    //Implementing URLSession
    URLSession.shared.dataTask(with: url) { (data, res, err) in
        if err != nil { print(err!) }
        guard let data = data else { return }
        
        let decoder = JSONDecoder()
        do {
            let todo = try decoder.decode([RawTodo].self, from: data)
            print(todo[0])
        } catch {
            print(error)
        }
        group.leave()
    }.resume()
}

func getUserTodo(user: RawUser, index: Int) {
    let urlString = "https://jsonplaceholder.typicode.com/todos?userId=\(user.id)"
    guard let url = URL(string: urlString) else { return }
    
    //Implementing URLSession
    URLSession.shared.dataTask(with: url) { (data, res, err) in
        if err != nil { print(err!) }
        guard let data = data else { return }
        
        let decoder = JSONDecoder()
        do {
            let todos = try decoder.decode([RawTodo].self, from: data)
            let u = User(id: user.id, name: user.name, username: user.username, email: user.email, todos: todos)
            dataUsers?.append(u)
            for todo in todos {
                userTodos!.append(todo)
            }
            
        } catch {
            print(error)
        }
        
        print("COUNT: \(index) ++++++++++")
        
        innerGroup.leave()
        
        if (index == users!.count - 1) { group.leave() }
        
        }.resume()
    
}

group.enter()
    print("enterusers")
    getUsers()
group.wait()
group.enter()
    for (index, user) in users!.enumerated() {
        innerGroup.enter()
        getUserTodo(user: user, index: index + 1)
    }
group.wait()
group.enter()
    print("enterusers_______________________")
    getUsers()
group.wait()
print("finished")
print(dataUsers![0].id)
print(dataUsers![0].name)
print(dataUsers![0].todos[0].userId)
print(dataUsers![0].todos[0].title)
print(type(of: users))
print(type(of: users))
