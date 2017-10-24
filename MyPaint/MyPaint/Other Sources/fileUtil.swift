import UIKit

func readData(forResource name: String, withExtension ext: String? = nil) -> Data {
    let url = Bundle.main.url(forResource: name, withExtension: ext)!
    var source = try! Data(contentsOf: url)
    var trailingNul: UInt8 = 0
    source.append(&trailingNul, count: 1)
    return source
}
