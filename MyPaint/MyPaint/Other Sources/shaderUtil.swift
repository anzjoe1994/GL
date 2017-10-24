import UIKit
import OpenGLES


private func printf(_ format: String, args: [CVarArg]) {
    print(String(format: format, arguments: args), terminator: "")
}
private func printf(_ format: String, args: CVarArg...) {
    printf(format, args: args)
}
func LogInfo(_ format: String, args: CVarArg...) {
    printf(format, args: args)
}
func LogError(_ format: String, args: CVarArg...) {
    printf(format, args: args)
}


struct glue {
    
    /* Shader Utilities */
    
    /* Compile a shader from the provided source(s) */
    static func compileShader(_ target: GLenum,
        _ count: GLsizei,
        _ sources: UnsafePointer<UnsafePointer<GLchar>?>,
        _ shader: inout GLuint) -> GLint
    {
        var logLength: GLint = 0, status: GLint = 0
        
        shader = glCreateShader(target)
        glShaderSource(shader, count, sources, nil)
        glCompileShader(shader)
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH.ui, &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<CChar>.allocate(capacity: logLength.l)
            glGetShaderInfoLog(shader, logLength, &logLength, log)
            LogInfo("Shader compile log:\n%@", args: String(cString: log))
            log.deallocate(capacity: logLength.l)
        }
        
        glGetShaderiv(shader, GL_COMPILE_STATUS.ui, &status)
        if status == 0 {
            
            LogError("Failed to compile shader:\n")
            for i in 0..<count.l {
                LogInfo("%@", args: sources[i].map{String(cString: $0)} ?? "")
            }
        }
        glError()
        
        return status
    }
    
    
    /* Link a program with all currently attached shaders */
    static func linkProgram(_ program: GLuint) -> GLint {
        var logLength: GLint = 0, status: GLint = 0
        
        glLinkProgram(program)
        glGetProgramiv(program, GL_INFO_LOG_LENGTH.ui, &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<CChar>.allocate(capacity: logLength.l)
            glGetProgramInfoLog(program, logLength, &logLength, log)
            LogInfo("Program link log:\n%@", args: String(cString: log))
            log.deallocate(capacity: logLength.l)
        }
        
        glGetProgramiv(program, GL_LINK_STATUS.ui, &status)
        if status == 0 {
            LogError("Failed to link program %d", args: program)
        }
        glError()
        
        return status
    }
    
    
    /* Validate a program (for i.e. inconsistent samplers) */
    static func validateProgram(_ program: GLuint) -> GLint {
        var logLength: GLint = 0, status: GLint = 0
        
        glValidateProgram(program)
        glGetProgramiv(program, GL_INFO_LOG_LENGTH.ui, &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<CChar>.allocate(capacity: logLength.l)
            glGetProgramInfoLog(program, logLength, &logLength, log)
            LogInfo("Program validate log:\n%@", args: String(cString: log))
            log.deallocate(capacity: logLength.l)
        }
        
        glGetProgramiv(program, GL_VALIDATE_STATUS.ui, &status)
        if status == 0 {
            LogError("Failed to validate program %d", args: program)
        }
        glError()
        
        return status
    }
    
    
    /* Return named uniform location after linking */
    static func getUniformLocation(_ program: GLuint, _ uniformName: UnsafePointer<CChar>) -> GLint {
        
        return glGetUniformLocation(program, uniformName)
        
    }
    
    
    /* Shader Conveniences */
    
    /* Convenience wrapper that compiles, links, enumerates uniforms and attribs */
    @discardableResult
    static func createProgram(_ _vertSource: UnsafePointer<CChar>,
        _ _fragSource: UnsafePointer<CChar>,
        _ attribNames: [String],
        _ attribLocations: [GLuint],
        _ uniformNames: [String],
        _ uniformLocations: inout [GLint],
        _ program: inout GLuint) -> GLint
    {
        var vertShader: GLuint = 0, fragShader: GLuint = 0, prog: GLuint = 0, status: GLint = 1
        
        prog = glCreateProgram()
        
        var vertSource: UnsafePointer<CChar>? = _vertSource
        status *= compileShader(GL_VERTEX_SHADER.ui, 1, &vertSource, &vertShader)
        var fragSource: UnsafePointer<CChar>? = _fragSource
        status *= compileShader(GL_FRAGMENT_SHADER.ui, 1, &fragSource, &fragShader)
        glAttachShader(prog, vertShader)
        glAttachShader(prog, fragShader)
        
        for i in 0..<attribNames.count {
            if !attribNames[i].isEmpty {
                glBindAttribLocation(prog, attribLocations[i], attribNames[i])
            }
        }
        
        status *= linkProgram(prog)
        status *= validateProgram(prog)
        
        if status != 0 {
            for i in 0..<uniformNames.count {
                if !uniformNames[i].isEmpty {
                    uniformLocations[i] = getUniformLocation(prog, uniformNames[i])
                }
            }
            program = prog
        }
        if vertShader != 0 {
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDeleteShader(fragShader)
        }
        glError()
        
        return status
    }
}
