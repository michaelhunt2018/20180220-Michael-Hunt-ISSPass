//
//  ViewController.swift
//  ISS Pass Code Challenge
//
//  Created by Michael Hunt on 2/20/18.
//  Copyright © 2018 Michael Hunt. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate  {
    
    let locationManager = CLLocationManager()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return text.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let passCell = passTableView.dequeueReusableCell(withIdentifier: "cell")
        passCell?.textLabel?.text = text[indexPath.row]
        passCell?.detailTextLabel?.text = detail[indexPath.row]
        return passCell!
    }
    
    

    @IBOutlet weak var passTableView: UITableView!
    
    let text = ["TitleOne", "TitleTwo", "TitleThree"]
    let detail = ["DetailOne", "DetailTwo", "DetailThree"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
        
        passTableView.delegate = self
        passTableView.dataSource = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            
            let url = URL(string: "http://api.open-notify.org/iss-pass.json?lat=LAT&lon=LON")
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                if let data = data {
                    do {
                        // Convert the data to JSON
                        let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        
                        if let json = jsonSerialized, let url = json["url"], let response = json["response"] {
                            print(url)
                            print(response)
                        }
                    }  catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            task.resume()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopup()
        }
    }
    
    func showLocationDisabledPopup() {
        let alertController = UIAlertController(title: "Location Access Disabled", message: "Please allow location access to calculate ISS passes", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil )
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

