//
//  FileProviderItem.swift
//  Files
//
//  Created by Kris Foster on 7/11/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import MobileCoreServices
import FileProvider

func fileNameToUTI(fileName: String) -> String {
    let fileNameExtension = fileName.components(separatedBy: ".").last!
    let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileNameExtension as CFString, nil)
    if uti == nil {
        return kUTTypeItem as String
    }
    return uti!.takeUnretainedValue() as String
}

class FileProviderItem: NSObject, NSFileProviderItem {
    
    var name: String
    var parent: String
    var type: String
    var lastModified: Date
    
    init(name: String, isDir: Bool, isLink: Bool, lastModified: Date, parent: NSFileProviderItemIdentifier) {
        self.name = name
        self.parent = parent.rawValue
        if isDir {
            self.type = kUTTypeFolder as String
        } else if isLink {
            self.type = kUTTypeSymLink as String
        } else {
            self.type = fileNameToUTI(fileName: self.name)
        }
        self.lastModified = lastModified
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        // XXX self.name is a bad choice
        return NSFileProviderItemIdentifier(self.name)
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier(self.parent)
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        // Limit the capabilities, add new capabilities when we support them
        // https://developer.apple.com/documentation/fileprovider/nsfileprovideritemcapabilities
        return [ .allowsReading ]
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
