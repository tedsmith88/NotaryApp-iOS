import SwiftUI
import MapKit
import CoreData

struct MapView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.fio)]) var notaries: FetchedResults<NotaryEntity>
    
    // Начальная точка карты
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: notaries.compactMap { $0.location }) { notaryLocation in
            MapMarker(coordinate: notaryLocation.coordinate, tint: Theme.primary)
        }
        .navigationTitle("Нотариусы на карте")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Расширение для удобного использования в MapKit
extension NotaryEntity {
    var location: LocationItem? {
        let lat = latitude
        let lon = longitude
        return LocationItem(
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            name: self.fio ?? "Нотариус"
        )
    }
}

struct LocationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
}
