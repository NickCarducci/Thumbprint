//
//  ContentView.swift
//  Thumbprint
//
//  Created by Nicholas Carducci on 7/4/23.
//

import SwiftUI
import MapKit
import Firebase
//import Geofirestore
import CoreLocation
import CoreLocationUI

struct MapView: UIViewRepresentable {
    
    let mapView = MKMapView()
    
    var annotation: Annotation?
    @Binding var latlng:CLLocationCoordinate2D//Array<CLLocationDegrees>
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let annotation = annotation {
            //UIAlertController
            //annotation.rightCalloutAccessoryView = rightButton
            
            uiView.addAnnotation(annotation)
        }
        print("updated \(latlng)")
        //let center = latlng//CLLocationCoordinate2D(latitude: latlng[0], longitude: latlng[1])
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: latlng, span: span)
        uiView.setRegion(region, animated: true)
    }
    //UIViewRepresentableContext<MapView> Context
    func makeUIView(context: Context) -> MKMapView {
        
        let center = CLLocationCoordinate2D(latitude: 43, longitude: -74)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        /*let longPressed = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addPin(gesture:)))
        mapView.addGestureRecognizer(longPressed)*/
        
        return mapView
    }
    //@Binding var showingAlert: String
    class Coordinator: NSObject, MKMapViewDelegate {
        init(mapView: MKMapView){
            super.init()
            mapView.delegate = self
            
        }
        /*@objc func addPin(gesture: UILongPressGestureRecognizer) {
            // do whatever needed here
            $showingAlert = annotation!.subtitle!
        }*/
        func mapView(_ mapView: MKMapView, viewFor annotation: Annotation, calloutAccessoryControlTapped control: UIControl) -> MKAnnotationView? {
            
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            pin.canShowCallout = false
            pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            
            if control == pin.rightCalloutAccessoryView {
                UIApplication.shared.open(URL(string: annotation.subtitle!)!)
            }
            
            return pin
        }
        func mapView(_ mapView: MKMapView,didSelect view: MKAnnotationView){
            if view.annotation is MKUserLocation { return }

            /*currentCallout?.removeFromSuperview()
            let customCallout = UIView()
            //customCallout.frame = .init(x: 0, y: 0, width: 100, height: 200)
            
            view.addSubview(customCallout)
            customCallout.translatesAutoresizingMaskIntoConstraints=false
            customCallout.widthAnchor.constraint(equalToConstant: 100).isActive = true
            customCallout.heightAnchor.constraint(equalToConstant: 200).isActive = true
            customCallout.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            //customCallout.centerYAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            currentCallout = customCallout*/
            
            //let annotation = view.annotation as? Annotation
            //print("\(annotation!.subtitle!)")
            if let annotationTitle = view.annotation?.subtitle {
                UIApplication.shared.open(URL(string: annotationTitle!)!)
                //print("User tapped on annotation with title: \(annotationTitle!)")
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(mapView: mapView)
    }
    /*func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        let ac = UIAlertController(title: "", message: "Open Event?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: annotation!.subtitle!)!)
            }
        ))
        present(ac, animated: true)
    }*/
    var currentCallout: UIView?
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
        super.init()
    }
}
class Fetch: ObservableObject {
    func fetch() {
        
    }
}
class Search: ObservableObject {
    @Published var searchQuery: String = ""
}
/*class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
}*/
struct FirestoreSubView: View {
    @Binding public var show:String
    @Binding public var message:String
    let defaults = UserDefaults.standard
    var body: some View {
        HStack{
            Text("\(message)")
                .padding(10)
        }
    }
}

struct Post {
    var id: String
    var message: String
}
extension Post: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case message = "message"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try podcastContainer.decode(String.self, forKey: .id)
        self.message = try podcastContainer.decode(String.self, forKey: .message)
    }
}


struct ContentView: View {
    //@StateObject var locationManager = LocationManager()
    //@ObservedObject var locationManager = LocationManager()
    
    @State var annotation: Annotation?
    @State var annotations = [Annotation]()
    
    //@State var searchQuery = "" //{didSet {performSearch(query: searchQuery)}}
    @State var place: Place?
    @State var ticketmaster: Ticketmaster?
    
