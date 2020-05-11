//
//  Net.swift
//  Tutorial4
//
//  Created by 위대연 on 2020/05/07.
//  Copyright © 2020 위대연. All rights reserved.
//

import Foundation
import Alamofire

class Net {
    var manager:Alamofire.SessionManager?
    static let sheared = Net()
    
    struct ViewsForm {
        let date:String
        let count:Int
    }
    
    let server = "http://127.0.0.1:5000"
    let viewsApi = "/api/get-views"
    
    private init() {
        let confi = URLSessionConfiguration.default
        confi.timeoutIntervalForRequest = 30
        self.manager = Alamofire.SessionManager(configuration: confi)
    }
    
    ///parameter timezone = current
    func getViews(year:Int, month:Int,_ complet:@escaping (Array<ViewsForm>)->Void ) {
        let url = URL(string: self.server + self.viewsApi)!
        let param:Parameters = ["year":year, "month":month, "tz":9]
        print("request = \(year) - \(month)")
        request(url, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in

            switch response.result {
            case .failure(let err):
                print("Error Net.getViews, \(err.localizedDescription)")
                complet(Array<ViewsForm>())
            case .success(let result):
                if let root = result as? [String:Any]{
                    let status = root["result"] as? String ?? ""
                    let error = root["error"] as? String ?? ""
                    if status != "success" {
                        print("Net.getViews reqeust status = \(status), \(error)")
                        complet(Array<ViewsForm>())
                    } else {
                        var returnArray = [ViewsForm]()
                        let views_data = root["searched"] as! [Any]
                        for datum in views_data {
                            if let views = datum as? [String:Any] {
                                let count = views["count"] as? Int ?? 0
                                let date = views["date_str"] as? String ?? ""
                                returnArray.append(ViewsForm(date: date, count: count))
                            }
                        }
                        complet(returnArray)
                    }
                } else {
                    complet(Array<ViewsForm>())
                }
            }// response.sresult
        }// request
    }//getViews
    
    func cancelRequest() {
        self.manager?.session.invalidateAndCancel()
    }
    
}
