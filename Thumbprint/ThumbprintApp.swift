//
//  ThumbprintApp.swift
//  Thumbprint
//
//  Created by Nicholas Carducci on 7/4/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class FirestoreManager: ObservableObject {

}

@main
struct ThumbprintApp: App {
    @StateObject var firestoreManager = FirestoreManager()
    init() {
        FirebaseApp.configure()
        Auth.auth().signInAnonymously { authResult, error in
          // ...
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firestoreManager)
        }
    }
}
