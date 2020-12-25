//
//  SudokuSolver.swift
//  
//
//  Created by 江崎航平 on 2020/11/29.
//

/*          Overview of solveSudoku
 *  solveSudoku solves sudoku literally, by updating "NumCandidates"
 * which has information about which number should be located on
 * a cell. The algorithm is as follows:
 *
 * Step 1. --firstUpdateNumCandidates--
 *         Initialize NumCandidates from the unchanged sudoku.
 *
 * Step 2. --updateNumCandidates--
 *         For location (i,j), if a number n is in the row i, in the
 *         column j, or in the block b, n can't be located in (i,j).
 *         Considering this condition, update NumCandidates from the
 *         current sudoku.
 *         (In the first loop, this is verbose step)
 *
 * Step 3. --checkCandidateNums--
 *         For each location, check if the number of candidate-numbers
 *         is one. If so, n is determined
 *
 * Step 4. --findSameCandidateNumsInBlock etc.--
 *         Find locations which have same candidate-numbers in
 *         common in a block, row and column. If the count of
 *         such locations is equal to the count of candidate-numbers,
 *         those numbers can't be located in the other locations
 *         in the block, row or column.
 *
 * Step 5-1. --checkCandidateLocs--
 *           Make Dictionary of candidate-locations from NumCandidates,
 *           and check its uniqueness for each number
 *
 * Step 5-2. --findHiddenBlock etc.--
 *           Using the Dictionary mentioned above, find a block, row,
 *           or column only in which candidate-locations for n are.
 *           If found, n can't be located in the block, row or column
 *           except the candidate-locations
 *
 * Step 5-3. --findSameCandidateLocs--
 *           Using the Dictionary mentioned above, find numbers which
 *           have same candidate-locations in common in a block, row,
 *           or column. If the count of such numbers is equal to the
 *           count of candidate-locations, those numbers can't be
 *           located in the other locations.
 *           (This is reverse approach of Step 4)
 *
 * Step 6. --findSameRowsInBlockRow etc.--
 *         In a block row, find rows over blocks which have
 *         candidate-locations of n. If the count of rows is euqal to
 *         the count of blocks where the rows are cadidate of n, the
 *         number can't be located in the rows in the other blocks.
 *
 * Step 7. --XWing--
 *         Check if some rows have same candidate-locations for n.
 *         If the count of such rows are equal to the count of
 *         candidate-locations for n, n can't be located in the other
 *         other rows.
 *
 * Step 8. If sudoku is solved, return the solved sudoku.
 *         If sudoku is unsolved and NumCandidates is updating,
 *         repeat the loop of Step 2 ~ Step 7.
 *         If sudoku is unsolved and NumCandidates is not updated
 *         anymore, return original sudoku and exit, since this means
 *         this program cannot solve the sudoku anymore.
 */


