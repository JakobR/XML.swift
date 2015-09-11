//
//  Box.swift
//  LibXML
//
//  Created by Jakob Rath on 04/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation

final class Box<Wrapped> {
    let value: Wrapped

    init(_ value: Wrapped) {
        self.value = value
    }
}
