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
    static func fromCString(cs: UnsafePointer<xmlChar>) -> String? {
        return String.fromCString(UnsafePointer<CChar>(cs))
    }
}