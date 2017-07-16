//
//  FileProviderExtension.swift
//  Files
//
//  Created by Kris Foster on 7/11/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import FileProvider

class FileProviderExtension: NSFileProviderExtension {
    
    // MARK: Properties
    
    // Using jngl for now, maybe upspin is better?
    let scheme = "jngl"
    var upspin: Upspin!
    
    // This is our file provider manager, it handles things like placeholders on disk
    var fileProviderManager: NSFileProviderManager!
    var fileManager: FileManager!
    
    override init() {
        super.init()
        
        fileProviderManager = NSFileProviderManager.default()
        fileManager = FileManager()
            
        do {
            upspin = try UpspinClientFromKeychain()
        } catch let error {
            // TODO: Handle this better? The keychain may be empty if the user just installed the app.
            print("FileProviderExtension could not get upspin client: \(error)")
            fatalError(error.localizedDescription)
        }
    }
    
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        // resolve the given identifier to a record in the model
        // TODO: implement the actual lookup in a proper database
        
        // XXX: Hacky hacky, we'll fake this up for the moment. It slams a bunch of calls to the upspin server.
        let dirEntry = try upspin.client.glob(identifier.rawValue)
        let name = dirEntry.name()!
        let isDir = dirEntry.isDir()
        let isLink = dirEntry.isLink()
        let lastModified = dateFrom(unixTime: dirEntry.lastModified())
        
