import SwiftUI
import MapKit
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var model: SpoofModel
    @State private var camera = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 64.5, longitude: 12.0),
        span: MKCoordinateSpan(latitudeDelta: 14, longitudeDelta: 20)))
    @State private var importing = false
    @State private var query = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { proxy in
                Map(position: $camera) { Marker("Spoofed", coordinate: model.coordinate) }
                    .onTapGesture { p in
                        if let c = proxy.convert(p, from: .local) { model.teleport(to: c) }
                    }
            }
            .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack {
                    TextField("Search place in Norway", text: $query, onCommit: search)
                        .textFieldStyle(.roundedBorder)
                    Button("Pairing") { importing = true }.buttonStyle(.bordered)
                }
                .padding(10).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal).padding(.top, 50)
                Spacer()
                Text(model.status).font(.footnote).padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                HStack(alignment: .bottom) {
                    JoystickView { model.stick = $0 }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(Int(model.speedKmh)) km/h").font(.caption)
                        Slider(value: $model.speedKmh, in: 1...60).frame(width: 140)
                        Button(model.running ? "Stop" : "Start") {
                            model.running ? model.stop() : model.start()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(model.running ? .red : .green)
                    }
                }
                .padding()
            }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.data]) { r in
            if case .success(let url) = r { model.importPairing(url) }
        }
    }

    private func search() {
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query + " Norway"
        MKLocalSearch(request: req).start { resp, _ in
            guard let item = resp?.mapItems.first else { return }
            let c = item.placemark.coordinate
            camera = .region(MKCoordinateRegion(center: c, latitudinalMeters: 3000, longitudinalMeters: 3000))
            model.teleport(to: c)
        }
    }
}
