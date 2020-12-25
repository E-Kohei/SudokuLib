import XCTest
@testable import Sudoku

final class NoteTests:XCTestCase {
    func testNote() {
        var note1 = Note(size: 3)
        XCTAssert(note1[0,0] == 0)
        XCTAssert(note1.getRow(row: 0) == [0,0,0,0,0,0,0,0,0])
        XCTAssert(note1.getCol(col: 8) == [0,0,0,0,0,0,0,0,0])
        
        note1.setNoteArray(row: 1, col: 1, noteIndicators: [1,1,0,0,0,0,0,1,0])
        XCTAssert(note1.getNoteArray(row: 1, col: 1) == [1,1,0,0,0,0,0,1,0])
        
        note1.toggleNoteNumber(row: 8, col: 5, m: 7)
        XCTAssert(note1.getNoteArray(row: 8, col: 5) == [0,0,0,0,0,0,1,0,0])
        note1.toggleNoteNumber(row: 1, col: 1, m: 8)
        XCTAssert(note1.getNoteArray(row: 1, col: 1) == [1,1,0,0,0,0,0,0,0])
    }
    
    static var allTests = [
        ("testNote", testNote)
    ]
}
