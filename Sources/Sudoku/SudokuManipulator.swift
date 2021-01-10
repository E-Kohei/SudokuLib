//
//  SudokuManipulator.swift
//

//
//  Created by 江崎航平 on 2020/12/09.
//
//  Fundamental transformations of sudoku.
//  We regard two sudoku as "essentially same" if one can be transformed
//  into another by some sequence of these transformations.

/**
 Permute numbers (except 0) in sudoku
 */
public func permuteNumbers(sudoku: Sudoku, permutation: [Int:Int]) {
    let size = sudoku.size
    if !isValidPermutation(permutation, from: 1, through: size*size) {
        return
    }
    for cell in getAllCells(size: size) {
        let oldN = sudoku[cell.row, cell.col]
        if let newN = permutation[oldN], oldN != 0 {
            sudoku[cell.row, cell.col] = newN
        }
    }
}

/**
 Axis by which you reflect sudoku
 */
public enum ReflectAxis {
    case vertical
    case horizontal
    case diagonal
    
    static let allAxis: [ReflectAxis] = [.vertical, .horizontal, .diagonal]
}

/**
 Reflect sudoku
 */
public func reflectSudoku(sudoku: Sudoku, axis: ReflectAxis) {
    let size = sudoku.size
    let reversePermutation = Dictionary<Int,Int>(
        uniqueKeysWithValues: zip(0..<size, stride(from: size-1, through: 0, by: -1)))
    switch axis {
    case .vertical:
        permuteBlockCols(sudoku: sudoku, permutation: reversePermutation)
        for bCol in 0..<size {
            permuteOneBlockCol(sudoku: sudoku, bCol: bCol, permutation: reversePermutation)
        }
    case .horizontal:
        permuteBlockRows(sudoku: sudoku, permutation: reversePermutation)
        for bRow in 0..<size {
            permuteOneBlockRow(sudoku: sudoku, bRow: bRow, permutation: reversePermutation)
        }
    case .diagonal:
        let tmp = Sudoku(size: size)
        for cell in getAllCells(size: size) {
            tmp[cell.row, cell.col] = sudoku[cell.col, cell.row]
        }
        for cell in getAllCells(size: size) {
            sudoku[cell.row, cell.col] = tmp[cell.row, cell.col]
        }
    }
}

/**
 Rotate sudoku (left rotation)
 */
public func rotateSudoku(sudoku: Sudoku, numRotation: Int) {
    let ss = sudoku.size * sudoku.size
    for _ in 0..<numRotation {
        // rotate outside cells and then inside cells
        for i in 0..<ss/2 {
            for j in i..<ss-1-i {
                let tmpNum = sudoku[i, j]
                sudoku[i, j] = sudoku[j, ss-1-i]
                sudoku[j, ss-1-i] = sudoku[ss-1-i, ss-1-j]
                sudoku[ss-1-i, ss-1-j] = sudoku[ss-1-j, i]
                sudoku[ss-1-j, i] = tmpNum
            }
        }
    }
}

/**
 Permute block-rows in sudolu
 */
public func permuteBlockRows(sudoku: Sudoku, permutation: [Int:Int]) {
    let size = sudoku.size
    if !isValidPermutation(permutation, from: 0, through: size-1) {
        return
    }
    let tmp = Sudoku(size: size)
    for bRow in 0..<size {
        let bRow2 = permutation[bRow]!
        for bCol in 0..<size {
            tmp.setBlock(block: bRow2*size + bCol,
                         newBlock: sudoku.getBlock(block: bRow*size + bCol))
        }
    }
    for b in 0..<size*size {
        sudoku.setBlock(block: b, newBlock: tmp.getBlock(block: b))
    }
}

/**
 Permute block-columns in sudoku
 */
public func permuteBlockCols(sudoku: Sudoku, permutation: [Int:Int]) {
    let size = sudoku.size
    if !isValidPermutation(permutation, from: 0, through: size-1) {
        return
    }
    let tmp = Sudoku(size: size)
    for bCol in 0..<size {
        let bCol2 = permutation[bCol]!
        for bRow in 0..<size {
            tmp.setBlock(block: bRow*size + bCol2,
                         newBlock: sudoku.getBlock(block: bRow*size + bCol))
        }
    }
    for b in 0..<size*size {
        sudoku.setBlock(block: b, newBlock: tmp.getBlock(block: b))
    }
}

/**
 Permute rows in one block-row (bRow) in sudoku
 */
public func permuteOneBlockRow(sudoku: Sudoku, bRow: Int, permutation: [Int:Int]) {
    let size = sudoku.size
    if !isValidPermutation(permutation, from: 0, through: size-1) {
        return
    }
    let tmp = Sudoku(size: size)
    let startRow = bRow * size
    for i in 0..<size {
        for j in 0..<size*size {
            let n = sudoku[startRow + i, j]
            tmp[startRow + permutation[i]!, j] = n
        }
    }
    for i in startRow..<startRow+size {
        for j in 0..<size*size {
            sudoku[i,j] = tmp[i,j]
        }
    }
}

