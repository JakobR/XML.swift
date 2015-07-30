//
//  Helper.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

protocol CLinkedListNext {
    var cLinkedListNext: UnsafeMutablePointer<Self> { get }
}

class CLinkedList<T : CLinkedListNext>: SequenceType {
    typealias Generator = CLinkedListGenerator<T>

    private var first: UnsafeMutablePointer<T>

    init(_ first: UnsafeMutablePointer<T>) {
        self.first = first
    }

    func generate() -> CLinkedList.Generator {
        return CLinkedListGenerator<T>(first)
    }
}

class CLinkedListGenerator<T : CLinkedListNext>: GeneratorType {
    private var _next: UnsafeMutablePointer<T>

    init(_ first: UnsafeMutablePointer<T>) {
        _next = first
    }

    func next() -> UnsafeMutablePointer<T>? {
        if _next == nil {
            return Optional<UnsafeMutablePointer<T>>()
        } else {
            let result = _next
            _next = _next.memory.cLinkedListNext
            return result
        }
    }
}
