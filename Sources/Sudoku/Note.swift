//
//  Note.swift
//  
//
//  Created by 江崎航平 on 2020/11/29.
//

public struct Note: CustomStringConvertible, Hashable {
    
    public var description: String {
        let ss = size*size
        let digitLen: Int = size / 10 + 1
        var s: String = ""
        // delimiter between size x size blocks
        var delimiter: String = ""
        for _ in 0 ..< (digitLen+1)*ss + 2*(size-1) {
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
                let numS = String(notes[i][j])
                s += String(repeating: " ", count: digitLen - numS.count) + numS
            }
            s += "\n"
        }
        return s
    }
    
    private var notes = [[Int]]()   // notes of note (represented as size*size bits)
                                    // 0 means blank
    private(set) var size: Int           // size of one block. So there are size*size rows and cols
    
    /**
     Constructor to make initialized note (all notes are 0)
     */
    public init(size: Int) {
        self.size = size
        let ss = size*size
        for _ in 0..<ss {
            notes.append( Array(repeating: 0, count: ss) )
        }
    }
    /**
     Constructor to make note from 2d-array
     */
    public init(nums: [[Int]], size: Int) throws {
        self.size = size
        let ss = size*size
        if !checkSize(nums, ss) {
            throw InvalidSudokuSizeError()
        }
        else {
            notes = nums
        }
    }
    
    public static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.notes == rhs.notes
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(notes)
    }
    
    public subscript(i: Int, j: Int) -> Int {
        get {
            return notes[i][j]
        }
        set {
            notes[i][j] = newValue
        }
    }
    
    /**
     returns i-th row
     */
    public func getRow(row: Int) -> [Int] {
        return notes[row]
    }
    
    /**
     returns j-th column
     */
    public func getCol(col: Int) -> [Int] {
        var column = [Int]()
        for array in notes {
            column.append(array[col])
        }
        return column
    }
    
    /**
     returns note array at notes[row][col]
     */
    public func getNoteArray(row: Int, col: Int) -> [Int] {
        let ss = size*size
        var noteIndicators = Array(repeating: 0, count: ss)
        let noteNum = notes[row][col]
        for k in 0..<ss {
            noteIndicators[k] = (noteNum >> k & 1)
        }
        return noteIndicators
    }
    
    /**
     sets note array at notes[row][col]
     */
    public mutating func setNoteArray(row: Int, col: Int, noteIndicators: [Int]) {
        var noteNumber = 0
        let ss = size*size
        for k in 0..<ss {
            noteNumber += (noteIndicators[k] << k)
        }
        notes[row][col] = noteNumber
    }
    
    /**
     toggle note number m at (row,col)
     */
    public mutating func toggleNoteNumber(row: Int, col: Int, m: Int) {
        if (1 <= m && m <= size*size) {
            // add or remove note by toggling indicator
            let toggled = notes[row][col] ^ (1 << (m-1))
            notes[row][col] = toggled
        }
        else if (m == 0) {
            // reset the note
            notes[row][col] = 0
        }
    }
    
    /**
     returns matrix of notes int b-th block
     */
    public func getBlock(block: Int) -> [[Int]] {
        var matrix = [[Int]]()
        var row = [0,0,0]
        for i in 0..<size {
            for j in 0..<size {
                row[j] = notes[i + size*(block/size)][j + size*(block%size)]
            }
            matrix.append(row)
        }
        return matrix
    }
    
    /**
     returns Array of notes in b-th block
     */
    public func getBlockAsArray(block: Int) -> [Int] {
        var array = [Int]()
        for i in 0..<size {
            for j in 0..<size {
                array.append( notes[i + size*(block/size)][j + size*(block%size)] )
            }
        }
        return array
    }
    
    /**
     sets matrix of notes in b-th block
     */
    public mutating func setBlock(block: Int, newBlock: [[Int]]) {
        for i in 0..<size {
            for j in 0..<size {
                notes[i + size*(block/size)][j + size*(block%size)] = newBlock[i][j]
            }
        }
    }
    
    /**
     clear all notes, that is set all note numbers 0
     */
    public mutating func clear() {
        let ss = size*size
        for i in 0..<ss {
            for j in 0..<ss {
                notes[i][j] = 0
            }
        }
    }
    
    private func checkSize(_ matrix: [[Any]], _ ss: Int) -> Bool {
        if matrix.count != ss {
            return false
        }
        for array in matrix {
            if array.count != ss {
                return false
            }
        }
        return true
    }
}
