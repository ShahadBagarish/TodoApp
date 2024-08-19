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

class InMemoryCache: Cache {
    
    var savedData: [Todo]?
    
    func save(todos: [Todo]) {
        savedData = todos
    }
    
    func load() -> [Todo]? {
        return savedData
    }
    
    
}

final class TodoManager: FileSystemCache {
    var tasks: [Todo] = []
    
    func add(_ title: String){
        let task = Todo(description: "This is a description for \(title) task", title: title)
        tasks.append(task)
        save(todos: tasks)
    }
    
    func listTodos(){
        if let load = load() {
            if load.isEmpty{
                print("\n 💡 There is no task added \n")
            }else{
                print("\n 📝 Your Todos: ")
                for index in load.indices {
                    print("    \(index+1). \(load[index].isCompleted ? "✅" : "❌") \(load[index].title) ")
                }
                print(" ")
            }
        }
    }
    
    func toggleCompletion(at index: Int){
        if let loadData = load(){
            if index > loadData.count{
                print("\n ⚠️ There is no \(index) task \n")
            }else{
                print("\n 🔄 Todo completion status is toggled! \n")
                tasks[index-1].isCompleted = !tasks[index-1].isCompleted
                save(todos: tasks)
            }
        }
        
    }
    
    func delete(at index: Int){
        if let load = load() {
            if index > load.count{
                print("\n ⚠️ There is no \(index) task \n")
            }else{
                
                tasks.remove(at: index-1)
                save(todos: tasks)
                print("\n 🗑️ Todo Deleted \n")
            }
        }
    }
}


final class App {
    
    enum Command: String{
        case add
        case list
        case toggle
        case delete
        case exit
    }
    
    
    func run(){

        let manager = TodoManager()
        var breaker = Command.list
        
        repeat {
            print("What you would like to do? (add, list, toggle, delete, exit): ")
            if let input = readLine() {
                if let inp = App.Command(rawValue: input) {
                    switch inp{
                    case .add:
                        print("Enter todo title: ")
                        if let title = readLine() {
                            manager.add(title)
                            print("\n 📌 Todo added! \n")
                        }
                        
                    case .delete:
                        manager.listTodos()
                        print("Enter the number of the todo to delete: \n")
                        if let number = readLine() {
                            if let num = Int(number) {
                                manager.delete(at: Int(num))
                            }
                        }
                        
                    case .list:
                        manager.listTodos()
                        
                    case .toggle:
                        manager.listTodos()
                        print("Enter the number of todo to toggle: ")
                        if let number = readLine() {
                            if let num = Int(number) {
                                manager.toggleCompletion(at: Int(num))
                            }
                        }
                    case .exit:
                        breaker = Command.exit
                    }
                }else{
                    print("\n ⚠️ Entry not valid \n")
                }
            }
            
        } while breaker != .exit
    }
}

// TODO: Write code to set up and run the app.
print(" 🌟 Welcom to Todo CLI 🌟")
let app: () = App().run()



