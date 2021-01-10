import XCTest
@testable import Sudoku

final class SudokuSolverTests: XCTestCase {
    func testCandidateMatrix() {
        let cm = CandidateMatrix(size: 3)
        print(cm)
        
        for n in 1...9 {
            XCTAssert(cm.isCandidate(row: 1, col: 1, n: n) == true)
        }
        
        cm.noCandidate(row: 7, col: 6, n: 1)
        XCTAssert(cm.isCandidate(row: 7, col: 6, n: 1) == false)
        
        cm.noCandidate(cell: Cell(row: 1, col: 1), numbers: [1,5,8,9])
        print(String(cm.indicators[1][1], radix: 2))
        XCTAssert(cm.getCandidateNumbers(row: 1, col: 1) == [2,3,4,6,7])
        
        let cells = getBlockCells(size: 3, block: 4)
        cm.noCandidate(cells: cells, numbers: [3,4,5,6,7])
        XCTAssert(cm.getCandidateNumbers(cell: Cell(row: 5, col: 5)) == [1,2,8,9])
        XCTAssert(cm.getCandidateNumbers(cell: Cell(row: 3, col: 4)) == [1,2,8,9])
        
        let cm_size5 = CandidateMatrix(size: 5)
        let cells2 = getBlockCells(size: 5, block: 11)
        cm_size5.noCandidate(cells: cells2, numbers: [1,4,7,3,9,11,16,22,12,11,18,19])
        print("cm_size5.indicators[12][7] : " + String(cm_size5.indicators[12][7], radix: 2))
        XCTAssert(cm_size5.getCandidateNumbers(row: 12, col: 7) == [2,5,6,8,10,13,14,15,17,20,21,23,24,25])
        
        cm.determine(row: 5, col: 3, n: 9)
        XCTAssert(cm.getCandidateNumbers(cell: Cell(row: 5, col: 3)) == [9])
        cm.noCandidate(row: 5, col: 3, numbers: [1,2,9])
        XCTAssert(cm.hasNoCandidate(cell: Cell(row: 5, col: 3)))
        
        cm.determine(cell: Cell(row: 7, col: 7), n: 8)
        XCTAssert(cm.getDeterminedNumber(row: 7, col: 7)! == 8)
        cm.noCandidate(row: 7, col: 2, numbers: [1,4,5,6,7,8,9])
        XCTAssert( cm.getDeterminedNumber(cell: Cell(row: 7, col: 2)) == nil )
        cm.noCandidate(row: 7, col: 3, numbers: [1,2,3,4,5,6,8,9])
        XCTAssert(cm.getDeterminedNumber(row: 7, col: 3) == 7)
        XCTAssert(cm.isDetermined(cell: Cell(row: 7, col: 3)) == true)
        
        cm.toggleCandidate(row: 1, col: 1, n: 3)
        XCTAssert(cm.getCandidateNumbers(cell: Cell(row: 1, col: 1)) == [2,4,6,7])
        cm.toggleCandidate(row: 1, col: 1, n: 1)
        XCTAssert(cm.getCandidateNumbers(row: 1, col: 1) == [1,2,4,6,7])
        
        let copy = cm.copy()
        copy.determine(row: 8, col: 8, n: 5)
        XCTAssert(cm.isDetermined(cell: Cell(row: 8, col: 8)) == false)
        print(cm.getCandidateNumbers(row: 8, col: 8))
        print(copy.getCandidateNumbers(row: 8, col: 8))
        
        print(cm)
    }
    
