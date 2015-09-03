//
//  String.swift
//  LibXML
//
//  Created by Jakob Rath on 03/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2

extension String {
    /// Creates a new Swift string by copying an existing libxml2 string.
    /// Returns nil if the libxml2 string is NULL.
    ///
    /// (Aborts the program if the libxml2 string is invalid.)
    static func fromXMLString(cs: UnsafePointer<xmlChar>) -> String? {
        // No string there? Return nil
        guard cs != nil else { return nil }
        // libxml2 uses UTF-8 internally. If String.fromCString returns nil, a serious error occurred somewhere. Don't swallow that.
        switch String.fromCString(UnsafePointer<CChar>(cs)) {
        case .None: fatalError("String.fromXMLString: libxml2 string is invalid (contains ill-formed UTF-8 code sequences).")
        case .Some(let str): return str
        }
    }
}