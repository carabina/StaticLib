//
//  Base.swift
//  AppBasicLibrary
//
//  Created by Roma Novakov on 04.05.16.
//  Copyright © 2016 novacom. All rights reserved.
//

import Foundation

//MARK: - ModelObserver Protocol
protocol ObserverModelProtocol : class {
    
    // Model did load 
    // Model will load
    func modelDidLoad()
}

//MARK: - ObservableModelProtocol Protocol
protocol ObservableProtocol {
    
    var observerSet : NSMutableSet { get }
    
    func registerObserver(observer: NSObject)
    func unregisterObserver(observer: NSObject)
    func notifyObserversWithSelector(selector: Selector, andObject object: AnyObject?)
    func notifyObserversInMainThreadWithSelector(selector: Selector, andObject object: AnyObject?)
    
}


//MARK: - ObservableObject Protocol
public class ObservableObject : NSObject, ObservableProtocol {

    private(set) var observerSet : NSMutableSet = NSMutableSet()
    
    func registerObserver(observer: NSObject) {
        
        let lockQueue = dispatch_queue_create("com.registerObserver.queue", nil)
        dispatch_sync(lockQueue) {
            let weakLink = WeakLink(target: observer)
            self.observerSet.addObject(weakLink)
        }
        
    }
    
    func unregisterObserver(observer: NSObject) {
        
        let lockQueue = dispatch_queue_create("com.unregisterObserver.queue", nil)
        dispatch_sync(lockQueue) {
            let weakLink = WeakLink(target: observer)
            //FIXIT: =============================
            self.observerSet.removeObject(weakLink)
            // ===================================
        }
    }
   
    func notifyObserversWithSelector(selector: Selector, andObject object: AnyObject?) {
        
        let lockQueue = dispatch_queue_create("com.unregisterObserver.queue", nil)
        dispatch_sync(lockQueue) {
            for object in self.observerSet {
                let weakLink = object as! WeakLink
                if weakLink.target?.respondsToSelector(selector) != nil {
                    weakLink.target!.performSelector(selector, withObject: object)
                }
            }
        }
    }

    func notifyObserversInMainThreadWithSelector(selector: Selector, andObject object: AnyObject?) {
        
        
        
    }
 
    
}