    func testFunctionsForSolveSudoku() {
        let cm1 = CandidateMatrix(size: 3)
        let nums = [
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
        let solvedS = try! Sudoku(nums: nums, size: 3)
        
        // updateNumCandidates
        updateNumCandidates(sudoku: solvedS, candidateMatrix: cm1)
        XCTAssert(cm1.getDeterminedNumber(cell: Cell(row: 0, col: 1))! == 7)
        var count = 0
        for i in 0..<9 { for j in 0..<9 {
            if cm1.isDetermined(row: i, col: j){ count += 1 }
        }}
        XCTAssert(count == 25)
        XCTAssert(cm1.getCandidateNumbers(row: 0, col: 0) == [3,4,5])
        XCTAssert(cm1.getCandidateNumbers(row: 4, col: 5) == [1,3,6])
        
        // makeCandidateLocs
        let clib = makeCandidateLocsInBlock(candidateMatrix: cm1, block: 6)
        XCTAssert(clib[1] == Set([Cell(row: 8, col: 1)]))
        XCTAssert(clib[2] == Set([Cell(row: 6, col: 1), Cell(row: 8, col:0), Cell(row: 8, col: 1)]))
        XCTAssert(clib[4] == Set([Cell(row: 7, col: 1)]))
        
        let clir = makeCandidateLocsInRow(candidateMatrix: cm1, row: 4)
        XCTAssert(clir[1] == Set([Cell(row: 4, col: 3), Cell(row: 4, col: 5), Cell(row: 4, col: 8)]))
        XCTAssert(clir[8] == Set([Cell(row: 4, col: 4)]))
        
        let clic = makeCandidateLocsInCol(candidateMatrix: cm1, col: 1)
        XCTAssert(clic[1] == Set([Cell(row: 8, col: 1)]))
        XCTAssert(clic[2] == Set([Cell(row: 3, col: 1), Cell(row: 6, col: 1), Cell(row: 8, col: 1)]))
        
        // checkCandidateLocs
        let copyS = solvedS.copy()
        checkCandidateLocs(sudoku: copyS, candidateLocs: clib)
        XCTAssert(copyS[8,1] == 1)
        copyS[8,1] = 0
        checkCandidateLocs(sudoku: copyS, candidateLocs: clic)
        XCTAssert(copyS[8,1] == 1)
        
        // checkCandidateNums
        cm1.noCandidate(row: 6, col: 8, numbers: [1,2,4,5,6,7,8,9])
        checkCandidateNums(sudoku: solvedS, candidateMatrix: cm1)
        XCTAssert(solvedS[6,8] == 3)
        
        // findHidden
        cm1.noCandidate(row: 5, col: 0, n: 7)
        let clib2 = makeCandidateLocsInBlock(candidateMatrix: cm1, block: 3)
        findHiddenRowAndCol(candidateLocs: clib2, candidateMatrix: cm1)
        for j in [0,2] {
            XCTAssert(cm1.isCandidate(row: 4, col: j, n: 7) == true)
        }
        for j in 3..<9 {
            XCTAssert(cm1.isCandidate(row: 4, col: j, n: 7) == false)
        }
        
        for i in 3..<9 {
            cm1.noCandidate(row: i, col: 0 ,n: 5)
        }
        let clic2 = makeCandidateLocsInCol(candidateMatrix: cm1, col: 0)
        findHiddenBlock(candidateLocs: clic2, candidateMatrix: cm1)
        XCTAssert(cm1.isCandidate(row: 0, col: 0, n: 5) == true)
        for i in 0...2 {
            for j in 1...2 {
                XCTAssert(cm1.isCandidate(row: i, col: j, n: 5) == false)
            }
        }
        
        // findLocsWithSameCandidateNums
        let cm2 = CandidateMatrix(size: 3)
        cm2.noCandidate(row: 7, col: 7, numbers: [1,2,4,6,7,8])  // exclude 3,5,9
        cm2.noCandidate(row: 6, col: 8, numbers: [1,2,4,6,7,8])
        cm2.noCandidate(row: 8, col: 7, numbers: [1,2,4,6,7,8])
        findLocsWithSameCandidateNumsInBlock(candidateMatrix: cm2, block: 8)
        XCTAssert(cm2.isCandidate(row: 6, col: 6, n: 3) == false)
        XCTAssert(cm2.isCandidate(row: 6, col: 6, n: 5) == false)
        XCTAssert(cm2.isCandidate(row: 6, col: 6, n: 9) == false)
        XCTAssert(cm2.isCandidate(row: 7, col: 8, n: 3) == false)
        XCTAssert(cm2.isCandidate(row: 7, col: 8, n: 5) == false)
        XCTAssert(cm2.isCandidate(row: 7, col: 8, n: 9) == false)
        
        cm2.noCandidate(row: 1, col: 2, numbers: [3,4,5,7,9])    // exclude 1,2,6,8
        cm2.noCandidate(row: 1, col: 3, numbers: [3,4,5,7,9])
        cm2.noCandidate(row: 1, col: 6, numbers: [3,4,5,7,9])
        cm2.noCandidate(row: 1, col: 8, numbers: [3,4,5,7,9])
        findLocsWithSameCandidateNumsInRow(candidateMatrix: cm2, row: 1)
        for j in 0..<9 {
            if j != 2 && j != 3 && j != 6 && j != 8 {
                XCTAssert(cm2.isCandidate(row: 1, col: j, n: 1) == false)
                XCTAssert(cm2.isCandidate(row: 1, col: j, n: 2) == false)
                XCTAssert(cm2.isCandidate(row: 1, col: j, n: 6) == false)
                XCTAssert(cm2.isCandidate(row: 1, col: j, n: 8) == false)
            }
        }
        
        cm2.noCandidate(cell: Cell(row: 2, col: 7), numbers: [1,2,4,6,7,8])  // exclude 3,5,9
        XCTAssert(cm2.isCandidate(row: 0, col: 7, n: 3) == true)
        findLocsWithSameCandidateNumsInCol(candidateMatrix: cm2, col: 7)
        for i in 0..<9 {
            if i != 2 && i != 7 && i != 8 {
                XCTAssert(cm2.isCandidate(row: i, col: 7, n: 3) == false)
                XCTAssert(cm2.isCandidate(row: i, col: 7, n: 5) == false)
                XCTAssert(cm2.isCandidate(row: i, col: 7, n: 9) == false)
            }
        }
        
        // findNumsWithSameCandidateLocs
        cm2.noCandidate(row: 3, col: 1, numbers: [3,7,9])
        cm2.noCandidate(row: 3, col: 2, numbers: [3,7,9])
        cm2.noCandidate(row: 4, col: 0, numbers: [3,7,9])
        cm2.noCandidate(row: 4, col: 2, numbers: [3,7,9])
        cm2.noCandidate(row: 5, col: 0, numbers: [3,7,9])
        cm2.noCandidate(row: 5, col: 1, numbers: [3,7,9])
        let clib3 = makeCandidateLocsInBlock(candidateMatrix: cm2, block: 3)
        XCTAssert(cm2.getCandidateNumbers(row: 4, col: 1) == [1,2,3,4,5,6,7,8,9])
        findNumsWithSameCandidateLocs(candidateLocs: clib3, candidateMatrix: cm2)
        XCTAssert(cm2.getCandidateNumbers(row: 3, col: 0) == [3,7,9])
        XCTAssert(cm2.getCandidateNumbers(row: 4, col: 1) == [3,7,9])
        XCTAssert(cm2.getCandidateNumbers(row: 5, col: 2) == [3,7,9])
        
        // findRowsWithSameCandidateNumInBlockRow
        cm2.noCandidate(row: 4, col: 1, n: 9)
        cm2.noCandidate(row: 4, col: 6, n: 9)
        cm2.noCandidate(row: 4, col: 7, n: 9)
        cm2.noCandidate(row: 4, col: 8, n: 9)
        findRowsWithSameCandidateNumInBlockRow(candidateMatrix: cm2, bRow: 1)
        for cell in getBlockCells(size: 3, block: 4) {
            if cell.row == 4 {
                XCTAssert(cm2.isCandidate(cell: cell, n: 9) == true)
            }
            else {
                XCTAssert(cm2.isCandidate(cell: cell, n: 9) == false)
            }
        }
        
        // findColsWithSameCandidateNumInBlockCol
        let cm3 = CandidateMatrix(size: 4)
        for i in 0..<4 {
            cm3.noCandidate(row: i, col: 4, n: 12)
            cm3.noCandidate(row: i, col: 7, n: 12)
        }
        for i in 12..<16 {
            cm3.noCandidate(row: i, col: 4, n: 12)
            cm3.noCandidate(row: i, col: 7, n: 12)
        }
        findColsWithSameCandidateNumInBlockCol(candidateMatrix: cm3, bCol: 1)
        for i in 4..<12 {
            XCTAssert(cm3.isCandidate(row: i, col: 4, n: 12) == true)
            XCTAssert(cm3.isCandidate(row: i, col: 5, n: 12) == false)
            XCTAssert(cm3.isCandidate(row: i, col: 6, n: 12) == false)
            XCTAssert(cm3.isCandidate(row: i, col: 7, n: 12) == true)
        }
        
        // xwingRow
        for i in [1,4,7,8,13] {
            for j in [0,1,2,3,4,6,8,10,12,13,14] {   // candidate at col 5,7,9,11,15
                cm3.noCandidate(row: i, col: j, n: 5)
            }
        }
        xwingRow(candidateMatrix: cm3)
        XCTAssert(cm3.isCandidate(row: 1, col: 6, n: 5) == false)
        XCTAssert(cm3.isCandidate(row: 13, col: 15, n: 5) == true)
        XCTAssert(cm3.isCandidate(row: 3, col: 5, n: 5) == false)
        for i in [0,2,3,5,6,9,10,11,12,14,15] {
            for j in [5,7,9,11,15] {
                XCTAssert(cm3.isCandidate(row: i, col: j, n: 5) == false)
            }
        }
        
        // xwingCol
        for i in [0,1,3,5,6] {    // candidate at row 2,4,7,8
            for j in [0,3,5,8] {
                cm2.noCandidate(row: i, col: j, n: 9)
            }
        }
        for cell in getCellsFromRowsAndCols(rows: [2,4,7,8], cols: [0,3,5,8]) {
            cm2.yesCandidate(cell: cell, n: 9)
        }
        xwingCol(candidateMatrix: cm2)
        XCTAssert(cm2.isCandidate(row: 3, col: 8, n: 9) == false)
        XCTAssert(cm2.isCandidate(row: 2, col: 3, n: 9) == true)
        XCTAssert(cm2.isCandidate(row: 4, col: 7, n: 9) == false)
        for i in [2,4,7,8] {
            for j in [1,2,4,6,7] {
                XCTAssert(cm2.isCandidate(row: i, col: j, n: 9) == false)
            }
        }
        
        // hasNumbersMoreThan17
        let nums2 = [
            [1,2,3,4,5,6,7,8,9],
            [0,0,0,0,0,0,0,0,0],
            [7,8,9,1,2,3,4,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0]
        ]
        let sudoku2 = try! Sudoku(nums: nums2, size: 3)
        XCTAssert(hasNumbersMoreThan17(sudoku: sudoku2) == false)
        sudoku2[1,1] = 5
        XCTAssert(hasNumbersMoreThan17(sudoku: sudoku2) == true)
        
        // hasContradiction
        let cm4 = CandidateMatrix(size: 3)
        sudoku2[1,0] = 4
        updateNumCandidates(sudoku: sudoku2, candidateMatrix: cm4)
        XCTAssert(hasContradiction(sudoku: sudoku2, candidateMatrix: cm4) == false)
        sudoku2[6,2] = 5
        sudoku2[3,2] = 5
        updateNumCandidates(sudoku: sudoku2, candidateMatrix: cm4)
        XCTAssert(hasContradiction(sudoku: sudoku2, candidateMatrix: cm4) == true)
        
        let cm5 = CandidateMatrix(size: 3)
        XCTAssert(getAllCells(size: 3).count == 81)
        cm5.noCandidate(cells: getBlockCells(size: 3, block: 5), n: 8)
        XCTAssert(hasContradiction(sudoku: Sudoku(size: 3), candidateMatrix: cm5) == true)
        
    }
    
    func testSolveSudoku() {
        let nums = [
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
            let sudoku = try Sudoku(nums: nums, size: 3)
            let resultPair = solveSudoku(sudoku: sudoku)
            XCTAssert(resultPair.isSolved == true)
            print("answer of solveSudoku:")
            print(resultPair.answer)
        }
        catch let e as InvalidSudokuSizeError {
            print(e.message)
        }
        catch {
            print("Unknown error")
        }
        
        let nums2 = [
            [0,2,0,3,0,0,8,0,0],
            [0,0,6,0,0,5,0,2,0],
            [4,0,0,0,9,0,0,0,7],
            [0,0,0,0,0,2,0,4,0],
            [0,0,5,0,0,0,6,0,0],
            [0,1,0,8,0,0,0,0,0],
            [7,0,0,0,1,0,0,0,6],
            [0,8,0,7,0,0,3,0,0],
            [0,0,1,0,0,9,0,5,0]
        ]
        let sudoku2 = try! Sudoku(nums: nums2, size: 3)
        let result2 = solveSudoku(sudoku: sudoku2)
        XCTAssert(result2.isSolved == true)
        print("answer of solveSudoku 2: ")
        print(result2.answer)
        
        let nums3 = [
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
        let sudoku3 = try! Sudoku(nums: nums3, size: 3)
        let result3 = solveSudoku(sudoku: sudoku3)
        XCTAssert(result3.isSolved == true)
        print("answer of solveSudoku 3:")
        print(result3.answer)
        
        let nums4 = [
            [0,0,6,0,1,0,0,0,0],
            [0,9,0,0,0,8,0,6,0],
            [3,0,0,6,0,0,0,0,5],
            [5,0,0,2,0,0,0,7,0],
            [0,0,9,0,7,0,1,0,0],
            [0,6,0,0,0,4,0,0,3],
            [1,0,0,0,0,3,0,0,2],
            [0,4,0,5,0,0,0,8,0],
            [0,0,0,0,2,0,7,0,0],
        ]
        let sudoku4 = try! Sudoku(nums: nums4, size: 3)
        let result4 = solveSudoku(sudoku: sudoku4)
        XCTAssert(result4.isSolved == true)
        print("answer of solveSudoku 4:")
        print(result4.answer)
        
        let nums5 = [
            [2,0,0,0,0,0,0,0,7],
            [0,9,0,0,1,0,0,0,0],
            [0,0,6,0,0,8,0,3,0],
            [0,4,0,1,0,0,0,0,8],
            [0,0,5,0,4,0,1,0,0],
            [3,0,0,0,0,2,0,6,0],
            [0,7,0,3,0,0,9,0,0],
            [0,0,0,0,2,0,0,5,0],
            [8,0,0,0,0,0,0,0,4]
        ]
        let sudoku5 = try! Sudoku(nums: nums5, size: 3)
        let result5 = solveSudoku(sudoku: sudoku5)
        XCTAssert(result5.isSolved == true)
        print("answer of solveSudoku 5:")
        print(result5.answer)
        
        let result8 = solveSudokuWithTrials(sudoku: sudoku5)
        XCTAssert(result8.status == .solvable)
        print("answer of solveSudokuWithTrials 1: ")
        if let ans = result8.answer {
            print(ans)
        }
        
        
        
        let nums7 = [
            [0,0,5,3,0,0,0,0,0],
            [8,0,9,0,0,0,1,2,0],
            [0,7,0,0,1,0,5,0,0],
            [4,0,6,0,0,5,3,0,0],
            [0,1,0,0,7,0,0,0,6],
            [0,0,3,2,0,0,0,8,0],
            [0,6,0,5,0,0,0,0,9],
            [0,0,4,0,0,0,0,3,0],
            [0,0,0,0,0,9,7,0,0]
        ]
        let sudoku7 = try! Sudoku(nums: nums7, size: 3)
        let result7_2 = solveSudoku(sudoku: sudoku7)
        XCTAssert(result7_2.isSolved == false)
        print("answer of solveSudoku 7_2: ")
        print(result7_2.answer)
        
        let nums7_2 = [
            [0,0,5,3,0,0,0,0,0],
            [8,0,0,0,0,0,0,2,0],
            [0,7,0,0,1,0,5,0,0],
            [4,0,6,0,0,5,3,0,0],
            [0,1,0,0,7,0,0,0,6],
            [0,0,3,2,0,0,0,8,0],
            [0,6,0,5,0,0,0,0,9],
            [0,0,4,0,0,0,0,3,0],
            [0,0,0,0,0,9,7,0,0]
        ]
        let sudoku7_2 = try! Sudoku(nums: nums7_2, size: 3)
        let result7_3 = solveSudokuWithTrials(sudoku: sudoku7_2)
        XCTAssert(result7_3.status == .solvable)
        print("answer of solveSudoku 7_3: ")
        if let ans = result7_3.answer {
            print(ans)
        }
        
        
        
        let nums6 = [
            [0,0,5,3,0,0,0,0,0],
            [8,0,0,0,0,0,0,2,0],
            [0,7,0,0,1,0,5,0,0],
            [4,0,0,0,0,5,3,0,0],
            [0,1,0,0,7,0,0,0,6],
            [0,0,3,2,0,0,0,8,0],
            [0,6,0,5,0,0,0,0,9],
            [0,0,4,0,0,0,0,3,0],
            [0,0,0,0,0,9,7,0,0]
        ]
        let sudoku6 = try! Sudoku(nums: nums6, size: 3)
        print(sudoku6)
        let result6 = solveSudoku(sudoku: sudoku6)
        XCTAssert(result6.isSolved == false)
        print("answer of solveSudoku 6:")
        print(result6.answer)
        print("Solving the most difficult sudoku in the world...")
        let result7 = solveSudokuWithTrials(sudoku: sudoku6)
        XCTAssert(result7.status == SudokuStatus.solvable)
        print("answer of solveSudokuWithTrials 7:")
        print(result7.answer!)
        
    }
    
    func testOfSolveSudokuWithTrials() {
        let nums = [
            [0,0,5,3,0,0,0,0,0],
            [8,0,0,0,0,0,0,2,0],
            [0,7,0,0,1,0,5,0,0],
            [4,0,0,0,0,5,3,0,0],
            [0,1,0,0,7,0,0,0,6],
            [0,0,3,2,0,0,0,8,0],
            [0,6,0,5,0,0,0,0,9],
            [0,0,4,0,0,0,0,3,0],
            [0,0,0,0,0,9,7,0,0]
        ]
        let sudoku = try! Sudoku(nums: nums, size: 3)
        print("Solving the most difficult sudoku in the world...")
        let result = solveSudokuWithTrials(sudoku: sudoku)
        XCTAssert(result.status == SudokuStatus.solvable)
        print("answer of solveSudokuWithTrials:")
        print(result.answer!)
        
        let nums2 = [
            [1,2,3,4,5,6,7,8,9],
            [4,5,6,7,8,9,1,2,3],
            [7,8,9,1,2,3,4,5,6],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0]
        ]
        let sudoku2 = try! Sudoku(nums: nums2, size: 3)
        print("Tyring to solve a sudoku which has some solutions...")
        let result2 = solveSudokuWithTrials(sudoku: sudoku2)
        XCTAssert(result2.status == .hasSomeSolutions)
        XCTAssert(result2.answer == nil)
        
        let nums3 = [
            [1,2,3,4,5,6,7,8,9],
            [4,5,6,7,8,9,1,2,3],
            [7,8,9,1,2,3,4,5,6],
            [2,0,0,0,0,0,0,0,0],
            [5,0,0,0,0,0,0,0,0],
            [3,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,8,0,0,0,0,0,0],
            [0,0,2,0,0,0,0,0,0]
        ]
        let sudoku3 = try! Sudoku(nums: nums3, size: 3)
        print("Tyring to solve unsolvable sudoku...")
        let result3 = solveSudokuWithTrials(sudoku: sudoku3)
        XCTAssert(result3.status == .unsolvable)
        XCTAssert(result3.answer == nil)
    }
    
    func testAnalyzeSudoku() {
        let nums = [
            [0,0,5,3,0,0,0,0,0],
            [8,0,0,0,0,0,0,2,0],
            [0,7,0,0,1,0,5,0,0],
            [4,0,0,0,0,5,3,0,0],
            [0,1,0,0,7,0,0,0,6],
            [0,0,3,2,0,0,0,8,0],
            [0,6,0,5,0,0,0,0,9],
            [0,0,4,0,0,0,0,3,0],
            [0,0,0,0,0,9,7,0,0]
        ]
        let sudoku = try! Sudoku(nums: nums, size: 3)
        XCTAssert(analyzeSudoku(sudoku: sudoku) == SudokuStatus.solvable)
        
        let nums2 = [
            [1,2,3,4,5,6,7,8,9],
            [4,5,6,7,8,9,1,2,3],
            [7,8,9,1,2,3,4,5,6],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0]
        ]
        let sudoku2 = try! Sudoku(nums: nums2, size: 3)
        XCTAssert(analyzeSudoku(sudoku: sudoku2) == .hasSomeSolutions)
        
        let nums3 = [
            [1,2,3,4,5,6,7,8,9],
            [4,5,6,7,8,9,1,2,3],
            [7,8,9,1,2,3,4,5,6],
            [2,0,0,0,0,0,0,0,0],
            [5,0,0,0,0,0,0,0,0],
            [3,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,8,0,0,0,0,0,0],
            [0,0,2,0,0,0,0,0,0]
        ]
        let sudoku3 = try! Sudoku(nums: nums3, size: 3)
        XCTAssert(analyzeSudoku(sudoku: sudoku3) == .unsolvable)
    }
    