        return FileProviderItem(name: name, isDir: isDir, isLink: isLink, lastModified: lastModified, parent: NSFileProviderItemIdentifier.rootContainer)
    }
    
    func fileName(from identifier: NSFileProviderItemIdentifier) -> String {
        // This is the last component in the identifier
        // e.g. user@email.com/somedir/somefile.txt
        let components = identifier.rawValue.components(separatedBy: "/")
        return components[components.count - 1]
    }
    
    func fileName(from rawValue: String) -> String {
        // This is the last component in the string
        // e.g. user@email.com/somedir/somefile.txt
        let components = rawValue.components(separatedBy: "/")
        return components[components.count - 1]
    }
    
    /*
     Our URLs follow this schema:
     
     URL: file://baseURL/user@email.com/somedir/somefile.txt/somefile.txt
          |- base url -| |- item identifier -----------| | filename |
           fileProviderManager.documentStorageURL
     */
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        // We want to return the URL on disk for this item
        
        // resolve the given identifier to a file on disk
        guard let thisItem = try? item(for: identifier) else {
            return nil
        }
        
        let perItemDirectory = fileProviderManager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
        let filename = fileName(from: thisItem.filename)
        let itemUrl = perItemDirectory.appendingPathComponent(filename, isDirectory: false)
        
        return itemUrl
    }
    
    func itemIdentifierFrom(url: URL) -> NSFileProviderItemIdentifier {
        // We want to return an item identifier given an URL
        return NSFileProviderItemIdentifier(identifierFrom(url: url))
    }
    
    func identifierFrom(url: URL) -> String {
        // We want to return an item identifier given an URL
        // Split off the base URL and the filename to get the raw identifier
        let baseComponentCount = fileProviderManager.documentStorageURL.pathComponents.count
        let identifierComponents = Array(url.pathComponents[baseComponentCount ... url.pathComponents.count - 2])
        let identifier = NSString.path(withComponents: identifierComponents)
        return identifier
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // resolve the given URL to a persistent identifier using a database (which we don't have yet)
        return itemIdentifierFrom(url: url)
    }
    
    func placeholderDir(from url: URL) -> URL {
        // We want to strip off the filename and return the rest
        let components = url.path.components(separatedBy: "/")
        let dir = components[0 ... components.count - 2].joined(separator: "/")
        return URL(fileURLWithPath: dir)
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        // After writing the placeholder to disk, call the provided completion handler.
        // If any errors occur during this process, pass the error to the completion handler.
        // The system then passes the error back to the original coordinated read or write.
        
        let identifier = itemIdentifierFrom(url: url)
        
        var thisItem: NSFileProviderItem?
        do {
            thisItem = try item(for: identifier)
        } catch let error {
            print("providePlaceholder: \(error)")
            completionHandler(error)
            return
        }
        
        do {
            let dir = placeholderDir(from: url)
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("providePlaceholder: \(error)")
            completionHandler(error)
            return
        }
        
        do {
            try NSFileProviderManager.writePlaceholder(at: url, withMetadata: thisItem!)
        } catch let error {
            print("providePlaceholder: \(error)")
            completionHandler(error)
            return
        }
        
        completionHandler(nil)
    }
    
    override func startProvidingItem(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        print("FileProviderExtension: startProvidingItem for \(url)")
        
        // TODO: Something smarter and more efficient than downloading a fresh copy on each request
        let identifier = identifierFrom(url: url)
        var data: Data!
        do {
            data = try upspin.client.get(identifier)
        } catch let error {
            print("Upspin failed to get \(identifier)")
            completionHandler(error)
            return
        }
        
        // Save the file to url. providePlaceholder already created the necessary directories.
        do {
            // XXX: Do we want to set atomic here?
            try data.write(to: url)
        } catch let error {
            print("Failed to write data to \(url)")
            completionHandler(error)
            return
        }
        
        completionHandler(nil)
    }
    
    
    override func itemChanged(at url: URL) {
        print("Not implemented: FileProviderExtension: itemChanged")
        
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /* TODO:
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
    }
    
    override func stopProvidingItem(at url: URL) {
        print("Not implemented: FileProviderExtension: stopProvidingItem")
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        
        // TODO: look up whether the file has local changes
        let fileHasLocalChanges = false
        
        if !fileHasLocalChanges {
            // remove the existing file to free up space
            do {
                _ = try FileManager.default.removeItem(at: url)
            } catch {
                // Handle error
            }
            
            // write out a placeholder to facilitate future property lookups
            self.providePlaceholder(at: url, completionHandler: { error in
                // TODO: handle any error, do any necessary cleanup
            })
        }
    }
    
    // MARK: - Actions
    
    /* TODO: implement the actions for items here
     each of the actions follows the same pattern:
     - make a note of the change in the local model
     - schedule a server request as a background task to inform the server of the change
     - call the completion block with the modified item in its post-modification state
     */
    
    override func createDirectory(withName directoryName: String, inParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: createDirectory")
        completionHandler(nil, nil)
    }
    
    override func deleteItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (Error?) -> Void) {
        print("Not implemented: deleteItem")
        completionHandler(nil)
    }
    
    override func importDocument(at fileURL: URL, toParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: importDocument")
        completionHandler(nil, nil)
    }
    
    override func renameItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, toName itemName: String, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: renameItem")
        completionHandler(nil, nil)
    }
    
    override func reparentItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, toParentItemWithIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: reparentItem")
        completionHandler(nil, nil)
    }
    
    override func setFavoriteRank(_ favoriteRank: NSNumber?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: setFavoriteRank")
        completionHandler(nil, nil)
    }
    
    override func setLastUsedDate(_ lastUsedDate: Date?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: setLastUsedDate")
        completionHandler(nil, nil)
    }
    
    override func setTagData(_ tagData: Data?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: setTagData")
        completionHandler(nil, nil)
    }
    
    override func trashItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: trashItem")
        completionHandler(nil, nil)
    }
    
    override func untrashItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, toParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier?, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        print("Not implemented: untrashItem")
        completionHandler(nil, nil)
    }
    
    // MARK: - Enumeration
    
    override func enumerator(forContainerItemIdentifier containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        var maybeEnumerator: NSFileProviderEnumerator? = nil
        
        switch containerItemIdentifier {
        case .rootContainer:
            maybeEnumerator = RootContainerEnumerator(enumeratedItemIdentifier: containerItemIdentifier, upspin: upspin)
        case .workingSet:
            maybeEnumerator = WorkingSetEnumerator(enumeratedItemIdentifier: containerItemIdentifier, upspin: upspin)
        default:
            maybeEnumerator = DirectoryEnumerator(enumeratedItemIdentifier: containerItemIdentifier, upspin: upspin)
        }
        
        guard let enumerator = maybeEnumerator else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:])
        }
        return enumerator
    }
    
}
