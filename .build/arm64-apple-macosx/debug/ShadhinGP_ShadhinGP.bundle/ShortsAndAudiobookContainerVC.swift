//
//  WebContainerVC.swift
//  Shadhin_Gp_Examaple
//
//  Created by Shadhin Music on 23/11/25.
//

import UIKit
import WebKit

final class ShortsAndAudiobookContainerVC: UIViewController, NIBVCProtocol {

    // MARK: - Single Shared WebView
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        
        // Video Settings
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let js = """
        (function() {
            function forceInline(v) {
                try {
                    v.playsInline = true;
                    v.setAttribute('playsinline', '');
                    v.setAttribute('webkit-playsinline', '');
                } catch(e) {}
            }
            function applyToExisting() {
                try {
                    var vids = document.querySelectorAll('video');
                    vids.forEach(v => forceInline(v));
                } catch(e){}
            }
            applyToExisting();

            // Observe dynamically added videos
            try {
                const observer = new MutationObserver(mutations => {
                    mutations.forEach(m => {
                        m.addedNodes.forEach(node => {
                            if (!node) return;
                            if (node.tagName === 'VIDEO') forceInline(node);
                            if (node.querySelectorAll) {
                                node.querySelectorAll('video').forEach(v => forceInline(v));
                            }
                        });
                    });
                });
                observer.observe(document.documentElement || document.body, {
                    childList: true,
                    subtree: true
                });
            } catch(e){}

            // Block fullscreen completely
            try {
                HTMLVideoElement.prototype.requestFullscreen = () => Promise.resolve();
                HTMLVideoElement.prototype.webkitEnterFullscreen = () => {};
                Element.prototype.requestFullscreen = () => Promise.resolve();
            } catch(e){}
        })();
        """
        
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        
        let web = WKWebView(frame: .zero, configuration: config)
        web.scrollView.isScrollEnabled = true
        web.navigationDelegate = self
        web.allowsBackForwardNavigationGestures = true
        web.isOpaque = false
        web.backgroundColor = .clear
        if #available(iOS 16.4, *) { web.isInspectable = true }
        return web
    }()
    
    // MARK: - Loading Overlay (Beautiful Full Screen Loader)
    private lazy var loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.isHidden = true
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()
    
    private var snapshotView: UIView?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupLoadingOverlay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            LoadingIndicator.initLoadingIndicator(view: self.loadingOverlay)
            LoadingIndicator.startAnimation()
        }

        self.view.backgroundColor = ShadhinCore.instance.defaults.isLighTheam ? .white : .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllMediaAndLoading()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAllMediaAndLoading()
    }

    private func stopAllMediaAndLoading() {
        webView.evaluateJavaScript("document.querySelectorAll('video, audio').forEach(el => el.pause && el.pause());") { _, error in
            if error != nil { print("Pause failed") }
        }
        
        webView.stopLoading()
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupLoadingOverlay() {
        view.addSubview(loadingOverlay)
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(loadingOverlay)
    }

    // MARK: - Public Methods (Call from TabBar)
    func showShorts() {
        let token = ShadhinCore.instance.defaults.userSessionToken
        let isDark = !ShadhinCore.instance.defaults.isLighTheam
        let urlStr = "https://shadhinmusic.com/shorts/for-you?token=\(token)&source=android&isDarkTheme=\(isDark)&code=\(ShadhinCore.instance.defaults.userCode)"
        loadURL(urlStr)
    }
    
    func showAudiobook() {
        let token = ShadhinCore.instance.defaults.userSessionToken
        let isDark = !ShadhinCore.instance.defaults.isLighTheam
        let urlStr = "https://shadhinmusic.com/audiobook-home?token=\(token)&source=android&isDarkTheme=\(isDark)&code=\(ShadhinCore.instance.defaults.userCode)"
        loadURL(urlStr)
    }
    
    func showAudiobookDetails(contentType: String, contentID: String) {
        let token = ShadhinCore.instance.defaults.userSessionToken
        let isDark = !ShadhinCore.instance.defaults.isLighTheam
        let urlStr = "https://shadhinmusic.com/details/\(contentType)/\(contentID)?type=AUDIOBOOK&token=\(token)&source=android&isDarkTheme=\(isDark)&code=\(ShadhinCore.instance.defaults.userCode)"
        loadURL(urlStr)
    }
    
    public func openShortsPlayer(url: String) {
        loadURL(url)
    }
    
    // MARK: - Private Loading Logic
    private func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        if snapshotView == nil {
            if let snap = webView.snapshotView(afterScreenUpdates: true) {
                snapshotView = snap
                snap.frame = webView.bounds
                view.addSubview(snap)
                view.bringSubviewToFront(snap)
            }
        }
        
        webView.load(URLRequest(url: url))
    }
    
    private func removeSnapshot() {
        UIView.animate(withDuration: 0.25, animations: {
            self.snapshotView?.alpha = 0
        }) { _ in
            self.snapshotView?.removeFromSuperview()
            self.snapshotView = nil
        }
    }
    
    private func showLoader() {
        loadingOverlay.isHidden = false
        view.bringSubviewToFront(loadingOverlay)
    }
    
    private func hideLoader() {
        loadingOverlay.isHidden = true
    }
    
    private func gpWebPaymentViewPageBgChange() {
        let currentURL = webView.url?.absoluteString ?? ""
        if currentURL.contains("https://sg.dob.payment.io/v3/consent?token=") {
            webView.backgroundColor = .white
            webView.scrollView.backgroundColor = .white
        } else {
            let bgColor: UIColor = ShadhinCore.instance.defaults.isLighTheam ? .white : .black
            webView.backgroundColor = bgColor
            webView.scrollView.backgroundColor = bgColor
        }
    }
}

// MARK: - WKNavigationDelegate
extension ShortsAndAudiobookContainerVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoader()
        self.gpWebPaymentViewPageBgChange()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoader()
        removeSnapshot()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoader()
        removeSnapshot()
        print("Web load failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideLoader()
        removeSnapshot()
        print("Web failed to start: \(error.localizedDescription)")
    }
}
