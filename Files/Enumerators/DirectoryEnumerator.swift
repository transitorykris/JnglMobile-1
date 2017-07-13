//
//  DirectoryEnumerator.swift
//  Files
//
//  Created by Kris Foster on 7/12/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import FileProvider
import Spinner

class DirectoryEnumerator: FileProviderEnumerator {
    
    override func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {        
        var listing: [FileProviderItem]!
        do {
            try listing = listDirectory(path: enumeratedItemIdentifier.rawValue, parent: enumeratedItemIdentifier)
        } catch let error {
            observer.finishEnumeratingWithError(error)
            return
        }
        
        // inspect the page to determine whether this is an initial or a follow-up request
        switch page as NSFileProviderPage {
        case NSFileProviderInitialPageSortedByName:
            listing = sortByName(listing: listing)
        case NSFileProviderInitialPageSortedByDate:
            listing = sortByDate(listing: listing)
        default:
            print("Not implemented: request for page starting at specific page")
        }
        
        // perform a server request to fetch root directory contents
        observer.didEnumerate(listing)
        observer.finishEnumerating(upToPage: nil)
    }
    
}