    static var allTests = [
        ("testSudokuSolver:CandidateMatrix", testCandidateMatrix),
        ("testSudokuSolver:FunctionsForSolveSudoku", testFunctionsForSolveSudoku),
        ("testSudokuSolver:SolveSudoku", testSolveSudoku),
        ("testSudokuSolver:SolveSudokuWithTrials", testOfSolveSudokuWithTrials)
    ]
}

// Square matrix of bits which represents whether some number is candidate at a certain location.
fileprivate class CandidateMatrix: Equatable {
    var indicators = [[Int]]()
    private(set) var size: Int
    
    /// make size*size x size*size candidate matrix
    init(size: Int) {
        self.size = size
        let ss = size*size
        let allBitOn = Array(0..<ss).reduce(0) {
            (result, bit) in return result | (1<<bit)
        }
        for _ in 0..<ss {
            // firstly, all numbers are candidate numbers
            indicators.append(Array(repeating: allBitOn, count: ss) )
        }
    }
    
    static func ==(lhs: CandidateMatrix, rhs: CandidateMatrix) -> Bool {
        return lhs.indicators == rhs.indicators && lhs.size == rhs.size
    }
    
    func copy() -> CandidateMatrix {
        let cm = CandidateMatrix(size: self.size)
        cm.indicators = self.indicators
        return cm
    }
    
    /// returns true if n is candidate at (row,col)
    func isCandidate(row: Int, col: Int, n: Int) -> Bool {
        return (indicators[row][col] >> (n-1)) & 1 == 1
    }
    
    /// returns true if n is candidate at cell
    func isCandidate(cell: Cell, n: Int) -> Bool {
        return (indicators[cell.row][cell.col] >> (n-1)) & 1 == 1
    }
    
    /// returns true if it has no candidate at (row,col)
    func hasNoCandidate(row: Int, col: Int) -> Bool {
        return indicators[row][col] == 0
    }
    
    /// returns true if it has no candidate at cell
    func hasNoCandidate(cell: Cell) -> Bool {
        return indicators[cell.row][cell.col] == 0
    }
    
    /// toggle candidate bit for n at (row,col)
    func toggleCandidate(row: Int, col: Int, n: Int) {
        if (1 <= n && n <= size*size) {
            let toggled = indicators[row][col] ^ (1 << (n-1))
            indicators[row][col] = toggled
        }
    }
    
    /// update Candidate that n is candidate at (row, col)
    func yesCandidate(row: Int, col: Int, n: Int) {
        if (1 <= n && n <= size*size && !isCandidate(row: row, col: col, n: n)) {
            let toggled = indicators[row][col] | (1 << (n-1))
            indicators[row][col] = toggled
        }
    }
    
    /// update Candidate that n is candidate at cell
    func yesCandidate(cell: Cell, n: Int) {
        if (1 <= n && n <= size*size && !isCandidate(cell: cell, n: n)) {
            let toggled = indicators[cell.row][cell.col] | (1 << (n-1))
            indicators[cell.row][cell.col] = toggled
        }
    }
    
    /// update Candidate that n is not candidate at (row,col)
    func noCandidate(row: Int, col: Int, n: Int) {
        if (1 <= n && n <= size*size && isCandidate(row: row, col: col, n: n)) {
            let toggled = indicators[row][col] & ~(1 << (n-1))
            indicators[row][col] = toggled
        }
    }
    
    /// update Candidate that n is not candidate at cell
    func noCandidate(cell: Cell, n: Int) {
        if (1 <= n && n <= size*size && isCandidate(cell: cell, n: n)) {
            let toggled = indicators[cell.row][cell.col] & ~(1 << (n-1))
            indicators[cell.row][cell.col] = toggled
        }
    }
    
    ///update Candidate that numbers are not candidate at (row,col)
    func noCandidate<T: Sequence>(row: Int, col: Int, numbers: T) where T.Element == Int {
        var toggled = indicators[row][col]
        for n in numbers {
            if (1 <= n && n <= size*size && isCandidate(row: row, col: col, n: n)) {
                toggled &= ~(1 << (n-1))
            }
        }
        indicators[row][col] = toggled
    }
    
    ///update Candidate that numbers are not candidate at cell
    func noCandidate<T: Sequence>(cell: Cell, numbers: T) where T.Element == Int {
        var toggled = indicators[cell.row][cell.col]
        for n in numbers {
            if (1 <= n && n <= size*size && isCandidate(cell: cell, n: n)) {
                toggled &= ~(1 << (n-1))
            }
        }
        indicators[cell.row][cell.col] = toggled
    }
    
    /// update Candidate that n is not candidate at cells
    func noCandidate<T: Sequence>(cells: T, n: Int) where T.Element == Cell {
        for cell in cells {
            noCandidate(row: cell.row, col: cell.col, n: n)
        }
    }
    
    /// update Candidate that numbers are not candidate at cells
    func noCandidate<T1: Sequence, T2: Sequence>(cells: T1, numbers: T2) where T1.Element == Cell, T2.Element == Int {
        for cell in cells {
            noCandidate(row: cell.row, col: cell.col, numbers: numbers)
        }
    }
    
    /// gets candidate-numbers at (row,col)
    func getCandidateNumbers(row: Int, col: Int) -> [Int] {
        let ss = size*size
        var candidates = [Int]()
        let indicator = indicators[row][col]
        for k in 0..<ss {
            if (indicator >> k & 1) == 1 {
                candidates.append(k+1)
            }
        }
        return candidates
    }
    
    /// gets candidate-numbers at cell
    func getCandidateNumbers(cell: Cell) -> [Int] {
        let ss = size*size
        var candidates = [Int]()
        let indicator = indicators[cell.row][cell.col]
        for k in 0..<ss {
            if (indicator >> k & 1) == 1 {
                candidates.append(k+1)
            }
        }
        return candidates
    }
    
    /// checks if n is determined at (row,col)
    func isDetermined(row: Int, col: Int) -> Bool {
        return getCandidateNumbers(row: row, col: col).count == 1
    }
    
    /// checks if n is determined at cell
    func isDetermined(cell: Cell) -> Bool {
        return getCandidateNumbers(cell: cell).count == 1
    }
    
    /// returns determined number at (row,col)
    func getDeterminedNumber(row: Int, col: Int) -> Int? {
        let candidates = getCandidateNumbers(row: row, col: col)
        return candidates.count == 1 ? candidates[0] : nil
    }
    
    /// returns determined number at cell
    func getDeterminedNumber(cell: Cell) -> Int? {
        let candidates = getCandidateNumbers(cell: cell)
        return candidates.count == 1 ? candidates[0] : nil
    }
    
    /// update Candidate that n is determined at (row,col)
    func determine(row: Int, col: Int, n: Int) {
        if (1 <= n && n <= size*size) {
            // only n-th bit is on
            indicators[row][col] = (1 << (n-1))
        }
    }
    
    /// update Candidate that n is determined at cell
    func determine(cell: Cell, n: Int) {
        if (1 <= n && n <= size*size) {
            // only n-th bit is on
            indicators[cell.row][cell.col] = (1 << (n-1))
        }
    }
}

