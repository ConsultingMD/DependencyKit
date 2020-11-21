import Foundation
import NetworkClient
import QuartzCore

class TimingNetworkMonitor: NetworkMonitorInterface {
    
    var callsInFlight = [UUID: CFTimeInterval]()
    
    func requested(url: URL, event: UUID) {
        callsInFlight[event] = CACurrentMediaTime()
    }
    
    func resolved(url: URL, event: UUID) {
        if let start = callsInFlight[event] {
            let time = CACurrentMediaTime() - start
            print("Network call: \(url), resolved in \(time) seconds")
            callsInFlight.removeValue(forKey: event)
        }
    }
    
}
