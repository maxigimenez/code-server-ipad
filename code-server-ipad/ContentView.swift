//
//  ContentView.swift
//  code-server-ipad
//
//  Created by Maxi Gimenez on 7/9/20.
//  Copyright © 2020 Maxi Gimenez. All rights reserved.
//

import SwiftUI
import WebKit
import Combine

class WebViewModel: ObservableObject {
    @Published var link: String
    @Published var didFinishLoading: Bool = false

    init (link: String) {
        self.link = link
    }
}

struct SwiftUIWebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    let webView = WKWebView()

    func makeUIView(context: UIViewRepresentableContext<SwiftUIWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        if let url = URL(string: viewModel.link) {
            self.webView.load(URLRequest(url: url))
        }
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SwiftUIWebView>) {
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.viewModel.didFinishLoading = true
        }
    }

    func makeCoordinator() -> SwiftUIWebView.Coordinator {
        Coordinator(viewModel)
    }
}

struct ContentView: View {
    @ObservedObject var model = WebViewModel(link: "http://localhost:3000")
    
    var body: some View {
        SwiftUIWebView(viewModel: model)
    }
}
