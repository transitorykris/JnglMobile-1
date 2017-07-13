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
    // TODO: register the jngl scheme
    let scheme = "jngl"
    var upspin: Upspin!
    
    //var fileManager = FileManager()
    
    func createUpspinClient() {
        // Try to get our user's config from the Keychain and create our client
        let keychain = Keychain()
        var data: Data!
        do {
            data = try keychain.getKeychainItem()
        } catch {
            fatalError("No config found in keychain")
        }
        do {
            let propertyListDecoder = PropertyListDecoder()
            upspin = try propertyListDecoder.decode(Upspin.self, from: data!)
        } catch {
            fatalError("Could not decode into an Upspin object")
        }
    }
    
    override init() {
        super.init()
        
        createUpspinClient()
    }
    
    func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem? {
        print("Not implemented: FileProviderExtension: item \(identifier)")
        
        // resolve the given identifier to a record in the model
        
        // TODO: implement the actual lookup
        return nil
    }
    
    func fileURLFrom(path: String) -> URL {
        var url = URLComponents()
        url.scheme = scheme
        url.path = NSString.path(withComponents: [upspin.config.userName(), path])
        return url.url!
    }
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        /*
        // resolve the given identifier to a file on disk
        guard let item = try? item(for: identifier) else {
            print("FileProviderExtension: urlForItem returning nil")
            return nil
        }
         
        // in this implementation, all paths are structured as <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default()
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
         
        return perItemDirectory.appendingPathComponent(item.filename, isDirectory:false)
         */
        
        let url = fileURLFrom(path: identifier.rawValue)
        print("FileProviderExtension: urlForItem returning \(String(describing: url))")
        return url
    }
    
    func identifierFrom(url: URL) -> NSFileProviderItemIdentifier {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        return NSFileProviderItemIdentifier(components!.path)
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        /*
        // resolve the given URL to a persistent identifier using a database
        let pathComponents = url.pathComponents
        
        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)
        
        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
         */
        
        let identifier = identifierFrom(url: url)
        print("FileProviderExtension: persistentIdentifierForItem \(identifier)")
        return identifier
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        print("Not implemented: FileProviderExtension: providePlaceholder at \(url.absoluteString)")
        
        // Override this method to provide a placeholder for the given URL
        
        // After writing the placeholder to disk, call the provided completion handler.
        // If any errors occur during this process, pass the error to the completion handler.
        // The system then passes the error back to the original coordinated read or write.
        
        // If the placeholder was successfully written to disk, this value is nil.
        // Otherwise, it holds an NSError object describing the error.
        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
    }
    
    override func startProvidingItem(at url: URL, completionHandler: ((_ error: Error?) -> Void)?) {
        print("Not implemented: FileProviderExtension: startProvidingItem")
        
        // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
        
        /* TODO:
         This is one of the main entry points of the file provider. We need to check whether the file already exists on disk,
         whether we know of a more recent version of the file, and implement a policy for these cases. Pseudocode:
         
         if !fileOnDisk {
             downloadRemoteFile()
             callCompletion(downloadErrorOrNil)
         } else if fileIsCurrent {
             callCompletion(nil)
         } else {
             if localFileHasChanges {
                 // in this case, a version of the file is on disk, but we know of a more recent version
                 // we need to implement a strategy to resolve this conflict
                 moveLocalFileAside()
                 scheduleUploadOfLocalFile()
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             } else {
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             }
         }
         */
        
        completionHandler?(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
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
