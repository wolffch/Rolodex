//
//  MyContacts.swift
//  Rolodex
//
//  Created by Christina Wolff on 4/3/19.
//  Copyright © 2019 Christina Wolff. All rights reserved.
//

import SQLite

class MycontactsDB {
    static let instance = MycontactsDB()
    private let db: Connection?
    
    private let contacts = Table("contacts")
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let phone = Expression<String>("phone")
    private let address = Expression<String>("address")
    
    private init() {
        //path on the device or simultor to store the database
        let path = NSSearchPathForDirectoriesInDomains (
        .documentDirectory, .userDomainMask, true
        ).first!
        //attempt the statements in the do vblock. If it fails then drop down and execute the catch block
        do {
            print("\(path)/MyContacts.sqlite3")
            db = try Connection("\(path)/MyContacts.sqlite3")
        } catch {
            //Why would I be here?
            //1) File does not exist; connection will try to create the file/ If successful, we will not end up in the catch block.
            //2) Not enough space on device
            //3) Do not have permission to create the file on device
            db = nil
            print ("unable to open database")
        }
        //We could end up here with database witout contacts table
        // or a data base opened a contact table
        createTable()
    }
    
    func createTable() {
        do {
            //db is connection to data base. .run runs a command
            try db!.run(
                contacts.create(ifNotExists: true)
                {
                    table in
                    table.column(id, primaryKey: true)
                    table.column(name)
                    table.column(phone, unique:true)
                    table.column(address)
            })
        }
        catch {
            print("unable to create table")
        }
    }
    
    func addContact(cname: String, cphone: String, caddress: String) -> Int64? {
        do {
            //setup a sql command to insert a record into the database table
            let insert = contacts.insert(name <- cname, phone <- cphone, address <- caddress)
            //execute the command
            let id = try db!.run(insert)
            print(insert)
            print(insert.asSQL())
            return id
        }
        catach {
            print("insert failed")
            return -1
        }
    }
    
    func getContacts() -> [Contact] {
        var contacts = [Contact]()
        
        do {
            //the following for loop is similar to the sql select 
            for contact in try db!.prepare(self.contacts) {
                contacts.append(Contact(
                    id: contact[id],
                    name: contact[name]!,
                    phone: contact[phone],
                    address: contact[address]))
            }
        }
        catch {
            print("select failed")
        }
        return contacts
    }
    
    func deleteContact(cid: Int64) -> Bool {
        do {
            let contact = contacts.filter(id==cid)
            try db!.run(contact.delete())
            return true }
        catch {
            print("delete failed")
            }
        return false
        }
    func updateContact(cid:Int64, newContact: Contact) -> Bool {
        let contact = contacts.filter(id==cid)
        do {
            let update = contact.update([
                name <- newContact.name,
                phone <- newContact.phone,
                address <- newContact.address
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("update failed: \(error)")
        }
        return false
    }
}
