import Foundation
@main enum NativeApplication {
    #if OUTNUMBERED_DEVELOPMENT
    static let developmentBuild=true
    #else
    static let developmentBuild=false
    #endif
#if arch(x86_64)
    static let architecture="x86_64"
#elseif arch(arm64)
    static let architecture="arm64"
#else
    static let architecture="unknown"
#endif
    static let startedAt=ProcessInfo.processInfo.systemUptime
    static var assets:URL {
        if let path=ProcessInfo.processInfo.environment["OUTNUMBERED_ASSETS"] { return URL(fileURLWithPath:path) }
        #if os(Windows)
        return URL(fileURLWithPath:CommandLine.arguments[0]).standardizedFileURL.deletingLastPathComponent().appendingPathComponent("assets")
        #else
        return Bundle.main.resourceURL!.appendingPathComponent("assets")
        #endif
    }
    static func main() {
        if CommandLine.arguments.contains("--self-test") {
            do { try nativeIntegrationChecks(root:assets) } catch { print("Native checks failed: \(error)");exit(1) };return
        }
        #if os(Windows)
        runWindowsGame()
        #elseif !OUTNUMBERED_PORTABLE
        runMacGame()
        #else
        print("Portable check harness: use --self-test")
        #endif
    }
}
