//
//  HelpCenterMoreItemCV.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 3/11/25.
//

import UIKit
import WebKit

// MARK: - Simple In-Memory SVG Cache
fileprivate class SVGCache {
    static let shared = SVGCache()
    private init() {}

    private var cache: [URL: String] = [:]
    
    func get(for url: URL) -> String? {
        return cache[url]
    }
    
    func set(_ svg: String, for url: URL) {
        cache[url] = svg
    }
    
    func clear() {
        cache.removeAll()
    }
}

class HelpCenterMoreItemCV: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView! {
        didSet {
            self.bgView.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
        
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib {
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func dataBindCell(data: FAQMainCategory) {
        if data.iconUrl.lowercased().hasSuffix(".svg"),
           let url = URL(string: data.iconUrl) {
            self.imageIcon.loadSVG(from: url)
        } else {
            self.imageIcon.kf.setImage(with: URL(string: data.iconUrl))
        }
        
        self.titleLabel.text = ShadhinCore.instance.isBangla ? data.titleBn : data.titleEn
    }
}


// MARK: - UIImageView + SVG Loading with Cache
extension UIImageView {
    func loadSVG(from url: URL) {
        
        self.subviews.filter({ $0 is WKWebView }).forEach { $0.removeFromSuperview() }
        
        let webView = WKWebView(frame: self.bounds)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        webView.contentMode = .scaleAspectFit
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        func render(svgString: String) {
            let html = """
            <html>
              <head>
                <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, user-scalable=no">
                <style>
                  body {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    width: 100%;
                    height: 100%;
                  }
                  svg {
                    width: 100%;
                    height: 100%;
                    object-fit: contain;
                  }
                </style>
              </head>
              <body>
                \(svgString)
              </body>
            </html>
            """

            DispatchQueue.main.async {
                webView.loadHTMLString(html, baseURL: nil)
                self.addSubview(webView)
                NSLayoutConstraint.activate([
                    webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                    webView.topAnchor.constraint(equalTo: self.topAnchor),
                    webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
            }
        }

        if let cachedSVG = SVGCache.shared.get(for: url) {
            render(svgString: cachedSVG)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let svgString = String(data: data, encoding: .utf8) else { return }

            SVGCache.shared.set(svgString, for: url)
            render(svgString: svgString)
        }.resume()
    }
}
