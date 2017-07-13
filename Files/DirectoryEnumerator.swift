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
    
    override init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, upspin: Upspin) {
        print("DirectoryEnumerator: init")
        
        super.init(enumeratedItemIdentifier: enumeratedItemIdentifier, upspin: upspin)
    }
    
    override func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        print("DirectoryEnumerator: enumerateItems")
        
        // perform a server request to fetch root directory contents
        observer.didEnumerate(listDirectory(path: enumeratedItemIdentifier.rawValue, parent: enumeratedItemIdentifier))
        observer.finishEnumerating(upToPage: nil)
    }
    
}
