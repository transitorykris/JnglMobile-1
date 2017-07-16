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
    
    // This is for enumerating the contents of a specific directory
    
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
        
        observer.didEnumerate(listing)
        
        // We're returning everything as a single page here (upToPAge: nil)
        // TOOD: Since the extension is given a very small amount of memory,
        // paginating the results may be necessary for directories with lots
        // of files.
        observer.finishEnumerating(upToPage: nil)
    }
    
}
