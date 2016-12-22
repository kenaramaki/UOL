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
    
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor(red: 247/255, green: 178/255, blue: 32/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let logo = UIImage(named: "uol.png")
        imageView.image = logo
        navigationItem.titleView = imageView
        
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
                                        
                                 
                                        // Adicionando cada noticia no array de noticias
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
    
    //Métodos TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticiasArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NoticiaTableViewCell
        
        let noticia = noticiasArray[indexPath.row]
        
        cell.titleLabel.text = noticia.title
        cell.timeLabel.text = String(describing: noticia.updated)
        
        guard let thumbURL = NSURL(string: noticia.thumb) else {
            return cell
        }
        
        guard let data = NSData(contentsOf: thumbURL as URL) else {
            return cell
        }
        
        cell.thumbImageView.image = UIImage(data: data as Data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let noticia = noticiasArray[indexPath.row]
        
        if let transição = storyboard?.instantiateViewController(withIdentifier: "detalhesViewController") as? DetalhesViewController {
            
            transição.endereçoWebView = noticia.webViewURL
            transição.endereçoShare   = noticia.shareURL
            
            self.navigationController?.pushViewController(transição, animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
}
