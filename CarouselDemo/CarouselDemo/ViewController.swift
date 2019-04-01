//
//  ViewController.swift
//  CarouselDemo
//
//  Created by Stegowl on 02/10/18.
//  Copyright © 2018 Stegowl. All rights reserved.
//

import UIKit
import iCarousel
import SDWebImage
import Alamofire
import SwiftyJSON


class ViewController: UIViewController, iCarouselDelegate, iCarouselDataSource, UITableViewDelegate, UITableViewDataSource {
    
   
    @IBOutlet weak var carouseltblView: iCarousel!
    @IBOutlet weak var tblData: UITableView!
    
    @IBOutlet weak var constraintcarouselheight: NSLayoutConstraint!
    @IBOutlet weak var viewcarouselView: UIView!
    var imageItems = UIImageView()
    var arrList = NSMutableArray()
    var arrDataList = NSMutableArray()
    var id = 0
    var aid = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carouseltblView.dataSource = self
        carouseltblView.type = .rotary
        // Do any additional setup after loading the view, typically from a nib.
        WBGetArtists()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewControllerTVC", for: indexPath) as! viewControllerTVC
        id = (arrList[indexPath.row] as AnyObject)["artist_id"] as! Int
        cell.lblName.text = (arrList[indexPath.row] as AnyObject) ["artist_name"] as? String
        let img_url = URL(string:((arrList[indexPath.row] as AnyObject)["image"] as? String)!)
        cell.imgData.sd_setImage(with: img_url, placeholderImage: UIImage(named: "PlaceHolder"), options: SDWebImageOptions.continueInBackground)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        return arrDataList.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        if let view = view as? UIImageView {
            imageItems = view
        }
        else {
            imageItems = UIImageView(frame: CGRect(x: 0, y: 0, width: 145, height: 110))
            
            let images = ((arrDataList.object(at: index)as AnyObject).value(forKey: "image") as? String)!
            imageItems.sd_setImage(with: URL(string: images), placeholderImage: UIImage(named: "notification"), options: SDWebImageOptions.continueInBackground)
            
            imageItems.contentMode = .scaleAspectFit
            
            if index == carousel.currentItemIndex {
                imageItems.contentMode = .scaleAspectFit
                imageItems.clipsToBounds = false
                let CaroselColor = UIColor(red: 255.0/255.0, green: 2.0/255.0, blue: 0.0/255.0, alpha: 0.8)
                imageItems.layer.shadowColor = CaroselColor.cgColor//UIColor.white.cgColor
                imageItems.layer.shadowOpacity = 1
                imageItems.layer.shadowOffset = CGSize.zero
                imageItems.layer.shadowRadius = 10
            }
           
        }
        return imageItems
        
    }
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let id = (arrDataList.object(at: carouseltblView.currentItemIndex)as AnyObject).value(forKey: "artist_id") as? NSNumber
        aid = id as! Int
        
        WBSongsByArtist()
       
        self.carouseltblView.reloadData()
    }

    
    func WBGetArtists() -> Void {
        let strURL = "http://durisimomobileapps.net/lostraficante/api/artistlist"
        let parameter:Parameters = ["u_id" : 1]
        print("Expense ::: \(strURL)")
        print("Parameters ::: \(parameter)")
        AFWrapper.requestPOSTURL(strURL, params: parameter as [String : AnyObject], headers: nil, success: { (Response) -> Void in
            print(Response)
            if Response != JSON.null {
                let status = Response["status"].int
                if status == 1 {
                    let data = Response["data"].arrayValue as NSArray
                    //let data = Response["data"] as! NSArray
                    self.arrDataList = data.mutableCopy() as! NSMutableArray
                    self.carouseltblView.delegate = self
                    self.carouseltblView.reloadData()
                   // self.carouseltblView.type = .linear
                    
                    }
                
                }
                else{
                    
                    print(Response["msg"])
                }
            
        }){ (error) -> Void in
            print(error)
            //         self.makeToast(myMessages.ERROR, toastMessage: error.localizedDescription as String)
            
        }
    }
    
    //MARK:- API Call Category Songs
//    func WBSongsByArtist() -> Void {
//        let strURL = "http://durisimomobileapps.net/lostraficante/api/artistsong"
//        let parameter:Parameters = ["u_id" : 1,"artist_id": id]
//        print("Expense ::: \(strURL)")
//        print("Parameters ::: \(parameter)")
//
//        AFWrapper.requestPOSTURL(strURL, params: parameter as [String : AnyObject], headers: nil, success: { (Response) -> Void in
//            print(Response)
//            if Response != JSON.null {
//                let status = Response["status"].int
//                if status == 1 {
//
//                    self.arrList = (Response["data"] as! NSArray).mutableCopy() as! NSMutableArray
//
//                    self.tblData.reloadData()
//                    }
//
//                }
//                else{
//                     print(Response["msg"])
//                }
//        }){ (error) -> Void in
//            print(error)
//            //         self.makeToast(myMessages.ERROR, toastMessage: error.localizedDescription as String)
//
//        }
//    }
    func WBSongsByArtist()
    {
        let url = "http://durisimomobileapps.net/lostraficante/api/artistsong"
        let parameter:Parameters = ["u_id": 1 , "artist_id": id]
        print(parameter)
        print(url)
        
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default).responseJSON{ Response in
            print(Response)
            
            if Response.result.value != nil
            {
                let result = Response.result.value as! NSDictionary
                let status = result["status"] as! NSNumber
                print(result)
                if status == 1{
                    let data = result["data"] as! NSArray
                    self.arrList = data.mutableCopy() as! NSMutableArray
                    self.tblData.reloadData()
                }
                else
                {
                    //self.showMyAlert(myMessage: result["msg"] as! String)
                }
            }
            else
            {
                print("no songs available")
                
            }
        }
    }
}
