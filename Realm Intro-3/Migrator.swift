//
//  Migrator.swift
//  Realm Intro-2
//
//  Created by Stewart Lynch on 2022-03-08.
//

import Foundation
import RealmSwift

class Migrator: ObservableObject {
    private(set) var realm: Realm?
    var name: String? = nil
    
    // Observe Changes
    @Published var countries: Results<Country>?
    var countriesArray: [Country] {
        if let countries = countries {
            return Array(countries)
        } else {
            return []
        }
    }
    
    
    private var countriesToken: NotificationToken?
  
    init(name: String) {
        self.name = name
        initilizaSchema(name: name)
        setUpObserver()
    }
    
    func setUpObserver() {
        guard let realm = realm else { return }
        let observedCountries = realm.objects(Country.self)
        countriesToken = observedCountries.observe( { [weak self] _ in
            guard let self = self else { return }
            self.countries = observedCountries
        })
    }
    
    
    
    
    func initilizaSchema(name: String) {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let realmFileUrl = docDir.appendingPathComponent("\(name).realm")
        let config = Realm.Configuration.init(fileURL: realmFileUrl,schemaVersion: 1)
       
//        { migration, oldSchemaVersion in
//            if oldSchemaVersion < 1 {
//                migration.enumerateObjects(ofType: Country.className()) { _, newObject in
//                    newObject!["flag"] = "🏳️"
//                }
//            }
//        }
        Realm.Configuration.defaultConfiguration = config
        print(docDir.path)
        do {
            realm = try Realm()
        } catch {
            print("Error")
        }
    }
    
    
    
    func add(_ country: Country) {
        if let realm = realm {
            do {
                try realm.write {
                    realm.add(country)
                }
            } catch {
                print("Error saving")
            }
        }
    }
    
    func delete(_ country: Country) {
        if let realm = realm {
            if let countryDelete = realm.object(ofType: Country.self, forPrimaryKey: country.id) {
                do {
                    try realm.write {
                        realm.delete(countryDelete)
                    }
                } catch {
                    print("Could not delete")
                }
            }
        }
    }
    
}
