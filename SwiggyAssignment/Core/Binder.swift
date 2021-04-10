//
//  Binder.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.
//

import Foundation

class Binding<T> {
    var value: T {
        didSet {
            listener?(value)
        }
    }
    private var listener: ((T) -> Void)?
    init(value: T) {
        self.value = value
    }
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}
