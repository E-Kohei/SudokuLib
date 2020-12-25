import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SudokuTests.allTests),
        testCase(NoteTests.allTests),
        testCase(SudokuSolverTests.allTests),
        testCase(SudokuManipulatorTests.allTests),
        testCase(SudokuMakerTests.allTests)
    ]
}
#endif
