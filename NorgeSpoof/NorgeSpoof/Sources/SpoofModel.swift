import SwiftUI
import CoreLocation

@MainActor
final class SpoofModel: ObservableObject {
    // Starts in Oslo
    @Published var coordinate = CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522)
    @Published var running = false
    @Published var speedKmh: Double = 5
    @Published var status = "Import your pairing file to begin."
    @Published var pairingURL: URL?

    private let sim: LocationSimulating = IdeviceLocationSimulator()
    private var timer: Timer?
    /// Joystick vector, each axis -1...1 (x = east, y = north)
    var stick = CGVector.zero

    func importPairing(_ url: URL) {
        let dest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pairing.mobiledevicepairing")
        _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        try? FileManager.default.removeItem(at: dest)
        do {
            try FileManager.default.copyItem(at: url, to: dest)
            pairingURL = dest
            status = "Pairing file imported."
        } catch { status = "Import failed: \(error.localizedDescription)" }
    }

    func start() {
        guard let p = pairingURL else { status = "Import a pairing file first."; return }
        Task {
            do {
                try await sim.connect(pairingFile: p)
                try await sim.set(coordinate)
                running = true; status = "Spoofing active."
                startLoop()
            } catch { status = error.localizedDescription }
        }
    }

    func stop() {
        timer?.invalidate(); timer = nil; running = false
        Task { try? await sim.clear(); status = "Stopped. Real location restored." }
    }

    func teleport(to c: CLLocationCoordinate2D) {
        coordinate = c
        if running { Task { try? await sim.set(c) } }
    }

    private func startLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        let mag = min(1, hypot(stick.dx, stick.dy))
        if mag > 0.05 {
            let metres = speedKmh / 3.6 * mag           // metres in one second
            let dLat = Double(stick.dy) * metres / 111_320
            let dLon = Double(stick.dx) * metres / (111_320 * cos(coordinate.latitude * .pi / 180))
            coordinate.latitude += dLat
            coordinate.longitude += dLon
        }
        // Re-send every tick so the position stays pinned even when the stick is idle.
        Task { try? await sim.set(coordinate) }
    }
}
