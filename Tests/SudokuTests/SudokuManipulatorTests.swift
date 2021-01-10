import XCTest
@testable import Sudoku

final class SudokuManipulatorTests: XCTestCase {
    func testSudokuManipulator() {
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
        print(sudoku)
        
        let permuteNumbersSudoku = sudoku.copy()
        permuteNumbers(sudoku: permuteNumbersSudoku, permutation: [1:9, 2:8, 3:7, 4:6, 5:5, 6:4, 7:3, 8:2, 9:1])
        print("permuteNumbersSudoku")
        print(permuteNumbersSudoku)
        XCTAssert(permuteNumbersSudoku[0,0] == 9)
        XCTAssert(permuteNumbersSudoku[7,7] == 6)
        
        let permuteNumbersSudoku2 = sudoku.copy()
        permuteNumbers(sudoku: permuteNumbersSudoku2, permutation: [1:3, 2:2, 3:9, 4:7, 5:6, 6:8, 7:4, 8:5, 9:1])
        print("permuteNumbersSudoku2")
        print(permuteNumbersSudoku2)
        XCTAssert(permuteNumbersSudoku2[0,0] == 3)
        XCTAssert(permuteNumbersSudoku2[7,7] == 7)
        XCTAssert(permuteNumbersSudoku2[3,7] == 1)
        
        let reflectedByVertical = sudoku.copy()
        reflectSudoku(sudoku: reflectedByVertical, axis: .vertical)
        print("reflectedByVertical")
        print(reflectedByVertical)
        XCTAssert(reflectedByVertical[0,8] == 1)
        XCTAssert(reflectedByVertical[4,5] == 8)
        XCTAssert(reflectedByVertical[7,4] == 1)
        
        let reflectedByHorizontal = sudoku.copy()
        reflectSudoku(sudoku: reflectedByHorizontal, axis: .horizontal)
        print("reflectedByHorizontal")
        print(reflectedByHorizontal)
        XCTAssert(reflectedByHorizontal[8,3] == 4)
        XCTAssert(reflectedByHorizontal[4,5] == 1)
        XCTAssert(reflectedByHorizontal[7,4] == 8)
        
        let reflectedByDiagonal = sudoku.copy()
        reflectSudoku(sudoku: reflectedByDiagonal, axis: .diagonal)
        print("reflectedByDiagonal")
        print(reflectedByDiagonal)
        XCTAssert(reflectedByDiagonal[5,8] == 5)
        XCTAssert(reflectedByDiagonal[4,5] == 3)
        XCTAssert(reflectedByDiagonal[6,6] == 9)
        
        let rotated = sudoku.copy()
        rotateSudoku(sudoku: rotated, numRotation: 3)
        print("rotated")
        print(rotated)
        XCTAssert(rotated[1,1] == 7)
        XCTAssert(rotated[4,5] == 6)
        XCTAssert(rotated[4,4] == 9)
        
        let blockRowsPermuted = sudoku.copy()
        permuteBlockRows(sudoku: blockRowsPermuted, permutation: [0:2, 1:0, 2:1])
        print("blockRowsPermuted")
        print(blockRowsPermuted)
        XCTAssert(blockRowsPermuted[0,0] == 2)
        XCTAssert(blockRowsPermuted[4,5] == 2)
        XCTAssert(blockRowsPermuted[7,5] == 9)
        
        let blockColsPermuted = sudoku.copy()
        permuteBlockCols(sudoku: blockColsPermuted, permutation: [0:1, 1:2, 2:0])
        print("blockColsPermuted")
        print(blockColsPermuted)
        XCTAssert(blockColsPermuted[0,0] == 7)
        XCTAssert(blockColsPermuted[4,5] == 7)
        XCTAssert(blockColsPermuted[7,5] == 8)
        
        let oneBlockRowPermuted = sudoku.copy()
        permuteOneBlockRow(sudoku: oneBlockRowPermuted, bRow: 1, permutation: [0:2, 1:0, 2:1])
        print("oneBlockRowPermuted")
        print(oneBlockRowPermuted)
        XCTAssert(oneBlockRowPermuted[3,2] == 7)
        XCTAssert(oneBlockRowPermuted[4,5] == 4)
        XCTAssert(oneBlockRowPermuted[7,5] == 2)
        
        let oneBlockColPermuted = sudoku.copy()
        permuteOneBlockCol(sudoku: oneBlockColPermuted, bCol: 0, permutation: [0:1, 1:0, 2:2])
        print("oneBlockColPermuted")
        print(oneBlockColPermuted)
        XCTAssert(oneBlockColPermuted[3,2] == 4)
        XCTAssert(oneBlockColPermuted[4,5] == 1)
        XCTAssert(oneBlockColPermuted[7,0] == 7)
        
        
        
        let nums2 = [
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
        let sudoku2 = try! Sudoku(nums: nums2, size: 4)
        print(sudoku2)
        XCTAssert(sudoku2.isSolved() == true)
        
        let reflected2 = sudoku2.copy()
        reflectSudoku(sudoku: reflected2, axis: .vertical)
        XCTAssert(reflected2[0,0] == 16)
        XCTAssert(reflected2[8,7] == 11)
        XCTAssert(reflected2[15,14] == 1)
        
        let rotated2 = sudoku2.copy()
        rotateSudoku(sudoku: rotated2, numRotation: 2)
        XCTAssert(rotated2[0,0] == 15)
        XCTAssert(rotated2[8,7] == 6)
        XCTAssert(rotated2[15,14] == 2)
        
        
        sudoku2[1,2] = 1
        sudoku2[10,7] = 9
        var contradictions = findContradictions(sudoku: sudoku2)
        XCTAssert(contradictions[0][0] == true)
        XCTAssert(contradictions[1][2] == true)
        XCTAssert(contradictions[1][12] == true)
        XCTAssert(contradictions[11][2] == true)
        
        XCTAssert(contradictions[10][7] == true)
        XCTAssert(contradictions[10][14] == true)
        XCTAssert(contradictions[4][7] == true)
        XCTAssert(contradictions[8][6] == true)
        
        sudoku2[15,15] = 12
        findContradictions(sudoku: sudoku2, contradictionMatrix: &contradictions)
        XCTAssert(contradictions[15][15] == true)
        XCTAssert(contradictions[3][15] == true)
        XCTAssert(contradictions[15][12] == true)
    }
    
    static var allTests = [
        ("testSudokuManipulator", testSudokuManipulator)
    ]
}