/// Update data for NumCandidates
// For each location (i,j), check whether each number can be a candidate
// in the location. To check this, firstly check if (i,j) is empty,
// and them, check if the number is not involved in "checkList" which
// contains all numbers in the i-th row, the j-th column, and the block
// which includes (i,j). If so, it means the location is a
// candidate-location of the number n. (In other words, the number n
// is a candidate-number of the location (i,j).)
fileprivate func updateNumCandidates(sudoku: Sudoku, candidateMatrix: CandidateMatrix) {
    let ss = sudoku.size * sudoku.size
    for i in 0..<ss {
        for j in 0..<ss {
            
            // if no number is fixed, update candidates using checkList
            if (sudoku[i,j] == 0) {
                // checkList to check if a number  can be
                // located in the location (i,j)
                var checkList = Set<Int>()
                let b = sudoku.getBlockNumberFromLoc(row: i, col: j)
                checkList.formUnion(sudoku.getBlockAsArray(block: b))
                checkList.formUnion(sudoku.getRow(row: i))
                checkList.formUnion(sudoku.getCol(col: j))
                
                // remove numbers included in the checkList
                // from candidate-numbers at (i,j)
                candidateMatrix.noCandidate(row: i, col: j, numbers: checkList)
            }
            // otherwise, determine the cell
            else {
                candidateMatrix.determine(row: i, col: j, n: sudoku[i,j])
            }
            
        }
    }
}


