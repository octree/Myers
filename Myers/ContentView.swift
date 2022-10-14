//
//  ContentView.swift
//  Myers
//
//  Created by Octree on 2022/10/14.
//

import NaturalLanguage
import SwiftUI

struct DiffPlayground: View {
    @State private var bob: String = ""
    @State private var alice: String = ""
    private var diff: [Diff<Substring>] {
        Myers(bob.words, alice.words).diff()
    }

    private var text: AttributedString {
        diff.map { $0.attributedString }
            .reduce(AttributedString(), +)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Bob").padding(.leading).font(.callout).foregroundColor(Color(white: 0.7))
            TextEditor(text: $bob)
            Divider()
            Text("Alice").padding(.leading).font(.callout).foregroundColor(Color(white: 0.7))
            TextEditor(text: $alice)
            Divider()
            Text("Diff").padding(.leading).font(.callout).foregroundColor(Color(white: 0.7))
            Text(text)
        }
        .font(.system(size: 16))
    }
}

extension String {
    var words: [Substring] {
        let tagger = NaturalLanguage.NLTagger(tagSchemes: [.tokenType])
        tagger.string = self
        var result = [Substring]()
        tagger.enumerateTags(in: startIndex ..< endIndex,
                             unit: .word,
                             scheme: .tokenType,
                             options: [.joinNames]) { _, range in
            result.append(self[range])
            return true
        }
        return result
    }
}

extension Diff where T: CustomStringConvertible {
    var attributedString: AttributedString {
        var text = AttributedString(value.description)
        switch type {
        case .delete:
            text.foregroundColor = .red
            text.backgroundColor = .red.opacity(0.1)
            text.strikethroughStyle = .single
            text.strikethroughColor = .red
        case .insert:
            text.foregroundColor = .green
            text.backgroundColor = .green.opacity(0.1)
        case .same:
            break
        }
        return text
    }
}

extension String {
    var lines: [String] {
        var lines: [String] = []
        enumerateLines { line, stop in
            lines.append(line)
        }
        return lines
    }
}
