//
//  FileProviderEnumerator.swift
//  Files
//
//  Created by Kris Foster on 7/11/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import FileProvider

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    
    var enumeratedItemIdentifier: NSFileProviderItemIdentifier
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier) {
        print("FileProviderEnumerator: init")
        
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        super.init()
    }

    func invalidate() {
        print("FileProviderEnumerator: invalidate")
        
        // TODO: perform invalidation of server connection if necessary
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
         // - perform a server request to fetch directory contents
        switch enumeratedItemIdentifier {
        case NSFileProviderItemIdentifier.rootContainer:
            print("Not implemented: handling request for root container")
            // perform a server request to fetch directory contents
        case NSFileProviderItemIdentifier.allDirectories:
            print("Not implemented: handling request for all directories")
            // perform a server request to fetch directory contents
        case NSFileProviderItemIdentifier.workingSet:
            print("Not implemented: handling request for the working set")
            // perform a server request to update your local database
            // fetch the active set from your local database
        default:
            print("Unknown enumeratedItemIdentifier \(enumeratedItemIdentifier)")
            return
        }
        
        // inform the observer about the items returned by the server (possibly multiple times)
        // Hardcode an item..
        let updatedItems = [
            FileProviderItem(name: "test.txt", isDir: false, isLink: false, parent: enumeratedItemIdentifier),
            FileProviderItem(name: "MyFolder", isDir: true, isLink: false, parent: enumeratedItemIdentifier),
            FileProviderItem(name: "photo.jpg", isDir: false, isLink: false, parent: enumeratedItemIdentifier),
            FileProviderItem(name: "unknownfile", isDir: false, isLink: false, parent: enumeratedItemIdentifier),
            FileProviderItem(name: "asymlink", isDir: false, isLink: true, parent: enumeratedItemIdentifier),
            ]
        observer.didEnumerate(updatedItems)
        
        // inform the observer that you are finished with this page
        // nil seems to signal that there are no more pages
        observer.finishEnumerating(upToPage: nil)
        
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