// Make Dictionary which maps number n to Set of its
// candidate-locations in a block
fileprivate func makeCandidateLocsInBlock(candidateMatrix: CandidateMatrix, block: Int) -> [Int:Set<Cell>] {
    let size = candidateMatrix.size
    let ss = size*size
    var candidateLocsInBlock = Dictionary<Int, Set<Cell>>()
    for n in 1...ss {
        candidateLocsInBlock[n] = Set<Cell>()
        for cell in getBlockCells(size: size, block: block) {
            if candidateMatrix.isCandidate(cell: cell, n: n) {
                candidateLocsInBlock[n]?.insert(cell)
            }
        }
    }
    return candidateLocsInBlock
}

// Make Dictionary which maps number n to Set of its
// candidate-locations in a row
fileprivate func makeCandidateLocsInRow(candidateMatrix: CandidateMatrix, row: Int) -> [Int:Set<Cell>] {
    let size = candidateMatrix.size
    let ss = size*size
    var candidateLocsInRow = Dictionary<Int, Set<Cell>>()
    for n in 1...ss {
        candidateLocsInRow[n] = Set<Cell>()
        for j in 0..<ss {
            if candidateMatrix.isCandidate(row: row, col: j, n: n) {
                candidateLocsInRow[n]?.insert(Cell(row: row, col: j))
            }
        }
    }
    return candidateLocsInRow
}


