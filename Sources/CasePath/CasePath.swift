@attached(member, names: named(Cases), named(cases))
@attached(extension, conformances: CasePathable)

public macro CasePathable() = #externalMacro(
    module: "CasePathMacros",
    type: "CasePathableMacro"
)
