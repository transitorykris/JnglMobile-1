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
        print("FileProviderEnumerator: init")
        
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        self.upspin = upspin
        super.init()
    }

    func invalidate() {
        print("FileProviderEnumerator: invalidate")
        
        // TODO: perform invalidation of server connection if necessary
    }
    
    func listDirectory(path: String, parent: NSFileProviderItemIdentifier) -> [FileProviderItem] {
        var dirEntry: SpinnerDirEntry?
        
        do {
            let filePath = NSString.path(withComponents: [path, "*"])
            print("Listing files for path \(filePath)")
            try dirEntry = upspin?.client.glob(filePath)
        } catch let error as NSError {
            print("Cannot list files \(error)")
            return []
        }
        
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
        print("FileProviderEnumerator: enumerateItems")
        
        // inspect the page to determine whether this is an initial or a follow-up request
        switch page as NSFileProviderPage {
        case NSFileProviderInitialPageSortedByName:
            print("Not implemented: request for initial page sorted by name")
        case NSFileProviderInitialPageSortedByDate:
            print("Not implemented: request for initial page sorted by date")
        default:
            print("Not implemented: request for page starting at specific page")
        }
        
         // If this is an enumerator for a directory, the root container or all directories:
        switch enumeratedItemIdentifier {
        case NSFileProviderItemIdentifier.rootContainer:
            print("Not implemented: handling request for root container")
            // perform a server request to fetch directory contents
        case NSFileProviderItemIdentifier.workingSet:
            print("Not implemented: handling request for the working set")
            // perform a server request to update your local database
            // fetch the active set from your local database
        default:
            print("Unknown enumeratedItemIdentifier \(enumeratedItemIdentifier)")
        }
        
        // Note: if an error occurs call
        // observer.finishEnumeratingWithError(<#T##error: Error##Error#>)
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, fromSyncAnchor anchor: Data) {
        print("FileProviderEnumerator: enumerateChanges")
        
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
    }
    
}
