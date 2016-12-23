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
        
        
        if let navigationBar = self.navigationController?.navigationBar {
        
            let imageView = UIImageView(frame: CGRect(x: ((navigationBar.frame.width/2) - 40), y: 0, width: 38, height: 38))
            imageView.contentMode = .scaleAspectFit
            let logo = UIImage(named: "uol.png")
            imageView.image = logo
            //navigationItem.titleView = imageView
        
            let titleFrame = CGRect(x: navigationBar.frame.width/2, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height)
        
            let titleLabel = UILabel(frame: titleFrame)
            titleLabel.text = "Notícia"
            titleLabel.textColor = UIColor.white
        
        
        
            navigationBar.addSubview(titleLabel)
            navigationBar.addSubview(imageView)
        
        }
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
        
        let updatedStr = String(describing: noticia.updated)
        
        // Aqui eu pego a string updated e corto ela para que aparecça apenas as horas
        // Exemplo: 20161222214536 (para melhor visualização 2016_12_22_21_45_36) e pego o 21
        let hourStart = updatedStr.index(updatedStr.startIndex, offsetBy:8)
        let hourEnd   = updatedStr.index(updatedStr.endIndex, offsetBy: -4)
        let hour      = updatedStr.substring(with: hourStart..<hourEnd)
        
        // Aqui eu pego a string updated e corto ela para que aparecça apenas os minutos
        // Exemplo: 20161222214536 (para melhor visualização 2016_12_22_21_45_36) e pego o 45
        let minuteStart = updatedStr.index(updatedStr.startIndex, offsetBy:10)
        let minuteEnd   = updatedStr.index(updatedStr.endIndex, offsetBy: -2)
        let minute      = updatedStr.substring(with: minuteStart..<minuteEnd)
        
        cell.titleLabel.text = noticia.title
        cell.timeLabel.text = ("\(hour)h\(minute)")
        
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
