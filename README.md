# XML.swift [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![GitHub license](https://img.shields.io/github/license/JakobR/XML.swift.svg)](https://raw.githubusercontent.com/JakobR/XML.swift/master/LICENSE.txt)

XML.swift is a Swift 2 wrapper of [libxml2](http://xmlsoft.org/).

It currently only supports a small subset of libxml2's functionality: parsing and validating XML data, read-only access to the XML tree, and XPath queries.
Contributions are, of course, welcome.

Credits to this [blog post of The Red Queen Coder](http://redqueencoder.com/wrapping-libxml2-for-swift/) for giving me a starting point on integrating libxml2 with Swift.


## Examples

### Loading a document

```swift
let data: NSData = /* ... */

do {
    let doc = try Document.create(data: data, options: [.ValidateDTD, .AttributeDefaults])
}
catch XML.Error.ParseError(let msg) {
    print("Error while parsing XML data: \(msg)")
}
catch XML.Error.InvalidDocument(let msg) {
    print("XML document is invalid: \(msg)")
}
```

### Accessing information about a node

```swift
let doc: Document = /* ... */
let node = doc.rootNode
print(node.name)
print(node.text)
print(node.children.count)  // All child nodes (including text nodes and all that)
print(node.elements.count)  // All child element nodes (correspond to XML tags: <element/>)
print(node.attributes)      // List of attributes on the node
print(node.valueForAttribute("lang", namespace: "http://www.w3.org/XML/1998/namespace"))
```

### XPath queries

Note that libxml2 only supports XPath 1.0.

```swift
let doc: Document = /* ... */
do {
    // Compile the query
    let xp = try XPath("//xpath/query/goes/here")
    // Evaluate on a document or a node
    let result = try xp.evaluateOn(doc)
    
    // Cast the value to the desired type...
    print(result.asBool())
    print(result.asNumber())
    print(result.asString())
    print(result.asNodeSet())

    // ...or unwrap with switch:
    switch result.value {
    case .NodeSet(let nodes):     // ...
    case .BoolValue(let value):   // ...
    case .NumberValue(let value): // ...
    case .StringValue(let value): // ...
    default: // ...
    }
}
catch let e as XPathError {
    print("XPath error: \(e.message)")
}
```
