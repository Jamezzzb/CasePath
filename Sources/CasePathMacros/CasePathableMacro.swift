import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum CasePathableMacro: MemberMacro {
    public static func expansion<D: DeclGroupSyntax>(
        of node: AttributeSyntax,
        providingMembersOf declaration: D,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let elements = declaration
            .memberBlock
            .members
            .flatMap {
                $0.decl.as(EnumCaseDeclSyntax.self)?.elements ?? []
            }
        let rootTypeName = declaration.as(EnumDeclSyntax.self)?.name.text ?? ""
        let casePathProperties = elements.map { element in
            guard let valueType = element.parameterClause?.parameters.first?.type.description
            else {
                return "var \(element.name.text): CasePath<\(rootTypeName), \(rootTypeName)> {\n" +
                "CasePath(embed: { $0 }, extract: { $0 })\n}"
            }
            return "var \(element.name.text): CasePath<\(rootTypeName), \(valueType)> {\n" +
            "CasePath(" +
            "embed: \(rootTypeName).\(element.name.text)," +
            "extract: {\n guard case let .\(element.name)(value) = $0 " +
            "else { return nil }\nreturn value\n}\n)\n}"
        }
        return [
"""
struct Cases {
\(raw: casePathProperties.joined(separator: "\n"))
}
static let cases = Cases()
"""
        ]
    }
}

extension CasePathableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let rootTypeName = declaration.as(EnumDeclSyntax.self)?.name.text ?? ""
        return [
            try! ExtensionDeclSyntax
                .init("extension \(raw: rootTypeName): CasePathable {}")
        ]
    }
}

@main
struct CasePathPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [CasePathableMacro.self]
}
