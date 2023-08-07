//
//  ChatView.swift
//  Thumbprint
//
//  Created by Nicholas Carducci on 7/25/23.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct Source {
    var original: String
}
extension Source: Decodable {
    enum CodingKeys: String, CodingKey {
        case original = "original"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.original = try podcastContainer.decode(String.self, forKey: .original)
    }
}
struct Photo {
    var src: Source
}
extension Photo: Decodable {
    enum CodingKeys: String, CodingKey {
        case src = "src"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.src = try podcastContainer.decode(Source.self, forKey: .src)
    }
}
struct Photos {
    var code: String
    var photos: Array<Photo>
}
extension Photos: Decodable {
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case photos = "photos"
    }
    init(from decoder: Decoder) throws {
        let podcastContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try podcastContainer.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.photos = try podcastContainer.decodeIfPresent([Photo].self, forKey: .photos) ?? []
    }
}
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}//https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui

struct Img {
    var url: String
}
struct ImageSubView: View {
    @Binding public var chosenPhoto:String
    @Binding public var urll:String
    var body: some View {
        HStack{
            AsyncImage(url: URL(string: urll)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    
            } placeholder: {
                Color.gray
            }.onTapGesture {
                chosenPhoto = urll
                print("\(urll)")
            }
            .border(chosenPhoto == urll ? .green : .black)
            //.frame(width: 250, height: 250)
            //$rocks[index].id
        }
    }
}
struct Loc {
    var center: Array<CLLocationDegrees>
    var placeName: String
}
struct LocationSubView: View {
    @Binding public var chosenCenter: Array<CLLocationDegrees>
    @Binding public var chosenPlaceName:String
    @Binding public var placeName:String
    @Binding public var center: Array<CLLocationDegrees>
    var body: some View {
        HStack{
            Text(placeName)
                .onTapGesture {
                    chosenCenter = center
                    chosenPlaceName = placeName
                    print("\(center)")
                }
                .border(chosenCenter == center ? .green : .black)
        }
    }
}
struct Types {
    var name: String
}
struct NewEvent: View {
    @StateObject private var vm = Search()
    @StateObject private var vm1 = Search()
    @FocusState private var nameIsFocused: Bool
    
    @State private var currentDate = Date()
    @State private var chosenPhoto = "https://images.pexels.com/photos/47547/squirrel-animal-cute-rodents-47547.jpeg"
    @State var chosenCenter: Array<CLLocationDegrees> = [43,-74]
    @State var chosenPlaceName: String = "Galway, New York"
    @State var chosenType: String = "business"
    
    @Binding var addEvent:Bool
    @State private var locations = [Loc]()
    @State private var images = [Img]()
    let columns: [GridItem] = [.init(.fixed(110)),.init(.fixed(110)),.init(.fixed(110))]
    
