//
//  Prospect.swift
//  HotProspects
//
//  Created by dominator on 03/04/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI

class Prospect: Identifiable, Codable{
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    
    static let saveKey = "SavedData"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey){
            if let decodedData = try? JSONDecoder().decode([Prospect].self, from: data){
                self.people = decodedData
                return
            }
        }
        
        self.people = []
    }
    
    func toggle(_ prospect: Prospect){
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    private func save(){
        if let encodedData = try? JSONEncoder().encode(self.people){
            UserDefaults.standard.set(encodedData, forKey: Self.saveKey)
        }
    }
    
    func add(_ prospect: Prospect){
        self.people.append(prospect)
        save()
    }
    
}
