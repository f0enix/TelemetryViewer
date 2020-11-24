//
//  DetailSidebar.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.11.20.
//

import SwiftUI

struct DetailSidebar<Content>: View where Content: View {
    private let content: Content
    private let maxWidth: CGFloat
    private let title: String

    @Binding var isOpen: Bool

    public init(isOpen: Binding<Bool>, title: String = "", maxWidth: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.maxWidth = maxWidth
        self.title = title
        self._isOpen = isOpen
    }

    var body: some View {
        HStack {
            Divider()

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation { isOpen = false }
                    }, label: {
                        Image(systemName: "sidebar.trailing")
                    })
                }
                .padding(.horizontal)

                Divider()

                content

                Spacer()
            }


        }
        .frame(maxWidth: maxWidth)
    }
}

struct DetailSidebar_Previews: PreviewProvider {
    static var previews: some View {

        HStack {
            Color.blue
            DetailSidebar(isOpen: .constant(true), title: "Hello world", maxWidth: 500) {
                Color.green
            }
        }


    }
}