// Square matrix of bits which represents whether some number is candidate at a certain location.
class CandidateMatrix: Equatable {
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

/**
 solve sudoku which is solvable without any trials
 */
public func solveSudoku(sudoku: Sudoku) -> (isSolved: Bool, answer: Sudoku) {
    let size = sudoku.size
    let ss = size*size
    let solvedS = sudoku.copy()
    
    // An array which stores indicators of candidate-numbers of
    // each location.
    let NumCandidates = CandidateMatrix(size: size)
    
    while (true) {
        // remember previous candidate matrix
        let prevNumCandidates = NumCandidates.copy()
        
        // update solvedS and NumCandidates
        solveSudokuFunctionSet(solvedS, NumCandidates, size, ss)
        
        // check if the sudoku is solved or no change with NumCandidates
        if solvedS.isSolved() {
            return (isSolved: true, answer: solvedS)
        }
        else if prevNumCandidates == NumCandidates {
            return (isSolved: false, answer: solvedS)
        }
    }
}

public enum SudokuStatus {
    case solvable
    case unsolvable
    case fewNumbers
    case hasSomeSolutions
    case unknown
}


/**
 solve sudoku with trials if needed, and return the answer and its status
 */
public func solveSudokuWithTrials(sudoku: Sudoku)
-> (status: SudokuStatus, answer: Sudoku?) {
    
    // firstly check if this sudoku has more numbers than "gold number" 17
    if !hasNumbersMoreThan17(sudoku: sudoku) {
        return (status: SudokuStatus.fewNumbers, answer: nil)
    }
    
    let size = sudoku.size
    let ss = size*size
    let solvedS = sudoku.copy()
    
    // An array which stores indicators of candidate-numbers of
    // each location.
    let NumCandidates = CandidateMatrix(size: size)
    
    while (true) {
        // remember previous candidate matrix
        let prevNumCandidates = NumCandidates.copy()
        
        // update solvedS and NumCandidates
        solveSudokuFunctionSet(solvedS, NumCandidates, size, ss)
        
        // the sudoku is solvable
        if solvedS.isSolved() {
            return (SudokuStatus.solvable, solvedS)
        }
        // the sudoku has contradiction (there is a cell where
        // any number can't be locate or there is a number that
        // can't be locate at any cells in block, row or column)
        else if prevNumCandidates == NumCandidates &&
                hasContradiction(sudoku: solvedS, candidateMatrix: NumCandidates) {
            return (SudokuStatus.unsolvable, nil)
        }
        // the sudoku can't be solved anymore by current hints:
        // need some assumption
        else if prevNumCandidates == NumCandidates {
            
            // take trace of the count of sudokus each of which must be
            // solvable, unsolvable, or hasSomeSolutions
            var countOfSolvable = 0
            var countOfUnSolvable = 0
            
            var candidateAnswer: Sudoku = Sudoku(size: 3)
            
            // Array of solved sudokus by assuming some number
            //var solvedSudokus = [(SudokuStatus, Sudoku)]()
            
            // start with easy assumptions
            findbranch: for countOfCandidateNums in 2 ..< ss {
                for cell in getAllCells(size: size) {
                    let candidateNumsAtTheCell = NumCandidates.getCandidateNumbers(cell: cell)
                    if candidateNumsAtTheCell.count == countOfCandidateNums {
                        for k in 0..<countOfCandidateNums {
                            let assumedSudoku = solvedS.copy()
                            assumedSudoku[cell.row,cell.col] = candidateNumsAtTheCell[k]
                            let (status, answer) = solveSudokuWithTrials(sudoku: assumedSudoku)
                            switch status {
                            case .solvable:
                                countOfSolvable += 1
                                candidateAnswer = answer!
                                break
                            case .unsolvable:
                                countOfUnSolvable += 1
                                break
                            case .hasSomeSolutions:  // This result is same as that of the callee of this function
                                return (status, answer)  // This must be (.hasSomeSolutions, nil)
                            default:
                                return (.unknown, nil)
                            }
                            //solvedSudokus.append((status, answer))
                            if countOfSolvable >= 2 {
                                return (.hasSomeSolutions, nil)
                            }
                        }
                        // it's enough to find one branch point
                        break findbranch
                    }
                }
            }
            
            // here is reached if there is only one solution or no solutions
            if countOfSolvable == 1 {
                return (.solvable, candidateAnswer)
            }
            else {
                return (.unsolvable, nil)
            }
        }
        
    }
}

/**
 Check if the sudoku is solvable, unsolvable. or has some solutions.
 */
public func analyzeSudoku(sudoku: Sudoku) -> SudokuStatus {
    // firstly check if this sudoku has more numbers than "gold number" 17
    if !hasNumbersMoreThan17(sudoku: sudoku) {
        return .fewNumbers
    }
    
    let size = sudoku.size
    let ss = size*size
    let solvedS = sudoku.copy()
    
    // An array which stores indicators of candidate-numbers of
    // each location.
    let NumCandidates = CandidateMatrix(size: size)
    
    while (true) {
        // remember previous candidate matrix
        let prevNumCandidates = NumCandidates.copy()
        
        // update solvedS and NumCandidates
        solveSudokuFunctionSet(solvedS, NumCandidates, size, ss)
        
        // the sudoku is solvable
        if solvedS.isSolved() {
            return .solvable
        }
        // the sudoku has contradiction (there is a cell where
        // any number can't be locate or there is a number that
        // can't be locate at any cells in block, row or column)
        else if prevNumCandidates == NumCandidates &&
                hasContradiction(sudoku: solvedS, candidateMatrix: NumCandidates) {
            return .unsolvable
        }
        // the sudoku can't be solved anymore by current hints:
        // need some assumption
        else if prevNumCandidates == NumCandidates {
            
            // take trace of the count of sudokus each of which must be
            // solvable, unsolvable, or hasSomeSolutions
            var countOfSolvable = 0
            var countOfUnSolvable = 0
            
            // Array of solved sudokus by assuming some number
            //var solvedSudokus = [(SudokuStatus, Sudoku)]()
            
            // start with easy assumptions
            findbranch: for countOfCandidateNums in 2 ..< ss {
                for cell in getAllCells(size: size) {
                    let candidateNumsAtTheCell = NumCandidates.getCandidateNumbers(cell: cell)
                    if candidateNumsAtTheCell.count == countOfCandidateNums {
                        for k in 0..<countOfCandidateNums {
                            let assumedSudoku = solvedS.copy()
                            assumedSudoku[cell.row,cell.col] = candidateNumsAtTheCell[k]
                            let status = analyzeSudoku(sudoku: assumedSudoku)
                            switch status {
                            case .solvable:
                                countOfSolvable += 1
                                break
                            case .unsolvable:
                                countOfUnSolvable += 1
                                break
                            case .hasSomeSolutions:  // This result is same as that of the callee of this function
                                return status  // This must be .hasSomeSolutions
                            default:
                                return .unknown
                            }
                            //solvedSudokus.append((status, answer))
                            if countOfSolvable >= 2 {
                                return .hasSomeSolutions
                            }
                        }
                        // it's enough to find one branch point
                        break findbranch
                    }
                }
            }
            
            // here is reached if there is only one solution or no solutions
            if countOfSolvable == 1 {
                return .solvable
            }
            else {
                return .unsolvable
            }
        }
        
    }
}




/* private functions to solve sudoku */


// Core algorithm of solving sudoku.
// This function updates solvedS and NumCandidates to solve the sudoku.
// Note that both Sudoku and CandidateMatrix are reference type.
func solveSudokuFunctionSet(_ solvedS: Sudoku, _ NumCandidates: CandidateMatrix, _ size: Int, _ ss: Int) {
    updateNumCandidates(sudoku: solvedS, candidateMatrix: NumCandidates)
    
    checkCandidateNums(sudoku: solvedS, candidateMatrix: NumCandidates)
    
    findLocsWithSameCandidateNums(candidateMatrix: NumCandidates)
    
    for b in 0..<ss {
        let CandidateLocsInB = makeCandidateLocsInBlock(candidateMatrix: NumCandidates, block: b)
        checkCandidateLocs(sudoku: solvedS, candidateLocs: CandidateLocsInB)
        findHiddenRowAndCol(candidateLocs: CandidateLocsInB, candidateMatrix: NumCandidates)
        findNumsWithSameCandidateLocs(candidateLocs: CandidateLocsInB, candidateMatrix: NumCandidates)
    }
    for row in 0..<ss {
        let CandidateLocsInRow = makeCandidateLocsInRow(candidateMatrix: NumCandidates, row: row)
        checkCandidateLocs(sudoku: solvedS, candidateLocs: CandidateLocsInRow)
        findHiddenBlock(candidateLocs: CandidateLocsInRow, candidateMatrix: NumCandidates)
        findNumsWithSameCandidateLocs(candidateLocs: CandidateLocsInRow, candidateMatrix: NumCandidates)
    }
    for col in 0..<ss {
        let CandidateLocsInCol = makeCandidateLocsInCol(candidateMatrix: NumCandidates, col: col)
        checkCandidateLocs(sudoku: solvedS, candidateLocs: CandidateLocsInCol)
        findHiddenBlock(candidateLocs: CandidateLocsInCol, candidateMatrix: NumCandidates)
        findNumsWithSameCandidateLocs(candidateLocs: CandidateLocsInCol, candidateMatrix: NumCandidates)
    }
    
    for bLine in 0..<size {
        findRowsWithSameCandidateNumInBlockRow(candidateMatrix: NumCandidates, bRow: bLine)
        findColsWithSameCandidateNumInBlockCol(candidateMatrix: NumCandidates, bCol: bLine)
    }
    
    xwingRow(candidateMatrix: NumCandidates)
    xwingCol(candidateMatrix: NumCandidates)
}


// Update data for NumCandidates
// For each location (i,j), check whether each number can be a candidate
// in the location. To check this, firstly check if (i,j) is empty,
// and them, check if the number is not involved in "checkList" which
// contains all numbers in the i-th row, the j-th column, and the block
// which includes (i,j). If so, it means the location is a
// candidate-location of the number n. (In other words, the number n
// is a candidate-number of the location (i,j).)
func updateNumCandidates(sudoku: Sudoku, candidateMatrix: CandidateMatrix) {
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
func makeCandidateLocsInBlock(candidateMatrix: CandidateMatrix, block: Int) -> [Int:Set<Cell>] {
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
func makeCandidateLocsInRow(candidateMatrix: CandidateMatrix, row: Int) -> [Int:Set<Cell>] {
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
func makeCandidateLocsInCol(candidateMatrix: CandidateMatrix, col: Int) -> [Int:Set<Cell>] {
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
func checkCandidateLocs(sudoku: Sudoku, candidateLocs: [Int:Set<Cell>]) {
    
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
func checkCandidateNums(sudoku: Sudoku, candidateMatrix: CandidateMatrix) {
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
func findHiddenRowAndCol(candidateLocs: [Int:Set<Cell>], candidateMatrix: CandidateMatrix) {
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
func findHiddenBlock(candidateLocs: [Int:Set<Cell>], candidateMatrix: CandidateMatrix) {
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


func findLocsWithSameCandidateNums(candidateMatrix: CandidateMatrix) {
    let ss = candidateMatrix.size * candidateMatrix.size
    for k in 0..<ss {
        findLocsWithSameCandidateNumsInRow(candidateMatrix: candidateMatrix, row: k)
        findLocsWithSameCandidateNumsInCol(candidateMatrix: candidateMatrix, col: k)
        findLocsWithSameCandidateNumsInBlock(candidateMatrix: candidateMatrix, block: k)
    }
}

// In a block, find the locations that have same candidate-numbers.
func findLocsWithSameCandidateNumsInBlock(candidateMatrix: CandidateMatrix, block: Int) {
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
func findLocsWithSameCandidateNumsInRow(candidateMatrix: CandidateMatrix, row: Int) {
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
func findLocsWithSameCandidateNumsInCol(candidateMatrix: CandidateMatrix, col: Int) {
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
func findNumsWithSameCandidateLocs(candidateLocs: [Int:Set<Cell>], candidateMatrix: CandidateMatrix)
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
func findRowsWithSameCandidateNumInBlockRow(candidateMatrix: CandidateMatrix, bRow: Int) {
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
func findColsWithSameCandidateNumInBlockCol(candidateMatrix: CandidateMatrix, bCol: Int) {
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
func xwingRow(candidateMatrix: CandidateMatrix) {
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
func xwingCol(candidateMatrix: CandidateMatrix) {
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
func hasNumbersMoreThan17(sudoku: Sudoku) -> Bool {
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
func hasContradiction(sudoku: Sudoku, candidateMatrix: CandidateMatrix) -> Bool {
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
