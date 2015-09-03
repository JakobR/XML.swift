//
//  Helper.swift
//  LibXML
//
//  Created by Jakob Rath on 03/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation

private class Helper {
}

func LoadDataForResource(name: String?, withExtension ext: String?) -> NSData?
{
    guard let url = NSBundle(forClass: Helper.self).URLForResource(name, withExtension: ext) else { return nil }
    return NSData(contentsOfURL: url)
}