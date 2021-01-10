import XCTest
@testable import Sudoku

final class SudokuTests: XCTestCase {
    func testSudoku() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(Sudoku().text, "Hello, World!")
        
        let nums = [
            [1,2,3,4,5,6,7,8,9],
            [4,5,6,7,8,9,1,2,3],
            [7,8,9,1,2,3,4,5,6],
            [2,3,4,5,6,7,8,9,1],
            [5,6,7,8,9,1,2,3,4],
            [8,9,1,2,3,4,5,6,7],
            [3,4,5,6,7,8,9,1,2],
            [6,7,8,9,1,2,3,4,5],
            [9,1,2,3,4,5,6,7,8]
        ]
        do {
            let sudoku: Sudoku = try Sudoku(nums: nums, size: 3)
            for i in 0..<9 {
                for j in 0..<9 {
                    XCTAssert(sudoku[i,j] == nums[i][j])
                    XCTAssert(sudoku.isFixedCell(row: i, col: j) == true)
                }
            }
            XCTAssert(sudoku.isSolved() == true)
            print(sudoku)
        }
        catch let e as InvalidSudokuSizeError {
            print(e.message)
        }
        catch {
            print("Unknown error")
        }
        
        
        let nums2 = [
            [0,7,0,0,0,0,9,0,0],
            [1,0,0,0,0,5,0,3,0],
            [0,0,2,0,3,0,0,0,5],
            [6,0,0,7,0,0,3,0,0],
            [0,9,0,0,8,0,0,4,0],
            [0,0,1,0,0,2,0,0,9],
            [8,0,0,0,4,0,1,0,0],
            [0,4,0,5,0,0,0,0,2],
            [0,0,9,0,0,0,0,7,0]
        ]
        do {
            let sudoku2 = try Sudoku(nums: nums2, size: 3)
            print(sudoku2)
            XCTAssert(sudoku2.isFixedCell(row: 0, col: 1) == true)
            XCTAssert(sudoku2.isFixedCell(row: 0, col: 0) == false)
            XCTAssert(sudoku2.getRow(row: 5) == [0,0,1,0,0,2,0,0,9])
            XCTAssert(sudoku2.getCol(col: 7) == [0,3,0,0,4,0,0,0,7])
            XCTAssert(sudoku2.getBlockAsArray(block: 6) == [8,0,0,0,4,0,0,0,9])
            XCTAssert(sudoku2.getBlock(block: 2) == [[9,0,0],[0,3,0],[0,0,5]])
            
            let copy = sudoku2.copy()
            copy[0,0] = 9
            print(copy)
            print(sudoku2)
            
            let result = sudoku2.setNumber(row: 8, col: 7, number: 1)
            XCTAssert(sudoku2[8,7] == 7)
            XCTAssert(result == false)
            
            XCTAssert(sudoku2.getBlockNumberFromLoc(row: 7, col: 7) == 8)
            
            sudoku2.fixNumbers()
            XCTAssert(sudoku2.isFixedCell(row: 0, col: 1) == true)
            XCTAssert(sudoku2.isFixedCell(row: 2, col: 2) == true)
            XCTAssert(sudoku2.isFixedCell(row: 5, col: 6) == false)
            
            sudoku2.setNumber(row: 0, col: 7, number: 5)
            sudoku2.setNumber(row: 3, col: 2, number: 9)
            XCTAssert(sudoku2[0,7] == 5)
            XCTAssert(sudoku2[3,2] == 9)
            sudoku2.resetSudoku()
            XCTAssert(sudoku2[0,7] == 0)
            XCTAssert(sudoku2[3,2] == 0)
            sudoku2.resetFixedNumbers()
            XCTAssert(sudoku2.isFixedCell(row: 1, col: 6) == false)
            
        }
        catch let e as InvalidSudokuSizeError {
            print(e.message)
        }
        catch {
            print("Unknown error")
        }
        
        XCTAssert(getBlockCells(size: 3, block: 4) == [Cell(row: 3, col: 3),Cell(row: 3, col: 4),Cell(row: 3, col: 5),Cell(row: 4, col: 3),Cell(row: 4, col: 4),Cell(row: 4, col: 5),Cell(row: 5, col: 3),Cell(row: 5, col: 4),Cell(row: 5, col: 5)])
        XCTAssert(getRowCells(size: 4, row: 5) == [Cell(row: 5, col: 0),Cell(row: 5, col: 1),Cell(row: 5, col: 2),Cell(row: 5, col: 3),Cell(row: 5, col: 4),Cell(row: 5, col: 5),Cell(row: 5, col: 6),Cell(row: 5, col: 7),Cell(row: 5, col: 8),Cell(row: 5, col: 9),Cell(row: 5, col: 10),Cell(row: 5, col: 11),Cell(row: 5, col: 12),Cell(row: 5, col: 13),Cell(row: 5, col: 14),Cell(row: 5, col: 15)])
        XCTAssert(getColCells(size: 2, col: 3) == [Cell(row: 0, col: 3),Cell(row: 1, col: 3),Cell(row: 2, col: 3),Cell(row: 3, col: 3)])
        XCTAssert(Set(getCellsFromRowsAndCols(rows: [2,3,6,7], cols: [0,1,3])) == Set([Cell(row: 2, col: 0), Cell(row: 2, col: 1), Cell(row: 2, col: 3), Cell(row: 3, col: 0), Cell(row: 3, col: 1), Cell(row: 3, col: 3), Cell(row: 6, col: 0), Cell(row: 6, col: 1), Cell(row: 6, col: 3), Cell(row: 7, col: 0), Cell(row: 7, col: 1), Cell(row: 7, col: 3),]))
        XCTAssert(Sudoku.getBlockNumberFromLoc(row: 3, col: 5, size: 3) == 4)
        XCTAssert(Sudoku.getBlockNumberFromLoc(row: 6, col: 8, size: 3) == 8)
        XCTAssert(Sudoku.getBlockNumberFromLoc(row: 11, col: 19, size: 5) == 13)
        
        let sudoku3 = Sudoku(size: 3)
        let sudoku4 = Sudoku(size: 3)
        sudoku3[1,3] = 8
        try! Sudoku.copySudoku(from: sudoku3, to: sudoku4)
        XCTAssert(sudoku4[1,3] == 8)
        let sudoku5 = Sudoku(size: 5)
        do {
            try Sudoku.copySudoku(from: sudoku3, to: sudoku5)
        }
        catch let e as InvalidSudokuSizeError {
            XCTAssert(e.message == "Sudoku size mismatch")
        }
        catch {
            XCTAssert(true == false)
        }
     }

    static var allTests = [
        ("testSudoku", testSudoku),
    ]
}

