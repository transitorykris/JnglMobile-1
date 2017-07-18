//
//  WorkingSetEnumerator.swift
//  Files
//
//  Created by Kris Foster on 7/12/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import FileProvider
import Spinner

class WorkingSetEnumerator: FileProviderEnumerator {
    // Not implemented
    
    // The working set should contain things like recently accessed items
    // Note: the documents in this set will be indexed by Spotlight!
    
    deinit {
        print("WorkingSetEnumerator is being deallocated")
    }
}

