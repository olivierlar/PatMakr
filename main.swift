//
//  main.swift
//  PatMakr
//
//  Generates a random sequence of numbers that is structured in the form of pattern repetitions. The number and length of patterns as well as their number of occurrences can be controlled.
//
//  Created by Olivier Lartillot on 17.08.2017.
//  Copyright © 2017 Olivier Lartillot. All rights reserved.
//

import Foundation


// The parameter from can have two possible values, either .Highest or .Lowest.
// If the maximal number of levels (nbLevels) is set to infinite (for instance 1000), the parameter from is unused.
// If for instance we have a sequence of length 1000 and 2 levels (nbLevels), if from is .Lowest, this means that we will consider the 2 lowest levels, for which the pattern length will be respectively 3 and 30.
// For the same example with from set to .Highest, we will consider the 2 highest levels: pattern lengths 30 and 300.
enum Origin {
    case Highest
    case Lowest
}


// For a given sequence length and level (i.e. a given pattern length), we still need to specify the number of patterns and the number of pattern occurrences. The parameter levelType can have two values corresponding to the two extremes: either one single pattern but repeated many times (OnePatternManyTimes) or many pattern but each repeated only once (ManyPatternsTwice).
enum LevelType {
    case OnePatternManyTimes
    case ManyPatternsTwice
}


// This routine defines the values for the parameters. First set the sequenceLength to the desired value. Then you can either set your own parameters by setting Figure to 0 and by modifying the lines below starting after the comment "MANUAL MODIFICATIONS OF PARAMETERS BELOW", or you can set the parameters so that they would correspond to one configuration shown on one particular figure in the KDE paper, by setting Figure to the proper value.
func defineSpecification() -> (nbLevels: Int, from: Origin, levelType: LevelType, sequenceLength: Int) {
    let sequenceLength = 1_000 // Change the sequence length here

    let nbLevels: Int
    let from: Origin
    let levelType: LevelType
    
    let Figure = 0 // Choose the Figure number, 0 corresponding to manual parameters specification (cf. below).
    switch Figure {
    case 1:
        nbLevels = 1000
        from = Origin.Highest
        levelType = LevelType.OnePatternManyTimes
    default: // MANUAL MODIFICATIONS OF PARAMETERS BELOW
        nbLevels = 1000 // No constraint concerning the maximal number of levels
        from = Origin.Highest
        levelType = LevelType.OnePatternManyTimes
    }
    
    return (nbLevels, from, levelType, sequenceLength)
}


// This routine modify the sequence (input) by incorporating the patterns (with all their occurrences) corresponding to a given level, related to a particular patternLength.
func generateLevel(sequenceLength: Int, nbPatterns: Int, patternLength: Int, nbOccs: Int, input: [Int]) -> [Int] {
    var S = input
    
    if nbPatterns > 0 {
        var AlphabetSize = 0
        for _ in 1...nbPatterns {
            var pattern: [Int] = []
            for i in 1...nbOccs {
                let start = Int(arc4random_uniform(UInt32(sequenceLength-patternLength)))
                if i == 1 {
                    for j in start...start+patternLength-1 {
                        if S[Int(j)] == 0 {
                            AlphabetSize += 1
                            S[Int(j)] = AlphabetSize
                        }
                    }
                    pattern = Array(S[Int(start)...Int(start+patternLength-1)])
                } else {
                    S.replaceSubrange(Int(start)...Int(start+patternLength-1),with: pattern)
                }
            }
        }
    }
    
    return S
}

// This is the main routine
func Run() -> [Int] {
    // Parameters specification
    let param = defineSpecification();
    
    // The sequence is initially a sequence of 0s, where 0 is a special symbol that can never be part of any pattern occurrence
    var S0 = [Int](repeating: 0, count: param.sequenceLength+1)
    
    // Determination of the levels, each level corresponding to a particular pattern length
    var patternLength = [Int]()
    switch param.from {
    case .Lowest:
        var pl = 3
        for _ in 1...param.nbLevels {
            if pl > param.sequenceLength {
                break
            }
            patternLength.append(pl)
            pl = pl * 10
        }
    case .Highest:
        var pl = param.sequenceLength * 3 / 10
        for _ in 1...param.nbLevels {
            if pl == 0 {
                break
            }
            patternLength.insert(pl, at: 0)
            pl = pl / 10
        }
    }
    
    // For each level, determination of the number of patterns and number of pattern occurrences based on the parameters specification.
    for pl in patternLength {
        let nbPatterns,nbOccs: Int
        switch param.levelType {
        case .OnePatternManyTimes:
            nbPatterns = 1
            nbOccs = param.sequenceLength*2/3/pl
            if nbOccs < 2 {
                break
            }
        case .ManyPatternsTwice:
            nbPatterns = param.sequenceLength/pl/3
            nbOccs = 2
            if nbPatterns < 1 {
                break
            }
        }
        S0 = generateLevel(sequenceLength: param.sequenceLength, nbPatterns: nbPatterns, patternLength: pl, nbOccs: nbOccs, input: S0)
    }
    
    return S0
}

Run()
