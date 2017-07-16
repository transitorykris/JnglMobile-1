//
//  FileProviderItem.swift
//  Files
//
//  Created by Kris Foster on 7/11/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import MobileCoreServices
import FileProvider
import Spinner

// Attempt to determine the uniform type indentifier by the filename extension
func fileNameToUTI(fileName: String) -> String {
    let fileNameExtension = fileName.components(separatedBy: ".").last!
    let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileNameExtension as CFString, nil)
    if uti == nil {
        return kUTTypeItem as String
    }
    return uti!.takeUnretainedValue() as String
}

class FileProviderItem: NSObject, NSFileProviderItem {
    
    // MARK: Properties
    var name: String
    var parent: String
    var type: String
    var lastModified: Date
    
    init(dirEntry: SpinnerDirEntry, parent: NSFileProviderItemIdentifier) {
        
        // Set ourselves up using the Upspin directory entry
        
        self.name = dirEntry.name()
        
        self.parent = parent.rawValue
        
        if dirEntry.isDir() {
            self.type = kUTTypeFolder as String
        } else if dirEntry.isLink() {
            self.type = kUTTypeSymLink as String
        } else {
            self.type = fileNameToUTI(fileName: self.name)
        }
        
        self.lastModified = dateFrom(unixTime: dirEntry.lastModified())
        
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier(self.name)
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier(self.parent)
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        // Limit the capabilities, add new capabilities when we support them
        // https://developer.apple.com/documentation/fileprovider/nsfileprovideritemcapabilities
        return [ .allowsAll ]
    }
    
    var filename: String {
        return name
    }
    
    var typeIdentifier: String {
        return self.type
    }
    
    var contentModificationDate: Date? {
        return self.lastModified
    }
    
}
