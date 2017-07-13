//
//  FileProviderEnumerator.swift
//  Files
//
//  Created by Kris Foster on 7/11/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import FileProvider
import Spinner

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    
    var enumeratedItemIdentifier: NSFileProviderItemIdentifier
    
    var upspin: Upspin!
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, upspin: Upspin) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        self.upspin = upspin
        super.init()
    }

    func invalidate() {
        print("Not implemented: FileProviderEnumerator: invalidate")
        
        // TODO: perform invalidation of server connection if necessary
    }
    
    func listDirectory(path: String, parent: NSFileProviderItemIdentifier) throws -> [FileProviderItem] {
        var dirEntry: SpinnerDirEntry?
        
        let filePath = NSString.path(withComponents: [path, "*"])
        try dirEntry = upspin?.client.glob(filePath)
        
        var items: [FileProviderItem] = []
        var entry = dirEntry
        while entry != nil {
            let lastModified = Date(timeIntervalSince1970: Double(entry!.lastModified()))
            let item = FileProviderItem(name: entry!.name(), isDir: entry!.isDir(), isLink: entry!.isLink(), lastModified: lastModified, parent: parent)
            items.append(item)
            entry = entry?.next()
        }
        
        return items
    }
    
    func sortByName(listing: [FileProviderItem]) -> [FileProviderItem] {
        return listing.sorted(by: {
            (itemA, itemB) in
            return itemA.filename < itemB.filename
        })
    }
    
    func sortByDate(listing: [FileProviderItem]) -> [FileProviderItem] {
        return listing.sorted(by: {
            (itemA, itemB) in
            return itemA.lastModified < itemB.lastModified
        })
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        print("Not implemented: FileProviderEnumerator: enumerateItems")
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, fromSyncAnchor anchor: Data) {
        print("Not implemented: FileProviderEnumerator: enumerateChanges")
        
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
    }
    
}
