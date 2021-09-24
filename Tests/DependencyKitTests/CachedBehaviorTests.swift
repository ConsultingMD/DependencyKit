import XCTest
import DependencyKit

final class CachedBehaviorTests: XCTestCase {

    func testCache_BuildsOnce() {
        let holder = CacheTestResource()
        let value = holder.value
        XCTAssertEqual(holder.accessCount, 1)
        XCTAssertEqual(holder.value, value)
        XCTAssertEqual(holder.accessCount, 1)
    }

    func testCache_IsLazy() {
        let holder = CacheTestResource()
        XCTAssertEqual(holder.accessCount, 0)
        XCTAssertEqual(holder.value, holder.innerValue)
        XCTAssertEqual(holder.accessCount, 1)
    }

    func testCache_HasUniqueValuesAcrossVars() {
        let holder = CacheTestResource()
        let uuids = holder.uuids
        let uuidSet = Set(uuids)
        XCTAssertEqual(uuids.count, uuidSet.count)
    }

    func testCache_IsThreadSafe() {
        let group = DispatchGroup()
        let holder = CacheTestResource()
        for _ in 0...10000 {
            group.enter()
            DispatchQueue.global().async {
                XCTAssertEqual(holder.value, holder.innerValue)
                group.leave()
            }
        }
        let result = group.wait(timeout: DispatchTime.now() + 10)
        XCTAssertEqual(holder.accessCount, 1)
        XCTAssert(result == .success)
    }

    func testCache_distinguishesWeirdlyNamedFunctions() {
        // cached {} uses function names as keys. check this for simple failure cases.
        let holder = CacheTestResource()
        let emojiGroup = [holder.👍, holder.👍🏻, holder.👍🏽, holder.👯]
        let emojiSet = Set(emojiGroup)
        XCTAssertEqual(emojiGroup.count, emojiSet.count)
    }

    static var allTests = [
        ("testCache_BuildsOnce", testCache_BuildsOnce),
        ("testCache_IsLazy", testCache_IsLazy),
        ("testCache_IsThreadSafe", testCache_IsThreadSafe),
        ("testCache_HasUniqueValuesAcrossVars", testCache_HasUniqueValuesAcrossVars),
        ("testCache_distinguishesWeirdlyNamedFunctions", testCache_distinguishesWeirdlyNamedFunctions),
    ]
}

private class CacheTestResource: Resource<NilResource, ()> {

    let innerValue = "Hello"
    var accessCount = 0

    var value: String {
        cached {
            accessCount += 1
            return innerValue
        }
    }

    var uuid1: String {
        cached { UUID().uuidString }
    }

    var uuid2: String {
        cached { UUID().uuidString }
    }

    var uuid3: String {
        cached { UUID().uuidString }
    }

    var uuid4: String {
        cached { UUID().uuidString }
    }

    var uuid5: String {
        cached { UUID().uuidString }
    }

    var uuids: [String] {
        [uuid1, uuid2, uuid3, uuid4, uuid5]
    }

    var 👍: String {
        cached { UUID().uuidString }
    }

    var 👍🏽: String {
        cached { UUID().uuidString }
    }

    var 👍🏻: String {
        cached { UUID().uuidString }
    }

    var 👯: String {
        cached { UUID().uuidString }
    }

}
