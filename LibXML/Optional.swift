//
//  Optional.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

extension Optional {
    func map<U>(@noescape f: T throws -> U) throws -> U? {
        switch (self) {
        case .None: return .None
        case .Some(let x): return .Some(try f(x))
        }
    }
}