    let types = [
        Types(name: "food"),
        Types(name: "business"),
        Types(name: "tech"),
        Types(name: "recreation"),
        Types(name: "education"),
        Types(name: "arts"),
        Types(name: "sport"),
        Types(name: "concert"),
        Types(name: "cause"),
        Types(name: "party & clubbing"),
        Types(name: "day party festival")
    ]
    var body: some View {
        TabView {
            VStack{
                TextField("Places", text: $vm1.searchQuery).padding()
                    .focused($nameIsFocused)
                    .onReceive(
                        vm1.$searchQuery
                            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
                    ) {
                        guard !$0.isEmpty else { return }
                        /*if Auth.auth().currentUser == nil {
                            Auth.auth().signInAnonymously()
                        }*/
                        locations = []
                        print(">> searching for: \($0)")
                        //performSearch(query: searchQuery)
                        //print("searching \(vm.$searchQuery) s \($vm.searchQuery) v \(vm.searchQuery)")
                        Task {
                            let urlString =
                            "https://api.mapbox.com/geocoding/v5/mapbox.places/\(vm1.searchQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!).json?limit=2&access_token=pk.eyJ1Ijoibmlja2NhcmR1Y2NpIiwiYSI6ImNrMWhyZ3ZqajBhcm8zY3BoMnVnbW02dXQifQ.aw4gJV_fsZ1GKDjaWPxemQ"
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
                                        for location in place.features {
                                                //print("\(document.documentID): \(document.data())")
                                            let loc = Loc(center: [location.center[1],location.center[0]],placeName:location.placeName)
                                            //print(post)
                                            
                                            locations.append(loc)
                                            
                                        }
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            task.resume()
                        }
                    }
                HStack {
                    GeometryReader { geometry in
                        ScrollView {
                            List {//LazyVGrid(columns: columns) {
                                ForEach ($locations.indices, id: \.self){ index in
                                    LocationSubView(chosenCenter:$chosenCenter,chosenPlaceName:$chosenPlaceName,placeName: $locations[index].placeName,center: $locations[index].center)
                                }
                            }
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                        }
                        .frame(height: .infinity)
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            VStack{
                GeometryReader { geometry in
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach (0 ..< types.count, id: \.self){ index in
                                Text(types[index].name)
                                    .onTapGesture {
                                        chosenType = types[index].name
                                        print("\(chosenType)")
                                    }
                                    .border(chosenType == types[index].name ? .green : .gray)
                                    .padding(2)
                            }
                        }
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                    }
                    .frame(height: .infinity)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            VStack{
                DatePicker("", selection: $currentDate, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .padding()
                HStack {
                    TextField("Title", text: $vm.searchQuery).padding()
                        .focused($nameIsFocused)
                        .onReceive(
                            vm.$searchQuery
                                .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
                        ) {
                            guard !$0.isEmpty else { return }
                            images = []
                            
                            Task {
                                let urlString =
                                "https://api.pexels.com/v1/search?query=\(vm.searchQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&per_page=9&page=1"
                              
                                let url = URL(string: urlString)!
                                print("searching \(urlString)")
                                //let (data, _) = try await URLSession.shared.data(from: url)
                                
                                var request = URLRequest(url: url)
                                request.setValue("563492ad6f91700001000001702cdbab8c46478a86694c18d3e1bc6b", forHTTPHeaderField: "Authorization")
                                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                    //if error != nil { return print(error) }
                                    let decoder = JSONDecoder()
                                    decoder.dateDecodingStrategy = .iso8601
                                    if let data = data{
                                        do {
                                           let photo = try decoder.decode(Photos.self, from: data)
                                            print("\(photo)")
                                            for image in photo.photos {
                                                    //print("\(document.documentID): \(document.data())")
                                                let img = Img(url: image.src.original)
                                                //print(post)
                                                
                                                images.append(img)
                                                
                                            }
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                                task.resume()
                            }
                        }
                    Spacer()
                    Button(action: {
                        if vm.searchQuery != "" {
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = .init(identifier: "en_US_POSIX")
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                            var ref: DocumentReference? = nil
                            let db = Firestore.firestore()
                            ref = db.collection("event").addDocument(data: [
                                "place_name": chosenPlaceName,
                                "center": chosenCenter,
                                "coordinates": GeoPoint(latitude:chosenCenter[0],longitude: chosenCenter[1]),
                                "date": dateFormatter.string(from: currentDate),
                                "chosenPhoto": chosenPhoto,
                                "title": vm.searchQuery,
                                "subtype": FieldValue.arrayUnion([chosenType]),
                                "collection": "event"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                }
                            }
                            addEvent = false
                            
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.up")
                        }
                    }.buttonStyle(GradientButtonStyle())
                }
                GeometryReader { geometry in
                    ScrollView {
                        List {//LazyVGrid(columns: columns) {
                            ForEach ($images.indices, id: \.self){ index in
                                ImageSubView(chosenPhoto: $chosenPhoto,urll: $images[index].url)
                            }
                        }
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                    }
                    .frame(height: .infinity)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
        }
        .tabViewStyle(PageTabViewStyle())
    }
}
struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15.0)
            .scaleEffect(configuration.isPressed ? 1.3 : 1.0)
    }
}
struct AddEvent: View {
    @State public var addEvent: Bool = false
    var body: some View {
        
        NewEvent(addEvent: $addEvent)
            .offset(x: addEvent ? 0 : UIScreen.screenHeight)
            .frame(width: addEvent ? .infinity : 0)
        Button(action: {
            if(addEvent){ return addEvent = false }
            addEvent = true
        }) {
            HStack {
                Image(systemName: "arrow.up")
            }
        }.buttonStyle(GradientButtonStyle())
        
    }
}
