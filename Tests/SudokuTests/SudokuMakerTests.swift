import XCTest
@testable import Sudoku

final class SudokuMakerTests: XCTestCase {
    func testSudokuMaker() {
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
        let sudoku = try! Sudoku(nums: nums, size: 3)
        
        print("make sudoku from solution")
        let puzzle1 = makeSudokuFromSolution(sudoku: sudoku)
        print(puzzle1)
        XCTAssert(solveSudokuWithTrials(sudoku: puzzle1).status == .solvable)
        
        let nums2 = [
            [0,1,0,9,0,0,0,0,4],
            [4,0,0,0,2,0,5,0,0],
            [0,0,7,0,0,8,0,3,0],
            [0,0,1,0,0,0,0,0,5],
            [0,9,0,0,0,0,0,8,0],
            [2,0,0,0,0,0,6,0,0],
            [0,6,0,7,0,0,1,0,0],
            [0,0,3,0,5,0,0,0,9],
            [8,0,0,0,0,4,0,2,0]
        ]
        let sudoku2 = try! Sudoku(nums: nums2, size: 3)
        
        print("transform sudoku randomly")
        let puzzle2 = sudoku2.copy()
        transformSudokuRandomly(sudoku: puzzle2)
        XCTAssert(analyzeSudoku(sudoku: puzzle2) == .solvable)
        print(puzzle2)
        
        print("transform sudoku keeping symmetry")
        let puzzle3 = sudoku2.copy()
        transformSudokuKeepingSymmetry(sudoku: puzzle3)
        XCTAssert(analyzeSudoku(sudoku: puzzle3) == .solvable)
        print(puzzle3)

        let nums3 = [
            [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
            [5,6,7,8,9,10,11,12,13,14,15,16,1,2,3,4],
            [9,10,11,12,13,14,15,16,1,2,3,4,5,6,7,8],
            [13,14,15,16,1,2,3,4,5,6,7,8,9,10,11,12],
            [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1],
            [6,7,8,9,10,11,12,13,14,15,16,1,2,3,4,5],
            [10,11,12,13,14,15,16,1,2,3,4,5,6,7,8,9],
            [14,15,16,1,2,3,4,5,6,7,8,9,10,11,12,13],
            [3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2],
            [7,8,9,10,11,12,13,14,15,16,1,2,3,4,5,6],
            [11,12,13,14,15,16,1,2,3,4,5,6,7,8,9,10],
            [15,16,1,2,3,4,5,6,7,8,9,10,11,12,13,14],
            [4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,3],
            [8,9,10,11,12,13,14,15,16,1,2,3,4,5,6,7],
            [12,13,14,15,16,1,2,3,4,5,6,7,8,9,10,11],
            [16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        ]
        let sudoku3 = try! Sudoku(nums: nums3, size: 4)
        
        print("make sudoku from solution")
        let puzzle4 = makeSudokuFromSolution(sudoku: sudoku3)
        print(puzzle4)
        XCTAssert(analyzeSudoku(sudoku: puzzle4) == .solvable)
        
        print("transform sudoku keeping symmetry")
        transformSudokuKeepingSymmetry(sudoku: puzzle4)
        print(puzzle4)
        XCTAssert(analyzeSudoku(sudoku: puzzle4) == .solvable)
    }
    
    static var allTests = [
        ("testSudokuMaker", testSudokuMaker)
    ]
}
