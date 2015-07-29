//
//  AppDelegate.swift
//  LibXML-App
//
//  Created by Jakob Rath on 29/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Cocoa
import LibXML

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {

        print("Hello, World!")

        //let base_url = NSURL(fileURLWithPath: __FILE__).URLByDeletingLastPathComponent!.URLByDeletingLastPathComponent!.URLByDeletingLastPathComponent!
        //let dict_url = base_url.URLByAppendingPathComponent("Dictionary").URLByAppendingPathComponent("Data").URLByAppendingPathComponent("JMDict_small")
        let dict_url = NSURL(fileURLWithPath: "/Users/jakob/code/Dictionary/Data/JMDict_small")

        print("Loading dictionary at \(dict_url)...")

        //var str = try NSString(contentsOfURL: dict_url, encoding: NSUTF8StringEncoding)
        //print(str.length)

        do {
            let doc = try XMLDocument(url: dict_url)
            print(doc.root.children.count)
        }
        catch {
            print("error")
        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

