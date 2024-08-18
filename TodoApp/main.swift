//
//  main.swift
//  TodoApp
//
//  Created by Shahad Bagarish on 14/08/2024.
//

import Foundation

struct Todo: CustomStringConvertible , Codable {
    
    var description: String
    var id = UUID().uuidString.lowercased()
    var title: String
    var isCompleted: Bool = false
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.


class FileSystemCache: Cache {
    
    let path: URL
    let readingData: [Todo]
    
    init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let path = paths.appendingPathComponent("userProfile.json")
    }

    
    func save(todos: [Todo]) {
        let readingData = todos
        
        do {
         let jsonEncoder = JSONEncoder()
         let jsonData = try jsonEncoder.encode(readingData)
            try jsonData.write(to: self.path)
        } catch {
         print("Error encoding data: \(error)")
        }
    }
    
    func load() -> [Todo]? {
        
        do {
            let jsonData = try Data(contentsOf: self.path)
            
            let jsonDecoder = JSONDecoder()
            let readingData = try jsonDecoder.decode(Todo.self, from: jsonData)
            
        } catch {
            print("Error decoding data: \(error)")
        }
    }
    
    
}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    func save(todos: [Todo]) {
        <#code#>
    }
    
    func load() -> [Todo]? {
        <#code#>
    }
    
    
}

final class TodoManager: FileSystemCache {
    
    func listTodos(all: [Todo]){
        print("\n 📝 Your Todos: ")
        
        for index in all.indices {
            print("    \(index+1). \(all[index].isCompleted ? "✅" : "❌") \(all[index].title) ")
        }
        print(" ")
    }
    
    func addTodo(_ title: String) -> Todo{
        let task = Todo(description: "This is a description for \(title) task", title: title)
        return task
    }

    func toggleCompletion(at index: Int, all: inout [Todo]){
        if index > all.count{
            print("\n Number out of scope \n")
        }else{
            print("\n 🔄 Todo completion status is toggled! \n")
            return all[index-1].isCompleted = true
        }
    }
    func delete(at index: Int, all: inout [Todo]){
        all.remove(at: index-1)
        print("\n 🗑️ Todo Deleted \n")
    }
}


final class App {
    
    enum Command: String{
        case add
        case list
        case toggle
        case delete
    }
    
    let manager = TodoManager()
    var tasks: [Todo] = []
    
    func run(){
        var breaker = ""
        
        repeat {
            print("What you would like to do? (add, list, toggle, delete, exit): ")
            if let input = readLine() {
                guard input != "exit" else{
                    breaker = "exit"
                    break
                }
                if let inp = App.Command(rawValue: input) {
                    switch inp{
                    case .add:
                        print("\n Enter todo title: ")
                        if let title = readLine() {
                            var newAdd = manager.addTodo(title)
                            tasks.append(newAdd)
                            print("\n Todo added! \n")
                        }
                        
                    case .delete:
                        manager.listTodos(all: tasks)
                        print("\n Enter the number of the todo to delete: \n")
                        if var number = readLine() {
                            if var num = Int(number) {
                                manager.delete(at: Int(num), all: &tasks)
                            }
                        }
                        
                    case .list:
                        manager.listTodos(all: tasks)
                        
                    case .toggle:
                        print("\n Enter the number of todo to toggle: ")
                        if var number = readLine() {
                            if var num = Int(number) {
                                manager.toggleCompletion(at: Int(num), all: &tasks)
                            }
                        }
                    }
                }else{
                    print("Entry not valid")
                }
            }
            
        } while breaker != "exit"
    }
}

// TODO: Write code to set up and run the app.
print("Welcom to Todo CLI ✨")
let app: () = App().run()



