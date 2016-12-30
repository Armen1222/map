//
//  DirectionsListViewController.swift
//  Map3
//
//  Created by Falcon on 12/29/16.
//  Copyright © 2016 ex. All rights reserved.
//

import UIKit
import ArcGIS

protocol DirectionsListVCDelegate:class {
    func directionsListViewController(directionsListViewController:DirectionsListViewController, didSelectDirectionManuever directionManeuver:AGSDirectionManeuver)
    func directionsListViewControllerDidDeleteRoute(directionsListViewController:DirectionsListViewController)
}

class DirectionsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var milesLabel:UILabel!
    @IBOutlet var minutesLabel:UILabel!
    
    weak var delegate:DirectionsListVCDelegate?
    
    var route:AGSRoute! {
        didSet {
            self.tableView?.reloadData()
            self.updateLabels()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels() {
        if self.route != nil {
            let miles = String(format: "%.2f", self.route.totalLength*0.000621371)
            self.milesLabel.text = "(\(miles) mi)"
            
            var minutes = Int(self.route.totalTime)
            let hours = minutes/60
            minutes = minutes%60
            let hoursString = hours == 0 ? "" : "\(hours) hr "
            let minutesString = minutes == 0 ? "" : "\(minutes) min"
            self.minutesLabel.text = "\(hoursString)\(minutesString)"
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.route?.directionManeuvers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell")!
        
        cell.textLabel?.text = self.route.directionManeuvers[indexPath.row].directionText
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let directionManeuver = self.route.directionManeuvers[indexPath.row]
        self.delegate?.directionsListViewController(directionsListViewController: self, didSelectDirectionManuever: directionManeuver)
    }
    
    //MARK: - Actions
    
    @IBAction func deleteRouteAction() {
        self.delegate?.directionsListViewControllerDidDeleteRoute(directionsListViewController: self)
    }
}
