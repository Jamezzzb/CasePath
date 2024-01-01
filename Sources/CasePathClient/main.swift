import CasePath


//let (result, code) = #stringify(a + b)

//print("The value \(result) was produced by the code \"\(code)\"")
@CasePathable
enum Action {
    case feature1(Int)
    case feature2(String)
    case feature3
}
