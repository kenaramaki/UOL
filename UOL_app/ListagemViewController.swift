//
//  ListagemViewController.swift
//  UOL_app
//
//  Created by Árthur Ken Aramaki Mota on 19/12/16.
//  Copyright © 2016 Ken Aramaki. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ListagemViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, GADBannerViewDelegate {

    // API UOL
    final let urlString = "http://app.servicos.uol.com.br/c/api/v1/list/news/?app=uol-placar-futebol&version=2"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var banner: GADBannerView!
    
    
    var noticiasArray = [Noticia]()
    //var datasArray  = [String]()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.downloadJsonWithURL()
        
        // Atualizando tableView
        tableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(ListagemViewController.atualizaListagem), for: .valueChanged)
        
        // Personalização da NavigationBar
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
            titleLabel.text = "Notícias"
            titleLabel.textColor = UIColor.white
        
            navigationBar.addSubview(titleLabel)
            navigationBar.addSubview(imageView)
        
        }
        
        // Ads
        banner.isHidden = true
        
        banner.delegate = self
        banner.adUnitID = "ca-app-pub-7912055668134284/7780771650"
        banner.rootViewController = self
        banner.load(GADRequest())
        
    }
    
    // Exibe o banner assim que a view tiver recebido um ad
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        banner.isHidden = false
    }
    
    // Esconde o banner se falhar em receber um ad
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        banner.isHidden = true
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
    
    // Método atualizaListagem
    
    func atualizaListagem() {
        downloadJsonWithURL()
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    //Métodos TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticiasArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NoticiaTableViewCell
        
        let noticia = noticiasArray[indexPath.row]
        
        let updatedStr = String(describing: noticia.updated)
        
        // Aqui eu pego a string updatedStr e corto ela para que aparecça apenas as horas
        // Exemplo: 20161222214536 (para melhor visualização 2016_12_22_21_45_36) e pego o 21
        let hourStart = updatedStr.index(updatedStr.startIndex, offsetBy:8)
        let hourEnd   = updatedStr.index(updatedStr.endIndex, offsetBy: -4)
        let hour      = updatedStr.substring(with: hourStart..<hourEnd)
        
        // Aqui eu pego a string updatedStr e corto ela para que aparecça apenas os minutos
        // Exemplo: 20161222214536 (para melhor visualização 2016_12_22_21_45_36) e pego o 45
        let minuteStart = updatedStr.index(updatedStr.startIndex, offsetBy:10)
        let minuteEnd   = updatedStr.index(updatedStr.endIndex, offsetBy: -2)
        let minute      = updatedStr.substring(with: minuteStart..<minuteEnd)
        
        // Pegando o dia da string updatedStr
        let dayStart = updatedStr.index(updatedStr.startIndex, offsetBy: 6)
        let dayEnd   = updatedStr.index(updatedStr.endIndex, offsetBy: -6)
        let day      = updatedStr.substring(with: dayStart..<dayEnd)
        
        // Pegando o mês da string updatedStr
        let monthStart = updatedStr.index(updatedStr.startIndex, offsetBy: 4)
        let monthEnd   = updatedStr.index(updatedStr.endIndex, offsetBy: -8)
        let month      = updatedStr.substring(with: monthStart..<monthEnd)
        
        /*
        let dia = ("\(day)/\(month)")
        
        if datasArray.contains(dia) {
            
        } else {
            datasArray.append(dia)
        }
        
        print(datasArray)
        */
        
        
        if minute == "00" {
            cell.timeLabel.text = ("\(day)/\(month) - \(hour)h")
        } else {
            cell.timeLabel.text = ("\(day)/\(month) - \(hour)h\(minute)")
        }
        
        guard let thumbURL = NSURL(string: noticia.thumb) else {
            return cell
        }
        
        guard let data = NSData(contentsOf: thumbURL as URL) else {
            return cell
        }
        
        cell.titleLabel.text = noticia.title
        cell.thumbImageView.image = UIImage(data: data as Data)
        
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let meuHeader = UILabel()
        meuHeader.backgroundColor   = UIColor.white.withAlphaComponent(0.7)
        meuHeader.textAlignment     = .center
        meuHeader.textColor         = .black
        meuHeader.font              = UIFont.boldSystemFont(ofSize: 14)
        
        meuHeader.text = "Teste"//datasArray[section]
        
        return meuHeader
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //datasArray.count
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let noticia = noticiasArray[indexPath.row]
        
        if let transição = storyboard?.instantiateViewController(withIdentifier: "detalhesViewController") as? DetalhesViewController {
            
            transição.endereçoWebView = noticia.webViewURL
            transição.endereçoShare   = noticia.shareURL
            
            self.navigationController?.pushViewController(transição, animated: true)
            
            // Deselecionar a linha
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
}
