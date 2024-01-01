import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CasePathMacros)
import CasePathMacros

let testMacros: [String: Macro.Type] = [
    "CasePathable": CasePathableMacro.self,
]
#endif

final class CasePathTests: XCTestCase {
    func testMacro() throws {
        #if canImport(CasePathMacros)
        assertMacroExpansion(
"""
@CasePathable
enum Action {
  case feature1(Feature1.Action)
  case feature2(Feature2.Action)
  case feature3
}
""",
expandedSource:
"""
enum Action {
  case feature1(Feature1.Action)
  case feature2(Feature2.Action)
  case feature3

    struct Cases {
        var feature1: CasePath<Action, Feature1.Action> {
            CasePath(embed: Action.feature1, extract: {
             guard case let .feature1(value) = $0 else {
                     return nil
                 }
                 return value
                }
            )
        }
        var feature2: CasePath<Action, Feature2.Action> {
            CasePath(embed: Action.feature2, extract: {
             guard case let .feature2(value) = $0 else {
                     return nil
                 }
                 return value
                }
            )
        }
        var feature3: CasePath<Action, Action> {
            CasePath(embed: {
                    $0
                }, extract: {
                    $0
                })
        }
    }
    static let cases = Cases()
}

extension Action: CasePathable {
}
""", macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

//import CasePath
//@CasePathable
//enum Action {
//    case feature1(String)
//    case feature2(String)
//}
