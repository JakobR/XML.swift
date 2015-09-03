//
//  Error.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

public enum Error: ErrorType {
    /// A libxml2 allocation returned NULL.
    case MemoryError

    case UnknownEncoding

    case InvalidDocument

    case UnknownError // TODO: REMOVE
}