// Make Dictionary which maps number n to Set of its
// candidate-locations in a column
fileprivate func makeCandidateLocsInCol(candidateMatrix: CandidateMatrix, col: Int) -> [Int:Set<Cell>] {
    let size = candidateMatrix.size
    let ss = size*size
    var candidateLocsInCol = Dictionary<Int, Set<Cell>>()
    for n in 1...ss {
        candidateLocsInCol[n] = Set<Cell>()
        for i in 0..<ss {
            if candidateMatrix.isCandidate(row: i, col: col, n: n) {
                candidateLocsInCol[n]?.insert(Cell(row: i, col: col))
            }
        }
    }
    return candidateLocsInCol
}

//TODO: create code that updates partial canadidaterMatirx
// Check if the count of candidate-locations of a number n is one.
// If so, only the candidate n can be located at the location.
// After this operation, CandidateMatrix must be updated
fileprivate func checkCandidateLocs(sudoku: Sudoku, candidateLocs: [Int:Set<Cell>]) {
    
    let ss = sudoku.size * sudoku.size
    for n in 1...ss {
        if candidateLocs[n]?.count == 1, let location = candidateLocs[n]?.first {
            sudoku[location.row,location.col] = n
        }
    }
}

// Check if the count of candidate-numbers at a location (i,j) is one.
// If so, only the candidate can be located at the location (i,j).
// After this operation, CandidateMatrix must be updated
fileprivate func checkCandidateNums(sudoku: Sudoku, candidateMatrix: CandidateMatrix) {
    let ss = sudoku.size * sudoku.size
    for i in 0..<ss {
        for j in 0..<ss {
            if let n = candidateMatrix.getDeterminedNumber(row: i, col: j) {
                sudoku[i,j] = n
            }
        }
    }
}

// From candidate-location, find a row and/or a column
// that all these locations have in common.
// Generally, candidateLocs is candidate-locations of some block
fileprivate func findHiddenRowAndCol(candidateLocs: [Int:Set<Cell>], candidateMatrix: CandidateMatrix) {
    let size = candidateMatrix.size
    let ss = size*size
    for n in 1...ss {
        if let candidateLocsOfN = candidateLocs[n], candidateLocsOfN.count > 0 {
            // find hidden row
            let rowsOfCandiateNumbers = candidateLocsOfN.map {
                (cell: Cell) -> Int in return cell.row
            }
            let row = rowsOfCandiateNumbers[0]
            if rowsOfCandiateNumbers.allSatisfy({ $0 == row }) {
                // if the rows of all candidate-numbers are same,
                // this is hidden row
                var noCandidateLocs = Set(getRowCells(size: size, row: row))
                noCandidateLocs.subtract(candidateLocsOfN)     // exclude candidate-locations of n
                candidateMatrix.noCandidate(cells: noCandidateLocs, n: n)
            }
            
            // find hidden column
            let colsOfCandidateNumbers = candidateLocsOfN.map {
                (cell: Cell) -> Int in return cell.col
            }
            let col = colsOfCandidateNumbers[0]
            if colsOfCandidateNumbers.allSatisfy({ $0 == col }) {
                // if the columns of all candidate-numbers are same,
                // this is hidden column
                var noCandidateLocs = Set(getColCells(size: size, col: col))
                noCandidateLocs.subtract(candidateLocsOfN)     // exclude candidate-locations of n
                candidateMatrix.noCandidate(cells: noCandidateLocs, n: n)
            }
        }
    }
}


// From candidate-locations, find a block that contains all these
// locations.
// Generally, candidateLocs is candidate-locations of some row or column
fileprivate func findHiddenBlock(candidateLocs: [Int:Set<Cell>], candidateMatrix: CandidateMatrix) {
    let size = candidateMatrix.size
    let ss = size*size
    for n in 1...ss {
        if let candidateLocsOfN = candidateLocs[n], candidateLocsOfN.count > 0 {
            // find hidden block
            let blocksOfCandidateNumbers = candidateLocsOfN.map {
                (cell: Cell) -> Int
                in return Sudoku.getBlockNumberFromLoc(row: cell.row, col: cell.col, size: size)
            }
            let block = blocksOfCandidateNumbers[0]
            // if the blocks of all candidate-numbers are same,
            // this is hidden block
            if blocksOfCandidateNumbers.allSatisfy({ $0 == block }) {
                var noCandidateLocs = Set(getBlockCells(size: size, block: block))
                noCandidateLocs.subtract(candidateLocsOfN)     // exclude candidate-locations of n
                candidateMatrix.noCandidate(cells: noCandidateLocs, n: n)
            }
        }
    }
}


