//
//  Sudoku.swift
//
//
//  Created by 江崎航平 on 2020/11/29.
//

public class Sudoku: CustomStringConvertible, Hashable {
    
    public var description: String {
        let ss = size*size
        let digitLen: Int = ss / 10 + 1
        var s: String = ""
        // delimiter between size x size blocks
        var delimiter: String = ""
        for _ in 0 ..< (digitLen+1)*ss + 2*(size-1) - 1 {
            delimiter += "-"
        }
        for i in 0..<ss {
            if i != 0 && i%size == 0 {
                s += delimiter
                s += "\n"
            }
            for j in 0..<ss {
                if (j != 0 && j%size == 0) {
                    s += "| "
                }
                let numS = String(numbers[i][j])
                s += String(repeating: " ", count: digitLen - numS.count) + numS + " "
            }
            s += "\n"
        }
        return s
    }
    
    private var numbers = [[Int]]()         // numbers of sudoku
                                            // 0 means blank
    private var fixedNumbers = [[Bool]]()   // bool matrix that denies change of numbers
    public private(set) var size: Int                   // size of one block
    
    /**
     Constructor to make initialized sudoku (all numbers are 0)
     */
    public init(size: Int) {
        self.size = size
        let ss = size*size
        // create sudoku which is yet to be initialized and set them unfixed (all numbers are 0)
        for _ in 0..<ss {
            numbers.append( Array(repeating: 0, count: ss) )
            fixedNumbers.append( Array(repeating: false, count: ss) )
        }
    }
    
    /**
     Constructor to make sudoku from 2d-array
     */
    public init(nums: [[Int]], size: Int) throws {
        self.size = size
        let ss = size*size
        
        if checkInvalidSize(nums, ss) {
            throw InvalidSudokuSizeError()
        }
        else {
            numbers = nums
            for i in 0..<ss {
                fixedNumbers.append( numbers[i].map {
                    return $0 != 0
                } )
            }
        }
    }
    
    /**
     Constructor to make sudoku from 2 kind of 2d-arrays
     */
    public init(nums: [[Int]], fnums: [[Bool]], size: Int) throws {
        self.size = size
        let ss = size*size
        
        if checkInvalidSize(nums, ss) || checkInvalidSize(fnums, ss) {
            throw InvalidSudokuSizeError()
        }
        else {
            numbers = nums
            fixedNumbers = fnums
        }
    }
    
    public static func ==(lhs: Sudoku, rhs: Sudoku) -> Bool {
        return lhs.numbers == rhs.numbers && lhs.fixedNumbers == rhs.fixedNumbers
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(numbers)
        hasher.combine(fixedNumbers)
    }
    
    public subscript(i: Int, j: Int) -> Int {
        get {
            return numbers[i][j]
        }
        set {
            numbers[i][j] = newValue
        }
    }
    
    /**
     returns a copy of this sudoku
     */
    public func copy() -> Sudoku {
        let s = Sudoku(size: self.size)
        s.numbers = self.numbers
        s.fixedNumbers = self.fixedNumbers
        return s
    }
    
    /**
     copies a sudoku "from" to another sudoku "to" if they have same size, else throws an error.
     */
    class func copySudoku(from: Sudoku, to: Sudoku) throws {
        if from.size != to.size {
            throw InvalidSudokuSizeError(message: "Sudoku size mismatch")
        }
        to.numbers = from.numbers
        to.fixedNumbers = from.fixedNumbers
    }
    
    /**
     returns i-th row
     */
    public func getRow(row: Int) -> [Int] {
        return numbers[row]
    }
    
    /**
     returns j-th column
     */
    public func getCol(col: Int) -> [Int] {
        var column = [Int]()
        for array in numbers {
            column.append(array[col])
        }
        return column
    }
    
    /**
     sets n at numbers[i][j] if the cell is not fixed and return whether succeeded
     */
    @discardableResult
    public func setNumber(row: Int, col: Int, number: Int) -> Bool {
        if (!fixedNumbers[row][col]) {
            numbers[row][col] = number
            return true
        }
        else {
            return false
        }
    }
    
    /**
     returns block number from location (row,col)
     */
    public func getBlockNumberFromLoc(row: Int, col: Int) -> Int {
        return (row / size) * size + (col / size)
    }
    
    /**
     returns block number from location (row,col)
     */
    public static func getBlockNumberFromLoc(row: Int, col: Int, size: Int) -> Int {
        return (row / size) * size + (col / size)
    }
    
