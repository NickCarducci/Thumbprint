//
//  ContentView.swift
//  Thumbprint
//
//  Created by Nicholas Carducci on 7/4/23.
//

import SwiftUI
import MapKit
import Firebase

struct MapView: UIViewRepresentable {
    
    class Coordinator: NSObject, MKMapViewDelegate {
        init(mapView: MKMapView){
            super.init()
            mapView.delegate = self
        }
        private func mapView(_ mapView: MKMapView, viewFor annotation: Annotation) -> MKAnnotationView? {
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            pin.canShowCallout = true
            
            
            return pin
        }
    }
    var currentCallout: UIView?
    mutating func mapView(_ mapView: MKMapView,didSelect view: MKAnnotationView){
        currentCallout?.removeFromSuperview()
        let customCallout = UIView()
        //customCallout.frame = .init(x: 0, y: 0, width: 100, height: 200)
        
        view.addSubview(customCallout)
        customCallout.translatesAutoresizingMaskIntoConstraints=false
        customCallout.widthAnchor.constraint(equalToConstant: 100).isActive = true
        customCallout.heightAnchor.constraint(equalToConstant: 200).isActive = true
        customCallout.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //customCallout.centerYAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        currentCallout = customCallout
    }
    let mapView = MKMapView()
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(mapView: mapView)
    }
    
    var annotation: Annotation?
    
    //UIViewRepresentableContext<MapView> Context
    func makeUIView(context: Context) -> MKMapView {
        
        let center = CLLocationCoordinate2D(latitude: 43, longitude: -74)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        return mapView
    }
    var latlng:Array<CLLocationDegrees>
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let annotation = annotation {
            uiView.addAnnotation(annotation)
        }
        let center = CLLocationCoordinate2D(latitude: latlng[0], longitude: latlng[1])
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    typealias UIViewType = MKMapView
}
struct Event {
    var id: String
    var title: String
    var center: Array<CLLocationDegrees>
    var url: String
}
struct Feature {
    var placeName: String
    var center: Array<CLLocationDegrees>
}
extension Feature: Decodable {
    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case center = "center"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.placeName = try podcastContainer.decode(String.self, forKey: .placeName)
        self.center = try podcastContainer.decode([CLLocationDegrees].self, forKey: .center)
    }
}
struct Place {
    var features: Array<Feature>
}
extension Place: Decodable {
    enum CodingKeys: String, CodingKey {
        case features = "features"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.features = try podcastContainer.decode([Feature].self, forKey: .features)
    }
}
struct Location {
    var latitude: String
    var longitude: String
}
extension Location: Decodable {
    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try podcastContainer.decode(String.self, forKey: .latitude)
        self.longitude = try podcastContainer.decode(String.self, forKey: .longitude)
    }
}
struct Locations {
    var location: Location
}
extension Locations: Decodable {
    enum CodingKeys: String, CodingKey {
        case location = "location"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.location = try podcastContainer.decode(Location.self, forKey: .location)
    }
}
struct Venues {
    var venues: Array<Locations>
}
extension Venues: Decodable {
    enum CodingKeys: String, CodingKey {
        case venues = "venues"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.venues = try podcastContainer.decode([Locations].self, forKey: .venues)
    }
}
struct Ticket {
    var url: String
    var name: String
    var Embedded: Venues
}
extension Ticket: Decodable {
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case name = "name"
        case Embedded = "_embedded"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try podcastContainer.decode(String.self, forKey: .url)
        self.name = try podcastContainer.decode(String.self, forKey: .name)
        self.Embedded = try podcastContainer.decode(Venues.self, forKey: .Embedded)
    }
}
struct Concerts {
    var events: Array<Ticket>
}
extension Concerts: Decodable {
    enum CodingKeys: String, CodingKey {
        case events = "events"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.events = try podcastContainer.decode([Ticket].self, forKey: .events)
    }
}
struct Ticketmaster {
    var Embedded: Concerts
}
extension Ticketmaster: Decodable {
    enum CodingKeys: String, CodingKey {
        case Embedded = "_embedded"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.Embedded = try podcastContainer.decode(Concerts.self, forKey: .Embedded)
    }
}
class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
class Fetch: ObservableObject {
    func fetch() {
        
    }
}
class Search: ObservableObject {
    @Published var searchQuery: String = ""
}
struct ContentView: View {
    
    @State var annotation: Annotation?
    @State var annotations = [Annotation]()
    
    //@State var searchQuery = "" //{didSet {performSearch(query: searchQuery)}}
    @State var place: Place?
    @State var ticketmaster: Ticketmaster?
    
