//
//  ListagemViewController.swift
//  UOL_app
//
//  Created by Árthur Ken Aramaki Mota on 19/12/16.
//  Copyright © 2016 Ken Aramaki. All rights reserved.
//

import UIKit

class ListagemViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    // API UOL
    final let urlString = "http://app.servicos.uol.com.br/c/api/v1/list/news/?app=uol-placar-futebol&version=2"
    
    @IBOutlet weak var tableView: UITableView!

    var noticiasArray = [Noticia]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.downloadJsonWithURL()
        print("TESTE")
        
    }

    
    // Método downloadJsonWithURL
    func downloadJsonWithURL() {
        
        guard let url = NSURL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: (url as URL), completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print("ERROR")
            } else {
                
                if let data = data {
                    
                    do {
                        
                        if let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                            
                            print(jsonObj.value(forKey:"feed"))
                            
                            if let noticiasArray = jsonObj.value(forKey:"feed") as? NSArray {
                                
                                for noticia in noticiasArray {
                                    
                                    if let noticiasDict = noticia as? NSDictionary {
                                        
                                        // title
                                        let titleStr: String = {
                                            if let title = noticiasDict.value(forKey: "title") {
                                                return title as! String
                                            }
                                            return "Title"
                                            
                                        }()
                                        
                                        // updated
                                        let updatedNumber:NSNumber = {
                                            if let updated = noticiasDict.value(forKey: "updated") {
                                                return updated as! NSNumber
                                            }
                                            return NSNumber()
                                        }()
                                        
                                        // thumb
                                        let thumbStr:String = {
                                            if let thumb = noticiasDict.value(forKey: "thumb"){
                                                return thumb as! String
                                            }
                                            return "Image"
                                        }()
                                        
                                        // webViewURL
                                        let webViewURLStr:String = {
                                            if let webViewURL = noticiasDict.value(forKey: "webview-url") {
                                                return webViewURL as! String
                                            }
                                            return "webViewURL"
                                            
                                        }()
                                        
                                        // shareURL
                                        let shareURLStr:String = {
                                            if let shareURL = noticiasDict.value(forKey: "share-url") {
                                                return shareURL as! String
                                            }
                                            return "shareURL"
                                            
                                        }()
                                        
                                        /*
                                        // shareURL
                                        let shareURLStr:String = {
                                            if let shareURL = noticiasDict.value(forkey: "share-url"){
                                                return shareURL as! String
                                            }
                                            return "shareURL"
                                        }()
                                        */
                                        
                                        self.noticiasArray.append(Noticia(title: titleStr, thumb: thumbStr, updated: updatedNumber, shareURL: shareURLStr, webViewURL: webViewURLStr))
                                        
                                        OperationQueue.main.addOperation {
                                            self.tableView.reloadData()
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }catch {
                        
                    }
                    
                }
                
            }
            
        }).resume()
        
    }
    
    //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticiasArray.count
    }
    
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NoticiaTableViewCell
        return cell
    }
    
    
}
