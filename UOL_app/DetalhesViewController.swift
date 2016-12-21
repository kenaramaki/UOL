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
    var endereçoShare:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let eWebView = endereçoWebView,
              let urlWebView = URL(string: eWebView) else {
                fatalError("URL inválida")
        }
        
        /*
        guard let eShare = endereçoShare,
            let urlShare = URL(string: eShare) else {
                fatalError("URL inválida")
        }
        */
        
        let requestWebView = URLRequest(url: urlWebView)
        webView.loadRequest(requestWebView)
        
        
       
        
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        spinner.stopAnimating()
    }
    
    @IBAction func tapCompartilha(_ sender: Any) {
        
        let texto = "Veja este artigo"
        
        /*
        guard let eShare = endereçoShare,
            let urlShare = URL(string: eShare) else {
                fatalError("URL inválida")
        }
        */
        
        if let eShare = endereçoShare,
            let urlShare = URL(string: eShare) {
        
            let shareController = UIActivityViewController(activityItems: [texto, urlShare], applicationActivities: nil)
            self.present(shareController, animated: true, completion: nil)
        
        }
        
    }
    
}