fileprivate func findLocsWithSameCandidateNums(candidateMatrix: CandidateMatrix) {
    let ss = candidateMatrix.size * candidateMatrix.size
    for k in 0..<ss {
        findLocsWithSameCandidateNumsInRow(candidateMatrix: candidateMatrix, row: k)
        findLocsWithSameCandidateNumsInCol(candidateMatrix: candidateMatrix, col: k)
        findLocsWithSameCandidateNumsInBlock(candidateMatrix: candidateMatrix, block: k)
    }
}

// In a block, find the locations that have same candidate-numbers.
fileprivate func findLocsWithSameCandidateNumsInBlock(candidateMatrix: CandidateMatrix, block: Int) {
    let size = candidateMatrix.size
    var numsToLocs = [Set<Int>:Set<Cell>]()
    
    // group locations in the block by their candidate-numbers
    for cell in getBlockCells(size: size, block: block) {
        let candidateNums = Set( candidateMatrix.getCandidateNumbers(cell: cell) )
        numsToLocs[candidateNums, default: Set<Cell>()].insert(cell)
    }
    
    for (nums, locs) in numsToLocs {
        // if the count of numbers is equal to the count of locations
        // the other locations in the block can't be candidates of these numbers
        if nums.count == locs.count {
            var noCandidateCells = Set( getBlockCells(size: size, block: block) )
            noCandidateCells.subtract(locs)     // exclude candidate-locations of nums
            candidateMatrix.noCandidate(cells: noCandidateCells, numbers: nums)
        }
    }
}

// In a row, find the locations that have same candidate-numbers.
fileprivate func findLocsWithSameCandidateNumsInRow(candidateMatrix: CandidateMatrix, row: Int) {
    let size = candidateMatrix.size
    var numsToLocs = [Set<Int>:Set<Cell>]()
    
    // group locations in the row by their candidate-numbers
    for cell in getRowCells(size: size, row: row) {
        let candidateNums = Set( candidateMatrix.getCandidateNumbers(cell: cell) )
        numsToLocs[candidateNums, default: Set<Cell>()].insert(cell)
    }
    
    for (nums, locs) in numsToLocs {
        // if the count of numbers is equal to the count of locations
        // the other locations in the row can't be candidates of these numbers
        if nums.count == locs.count {
            var noCandidateCells = Set( getRowCells(size: size, row: row) )
            noCandidateCells.subtract(locs)
            candidateMatrix.noCandidate(cells: noCandidateCells, numbers: nums)
        }
    }
}

// In a column, find the locations that have same candidate-numbers.
fileprivate func findLocsWithSameCandidateNumsInCol(candidateMatrix: CandidateMatrix, col: Int) {
    let size = candidateMatrix.size
    var numsToLocs = [Set<Int>:Set<Cell>]()
    
    // group locations in the column by their candidate-numbers
    for cell in getColCells(size: size, col: col) {
        let candidateNums = Set( candidateMatrix.getCandidateNumbers(cell: cell) )
        numsToLocs[candidateNums, default: Set<Cell>()].insert(cell)
    }
    
    for (nums, locs) in numsToLocs {
        // if the count of numbers is equal to the count of locations
        // the other locations in the column can't be candidates of these numbers
        if nums.count == locs.count {
            var noCandidateCells = Set( getColCells(size: size, col: col) )
            noCandidateCells.subtract(locs)
            candidateMatrix.noCandidate(cells: noCandidateCells, numbers: nums)
        }
    }
}


// From candidateLocs, find the number that have same
// candidate-locations.
// This is reverse approach of findLocsWithSameCandidateNums
fileprivate func findNumsWithSameCandidateLocs(candidateLocs: [Int:Set<Cell>], candidateMatrix: CandidateMatrix)
{
    let size = candidateMatrix.size
    let ss = size*size
    var locsToNums = [Set<Cell>:Set<Int>]()
    
    // group numbers by their candidate-locations
    for n in 1...ss {
        if let locs = candidateLocs[n] {
            locsToNums[locs, default: Set<Int>()].insert(n)
        }
    }
    
    for (locs, nums) in locsToNums {
        // if the count of locations is equal to the count of numbers
        // the other numbers can't be candidates of these locations
        if locs.count == nums.count {
            var noCandidateNums = Set(1...ss)
            noCandidateNums.subtract(nums)
            candidateMatrix.noCandidate(cells: locs, numbers: noCandidateNums)
        }
    }
}


// Find rows which include candidate-locations of same n over one block-row.
// In this case, if the count of rows is equal to the count of blocks where
// the rows include candidate-locations of n, the number can't be located
// in the rows in the other blocks.
fileprivate func findRowsWithSameCandidateNumInBlockRow(candidateMatrix: CandidateMatrix, bRow: Int) {
    let size = candidateMatrix.size
    let ss = size*size
    
    for n in 1...ss {
        // make Dictionary which maps block number to candidate-rows, Set of rows
        // which include candidate-locations of n
        var candidateRowsOfN = [Int:Set<Int>]()
        for block in bRow*size..<(bRow+1)*size {
            for cell in getBlockCells(size: size, block: block) {
                if candidateMatrix.isCandidate(cell: cell, n: n) {
                    candidateRowsOfN[block, default: Set<Int>()].insert(cell.row)
                }
            }
        }
        
        // group block numbers by their candidate-rows
        var rowsToBlocks = [Set<Int>:Set<Int>]()
        for (block, rows) in candidateRowsOfN {
            rowsToBlocks[rows, default: Set<Int>()].insert(block)
        }
        
        // if the count of rows is equal to the count of blocks,
        // n can't be located in the rows in the other blocks.
        // it is also checked if rows.count != size for better performance
        for (rows, blocks) in rowsToBlocks {
            if rows.count == blocks.count && rows.count != size {
                var noCandidateLocs = Set<Cell>()
                for row in rows {
                    noCandidateLocs.formUnion(getRowCells(size: size, row: row))
                }
                for block in blocks {
                    noCandidateLocs.subtract(getBlockCells(size: size, block: block))
                }
                candidateMatrix.noCandidate(cells: noCandidateLocs, n: n)
            }
        }
    }
}

