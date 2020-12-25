//
//  SudokuMaker.swift
//  
//
//  Created by 江崎航平 on 2020/12/10.
//
//  Utlity functions to make sudoku puzzle.

/**
 Make sudoku from valid sudoku as a puzzle by manipluating it randomly.
 */
public func makeSudokuFromPuzzle(sudoku: Sudoku) -> Sudoku {
    let sudokuQ = sudoku.copy()
    transformSudokuRandomly(sudoku: sudokuQ)
    return sudokuQ
}

/**
 Make sudoku from solved sudoku by scraping numbers randomly.
 */
public func makeSudokuFromSolution(sudoku: Sudoku) -> Sudoku {
    let size = sudoku.size
    let ss = size*size
    let sudokuQ = sudoku.copy()
    if !sudokuQ.isSolved() {
        return sudokuQ
    }
    // continue trying to scrape until the sudokuQ is solvable
    while true {
        let i = Int.random(in: 0..<ss)
        let j = Int.random(in: 0..<ss)
        let n1 = sudokuQ[i,j]
        let n2 = sudokuQ[ss-1-i,ss-1-j]
        sudokuQ[i,j] = 0
        sudokuQ[ss-1-i,ss-1-j] = 0
        if analyzeSudoku(sudoku: sudokuQ) != .solvable {
            sudokuQ[i,j] = n1
            sudokuQ[ss-1-i,ss-1-j] = n2
            return sudokuQ
        }
    }
}

/**
 Transform sudoku randomly
 */
public func transformSudokuRandomly(sudoku: Sudoku) {
    let size = sudoku.size
    // permute numbers randomly
    let numPermutation = makeRandomPermutation(from: 1, through: size*size)
    permuteNumbers(sudoku: sudoku, permutation: numPermutation)
    // reflect, rotate or permute rows and columns randomly
    let count = Int.random(in: 10...50)
    for _ in 0..<count {
        let operation = Int.random(in: 0..<7)
        let permutation = makeRandomPermutation(from: 0, through: size-1)
        switch operation {
        case 0:  // do nothing
            break
        case 1:  // reflect
            reflectSudoku(sudoku: sudoku, axis: ReflectAxis.allAxis.randomElement()!)
        case 2:  // rotate
            rotateSudoku(sudoku: sudoku, numRotation: Int.random(in: 1...3))
        case 3:  // permute block-rows
            permuteBlockRows(sudoku: sudoku, permutation: permutation)
        case 4:  // permute block-columns
            permuteBlockCols(sudoku: sudoku, permutation: permutation)
        case 5:  // permute rows in a block-row
            permuteOneBlockRow(sudoku: sudoku, bRow: Int.random(in: 0..<size), permutation: permutation)
        case 6:  // permute columns in a block-column
            permuteOneBlockCol(sudoku: sudoku, bCol: Int.random(in: 0..<size), permutation: permutation)
        default:
            break
        }
    }
}

/**
 Transform sudoku randomly keeping its symmetry
 */