/**
 Permute columns in one block-column (bCol) in sudoku
 */
public func permuteOneBlockCol(sudoku: Sudoku, bCol: Int, permutation: [Int:Int]) {
    let size = sudoku.size
    if !isValidPermutation(permutation, from: 0, through: size-1) {
        return
    }
    let tmp = Sudoku(size: size)
    let startCol = bCol * size
    for i in 0..<size*size {
        for j in 0..<size {
            let n = sudoku[i, startCol + j]
            tmp[i, startCol + permutation[j]!] = n
        }
    }
    for i in 0..<size*size {
        for j in startCol..<startCol+size {
            sudoku[i,j] = tmp[i,j]
        }
    }
}


/**
 Create contradiction matrix of the sudoku, whose element indicates whether the number at the cell
 duplicates another cell's number in the same row, column or block.
 */
public func findContradictions(sudoku: Sudoku) -> [[Bool]] {
    let size = sudoku.size
    let ss = size * size
    var contradictionM = Array(repeating: Array(repeating: false, count: ss), count: ss)
    
    for k in 0..<ss {
        var indicators: [Bool]
        
        // check same numbers in the row
        indicators = findDuplicateNumbersInArray(array: sudoku.getRow(row: k))
        for l in 0..<ss {
            if indicators[l] {
                contradictionM[k][l] = indicators[l]
            }
        }
        
        // check same numbers in the column
        indicators = findDuplicateNumbersInArray(array: sudoku.getCol(col: k))
        for l in 0..<ss {
            if indicators[l] {
                contradictionM[l][k] = indicators[l]
            }
        }
        
        // check same numbers in the block
        let startRow = size * (k / size)
        let startCol = size * (k % size)
        indicators = findDuplicateNumbersInArray(array: sudoku.getBlockAsArray(block: k))
        for l1 in 0..<size {
            for l2 in 0..<size {
                if indicators[size*l1 + l2] {
                    contradictionM[startRow+l1][startCol+l2] = indicators[size*l1 + l2]
                }
            }
        }
        
    }
    
    return contradictionM
}

/**
 Update contradiction matrix of the sudoku, whose element indicates whether the number at the cell
 duplicates another cell's number in the same row, column or block.
 If the size of the sudoku and that of contradiction matrix, this function fails.
 */
public func findContradictions(sudoku: Sudoku, contradictionMatrix: inout [[Bool]]) {
    let size = sudoku.size
    let ss = size * size
    
    for k in 0..<ss {
        var indicators: [Bool]
        
        // check same numbers in the row
        indicators = findDuplicateNumbersInArray(array: sudoku.getRow(row: k))
        for l in 0..<ss {
            if indicators[l] {
                contradictionMatrix[k][l] = indicators[l]
            }
        }
        
        // check same numbers in the column
        indicators = findDuplicateNumbersInArray(array: sudoku.getCol(col: k))
        for l in 0..<ss {
            if indicators[l] {
                contradictionMatrix[l][k] = indicators[l]
            }
        }
        
        // check same numbers in the block
        let startRow = size * (k / size)
        let startCol = size * (k % size)
        indicators = findDuplicateNumbersInArray(array: sudoku.getBlockAsArray(block: k))
        for l1 in 0..<size {
            for l2 in 0..<size {
                if indicators[size*l1 + l2] {
                    contradictionMatrix[startRow+l1][startCol+l2] = indicators[size*l1 + l2]
                }
            }
        }
        
    }
}


// Check if the given permutation is valid
private func isValidPermutation(_ permutation: [Int:Int], from: Int, through: Int) -> Bool {
    if permutation.count != through - from + 1 {
        return false
    }
    var mappedNumbers = Set<Int>()
    for n in from...through {
        if let mappedTo = permutation[n] {
            mappedNumbers.insert(mappedTo)
        }
        else {
            return false
        }
    }
    if !mappedNumbers.isSuperset(of: from...through) {
        return false
    }
    return true
}

// True if a number is same as some of others
private func findDuplicateNumbersInArray(array: [Int]) -> [Bool] {
    let len = array.count
    var sorted = [(index: Int, element: Int)]()
    for (n,x) in array.enumerated() {
        sorted.append((n,x))
    }
    sorted.sort(by: { return $0.element < $1.element })
    var indicators = Array(repeating: false, count: array.count)
    
    // now, find duplicate numbers
    for i in 1..<len {
        let prev = sorted[i-1]
        let next = sorted[i]
        if prev.element == next.element {
            indicators[prev.index] = true
            indicators[next.index] = true
        }
    }
    return indicators
}