// Find columns which include candidate-locations of same n over one block-col.
// In this case, if the count of columns is equal to the count of blocks where
// the columns include candidate-locations of n, the number can't be located
// in the columns in the other blocks.
fileprivate func findColsWithSameCandidateNumInBlockCol(candidateMatrix: CandidateMatrix, bCol: Int) {
    let size = candidateMatrix.size
    let ss = size*size
    
    for n in 1...ss {
        // make Dictionary which maps block number to candidate-columns, Set of
        // columns which include candidate-locations of n
        var candidateColsOfN = [Int:Set<Int>]()
        for block in stride(from: bCol, to: bCol+size*size, by: size) {
            for cell in getBlockCells(size: size, block: block) {
                if candidateMatrix.isCandidate(cell: cell, n: n) {
                    candidateColsOfN[block, default: Set<Int>()].insert(cell.col)
                }
            }
        }
        
        // group block number by their candidate-columns
        var colsToBlocks = [Set<Int>:Set<Int>]()
        for (block, cols) in candidateColsOfN {
            colsToBlocks[cols, default: Set<Int>()].insert(block)
        }
        
        // if the count of columns is equal to the count of blocks,
        // n can't be located in the columns in the other blocks.
        // it is also checked if cols.count != size for better performance
        for (cols, blocks) in colsToBlocks {
            if cols.count == blocks.count && cols.count != size {
                var noCandidateLocs = Set<Cell>()
                for col in cols {
                    noCandidateLocs.formUnion(getColCells(size: size, col: col))
                }
                for block in blocks {
                    noCandidateLocs.subtract(getBlockCells(size: size, block: block))
                }
                candidateMatrix.noCandidate(cells: noCandidateLocs, n: n)
            }
        }
    }
}


// Find rows where the columns of candidate-locations for n
// are completely same.
// If the count of such rows are equal to the count of
// candidate-locations of n, in the other rows, n can't be
// located where the column is same as candidate-locations
// of the found rows.
fileprivate func xwingRow(candidateMatrix: CandidateMatrix) {
    let size = candidateMatrix.size
    let ss = size*size
    
    for n in 1...ss {
        var colsToRows = [Set<Int>:Set<Int>]()
        for row in 0..<ss {
            // get column-numbers of candidate-locations of n in the row
            let candidateColsOfTheRow = Set(getRowCells(size: size, row: row)
                .filter {
                    return candidateMatrix.isCandidate(cell: $0, n: n)
                }
                .map {
                    return $0.col
                })
            // group rows by their column-numbers where n is candidate
            colsToRows[candidateColsOfTheRow, default: Set<Int>()].insert(row)
        }
        for (cols, rows) in colsToRows {
            // if the count of rows (all of which have same column-numbers of
            // candidate-locations of n) is equal to the count of the
            // column-numbers, then n can't be located in the other locations
            // in the columns. ("other" means "except the rows (value of colsToRows)")
            if cols.count == rows.count {
                var noCandidateLocs = Set<Cell>()
                for col in cols {
                    noCandidateLocs.formUnion(getColCells(size: size, col: col))
                }
                noCandidateLocs.subtract(getCellsFromRowsAndCols(rows: rows, cols: cols))
                candidateMatrix.noCandidate(cells: noCandidateLocs, n: n)
            }
        }
    }
}

// Find columns where the rows of candidate-locations for n
// are completely same.
// If the count of such columns are equal to the count of
// candidate-locations of n, in the other columns, n can't be
// located where the row is same as candidate-locations
// of the found columns.
fileprivate func xwingCol(candidateMatrix: CandidateMatrix) {
    let size = candidateMatrix.size
    let ss = size*size
    
    for n in 1...ss {
        var rowsToCols = [Set<Int>:Set<Int>]()
        for col in 0..<ss {
            // get row-numbers of candidate-locations of n in the column
            let candidateRowsOfTheCol = Set(getColCells(size: size, col: col)
                .filter {
                    return candidateMatrix.isCandidate(cell: $0, n: n)
                }
                .map {
                    return $0.row
                })
            // group columns by their row-numbers where n is candidate
            rowsToCols[candidateRowsOfTheCol, default: Set<Int>()].insert(col)
        }
        for (rows, cols) in rowsToCols {
            // if the count of columns (al of which have same row-numbers of
            // candidate-locations of n) is equal to the count of the
            // row-numbers, then n can't be located in the other locations
            // in the rows. ("other" means "except the columns (value of rowsToCols)")
            if rows.count == cols.count {
                var noCandidateLocs = Set<Cell>()
                for row in rows {
                    noCandidateLocs.formUnion(getRowCells(size: size, row: row))
                }
                noCandidateLocs.subtract(getCellsFromRowsAndCols(rows: rows, cols: cols))
                candidateMatrix.noCandidate(cells: noCandidateLocs, n: n)
            }
        }
    }
}


// Check if the sudoku has more numbers than 17.
// If not the sudoku cannot be solved.
fileprivate func hasNumbersMoreThan17(sudoku: Sudoku) -> Bool {
    var count = 0
    let ss = sudoku.size * sudoku.size
    for i in 0..<ss {
        for j in 0..<ss {
            if sudoku[i,j] != 0 {
                count += 1
            }
            if count >= 17 {
                return true
            }
        }
    }
    return false
}


// Check if there is contradiction in the sudoku.
// In other words, check if there is a cell where
// any number can't locate.
fileprivate func hasContradiction(sudoku: Sudoku, candidateMatrix: CandidateMatrix) -> Bool {
    let ss = sudoku.size * sudoku.size
    
    // check if there is a cell that has no candidate-numbers
    for i in 0..<ss {
        for j in 0..<ss {
            if sudoku[i,j] == 0 && candidateMatrix.hasNoCandidate(row: i, col: j) {
                return true
            }
        }
    }
    
    // check if there is a number in a block, row or column
    // that has no candidate-locations
    for k in 0..<ss {
        let candidateLocsInBlock = makeCandidateLocsInBlock(candidateMatrix: candidateMatrix, block: k)
        let candidateLocsInRow = makeCandidateLocsInRow(candidateMatrix: candidateMatrix, row: k)
        let candidateLocsInCol = makeCandidateLocsInCol(candidateMatrix: candidateMatrix, col: k)
        let numInBlock = sudoku.getBlockAsArray(block: k)
        let numInRow = sudoku.getRow(row: k)
        let numInCol = sudoku.getCol(col: k)
        for n in 1...ss {
            if !numInBlock.contains(n) && candidateLocsInBlock[n]?.count == 0 {
                return true
            }
            if !numInRow.contains(n) && candidateLocsInRow[n]?.count == 0 {
                return true
            }
            if !numInCol.contains(n) && candidateLocsInCol[n]?.count == 0 {
                return true
            }
        }
    }
    
    return false
}

