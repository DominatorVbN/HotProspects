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
    var createdOn: Date? = nil
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    
    static let saveKey = "SavedData"
    
    private static var url: URL{
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        url.appendPathComponent(Self.saveKey)
        return url
    }
    
    init() {
        if let data = try? Data(contentsOf: Self.url){
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
            try? encodedData.write(to: Self.url, options: [.atomicWrite])
        }
    }
    
    func add(_ prospect: Prospect){
        self.people.append(prospect)
        save()
    }
    
}
