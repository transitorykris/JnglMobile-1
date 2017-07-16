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
    
    // The RootContainerEnumerator is for enumerating the user's root directory
    
    // TODO: The root should probably match how upspinfs behaves, this is a list of
    // identities in the global namespace that have content accessed by the user.
    
    override func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        // perform a server request to fetch root directory contents
        let userName = upspin.config.userName()!
        var listing: [FileProviderItem]!
        do {
            try listing = listDirectory(path: userName, parent: enumeratedItemIdentifier)
        } catch {
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