    @State var latlng =//:Array<CLLocationDegrees> =
    CLLocationCoordinate2D(latitude: 43, longitude: -74)
    @State var placename:String=""
    fileprivate func performSearch(query: String){
        

        let _ = print("searching")
    }
    @StateObject private var vm = Search()
    @FocusState private var nameIsFocused: Bool
    @State public var already: String = ""
    
    //@State public var showingAlert: String
    @State public var show: String = ""
    @State private var rocks = [Post]()
    var body: some View {
        ZStack(alignment: .top) {
            MapView(annotation: annotation,latlng: $latlng)
                .edgesIgnoringSafeArea(.all)
                /*.confirmationDialog("Are you sure?",
                  isPresented: $showingAlert) {
                  Button("Open link?", role: .destructive) {
                      UIApplication.shared.open(URL(string: showingAlert)!)
                   }
                 }*/
            VStack{
                HStack{
                    Image(systemName: "return.right")
                        .onTapGesture {
                            withAnimation(.default.speed(0.3)) {
                                if show == ""{
                                    show = "posts"
                                } else {
                                    show = ""
                                }
                            }
                        }
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .frame(height: 44)
                        .padding()
                    TextField("Cities", text: $vm.searchQuery).padding()
                        .focused($nameIsFocused)
                        .onReceive(
                            vm.$searchQuery
                                .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
                        ) {
                            guard !$0.isEmpty else { return }
                            /*if Auth.auth().currentUser == nil {
                                Auth.auth().signInAnonymously()
                            }*/
                            if already == vm.searchQuery { return }
                            already = vm.searchQuery
                            print(">> searching for: \($0)")
                            //performSearch(query: searchQuery)
                            //print("searching \(vm.$searchQuery) s \($vm.searchQuery) v \(vm.searchQuery)")
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .iso8601
                            Task {
                                let urlString = "https://api.mapbox.com/geocoding/v5/mapbox.places/\(vm.searchQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!).json?limit=2&types=place&access_token=pk.eyJ1Ijoibmlja2NhcmR1Y2NpIiwiYSI6ImNrMWhyZ3ZqajBhcm8zY3BoMnVnbW02dXQifQ.aw4gJV_fsZ1GKDjaWPxemQ"
                                let url = URL(string: urlString)!
                                print("searching \(urlString)")
                                //let (data, _) = try await URLSession.shared.data(from: url)
                                
                                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                                    //if error != nil { return print(error) }
                                    if let data = data{
                                        do {
                                           let place = try decoder.decode(Place.self, from: data)
                                            print("found \(place)")
                                            //place = try decoder.decode(Place.self, from: data)
                                            //print(place)
                                            DispatchQueue.main.async {
                                                if place.features.count == 0 {return}
                                                placename = place.features[0].placeName
                                                latlng = CLLocationCoordinate2D(latitude: place.features[0].center[1], longitude: place.features[0].center[0])
                                                nameIsFocused = false
                                            }
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                                task.resume()
                            }
                            
                            let db = Firestore.firestore()

                            /*let geoFirestoreRef = db.collection("event")
                            let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
                            
                            let center = GeoPoint(latitude: place.features[0].center[1], longitude: place.features[0].center[0])
                            
                            let circleQuery = geoFirestore.query(withCenter: center, radius: 100.0)
                            let _ = circleQuery.observeReady {
                                print("All initial data has been loaded and events have been fired!")
                            }
                            let _ = circleQuery.observe(.documentEntered, with: { (key, location) in
                                geoFirestoreRef.document(key!).getDocument  { (document, error) in
                                    //if error != nil { return print(error ?? "missing permissions probably") }
                                               if let document = document, document.exists {
                                                   
                                                   let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                   print("Document data: \(dataDescription)")
                                                   let event = Event(id: document.documentID,
                                                                     title: document["title"] as? String ?? "",
                                                                     center: document["center"] as? Array<CLLocationDegrees> ?? [-74,43],
                                                                     url: "https://tpt.net.co/event/\(document.documentID)")
                                                   print(event)
                                                   let annotation = Annotation(coordinate: .init(latitude: event.center[0],
                                                                                                 longitude: event.center[1]), title: event.title, subtitle: event.url)
                                                   self.annotation = annotation
                                               } else {
                                                   print("Document does not exist.")
                                               }
                                           }
                            })*/
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
                                                            /*.onLongPressGesture {
                                                                UIApplication.shared.open(URL(string: "https://tpt.net.co/event/\(document.documentID)")!
                                                            }*/
                                                        self.annotation = annotation
                                                    }
                                            }
                                    }
                            //latlng = [place?.features[0].center[0] ?? -74, place?.features[0].center[1] ?? 43]
                                let consumerSecret = "iAkWSqAXXAFLtxiFJYQJeqYpWcZDVUbt"
                                let urllString = "https://app.ticketmaster.com/discovery/v2/events.json?geoPoint=\(Geohash.encode(latitude:(place?.features[0].center[1]) ?? 0, longitude:(place?.features[0].center[0]) ?? 0, length:9))&classificationName=music&size=150&apikey=\(consumerSecret)"
                                let urll = URL(string: urllString)!
                                let task = URLSession.shared.dataTask(with: urll) { dataa, response, error in
                                    //let (dataa, _) = try await URLSession.shared.data(from: urll)
                                    if let dataa = dataa{
                                        do {
                                            let ticketmaster = try decoder.decode(Ticketmaster.self, from: dataa)
                                            //if ticketmaster?.Embedded.events.isEmpty! {
                                            print(ticketmaster)
                                            //if ticketmaster.Embedded.events.count == 0 {return}
                                            
                                            for event in ticketmaster.Embedded.events {
                                                let annotation = Annotation(coordinate: .init(latitude: Double(event.Embedded.venues[0].location.latitude)!,
                                                        longitude: Double(event.Embedded.venues[0].location.longitude)!), title: event.name, subtitle: event.url) //MKPointAnnotation
                                                    
                                                self.annotation = annotation
                                            }
                                            
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                                task.resume()
                        }
                        //.padding()
                }
                Spacer()
                AddEvent(latlng: $latlng)

                /*Text("location")
                    .onTapGesture {
                        let locManager = CLLocationManager()
                        locManager.requestWhenInUseAuthorization()
                        var currentLocation: CLLocation!

                          currentLocation = locManager.location
                        switch locManager.authorizationStatus {
                        case .restricted, .denied:()
                        default:
                            latlng =//:Array<CLLocationDegrees> =
                            CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                        }
                    }
                .frame(height: 44)
                .padding()*/
            }
            VStack(alignment: .leading) {
                HStack{
                    Spacer()
                
                    Text("Read")
                        .onTapGesture {
                            withAnimation(.default.speed(0.3)) {
                                
                                rocks = []
                                let db = Firestore.firestore()
                                db.collection("forum").whereField("city", isEqualTo: placename).getDocuments() { (querySnapshot, error) in
                                                if let error = error {
                                                        print("Error getting documents: \(error)")
                                                } else {
                                                        if querySnapshot!.documents.isEmpty {
                                                            return print("is empty")
                                                        }
                                                    
                                                        for document in querySnapshot!.documents {
                                                                //print("\(document.documentID): \(document.data())")
                                                            let post = Post(id: document.documentID,
                                                                            message: document["message"] as? String ?? "")
                                                            //print(post)
                                                            
                                                            rocks.append(post)
                                                            
                                                        }
                                                }
                                        }
                            }
                        }
                        .foregroundColor(.black)
                        .padding(10)
                }
                GeometryReader { geometry in
                    ScrollView {
                        List {
                            ForEach ($rocks.indices, id: \.self){ index in
                                FirestoreSubView(show:$show,message:$rocks[index].message)
                            }
                        }
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                    }
                    .frame(height: .infinity)
                }
                Image(systemName: "return.right")
                    .onTapGesture {
                        withAnimation(.default.speed(0.3)) {
                            if show == ""{
                                show = "posts"
                            } else {
                                show = ""
                            }
                        }
                    }
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .frame(height: 44)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(x: show == "posts" ? 0 : UIScreen.screenWidth)
            /*HStack{
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
                                
                                nameIsFocused = false
                            }
                    }
            }.padding()*/
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirestoreManager())
    }
}


