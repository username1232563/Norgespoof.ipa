import Foundation
import CoreLocation

/// The one piece that talks to the phone's developer services.
/// The UI only depends on this protocol, so the bridge can be swapped or fixed in isolation.
protocol LocationSimulating {
    func connect(pairingFile: URL) async throws
    func set(_ coordinate: CLLocationCoordinate2D) async throws
    func clear() async throws
}

enum SimError: LocalizedError {
    case notImplemented
    var errorDescription: String? {
        "Bridge not wired yet: connect IdeviceLocationSimulator to the idevice library (see README)."
    }
}

/// TODO: implement with the `idevice` library (jkcoxson/idevice, Swift bindings):
///  1. Load the pairing file you imported.
///  2. Open a lockdown/tunnel connection to 10.7.0.1 (LocalDevVPN loopback).
///  3. Start the DVT "location simulation" service and call simulate(lat, lon).
///  4. clear() stops the simulation and restores the real location.
/// Check the library's current README for the exact API names; they change between releases.
final class IdeviceLocationSimulator: LocationSimulating {
    func connect(pairingFile: URL) async throws { throw SimError.notImplemented }
    func set(_ coordinate: CLLocationCoordinate2D) async throws { throw SimError.notImplemented }
    func clear() async throws { throw SimError.notImplemented }
}
