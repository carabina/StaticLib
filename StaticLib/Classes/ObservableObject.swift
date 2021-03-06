//
//  Base.swift
//  AppBasicLibrary
//
//  Created by Roma Novakov on 04.05.16.
//  Copyright © 2016 novacom. All rights reserved.
//

import Foundation

//MARK: - ObservableModelProtocol Protocol
public protocol ObservableProtocol {
    
    func registerObserver(observer: NSObject)
    func unregisterObserver(observer: NSObject)
    func notifyObserversWithSelector(selector: Selector, andObject object: AnyObject?)
    func notifyObserversInMainThreadWithSelector(selector: Selector, andObject object: AnyObject?)
    
}


//MARK: - ObservableObject Protocol
/// ObservableObject it's base class of all Observable Models in app.
public class ObservableObject : NSObject, ObservableProtocol {
    
    private(set) public var observerSet : NSMutableSet = NSMutableSet()
    
    public func registerObserver(observer: NSObject) {
        
        objc_sync_enter(self.observerSet)

        let weakLink = WeakLink(target: observer)
        self.observerSet.addObject(weakLink)
        
        objc_sync_exit(self.observerSet)

    }
    
    public func unregisterObserver(observer: NSObject) {
        
        objc_sync_enter(self.observerSet)
        
        let weakLink = WeakLink(target: observer)
        self.observerSet.removeObject(weakLink)
        
        objc_sync_exit(self.observerSet)

    }
   
    public func notifyObserversWithSelector(selector: Selector, andObject object: AnyObject?) {
        
        //objc_sync_enter(self.observerSet)
        
        for obj in self.observerSet {
            let weakLink = obj as! WeakLink
            if let isResponse = weakLink.target?.respondsToSelector(selector) {
                if isResponse {
                    let observer = weakLink.target
                    observer?.performSelector(selector,
                                              withObject: self,
                                              withObject: object)
                }
            }
        }
    
        //objc_sync_exit(self.observerSet)
        
    }

    
    public func notifyObserversInMainThreadWithSelector(selector: Selector, andObject object: AnyObject?) {
        
        /* // IF this function call in Main Thread - Main Thread is dealloc
        dispatch_sync(dispatch_get_main_queue(), {[unowned self] in
            self.notifyObserversWithSelector(selector, andObject: object)
        })
        */
        
        if NSThread.isMainThread() {
            self.notifyObserversWithSelector(selector, andObject: object)
        } else {
            dispatch_sync(dispatch_get_main_queue(), {[unowned self] in
                self.notifyObserversWithSelector(selector, andObject: object)
            })
        }
 
    }

    
// Only test method
    deinit {
        //print("### Dealloc: "+"\(self)")
    }
    
}



