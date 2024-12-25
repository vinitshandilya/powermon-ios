import SwiftUI

struct ContentView: View {
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    var body: some View {
        if user_id.isEmpty {
            LoginView().onAppear() {
                print("user_id is empty")
            }
        } else {
            UserHome().onAppear() { // show logout button somewhere
                print("user_id found: \(user_id)")
            }
        }
    }
}