    /*
     returns matrix of numbers in b-th block
     */
    public func getBlock(block: Int) -> [[Int]] {
        var matrix = [[Int]]()
        var row = Array(repeating: 0, count: size)
        for i in 0..<size {
            for j in 0..<size{
                row[j] = numbers[i + size*(block/size)][j + size*(block%size)]
            }
            matrix.append(row)
        }
        return matrix
    }
    
    /**
     returns array of numbers in b-th block
     */
    public func getBlockAsArray(block: Int) -> [Int] {
        var array = [Int]()
        for i in 0..<size {
            for j in 0..<size {
                array.append(numbers[i + size*(block/size)][j + size*(block%size)])
            }
        }
        return array
    }
    
    /**
     sets matrix of numbers in b-th block
     */
    public func setBlock(block: Int, newBlock: [[Int]]) {
        for i in 0..<size {
            for j in 0..<size {
                numbers[i + size*(block/size)][j + size*(block%size)] = newBlock[i][j]
            }
        }
    }
    
    /**
     fix the cell (row,col)
     */
    public func fixCell(row: Int, col: Int, isFixed: Bool) {
        fixedNumbers[row][col] = isFixed
    }
    
    /**
     return if the cell is fixed
     */
    public func isFixedCell(row: Int, col: Int) -> Bool {
        return fixedNumbers[row][col]
    }
    
    /**
     fix cells where some number is already set
     */
    public func fixNumbers() {
        let ss = size*size
        for i in 0..<ss {
            for j in 0..<ss {
                if numbers[i][j] != 0 {
                    fixedNumbers[i][j] = true
                }
            }
        }
    }
    
    /**
     reset fixedNumbers to allow any change
     */
    public func resetFixedNumbers() {
        let ss = size*size
        for i in 0..<ss {
            for j in 0..<ss {
                fixedNumbers[i][j] = false
            }
        }
    }
    
    /**
     reset sudoku, that is set all unfixed numbers 0
     */
    public func resetSudoku() {
        let ss = size*size
        for i in 0..<ss {
            for j in 0..<ss {
                if !fixedNumbers[i][j] {
                    numbers[i][j] = 0
                }
            }
        }
    }
    
    /**
     checks if the sudoku is already solved
     */
    public func isSolved() -> Bool {
        let ss = size*size
        // if any of row. col, and block contains 1,2,...,size*size,
        // then the sudoku is solved
        let allNumbers = Set(1...ss)
        for n in 0..<ss {
            if !allNumbers.isSubset(of: getRow(row: n)) {
                return false
            }
            if !allNumbers.isSubset(of: getCol(col: n)) {
                return false
            }
            if !allNumbers.isSubset(of: getBlockAsArray(block: n)) {
                return false
            }
        }
        return true
    }
    
    private func checkInvalidSize(_ matrix: [[Any]], _ ss: Int) -> Bool {
        if matrix.count != ss {
            return true
        }
        for array in matrix {
            if array.count != ss {
                return true
            }
        }
        return false
    }
}


public struct Cell: Hashable {
    public var row: Int
    public var col: Int
    
    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(col)
    }
}


public struct InvalidSudokuSizeError: Error {
    public var message = "Invalid size for sudoku"
}


/* Other useful functions */

/// returns array of cells which is included in the row
public func getRowCells(size: Int, row: Int) -> [Cell] {
    var cells = [Cell]()
    let ss = size*size
    for j in 0..<ss {
        cells.append(Cell(row: row, col: j))
    }
    return cells
}

/// returns array of cells which is included in the column
public func getColCells(size: Int, col: Int) -> [Cell] {
    var cells = [Cell]()
    let ss = size*size
    for i in 0..<ss {
        cells.append(Cell(row: i, col: col))
    }
    return cells
}

/// returns array of cells which is included in the block
public func getBlockCells(size: Int, block: Int) -> [Cell] {
    var cells = [Cell]()
    let startRow = size * (block / size)
    let startCol = size * (block % size)
    for i in startRow..<startRow+size {
        for j in startCol..<startCol+size {
            cells.append(Cell(row: i, col: j))
        }
    }
    return cells
}

/// returns array of cells generated by cartesian product of rows and columns
public func getCellsFromRowsAndCols<T1: Sequence,T2: Sequence>(rows: T1, cols: T2) -> [Cell]
where T1.Element==Int, T2.Element == Int{
    var cells = [Cell]()
    for row in rows {
        for col in cols {
            cells.append(Cell(row: row, col: col))
        }
    }
    return cells
}

/// returns all cells in the sudoku
public func getAllCells(size: Int) -> [Cell] {
    let ss = size*size
    var cells = [Cell]()
    for i in 0..<ss {
        for j in 0..<ss {
            cells.append(Cell(row: i, col: j))
        }
    }
    return cells
}
