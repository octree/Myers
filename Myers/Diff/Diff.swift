//
//  Diff.swift
//  Myers
//
//  Created by Octree on 2022/1/31.
//

import Foundation

public struct Diff<T> {
    public enum `Type` {
        case insert(at: Int)
        case delete(at: Int)
        case same(old: Int, new: Int)
    }

    public var type: `Type`
    public var value: T
}

private struct _V {
    private var a: [Int]

    init(maxIndex largest: Int) {
        a = .init(repeating: 0, count: largest + 1)
    }

    @inline(__always) private static func transform(_ index: Int) -> Int {
        index <= 0 ? -index : (index &- 1)
    }

    subscript(_ index: Int) -> Int {
        get {
            a[_V.transform(index)]
        }
        set {
            a[_V.transform(index)] = newValue
        }
    }
}

public struct Myers<E: Equatable> {
    private let a: [E]
    private let b: [E]

    public init(_ a: [E], _ b: [E]) {
        self.a = a
        self.b = b
    }

    public func diff() -> [Diff<E>] {
        backtrace(shortestEdit())
    }

    private func backtrace(_ trace: [_V]) -> [Diff<E>] {
        var (x, y) = (a.count, b.count)
        var path: [Diff<E>] = []
        for (d, vertices) in trace.enumerated().reversed() {
            let k = x &- y
            let prevK: Int
            if k == -d || (k != d && vertices[k &- 1] < vertices[k &+ 1]) {
                prevK = k &+ 1
            } else {
                prevK = k &- 1
            }
            let prevX = vertices[prevK]
            let prevY = prevX &- prevK
            while x > prevX, y > prevY {
                path.append(.init(type: .same(old: x, new: y),
                                  value: a[x &- 1]))
                x &-= 1
                y &-= 1
            }
            if x == 0, y == 0 {
                return path.reversed()
            }
            if x == prevX {
                path.append(.init(type: .insert(at: y),
                                  value: b[y &- 1]))
            } else {
                path.append(.init(type: .delete(at: x),
                                  value: a[x &- 1]))
            }
            (x, y) = (prevX, prevY)
        }
        return path.reversed()
    }

    private func shortestEdit() -> [_V] {
        let maxX = a.count
        let maxY = b.count
        let max = maxX &+ maxY
        var vertices: _V = .init(maxIndex: 1)
        var trace = [_V]()
        var x = 0
        var y = 0
        for d in 0 ... max {
            let preV = vertices
            trace.append(preV)
            vertices = .init(maxIndex: d)
            for k in stride(from: -d, through: d, by: 2) {
                if k == -d || (k != d && preV[k &- 1] < preV[k &+ 1]) {
                    x = preV[k &+ 1]
                } else {
                    x = preV[k &- 1] &+ 1
                }
                y = x &- k
                while x < maxX, y < maxY, a[x] == b[y] {
                    x &+= 1
                    y &+= 1
                }
                vertices[k] = x
                if x >= maxX, y >= maxY {
                    return trace
                }
            }
            if x >= maxX, y >= maxY {
                break
            }
        }
        return trace
    }
}

extension Diff: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        switch type {
        case let .delete(x):
            return "- \(x)         \(value)"
        case let .insert(x):
            return "+      \(x)    \(value)"
        case let .same(old, new):
            return "  \(old)    \(new)    \(value)"
        }
    }
}
