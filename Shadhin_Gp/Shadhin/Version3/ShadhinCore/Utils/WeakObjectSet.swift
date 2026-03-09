//
//  WeakObject.swift
//  Shadhin
//
//  Created by Gakk Alpha on 10/7/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import Foundation



class WeakObjectSet {
    
    private var _objects: Set<WeakObject>
    
    init() {
        self._objects = Set<WeakObject>([])
    }
    
    init(_ objects: [ShadhinCoreNotifications]) {
        self._objects = Set<WeakObject>(objects.map { WeakObject($0) })
    }
    
    var objects: [ShadhinCoreNotifications] {
        return self._objects.compactMap { $0.object }
    }
    
    func contains(_ object: ShadhinCoreNotifications) -> Bool {
        return self._objects.contains(WeakObject(object))
    }
    
    func addObject(_ object: ShadhinCoreNotifications) {
        self._objects.insert(WeakObject(object))
    }
    
    func addingObject(_ object: ShadhinCoreNotifications) -> WeakObjectSet{
        return WeakObjectSet( self.objects + [object])
    }
    
    func addObjects(_ objects: [ShadhinCoreNotifications]) {
        self._objects.formUnion(objects.map { WeakObject($0) })
    }
    
    func addingObjects(_ objects: [ShadhinCoreNotifications]) -> WeakObjectSet {
        return WeakObjectSet( self.objects + objects)
    }
    
    func removeObject(_ object: ShadhinCoreNotifications) {
        self._objects.remove(WeakObject(object))
    }
    
    func removeObject(_ hashKey: Int) {
        guard let item = self._objects.first(where: {$0.hashKey == hashKey}) else {return}
        self._objects.remove(item)
    }
    
    func removingObject(_ object: ShadhinCoreNotifications) -> WeakObjectSet {
        var temporaryObjects = self._objects
        temporaryObjects.remove(WeakObject(object))
        return WeakObjectSet(temporaryObjects.compactMap { $0.object })
    }
    
    func removeObjects(_ objects: [ShadhinCoreNotifications]) {
        self._objects.subtract(objects.map { WeakObject($0) })
    }
    
    func removingObjects(_ objects: [ShadhinCoreNotifications]) -> WeakObjectSet{
        let temporaryObjects = self._objects.subtracting(objects.map { WeakObject($0) })
        return WeakObjectSet(temporaryObjects.compactMap { $0.object })
    }
    
    private class WeakObject: Equatable, Hashable{
        
        weak var object: ShadhinCoreNotifications?
        fileprivate let hashKey: Int
        
        init(_ object: ShadhinCoreNotifications) {
            self.object = object
            self.hashKey = ObjectIdentifier(object).hashValue
        }
        
        static func == (lhs: WeakObject, rhs: WeakObject) -> Bool {
            if lhs.object == nil || rhs.object == nil { return false }
            return lhs.object === rhs.object
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(hashKey)
        }
    }
}