    @State var latlng:Array<CLLocationDegrees> = [43,-74]
    
    fileprivate func performSearch(query: String){
        
        
        let _ = print("searching")
    }
    @StateObject private var vm = Search()
    var body: some View {
        ZStack(alignment: .top) {
            MapView(annotation: annotation,latlng: latlng)
                .edgesIgnoringSafeArea(.all)
            TextField("Search", text: $vm.searchQuery)
                .onReceive(
                    vm.$searchQuery
                        .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
                ) {
                    guard !$0.isEmpty else { return }
                    print(">> searching for: \($0)")
                    //performSearch(query: searchQuery)
                    //print("searching \(vm.$searchQuery) s \($vm.searchQuery) v \(vm.searchQuery)")
                    Task {
                        let urlString = "https://api.mapbox.com/geocoding/v5/mapbox.places/\(vm.searchQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!).json?limit=2&types=place&access_token=pk.eyJ1Ijoibmlja2NhcmR1Y2NpIiwiYSI6ImNrMWhyZ3ZqajBhcm8zY3BoMnVnbW02dXQifQ.aw4gJV_fsZ1GKDjaWPxemQ"
                        let url = URL(string: urlString)!
                        print("searching \(urlString)")
                        //let (data, _) = try await URLSession.shared.data(from: url)
                        
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            //if error != nil { return print(error) }
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .iso8601
                            if let data = data{
                                do {
                                   let place = try decoder.decode(Place.self, from: data)
                                    print("found \(place)")
                                    
                                    //place = try decoder.decode(Place.self, from: data)
                                    print(place)
                                    latlng = [place.features[0].center[1], place.features[0].center[0]]
                                    //latlng = [place?.features[0].center[0] ?? -74, place?.features[0].center[1] ?? 43]
                                    print(latlng)
                                    Task {
                                        let consumerSecret = "iAkWSqAXXAFLtxiFJYQJeqYpWcZDVUbt"
                                        let urllString = "https://app.ticketmaster.com/discovery/v2/events.json?geoPoint=\(Geohash.encode(latitude:latlng[0], longitude:latlng[1], length:9))&size=150&apikey=\(consumerSecret)"
                                        print("searching \(urllString)")
                                        let urll = URL(string: urllString)!
                                        let task = URLSession.shared.dataTask(with: urll) { dataa, response, error in
                                            //let (dataa, _) = try await URLSession.shared.data(from: urll)
                                            if let dataa = dataa{
                                                do {
                                                    let ticketmaster = try decoder.decode(Ticketmaster.self, from: dataa)
                                                    //if ticketmaster?.Embedded.events.isEmpty! {
                                                        print(ticketmaster)
                                                    
                                                    for event in ticketmaster.Embedded.events {
                                                        let annotation = Annotation(coordinate: .init(latitude: Double(event.Embedded.venues[0].location.latitude)!,
                                                                                                      longitude: Double(event.Embedded.venues[0].location.longitude)!), title: event.name, subtitle: event.url) //MKPointAnnotation
                                                            
                                                        self.annotation = annotation
                                                    }
                                                    
                                                    let db = Firestore.firestore()

                                                    db.collection("event").whereField("collection", isEqualTo: "event").getDocuments() { (querySnapshot, error) in
                                                                    if let error = error {
                                                                            print("Error getting documents: \(error)")
                                                                    } else {
                                                                            if querySnapshot!.documents.isEmpty {
                                                                                return print("is empty")
                                                                            }
                                                                            for document in querySnapshot!.documents {
                                                                                    //print("\(document.documentID): \(document.data())")
                                                                                let event = Event(id: document.documentID,
                                                                                                  title: document["title"] as? String ?? "",
                                                                                                  center: document["center"] as? Array<CLLocationDegrees> ?? [-74,43],
                                                                                                  url: "https://tpt.net.co/event/\(document.documentID)")
                                                                                print(event)
                                                                                let annotation = Annotation(coordinate: .init(latitude: event.center[0],
                                                                                                                              longitude: event.center[1]), title: event.title, subtitle: event.url)
                                                                                self.annotation = annotation
                                                                            }
                                                                    }
                                                            }
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                        }
                                        task.resume()
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        task.resume()
                        
                    }
                }
            HStack{
                Image(systemName: "pencil.circle")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Image(systemName: "bookmark.circle")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Image(systemName: "t.circle")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                            withAnimation(.default.speed(0.1)) {
                                
                            }
                    }
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirestoreManager())
    }
}
