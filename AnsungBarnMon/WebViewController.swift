//
//  WebViewController.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/31/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    
    @IBOutlet weak var webViewGroup: UIView!
    
    private var webView: WKWebView!
    
    var userID: String!
    var type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** 네비게이션 바 타이틀 */
//            self.navigationItem.title = "Test"
        
        self.navigationController?.navigationBar.isHidden = false
        
        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "bridge")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        configuration.userContentController = contentController
        
        let targetUrl: String!
        
        switch type {
        case "privacy":
            targetUrl = "https://www.anseong.go.kr/portal/contents.do?mId=0604000000"
        case "login":
//            let sessionData: [String: Any] = [
//                "key": userID as Any
//            ]
//            if JSONSerialization.isValidJSONObject(sessionData),
//               let data = try?JSONSerialization.data(withJSONObject: sessionData, options: []),
//               let param = String(data: data, encoding: .utf8) {
//                let script = WKUserScript(
//                    source: "Object.assign(window.sessionStorage, \(param));", injectionTime: .atDocumentStart, forMainFrameOnly: true
//                    )
//                configuration.userContentController.addUserScript(script)
//            }
            let script = WKUserScript(
                source: "window.sessionStorage.setItem('key', '"+userID+"');", injectionTime: .atDocumentStart, forMainFrameOnly: true
                )
            configuration.userContentController.addUserScript(script)

            targetUrl = "https://livestock.kr"
        default:
            targetUrl = ""
        }
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        let components = URLComponents(string: targetUrl)!
        let request = URLRequest(url: components.url!)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webViewGroup.addSubview(webView)
        setAutoLayout(from: webView, to: webViewGroup)
        webView.load(request)
        
        webView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.webView.alpha = 1
        }) { _ in
            
        }
    }
    
    /** auto leyout 설정 */
    public func setAutoLayout(from: UIView, to: UIView) {
        
        from.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: from, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .trailing, relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .top, relatedBy: .equal, toItem: to, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .bottom, relatedBy: .equal, toItem: to, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        view.layoutIfNeeded()
    }

}

extension WebViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print("\(navigationAction.request.url?.absoluteString ?? "")" )
        
        decisionHandler(.allow)
    }
}

extension WebViewController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
}

extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message.name)
    }
}
