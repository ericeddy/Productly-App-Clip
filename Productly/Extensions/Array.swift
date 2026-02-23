//
//  Array.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-21.
//

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

