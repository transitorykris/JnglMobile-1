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
func fileNameToUTI(fileName: String) -> CFString {
    let fileNameExtension = fileName.components(separatedBy: ".").last!
    let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileNameExtension as CFString, nil)
    if uti == nil {
        return kUTTypeItem
    }
    return uti!.takeUnretainedValue()
}

class FileProviderItem: NSObject, NSFileProviderItem {
    
    // MARK: Properties
    var name: String
    var parent: String
    var type: CFString
    var size: NSNumber
    var lastModified: Date
    
    init(dirEntry: SpinnerDirEntry, parent: NSFileProviderItemIdentifier) {
        // Set ourselves up using the Upspin directory entry
        self.name = dirEntry.name()
        self.parent = parent.rawValue
        
        if dirEntry.isDir() {
            self.type = kUTTypeFolder
        } else if dirEntry.isLink() {
            self.type = kUTTypeSymLink
        } else {
            self.type = fileNameToUTI(fileName: self.name)
        }
        
        self.size = dirEntry.size() as NSNumber
        self.lastModified = dateFrom(unixTime: dirEntry.lastModified())
        
        print("\(self.name) item initialized")
    }
    
    deinit {
        print("\(name) item is being deallocated")
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
        switch self.type {
        case kUTTypeFolder:
            // TODO: .allowsDeleting (only if dir is empty), .allowTrashing(?), .allowsWriting
            return [ .allowsAddingSubItems, .allowsContentEnumerating, .allowsReading ]
        case kUTTypeSymLink:
            // TODO: figure out what to do here. This could either be a folder or a file.
            return []
        default:
            // Everything else is a plain old file
            // TODO: .allowsDeleting, .allowsRenaming, .allowsReparenting, .allowsTrashing(?), .allowsWriting
            return [ .allowsReading ]
        }
    }
    
    var filename: String {
        return name
    }
    
    var documentSize: NSNumber? {
        return self.size
    }
    
    var typeIdentifier: String {
        return self.type as String
    }
    
    var contentModificationDate: Date? {
        return self.lastModified
    }
    
}
