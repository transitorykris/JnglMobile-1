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
    
    override init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, upspin: Upspin) {
        print("FileProviderEnumerator: init")
        
        super.init(enumeratedItemIdentifier: enumeratedItemIdentifier, upspin: upspin)
    }
    
    override func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        print("RootContainerEnumerator: enumerateItems")
        
        // perform a server request to fetch root directory contents
        let userName = upspin.config.userName()!
        observer.didEnumerate(listDirectory(path: userName, parent: enumeratedItemIdentifier))
        observer.finishEnumerating(upToPage: nil)
    }
    
}