public func transformSudokuKeepingSymmetry(sudoku: Sudoku) {
    let size = sudoku.size
    // permute numbers randomly
    let numPermutation = makeRandomPermutation(from: 1, through: size*size)
    permuteNumbers(sudoku: sudoku, permutation: numPermutation)
    // reflect, rotate or permute rows and columns randomly keeping symmetry
    let count = Int.random(in: 10...50)
    for _ in 0..<count {
        let operation = Int.random(in: 0..<7)
        switch operation {
        case 0:
            // do nothing
            break
        case 1:
            //reflect
            reflectSudoku(sudoku: sudoku, axis: ReflectAxis.allAxis.randomElement()!)
        case 2:
            // rotate
            rotateSudoku(sudoku: sudoku, numRotation: Int.random(in: 1...3))
        case 3:
            // permute block-rows symmetrically
            let symmetricalP = makeSymmetricalRandomPermutation(from: 0, through: size-1)
            permuteBlockRows(sudoku: sudoku, permutation: symmetricalP)
        case 4:
            // permute block-columns symmetrically
            let symmetricalP = makeSymmetricalRandomPermutation(from: 0, through: size-1)
            permuteBlockCols(sudoku: sudoku, permutation: symmetricalP)
        case 5:
            // permute rows in one block-row
            let bRow = Int.random(in: 0..<size)
            // if the bRow is the center of the block-rows (e.g., size = 5 and bRow = 2),
            // permute rows only in the block-row
            if size % 2 == 1 && bRow == size/2 {
                let symmetricalP = makeSymmetricalRandomPermutation(from: 0, through: size-1)
                permuteOneBlockRow(sudoku: sudoku, bRow: bRow, permutation: symmetricalP)
            }
            // else, permute both bRow and size-1-bRow
            let p = makeRandomPermutation(from: 0, through: size-1)
            let reversedP = makeNumberReservedPermutation(permutation: p)
            permuteOneBlockRow(sudoku: sudoku, bRow: bRow, permutation: p)
            permuteOneBlockRow(sudoku: sudoku, bRow: size-1-bRow, permutation: reversedP)
        case 6:
            // permute columns in one block-column
            let bCol = Int.random(in: 0..<size)
            // if the bCol is the center of the block-columns (e.g., size = 3, bCol = 1),
            // permute columns only in the block-col
            if size % 2 == 1 && bCol == size/2 {
                let symmetricalP = makeSymmetricalRandomPermutation(from: 0, through: size-1)
                permuteOneBlockCol(sudoku: sudoku, bCol: bCol, permutation: symmetricalP)
            }
            // else, permute both bCol and size-1-bCol
            let p = makeRandomPermutation(from: 0, through: size-1)
            let reversedP = makeNumberReservedPermutation(permutation: p)
            permuteOneBlockCol(sudoku: sudoku, bCol: bCol, permutation: p)
            permuteOneBlockCol(sudoku: sudoku, bCol: size-1-bCol, permutation: reversedP)
        default:
            break
        }
    }
    
}

/* functions to make permutation */

// make random permutation
func makeRandomPermutation(from: Int, through: Int) -> [Int:Int] {
    let range = from...through
    let randomArray = range.shuffled()
    return Dictionary<Int,Int>(uniqueKeysWithValues: zip(range, randomArray))
}

// make symmetrical random permtation, where 'symmetrical' means symmetrical by the center of the numbers
func makeSymmetricalRandomPermutation(from: Int, through: Int) -> [Int:Int] {
    let size = through - from + 1
    let keys = Array(from...through)
    var vals = keys
    let onesidePermutation = makeRandomPermutation(from: 0, through: (size-1)/2)
    
    // bisect the numbers and permute both sides in the same order
    for i in 0..<size/2 {
        vals[i] = keys[ onesidePermutation[i]! ]
        vals[size-1-i] = keys[ size-1-onesidePermutation[i]! ]
    }
    // then, swap one element and its 'opposite' element randomly
    for _ in 0..<size {
        let index = Int.random(in: 0..<size)
        vals.swapAt(index, size-1-index)
    }
    return Dictionary<Int,Int>(uniqueKeysWithValues: zip(keys, vals))
}

// make reverse permutation of the given permutation
// e.g., [1:2, 2:4, 3:1, 4:3] -> [1:3, 2:1, 3:4, 4:2]
// if permutation is not valid, this function fails
func makeReversePermutation(permutation: [Int:Int]) -> [Int:Int] {
    var reversed = [Int:Int]()
    for (key, val) in permutation {
        reversed[val] = key
    }
    return reversed
}

// make permutation whose numbers are reversed
// e.g., [1:3, 2:1, 3:4, 4:2] -> [4:2, 3:4, 2:1, 1:3]
//       [0:1, 1:2, 2:3, 3:0] -> [3:2, 2:1, 1:0, 0:3]
// if permutation is not valid, this function fails
func makeNumberReservedPermutation(permutation: [Int:Int]) -> [Int:Int] {
    var reversed = [Int:Int]()
    let from = permutation.keys.min()!
    let through = permutation.values.max()!
    for n in from...through {
        reversed[from+through-n] = from + through - permutation[n]!
    }
    return reversed
}
