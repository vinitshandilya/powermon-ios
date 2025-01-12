import SwiftUI

struct UserHome: View {
    
    var body: some View {
        
        TabView {
            
            HomeTab()
                        
            AutomationsTab()
            
            AnalyticsTab()
            
            AppSettingsTab()
            
            
        }
        .accentColor(Color("NavbarItemsColor"))
    }
}
