//
//  CLinkedList+libxml2.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import libxml2

extension _xmlNode: CLinkedListNext {
    var cLinkedListNext: UnsafeMutablePointer<_xmlNode> { return self.next }
}
