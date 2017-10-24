import UIKit

func glError(_ file: String = #file, line: Int = #line) {
    let err = glGetError()
    if err != GL_NO_ERROR.ui {
        print("glError: \(String(err, radix: 16)) caught at \(file):\(line)")
    }
}
