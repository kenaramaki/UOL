//
//  Noticia.swift
//  UOL_app
//
//  Created by Árthur Ken Aramaki Mota on 19/12/16.
//  Copyright © 2016 Ken Aramaki. All rights reserved.
//

import UIKit

class Noticia {
    
    let title:String
    let thumb:String
    let updated:NSNumber
    let shareURL:String
    let webViewURL:String
    
    init(title:String, thumb:String, updated:NSNumber, shareURL:String, webViewURL:String) {
        self.title      = title
        self.thumb      = thumb
        self.updated    = updated
        self.shareURL   = shareURL
        self.webViewURL = webViewURL
    }
    
}
