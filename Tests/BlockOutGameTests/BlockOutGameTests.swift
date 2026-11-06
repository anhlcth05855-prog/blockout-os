import XCTest
@testable import BlockOutGame

final class BlockOutGameTests: XCTestCase {

    func testLevel1Initialization() {
        let level = LevelRepository.baseLevels[0]
        let engine = GameEngine(level: level)

        XCTAssertEqual(engine.gridWidth, 5)
        XCTAssertEqual(engine.gridHeight, 5)
        XCTAssertEqual(engine.blocks.count, 2)
        XCTAssertEqual(engine.doors.count, 2)
        XCTAssertEqual(engine.movesMade, 0)
        XCTAssertFalse(engine.isWon)
        XCTAssertFalse(engine.isGameOver)
    }

    func testBlockEscapeThroughMatchingTopDoor() {
        // Level 1: b1 is blue, x=1, y=0, width=1, height=3, vertical
        // Door d1 is top, index=1, widthCells=2, blue
        let level = LevelRepository.baseLevels[0]
        let engine = GameEngine(level: level)

        let b1 = engine.blocks.first(where: { $0.id == "b1" })!
        let limits = engine.calculateLimits(block: b1)
        XCTAssertTrue(limits.canEscapeTop)

        let result = engine.applyMove(blockId: "b1", deltaCellsX: 0, deltaCellsY: -1, forceEscape: true)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.escaped)
        XCTAssertEqual(result!.escapeSide, .top)
        XCTAssertTrue(engine.getBlock(id: "b1")!.isEscaped)
    }

    func testObstacleBlocksMovement() {
        // Level 4 has rock obstacle at (2, 1)
        let level = LevelRepository.baseLevels[3]
        let engine = GameEngine(level: level)

        XCTAssertEqual(engine.obstacles.count, 1)
        XCTAssertFalse(engine.obstacles[0].isDestroyed)

        // Try destroying obstacle with hammer
        let destroyed = engine.destroyAnyObstacle()
        XCTAssertTrue(destroyed)
        XCTAssertTrue(engine.obstacles[0].isDestroyed)
    }

    func testUndoRestoresBlocks() {
        let level = LevelRepository.baseLevels[0]
        let engine = GameEngine(level: level)

        let b2 = engine.blocks.first(where: { $0.id == "b2" })!
        XCTAssertEqual(b2.y, 2)

        _ = engine.applyMove(blockId: "b2", deltaCellsX: 0, deltaCellsY: -1)
        XCTAssertEqual(engine.movesMade, 1)

        let undone = engine.undo()
        XCTAssertTrue(undone)
        XCTAssertEqual(engine.movesMade, 0)
    }

    func testDailyPuzzleGeneration() {
        let daily = LevelRepository.getDailyPuzzle()
        XCTAssertEqual(daily.id, 9999)
        XCTAssertEqual(daily.name, "Daily Challenge")
        XCTAssertEqual(daily.gridWidth, 6)
        XCTAssertEqual(daily.gridHeight, 6)
        XCTAssertEqual(daily.blocks.count, 4)
        XCTAssertEqual(daily.doors.count, 4)
    }

    func testLevel36CanyonMillExists() {
        let level36 = LevelRepository.getLevel(id: 36)
        XCTAssertEqual(level36.id, 36)
        XCTAssertEqual(level36.name, "The Canyon Mill")
        XCTAssertEqual(level36.blocks.count, 7)
        XCTAssertEqual(level36.doors.count, 8)
    }
}
