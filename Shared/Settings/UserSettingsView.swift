//
//  UserSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient

struct UserSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    @EnvironmentObject var telemetryManager: TelemetryManager
    
    var body: some View {
        if let user = api.user {
            
            VStack(alignment: .leading) {
                HStack {
                    Text("First Name")
                    Text(user.firstName).bold()
                }
                
                HStack {
                    Text("Last Name")
                    Text(user.lastName).bold()
                }
                
                HStack {
                    Text("Email")
                    Text(user.email).bold()
                }
                
                Button("Log Out") {
                    api.logout()
                }
            }
            .navigationTitle("User Settings")
            .onAppear {
                telemetryManager.send(TelemetrySignal.userSettingsShown.rawValue, for: api.user?.email)
            }
        }
    }
}
