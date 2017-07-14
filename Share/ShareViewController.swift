//
//  ShareViewController.swift
//  Share
//
//  Created by Kris Foster on 7/10/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    var upspin: Upspin!
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        // Move into a constructor?
        do {
            upspin = try UpspinClientFromKeychain()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        // Upload the item to a hard coded name
        let inputItems = extensionContext?.inputItems
        
        // Iterate over the items and attachments and upload what we find
        for case let item as NSExtensionItem in inputItems!  {
            for case let attachment as NSItemProvider in item.attachments! {
                if attachment.hasItemConformingToTypeIdentifier("public.data") {
                    attachment.loadItem(forTypeIdentifier: "public.data", options: nil, completionHandler: putItem)
                }
            }
        }
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func putItem(provider: NSSecureCoding?, error: Error!) {
        let url = provider as! URL
        let fileName = url.lastPathComponent
        var data: Data?
        do {
            data = try Data(contentsOf: url)
        } catch {
            fatalError("Failed to get data from URL")
        }
        do {
            // TODO: Something better than just dumping into the user's root directory
            let userName = upspin.config.userName()
            let filePath = NSString.path(withComponents: [userName!, fileName])
            try self.upspin.client.put(filePath, data: data)
        } catch {
            fatalError("Could not put file")
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}
