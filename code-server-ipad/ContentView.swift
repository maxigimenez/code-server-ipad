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

        self.webView.scrollView.bounces = false
        self.webView.scrollView.alwaysBounceVertical = false
        self.webView.scrollView.alwaysBounceVertical = false
        self.webView.hack_removeInputAccessory()
//        self.RemoveAutoCompleteFromWebView(webView: self.webView)
        self.webView.evaluateJavaScript("alert('a')", completionHandler: nil)
        
        self.webView.navigationDelegate = context.coordinator
        if let url = URL(string: viewModel.link) {
            self.webView.load(URLRequest(url: url))
        }
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SwiftUIWebView>) {
        return
    }
    
    func RemoveAutoCompleteFromWebView(webView: WKWebView) {
        let script: String = """
            alert('1')
        """
        webView.evaluateJavaScript(script, completionHandler: nil)
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
    @ObservedObject var model = WebViewModel(link: "http://192.168.1.78:8080")

    var body: some View {
        SwiftUIWebView(viewModel: model)
    }
}

fileprivate final class InputAccessoryHackHelper: NSObject {
    @objc var inputAccessoryView: AnyObject? { return nil }
}

extension WKWebView {
    func hack_removeInputAccessory() {
        guard let target = scrollView.subviews.first(where: {
            String(describing: type(of: $0)).hasPrefix("WKContent")
        }), let superclass = target.superclass else {
            return
        }

        let noInputAccessoryViewClassName = "\(superclass)_NoInputAccessoryView"
        var newClass: AnyClass? = NSClassFromString(noInputAccessoryViewClassName)

        if newClass == nil, let targetClass = object_getClass(target), let classNameCString = noInputAccessoryViewClassName.cString(using: .ascii) {
            newClass = objc_allocateClassPair(targetClass, classNameCString, 0)

            if let newClass = newClass {
                objc_registerClassPair(newClass)
            }
        }

        guard let noInputAccessoryClass = newClass, let originalMethod = class_getInstanceMethod(InputAccessoryHackHelper.self, #selector(getter: InputAccessoryHackHelper.inputAccessoryView)) else {
            return
        }
        class_addMethod(noInputAccessoryClass.self, #selector(getter: InputAccessoryHackHelper.inputAccessoryView), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        object_setClass(target, noInputAccessoryClass)
    }
}
