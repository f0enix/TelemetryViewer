//
//  BetaRequestsList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI
import TelemetryModels

struct BetaRequestDetailView: View {
    var betaRequestID: UUID?
    @EnvironmentObject var api: APIRepresentative

    @State var showDestructiveActions: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            if let betaRequest = api.betaRequests.first { $0.id == betaRequestID } {
                Group {
                    Text("Email")
                    Button(betaRequest.email) {
                        saveToClipBoard(betaRequest.email)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())

                    Text("Registration Token")
                    Button(betaRequest.registrationToken) {
                        saveToClipBoard(betaRequest.registrationToken)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())

                    Text("Requested At")

                    Text(betaRequest.requestedAt, style: .date) + Text(" at ") + Text(betaRequest.requestedAt, style: .time)

                    Text("Email Sent at")
                    if let sentAt = betaRequest.sentAt {
                        Text(sentAt, style: .date) + Text(" at ") + Text(sentAt, style: .time)
                    } else {
                        Text("–")
                    }

                    Text("Fulfilled")
                    Text(betaRequest.isFulfilled ? "Yes" : "No")
                }

                if betaRequest.sentAt == nil {
                    Divider()
                    Button("Send Email Now") {
                        api.sendEmail(for: betaRequest)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                Toggle("Show destructive actions", isOn: $showDestructiveActions)

                if showDestructiveActions {
                    Divider()
                    Button("Send Email Again") {
                        api.sendEmail(for: betaRequest)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Divider()

                    Button("Mark as \(betaRequest.isFulfilled ? "Not Fulfilled" : "Fulfilled")") {
                        let updateBody = BetaRequestUpdateBody(sentAt: betaRequest.sentAt, isFulfilled: !betaRequest.isFulfilled)
                        api.update(betaRequest: betaRequest, with: updateBody)
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Delete this Request") {
                        api.delete(betaRequest: betaRequest)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                Spacer()

            } else {
                Text("This Item does no longer exist.")
                    .foregroundColor(.grayColor)
            }
        }
        .navigationTitle(api.betaRequests.first { $0.id == betaRequestID }?.email ?? "No Selection")
        .padding(.horizontal)
    }
}

struct BetaRequestsList: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedItem: BetaRequestEmail?
    @State private var sidebarShown: Bool = false

    let refreshTimer = Timer.publish(
        every: 1 * 60, // 1 minute
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        HStack {
            List {
                let unfulfilled = api.betaRequests.filter { !$0.isFulfilled && $0.sentAt == nil }
                let emailSent = api.betaRequests.filter { !$0.isFulfilled && $0.sentAt != nil }
                let fulfilled = api.betaRequests.filter { $0.isFulfilled }

                HStack {
                    ValueView(value: Double(unfulfilled.count), title: "Unfulfilled", unit: "")
                    Divider()
                    ValueView(value: Double(emailSent.count), title: "Email Sent", unit: "")
                    Divider()
                    ValueView(value: Double(fulfilled.count), title: "Fulfilled", unit: "")
                    Divider()
                    Button(action: {
                        api.getBetaRequests()
                    }, label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                    })
                }

                Section(header: Text("Unfulfilled (\(unfulfilled.count))")) {
                    ForEach(unfulfilled) { betaRequest in
                        NavigationLink(destination: BetaRequestDetailView(betaRequestID: betaRequest.id)) {
                            Text(betaRequest.email)
                        }
                    }
                }
                Section(header: Text("Email Sent (\(emailSent.count))")) {
                    ForEach(emailSent) { betaRequest in
                        NavigationLink(destination: BetaRequestDetailView(betaRequestID: betaRequest.id)) {
                            Text(betaRequest.email)
                        }
                    }
                }

                Section(header: Text("Fulfilled (\(fulfilled.count))")) {
                    ForEach(fulfilled) { betaRequest in
                        NavigationLink(destination: BetaRequestDetailView(betaRequestID: betaRequest.id)) {
                            Text(betaRequest.email)
                        }
                    }
                }
            }
        }
        .navigationTitle("Beta Requests")
        .onReceive(refreshTimer) { _ in
            api.getBetaRequests()
        }
    }
}

struct BetaRequestsList_Previews: PreviewProvider {
    static var previews: some View {
        BetaRequestsList().environmentObject(APIRepresentative())
    }
}
