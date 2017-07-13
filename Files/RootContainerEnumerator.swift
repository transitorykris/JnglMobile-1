//
//  RootContainerEnumerator.swift
//  Files
//
//  Created by Kris Foster on 7/12/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import FileProvider
import Spinner

class RootContainerEnumerator: FileProviderEnumerator {
    
    override func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        // perform a server request to fetch root directory contents
        let userName = upspin.config.userName()!
        var listing: [FileProviderItem]!
        do {
            try listing = listDirectory(path: userName, parent: enumeratedItemIdentifier)
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
        observer.finishEnumerating(upToPage: nil)
    }
    
}
