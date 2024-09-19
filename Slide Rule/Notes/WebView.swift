//
//  WebView.swift
//  Slide Rule
//
//  Copyright (c) 2024 Rowan Richards
//
//  This file is part of Ultimate Slide Rule
//
//  Ultimate Slide Rule is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by the
//  Free Software Foundation, either version 3 of the License, or 
//  (at your option) any later version.
//
//  Ultimate Slide Rule is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

//  See the GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License along with this program.
//  If not, see <https://www.gnu.org/licenses/>.
//
//  Created by Rowan on 9/15/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable{
    @Binding var json: String
    @Binding var keyCommand: KeyCommand?
    @Binding var shouldRefresh: Bool
    @Binding var hasLoaded: Bool
    
    
    static var isReady: Bool = false
    static var wkWebView: WKWebView?
    
    init(json: Binding<String>, keyCommand: Binding<KeyCommand?>, shouldRefresh: Binding<Bool>, hasLoaded: Binding<Bool>){
        self._json = json
        self._keyCommand = keyCommand
        self._shouldRefresh = shouldRefresh
        self._hasLoaded = hasLoaded
        
        WebView.preload()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        var wkWebView: WKWebView?
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
            self.wkWebView = webView
            parent.hasLoaded = true
            //print("WebView finished loading")
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            //print("WebView started loading")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            //print("WebView failed to load with error: \(error.localizedDescription)")
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name{
            case "textHandler":
                if let messageBody = message.body as? String {
                    //if the web data is different from the stored data and we aren't trying to give data to the web
                    if parent.json != messageBody && !parent.shouldRefresh{
                        //print("Set parent json")
                        parent.json = messageBody
                        //print("Set json to '\(messageBody)'")
                    }else{
                        //print("Failed to set parent json. json: \(messageBody), shouldRefresh: \(parent.shouldRefresh), hasLoaded: \(parent.hasLoaded)")
                    }
                    //print("Recieved but did not set json to '\(messageBody)'")
                }
            default:
                print("Unknown webview handler message!: \n\"\(message)\"")
            }
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        //print("makeCoordinator")
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        //print("makeUIView")
        
        let webView = WebView.wkWebView!
        
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "textHandler")
        webView.configuration.userContentController.add(context.coordinator, name: "textHandler")
        
        //let t0 = Date().timeIntervalSince1970
        if let filePath = Bundle.main.path(forResource: "notes", ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        }
        //let t1 = Date().timeIntervalSince1970
        //print("It took \(t1-t0) seconds to load the page.")
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        //print("updateUIView")
        
        if shouldRefresh && hasLoaded {
            let js = "loadFields(String.raw`\(json)`)"
            webView.evaluateJavaScript(js){result, error in
                self.shouldRefresh = false
                //print("refreshed json!")
                if let result = result {
                    print("Result: \(result)")
                }
                if let error = error {
                    print("Error running \"\(js)\":")
                    print(error)
                }
            }
        }
        
        if let keyCommand = keyCommand {
            
            let js: String
            
            switch keyCommand.commandType{
            case .typed:
                js = "parseKeyTyped(String.raw`\(keyCommand.text)`)"
            case.special:
                js = "parseKeySpecial(String.raw`\(keyCommand.text)`)"
            case.command:
                js = "parseKeyCommand(String.raw`\(keyCommand.text)`)"
            case .createLine:
                js = "insertNewLine()"
            }
            
            webView.evaluateJavaScript(js){result, error in
                if let result = result {
                    print("Result: \(result)")
                }
                if let error = error {
                    print(error)
                }
                
            }
            
            DispatchQueue.main.async{
                self.keyCommand = nil
            }
        }
    }
    
    static func unload(){
        //print("unload)")
        WebView.wkWebView!.configuration.userContentController.removeAllScriptMessageHandlers()
        WebView.wkWebView!.navigationDelegate = nil
        WebView.wkWebView = nil
        WebView.isReady = false
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        //print("dismantleUIView")
    }
    
    static func preload() {
        if WebView.wkWebView == nil {
            //print("initiated preload webview")
            let webView = WKWebView()
            //print("preloading the web page")
            
            webView.isOpaque = false
            webView.backgroundColor = .white
            webView.scrollView.backgroundColor = .white
            webView.isInspectable = true
            
            WebView.wkWebView = webView
            //print("Sucessfully preloaded webView")
            WebView.isReady = true
        }
    }
}
