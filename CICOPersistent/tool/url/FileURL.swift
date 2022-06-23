//
//  CICOURL.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/8/29.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOAutoCodable

public enum FileURLType: String, Codable {
    case unknown
    case documents
    case library
    case tmp
    case app
}

public struct FileURL: Codable {
    public var fileURL: URL

    public static func transferPropertyToFileURL(type: FileURLType, relativePath: String) -> URL? {
        switch type {
        case .unknown:
            if relativePath.count == 0 {
                print("[WARN]: Empty file URL.")
                return URL.init(string: "https://www.cico.com/unknown")
            } else {
                return URL.init(string: relativePath)
            }
        case .documents:
            return PathAide.docFileURL(withSubPath: relativePath)
        case .library:
            return PathAide.libFileURL(withSubPath: relativePath)
        case .tmp:
            return PathAide.tempFileURL(withSubPath: relativePath)
        case .app:
            return Bundle.main.bundleURL.appendingPathComponent(relativePath)
        }
    }

    public static func transferURLToProperty(fileURL: URL?) -> (FileURLType, String) {
        var type = FileURLType.unknown
        var relativePath = ""

        guard let url = fileURL, url.isFileURL else {
            relativePath = fileURL?.absoluteString ?? ""
            return (type, relativePath)
        }

        let path = url.path
        let docPath = PathAide.docPath(withSubPath: nil)
        let libPath = PathAide.libPath(withSubPath: nil)
        let tmpPath = PathAide.tempPath(withSubPath: nil)
        let appPath = Bundle.main.bundleURL.path
        let originalAppPath = "/var/containers/Bundle/Application"
        
        /// 修正一下路径，之前app的path开头是originalAppPath，不知道从哪个系统版本开始，
        /// 前面加了/private的路径，导致下面判断资源在app内出错
        var fixedAppPath = appPath
        if let range = originalAppPath.range(of: originalAppPath) {
            fixedAppPath.removeSubrange(0..<range.lowerBound)
        }
        
        if path.hasPrefix(docPath) {
            type = .documents
            if path.count > docPath.count {
                relativePath = String(path.dropFirst(docPath.count + 1))
            }
        } else if path.hasPrefix(libPath) {
            type = .library
            if path.count > libPath.count {
                relativePath = String(path.dropFirst(libPath.count + 1))
            }
        } else if path.hasPrefix(tmpPath) {
            type = .tmp
            if path.count > tmpPath.count {
                relativePath = String(path.dropFirst(tmpPath.count + 1))
            }
        } else if path.hasPrefix(appPath) {
            type = .app
            if path.count > appPath.count {
                relativePath = String(path.dropFirst(appPath.count + 1))
            }
        } else if path.hasPrefix(fixedAppPath) {
            type = .app
            if path.count > fixedAppPath.count {
                relativePath = String(fixedAppPath.dropFirst(appPath.count + 1))
            }
        }

        return (type, relativePath)
    }

    public init?(type: FileURLType, relativePath: String) {
        if let fileURL = FileURL.transferPropertyToFileURL(type: type, relativePath: relativePath) {
            self.init(fileURL: fileURL)
        } else {
            return nil
        }
    }

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
}

extension FileURL {
    enum CodingKeys: String, CodingKey {
        case type
        case relativePath
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(FileURLType.self, forKey: .type)
        let relativePath = try container.decode(String.self, forKey: .relativePath)

        guard let fileURL = FileURL.transferPropertyToFileURL(type: type, relativePath: relativePath) else {
            print("[ERROR]: Invalid file url.")
            throw CodableError.decodeFailed
        }

        self.fileURL = fileURL
    }

    public func encode(to encoder: Encoder) throws {
        let (type, relativePath) = FileURL.transferURLToProperty(fileURL: self.fileURL)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(relativePath, forKey: .relativePath)
    }
}
