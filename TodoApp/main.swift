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

protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

class FileSystemCache: Cache {
    
    let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("userProfile.json")
    var readingData: [Todo] = []
    
    
    func save(todos: [Todo]) {
        readingData = todos
        
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
            _ = try jsonDecoder.decode([Todo].self, from: jsonData)
            
        } catch {
            print("Error decoding data: \(error)")
        }
        return readingData
    }
    
    
}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
class InMemoryCache: Cache {
    
    var savedData: [Todo]?
    
    func save(todos: [Todo]) {
        savedData = todos
    }
    
    func load() -> [Todo]? {
        return savedData
    }
    
    
}

final class TodoManager: InMemoryCache {
    var tasks: [Todo] = []
    
    func listTodos(){
        print("\n 📝 Your Todos: ")
        if let load = load() {
            for index in load.indices {
                print("    \(index+1). \(load[index].isCompleted ? "✅" : "❌") \(load[index].title) ")
            }
            print(" ")
        }
    }
    
    func addTodo(_ title: String){
        let task = Todo(description: "This is a description for \(title) task", title: title)
        tasks.append(task)
        save(todos: tasks)
    }
    
    func toggleCompletion(at index: Int){
        if let loadData = load(){
            if index > loadData.count{
                print("\n Number out of scope \n")
            }else{
                print("\n 🔄 Todo completion status is toggled! \n")
                tasks[index-1].isCompleted = true
                save(todos: tasks)
            }
        }
        
    }
    func delete(at index: Int){
        if let load = load() {
            tasks.remove(at: index-1)
            save(todos: tasks)
        }
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
    
    
    func run(){

        let manager = TodoManager()
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
                            manager.addTodo(title)
                            print("\n Todo added! \n")
                        }
                        
                    case .delete:
                        manager.listTodos()
                        print("\n Enter the number of the todo to delete: \n")
                        if let number = readLine() {
                            if let num = Int(number) {
                                manager.delete(at: Int(num))
                            }
                        }
                        
                    case .list:
                        manager.listTodos()
                        
                    case .toggle:
                        print("\n Enter the number of todo to toggle: ")
                        if let number = readLine() {
                            if let num = Int(number) {
                                manager.toggleCompletion(at: Int(num))
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



