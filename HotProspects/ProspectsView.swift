//
//  ProspectsView.swift
//  HotProspects
//
//  Created by dominator on 03/04/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

enum FilterType{
    case none, contacted, uncontacted
}

enum SortType: String,CaseIterable,Equatable{
    case none = "None"
    case byName = "By Name"
    case byMostRecent = "By Most Recent"
}

struct ProspectsView: View {
    @State private var isShowingSheet = false
    @State private var isShowingScanner = false
    @EnvironmentObject var prospects: Prospects
    let filter: FilterType
    @State var sortType: SortType = .byName
    var title: String{
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted"
        case .uncontacted:
            return "Uncontacted"
        }
    }
    var filteredProspects: [Prospect]{
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter(\.isContacted)
        case .uncontacted:
            return prospects.people.filter{!$0.isContacted}
        }
    }
    
    var sortedProspects: [Prospect]{
        switch sortType {
        case .none:
            return filteredProspects
        case .byName:
            return filteredProspects.sorted(by: {$0.name < $1.name})
        case .byMostRecent:
            return filteredProspects.sorted(by: {
                guard let firstDate = $0.createdOn else{
                    return $0.name < $1.name
                }
                guard let secondDate = $0.createdOn else{
                    return $0.name < $1.name
                }
                return firstDate > secondDate
            })
        }
    }
    var body: some View {
        NavigationView {
            List{
                ForEach(sortedProspects) { prospect in
                    HStack{
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: prospect.isContacted ? "checkmark.circle" : "questionmark.diamond")
                            .foregroundColor(.accentColor)
                    }
                    .contextMenu{
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted"){
                            self.prospects.toggle(prospect)
                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    let ui: IndexSet = IndexSet(indexSet.map({ index in
                        let element = self.sortedProspects[index]
                        let actualIndex = self.prospects.people.firstIndex(where: {$0.id == element.id})!
                        return actualIndex
                    }))
                    self.prospects.delete(ui)
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(
                leading:
                Button(action: {
                    self.isShowingSheet = true
                }){
                    HStack {
                        Image(systemName: self.sortType == .none ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                        Text("Sort")
                    }
                },
                trailing: Button(action: {
                self.isShowingScanner = true
            }) {
                Image(systemName: "qrcode.viewfinder")
                Text("Scan")
            })
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
            }
            .actionSheet(isPresented: $isShowingSheet) {
                ActionSheet(title: Text("Sort by:"), message: nil, buttons:
                    SortType.allCases.map({  type in
                        ActionSheet.Button.default(Text(type.rawValue)) {
                            self.sortType = type
                        }
                        })
                    + [.cancel()]
                )
            }
        }
    }
    
    func handleScan(_ result: Result<String, CodeScannerView.ScanError>){
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            person.createdOn = Date()
            self.prospects.add(person)
        case .failure(let error):
            print("Scanning failed")
        }
    }
    
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //testingpurpose
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { setting in
            if setting.authorizationStatus == .authorized{
                addRequest()
            }else{
                print("Unauthorized to send notification")
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
