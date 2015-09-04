//
//  AppDelegate.swift
//  LibXML-App
//
//  Created by Jakob Rath on 29/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Cocoa
import XML

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        let dict_url = NSURL(fileURLWithPath: "/Users/jakob/code/Dictionary/Data/JMDict_small")

        print("Loading dictionary at \(dict_url)...")

        //var str = try NSString(contentsOfURL: dict_url, encoding: NSUTF8StringEncoding)
        //print(str.length)

        do {
            if let data = NSData(contentsOfURL: dict_url) {
                let options: XML.ParserOptions = [.ValidateDTD, .AttributeDefaults, .NoNetworkAccess]
                let doc = try XML.Document.create(data: data, options: options)

                for e in doc.internalDTD.entities {
                    print("Entity: \(e.name) \t\t-> \(e.content)")
                }

//                for node in doc.root.children {
//                    for node in node.children {
//                        for node in node.elements {
//                            if node.name == "gloss" {
//                                let name = node.name ?? "???"
//                                let lang = node.valueForAttribute("lang") ?? "???"
//                                let nslang = node.valueForAttribute("lang", namespace: "http://www.w3.org/XML/1998/namespace") ?? "???"
//                                let content = node.text ?? "???"
//                                print("Node: <" + name + ">" + content + "</>, lang = " + lang + ", ns-aware lang = " + nslang)
//                            }
//                        }
//                    }
//                }

                let xp = try XPath("//entry")
                try xp.evaluateOn(doc.root)
            }
        }
        catch {
            print("error")
        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

