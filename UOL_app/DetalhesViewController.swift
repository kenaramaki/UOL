//
//  DetalhesViewController.swift
//  UOL_app
//
//  Created by Árthur Ken Aramaki Mota on 19/12/16.
//  Copyright © 2016 Ken Aramaki. All rights reserved.
//

import UIKit

class DetalhesViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var endereçoWebView:String?
    //var endereçoShare:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let ewv = endereçoWebView,
            let url = URL(string: ewv) else {
                fatalError("URL inválida")
        }
        
        let request = URLRequest(url: url)
        
        webView.loadRequest(request)
        
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        spinner.stopAnimating()
    }


}
