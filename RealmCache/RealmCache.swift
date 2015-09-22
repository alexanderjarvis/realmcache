//
//  RealmCache.swift
//  RealmCache
//
//  Created by Alex on 10/05/2015.
//  Copyright (c) 2015 PANAXIOM Ltd. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmCache {

    static let defaultCacheName = "cache"

    let name: String
    let realm: Realm

    private static func cachesDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        return paths[0]
    }

    private static func migrate(path: String) {
        let realmCacheSchemaVersion: UInt64 = 1

        let defaultRealmSchemaVersion = schemaVersionAtPath(Realm.Configuration.defaultConfiguration.path ?? "")

        let schemaVersion = defaultRealmSchemaVersion ?? realmCacheSchemaVersion

        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = schemaVersion

        do {
            try _ = Realm(configuration: config)
        } catch {

        }
    }

    public init(name: String = defaultCacheName) {
        self.name = name + ".realm"
        let path = RealmCache.cachesDirectory() + name
        RealmCache.migrate(path)
        self.realm = try! Realm(path: path)

    }

    deinit {
        realm.invalidate()
    }

    public func objectForKey(key: String) -> AnyObject? {
        if let cacheObject = realm.objectForPrimaryKey(CacheObject.self, key: key) {
            if expired(cacheObject) {
                removeObjectForKey(key)
                return nil
            } else if let object: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(cacheObject.value) {
                return object
            }
        }
        return nil
    }

    public func setObject(obj: NSSecureCoding, forKey key: String, expiresIn: NSTimeInterval = 0) {
        let _ = try? realm.write { [unowned self] in
            let cacheObject = CacheObject()
            cacheObject.key = key
            cacheObject.value = NSKeyedArchiver.archivedDataWithRootObject(obj)
            cacheObject.created = NSDate().timeIntervalSince1970
            cacheObject.expiresIn = expiresIn
            self.realm.add(cacheObject, update: true)
        }

    }
    func removeObjectForKey(key: String) {
        if let cacheObject = realm.objectForPrimaryKey(CacheObject.self, key: key) {
            let _ = try? realm.write { [unowned self] in
                self.realm.delete(cacheObject)
            }
        }
    }

    func removeAllObjects() {
        let _ = try? realm.write { [unowned self] in
            self.realm.deleteAll()
        }
    }

    func expired(cacheObject: CacheObject) -> Bool {
        if cacheObject.expiresIn != 0 {
            let now = NSDate().timeIntervalSince1970
            let expires = cacheObject.created + cacheObject.expiresIn
            if now > expires {
                return true
            }
        }
        return false
    }

    func pruneExpired() {
        let results = realm.objects(CacheObject).filter("expiresIn != 0")
        for cacheObject in results {
            if expired(cacheObject) {
                removeObjectForKey(cacheObject.key)
            }
        }
    }
}

class CacheObject: Object {

    dynamic var key: String = ""
    dynamic var value: NSData = NSData()
    dynamic var created: NSTimeInterval = 0
    dynamic var expiresIn: NSTimeInterval = 0

    static override func primaryKey() -> String? {
        return "key"
    }
}
