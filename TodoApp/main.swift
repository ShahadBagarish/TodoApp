//
//  main.swift
//  TodoApp
//
//  Created by Shahad Bagarish on 14/08/2024.
//

import Foundation

struct Todo: CustomStringConvertible , Codable {
    
    var id = UUID().uuidString.lowercased()
    var title: String
    var isCompleted: Bool = false
    var description: String {
        return " Todo -> \(title), Status? : \(isCompleted ? "Completed" : "Pending"), id: \(id) "
    }
}

protocol Cache {
    func save(todos: [Todo]) -> Bool
    func load() -> [Todo]?
}

class FileSystemCache: Cache {
    
    let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("userProfile.json")
    var readingData: [Todo] = []
    
    
    func save(todos: [Todo]) -> Bool {
        readingData = todos
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(readingData)
            try jsonData.write(to: self.path)
            return true
        } catch {
            print("Error encoding data: \(error)")
            return false
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
    
    func save(todos: [Todo]) -> Bool {
        savedData = todos
        return true
    }
    
    func load() -> [Todo]? {
        return savedData
    }
    
    
}

final class TodoManager {
    
    var cash: Cache
    private var tasks: [Todo] = []
    
    init(cash: Cache) {
        self.cash = cash
    }
    
    func add(_ title: String){
        let task = Todo(title: title)
        tasks.append(task)
        if cash.save(todos: tasks) {
            print("\n 📌 Todo added! \n")
        } else {
            print("\n ⚠️ Try Again \n")
        }
    }
    
    func listTodos(){
        if let load = cash.load() {
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
        if let loadData = cash.load(){
            if index > loadData.count || index <= 0 {
                print("\n ⚠️ There is no \(index) task \n")
            } else {
                tasks[index-1].isCompleted = !tasks[index-1].isCompleted
                if cash.save(todos: tasks) {
                    print("\n 🔄 Todo completion status is toggled! \n")
                } else {
                    print("\n ⚠️ Try Again \n")
                }
            }
        }
    }
    
    func delete(at index: Int){
        if let load = cash.load() {
            if index > load.count || index <= 0{
                print("\n ⚠️ There is no \(index) task \n")
            }else{
                tasks.remove(at: index-1)
                if cash.save(todos: tasks) {
                    print("\n 🗑️ Todo Deleted \n")
                } else {
                    print("\n ⚠️ Try Again \n")
                }
                
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
        
        let fileSystemCache = FileSystemCache()
        let manager = TodoManager(cash: fileSystemCache)
        
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
                        }
                        
                    case .delete:
                        if let load = manager.cash.load() {
                            if load.isEmpty{
                                print("\n 💡 There is no task to be deleted \n")
                            }else{
                                manager.listTodos()
                                print("Enter the number of the todo to delete: \n")
                                if let number = readLine() {
                                    if let num = Int(number) {
                                        manager.delete(at: Int(num))
                                    } else {
                                        print("\n ⚠️ Entry should be Integer number \n")
                                    }
                                }
                            }
                        }

                        
                    case .list:
                        manager.listTodos()
                        
                    case .toggle:
                        if let load = manager.cash.load() {
                            if load.isEmpty{
                                print("\n 💡 There is no task to be toggled \n")
                            }else{
                                manager.listTodos()
                                print("Enter the number of todo to toggle: ")
                                if let number = readLine() {
                                    if let num = Int(number) {
                                        manager.toggleCompletion(at: Int(num))
                                    }else {
                                        print("\n ⚠️ Entry should be Integer number \n")
                                    }
                                }
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



