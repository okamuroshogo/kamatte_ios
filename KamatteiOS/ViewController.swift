//
//  ViewController.swift
//  KamatteiOS
//
//  Created by shogo okamuro on 2018/10/28.
//  Copyright © 2018 shogo okamuro. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "https://kamatte.cc/"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        self.webView.load(request as URLRequest)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
    }
    
}

extension ViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            if url.absoluteString.contains("https://twitter.com/intent/tweet") {
                let params = url.queryParams()
                var schemeURL = URL(string: "twitter://post")!
                for (k,v) in params {
                    schemeURL = schemeURL.append(k, value: v)
                }
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.openURL(url)
                } else {
                    webView.load(URLRequest(url: url))
                }
            } else if url.absoluteString.contains("https://t.co/") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    webView.load(URLRequest(url: url))
                }
            } else {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 1.0, animations: {
            self.webView.alpha = 1.0
        }) { _ in
            self.webView.alpha = 1.0
        }
    }
}

public extension URL {
    public func queryParams() -> [String : String] {
        var params = [String : String]()
        
        guard let comps = URLComponents(string: self.absoluteString) else {
            return params
        }
        guard let queryItems = comps.queryItems else { return params }
        
        for queryItem in queryItems {
            params[queryItem.name] = queryItem.value
        }
        return params
    }
}

extension URL {
    
    @discardableResult
    func append(_ queryItem: String, value: String?) -> URL {
        
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        
        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // create query item if value is not nil
        guard let value = value else { return absoluteURL }
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)
        
        // returns the url from new url components
        return urlComponents.url!
    }
}
