//
//  main.swift
//  gcDispatch
//
//  Created by Tyler Walker on 8/11/18.
//  Copyright © 2018 None. All rights reserved.
//

import Foundation

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

//{
//    "userId": 1,
//    "id": 1,
//    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
//    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
//},
struct RawPost: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
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
    let posts: [RawPost]
}

let handlerBlock: (Data) -> Void = { data in
    print(data[0])
}

var users: [RawUser]?
var todos: [RawTodo]?
var posts: [RawPost]?

var dataUsers: [User]? = []
var userTodos: [RawTodo]? = []
var userPosts: [RawPost]? = []

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
            todos = try decoder.decode([RawTodo].self, from: data)
        } catch {
            print(error)
        }
        group.leave()
    }.resume()
}

func getPosts() {
    let urlString = "https://jsonplaceholder.typicode.com/posts"
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, res, err) in
        if err != nil { print(err!) }
        guard let data = data else { return }
        
        let decoder = JSONDecoder()
        do {
            posts = try decoder.decode([RawPost].self, from: data)
        } catch {
            print(err!)
        }
        
        group.leave()
        
    }.resume()
}

func normalizeUsers() -> [User] {
    var nUsers: [User] = []
    
    for user in users! {
        let u = User(
            id: user.id,
            name:
            user.name,
            username: user.username,
            email: user.email,
            todos: todos!.filter { $0.userId == user.id },
            posts: posts!.filter { $0.userId == user.id }
        )
        
        nUsers.append(u)
    }
    
    return nUsers
}

func dispatchGetUsers() -> Void {
    group.enter()
    getUsers()
}

func dispatchGetTodos() -> Void {
    group.enter()
    getTodos()
}

func dispatchGetPosts() -> Void {
    group.enter()
    getPosts()
}

dispatchGetUsers()
dispatchGetTodos()
dispatchGetPosts()

group.wait()

dataUsers = normalizeUsers()
