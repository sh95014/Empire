//
//  Map.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

enum MapSquare {
    case sea
    case land
}

class Map {
    
    let width = 100
    let height = 60
    
    func squareAt(column: Int, row: Int) -> MapSquare {
        worldMap[row][column] == "X" ? .land : .sea
    }
    
    func hasPort(column: Int, row: Int) -> Bool {
        // check the 8 surrounding squares to see if any of it is water
        (column - 1 > 0 &&
            ((row - 1 > 0      && squareAt(column: column - 1, row: row - 1) == .sea) ||
             (                  squareAt(column: column - 1, row: row) == .sea) ||
             (row + 1 < height && squareAt(column: column - 1, row: row + 1) == .sea))) ||

        (row - 1 > 0           && squareAt(column: column, row: row - 1) == .sea) ||
        (row + 1 < height      && squareAt(column: column, row: row + 1) == .sea) ||

        (column + 1 < width &&
            ((row - 1 > 0      && squareAt(column: column + 1, row: row - 1) == .sea) ||
             (                  squareAt(column: column + 1, row: row) == .sea) ||
             (row + 1 < height && squareAt(column: column + 1, row: row + 1) == .sea)))
    }
    
    private let worldMap = [
        Array("...................................................................................................."),
        Array("...................................................................................................."),
        Array(".....................................X.XX..........................................................."),
        Array("........................XXXXX......XXXX....X........................................................"),
        Array("......................XX.XXX..XXXXXXXXXXXXX.................X.X.X........X.........................."),
        Array("..................X..XX.XX...XXXXXXXXXXXX.........XXXX...................XX........................."),
        Array("................X.......X...XXXXXXXXXXXXX..........X................................................"),
        Array("..............X....X...X......XXXXXXXXXXX.......................XX.........XXX......................"),
        Array("...............XX....XX.X......XXXXXXXXXX......................X.......XXXXXXX.......XX.X..........."),
        Array(".............X.....X.X..X.......XXXXXXXX......................X.......XXXXXX...X.XX................."),
        Array("...............XXX.XX.XXXX.......XXXXXXXX.....................X...X...XXXXXXXXXXXXX...XXX........X.."),
        Array("..XXXXX.........XX..XX....XX.....XXXXXXX.............XX........X..X.XXXXXXXXXXXXXXXXXXXXXXX....X...."),
        Array(".XXXXXXXXXXXXXX......XXX...XX....XXXXX..............XXXXXX.X.XXXXXX..XXXXXXXXXXXXXXXXXXXXXXXXXXXXX.."),
        Array(".XXXXXXXXXXXXXXXXXXXXXX...XX.X..XXXX......X........XX.XX...XXXXXXX.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX."),
        Array("...XXXXXXXXXXXXXXXXXXX.X...XX....XXX.....XX.......XX..XXX.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...."),
        Array(".XXXXXXXXXXXXXXXXXXXX....X.......XX..............XXX.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.XXXX..."),
        Array("..XXX...XXXXXXXXXXXXX.....X......................XXX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...X......"),
        Array("...X......XXXXXXXXXXX.....XX.X...............X....XX..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.....XX......."),
        Array("..X........XXXXXXXXXXXX...XXXX................X..X...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX......X........"),
        Array("...........XXXXXXXXXXXXX.XXXXXX.............X.X..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....X........."),
        Array("............XXXXXXXXXXXXXXXXXX................X.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...........X.."),
        Array(".............XXXXXXXXXXXXXXX...X................XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.............."),
        Array(".............XXXXXXXXXXXXXXXX..................XXXXXXXX.X.XXX.XXXXXXXXXXXXXXXXXXXXXXX..............."),
        Array(".............XXXXXXXXXXXXXX....................XX.X.XXX...XX..XXXXXXXXXXXXXXXXXXXXXX..X............."),
        Array(".............XXXXXXXXXXXXX...................XXX...X.XX.X..XX.XXXXXXXXXXXXXXXXXXXXX................."),
        Array(".............XXXXXXXXXXXXX...................XX......X.XXXXXX.XXXXXXXXXXXXXXXXXX..X...X............."),
        Array("..............XXXXXXXXXXXX......................XX.......XXXXXXXXXXXXXXXXXXXXXXX..X.XX.............."),
        Array("..............XXXXXXXXXXX....................XXXXX.......XXXXXXXXXXXXXXXXXXXXXXXX..................."),
        Array("..............X.XXXXX..XX...................XXXXXXXX.XXXXXXX.XXXXXXXXXXXXXXXXXXXX..................."),
        Array("...............X.XXX....X...................XXXXXXXXXXXX.XXXX..XXXXXXXXXXXXXXXXX...................."),
        Array(".................XXX.......................XXXXXXXXXXXXX..XXX.....XXXXXXXXXXXXXX.X.................."),
        Array("...X..............XX..X..X................XXXXXXXXXXXXXXX.XXXXX....XXXX..XXXX......................."),
        Array("...................XXXX....X..............XXXXXXXXXXXXXXX..XXXX....XXX...XXX....X..................."),
        Array(".....................XXX..................XXXXXXXXXXXXXXXX.XX.......X.....XXX...X..................."),
        Array(".......................X...................XXXXXXXXXXXXXXX..........X.....X.X....X.................."),
        Array("........................X.XXXX.............XXXXXXXXXXXXXXXXXX.............X......X.................."),
        Array(".........................XXXXXX.............XXX..XXXXXXXXXXX.........X.....X...X.X.................."),
        Array("..........................XXXXXXX.................XXXXXXXXXX..............X...XX...................."),
        Array(".........................XXXXXXXX.................XXXXXXXXX................X..XX...................."),
        Array(".........................XXXXXXXXXXX..............XXXXXXXX.................X....X...XXX............."),
        Array(".........................XXXXXXXXXXXX..............XXXXXXX..................XX........XX..X........."),
        Array(".........................XXXXXXXXXXXX..............XXXXXXX.........................................."),
        Array("..........................XXXXXXXXXX...............XXXXXXX.........................XX.X............."),
        Array("...........................XXXXXXXXX..............XXXXXXXX..X.....................XXX.X......X......"),
        Array("............................XXXXXXXX..............XXXXXXX..XX....................XXXXXXX........X..."),
        Array("............................XXXXXXX................XXXXXX..X...................XXXXXXXXX.....X......"),
        Array("............................XXXXXX.................XXXXX.......................XXXXXXXXXX..........."),
        Array("...........................XXXXXX...................XXXX.......................XXXXXXXXXXX.........."),
        Array("...........................XXXXXX...................XXX........................XXXXXXXXXXX.........."),
        Array("...........................XXXXX....................X..........................XX....XXXX..........."),
        Array("...........................XXXX.......................................................XX............"),
        Array("...........................XXX.................................................................XX..."),
        Array("...........................XX..........................................................X.......X...."),
        Array("...........................XX................................................................XX....."),
        Array("..........................XX........................................................................"),
        Array("..........................XX........................................................................"),
        Array("...........................X..X....................................................................."),
        Array("...........................XX......................................................................."),
        Array("...................................................................................................."),
        Array("...................................................................................................."),
    ]

}
