//
//  CICOPublicPersistentService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/6/7.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation

private let kRootDirName = "cico_persistent"

public class PublicPersistentService: PersistentService {
    public static let shared: PublicPersistentService = {
        let rootDirURL = CICOPathAide.defaultPublicFileURL(withSubPath: kRootDirName)
        return PublicPersistentService.init(rootDirURL: rootDirURL)
    }()
    
    public override func clearAllPersistent() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
    
    public override func clearAllKVFile() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
    
    public override func clearAllKVDB() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
    
    public override func clearAllORMDB() -> Bool {
        print("[ERROR]: FORBIDDEN!")
        return false
    }
}
