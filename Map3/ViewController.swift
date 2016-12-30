//
//  ViewController.swift
//  Map3
//
//  Created by Falcon on 12/29/16.
//  Copyright © 2016 ex. All rights reserved.
//

import UIKit
import ArcGIS
import CoreLocation




class  ViewController: UIViewController , AGSGeoViewTouchDelegate , UIAdaptivePresentationControllerDelegate, DirectionsListVCDelegate {
    
    
    @IBOutlet var mapView:AGSMapView!
    @IBOutlet var segmentedControl:UISegmentedControl!
    @IBOutlet var routeParametersBBI:UIBarButtonItem!
    @IBOutlet var routeBBI:UIBarButtonItem!
    @IBOutlet var directionsListBBI:UIBarButtonItem!
    @IBOutlet var directionsBottomConstraint:NSLayoutConstraint!
    
    private var stopGraphicsOverlay = AGSGraphicsOverlay()
    private var barrierGraphicsOverlay = AGSGraphicsOverlay()
    private var routeGraphicsOverlay = AGSGraphicsOverlay()
    private var directionsGraphicsOverlay = AGSGraphicsOverlay()
    
    private var routeTask:AGSRouteTask!
    private var routeParameters:AGSRouteParameters!
    private var isDirectionsListVisible = false
    private var directionsListViewController:DirectionsListViewController!
    
    var generatedRoute:AGSRoute! {
        didSet {
            let flag = generatedRoute != nil
            self.directionsListBBI.isEnabled = flag
            self.toggleRouteDetails(on: flag)
//            self.directionsListViewController.route = generatedRoute
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//       self.mapView.map = AGSMap(basemapType: .streets, latitude: 127.78783,  longitude: 80.44444, levelOfDetail: 16)
        
     //   self.startLocationDisplay(autoPanMode: AGSLocationDisplayAutoPanMode.recenter)
        
        
        
        //add the source code button item to the right of navigation bar
       (self.navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["ViewController", "DirectionsListViewController", "RouteParametersViewController"]
        
        let map = AGSMap(basemap: AGSBasemap.topographic())
        
        self.mapView.map = map
        self.mapView.touchDelegate = self
        
        //add the graphics overlays to the map view
        self.mapView.graphicsOverlays.addObjects(from: [routeGraphicsOverlay, directionsGraphicsOverlay, barrierGraphicsOverlay, stopGraphicsOverlay])
        
        //zoom to viewpoint
        self.mapView.setViewpointCenter(AGSPoint(x: -13042254.715252, y: 3857970.236806, spatialReference: AGSSpatialReference(wkid: 3857)), scale: 1e5, completion: nil)
        
        //initialize route task
        self.routeTask = AGSRouteTask(url: NSURL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/Route")! as URL)
        
        //get default parameters
        self.getDefaultParameters()
        
        //hide directions list
        self.toggleRouteDetails(on: false)
    }
    
    //MARK: - Route logic
    
    func getDefaultParameters() {
        self.routeTask.defaultRouteParameters(completion: { [weak self] (params: AGSRouteParameters?, error: NSError?) -> Void in
            if error != nil {
                //               SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                
            }
            else {
                self?.routeParameters = params
                //enable bar button item
                self?.routeParametersBBI.isEnabled = true
            }
            } as! (AGSRouteParameters?, Error?) -> Void)
    }
    
    @IBAction func route() {
        //add check
        if self.routeParameters == nil || self.stopGraphicsOverlay.graphics.count < 2 {
            //           SVProgressHUD.showErrorWithStatus("Either parameters not loaded or not sufficient stops")
            return
        }
        
        //      SVProgressHUD.showWithStatus("Routing", maskType: SVProgressHUDMaskType.Gradient)
        
        //clear routes
        self.routeGraphicsOverlay.graphics.removeAllObjects()
        
        self.routeParameters.returnStops = true
        self.routeParameters.returnDirections = true
        
        //add stops
        var stops = [AGSStop]()
        for graphic in self.stopGraphicsOverlay.graphics as AnyObject as! [AGSGraphic] {
            let stop = AGSStop(point: graphic.geometry as! AGSPoint)
            stop.name = "\(self.stopGraphicsOverlay.graphics.index(of: graphic)+1)"
            stops.append(stop)
        }
        self.routeParameters.clearStops()
        self.routeParameters.setStops(stops)
        
        //add barriers
        var barriers = [AGSPolygonBarrier]()
        for graphic in self.barrierGraphicsOverlay.graphics as AnyObject as! [AGSGraphic] {
            let polygon = graphic.geometry as! AGSPolygon
            let barrier = AGSPolygonBarrier(polygon: polygon)
            barriers.append(barrier)
        }
        self.routeParameters.clearPolygonBarriers()
        self.routeParameters.setPolygonBarriers(barriers)
        
        //        self.routeTask.solveRouteWithParameters(self.routeParameters) { [weak self] (routeResult:AGSRouteResult?,  error:NSError?) -> Void in
        //            if let error = error {
        //                SVProgressHUD.showErrorWithStatus("\(error.localizedDescription) \(error.localizedFailureReason ?? "")")
        //            }
        //            else {
        //                SVProgressHUD.dismiss()
        //                let route = routeResult!.routes[0]
        //                let routeGraphic = AGSGraphic(geometry: route.routeGeometry, symbol: self!.routeSymbol(), attributes: nil)
        //                self?.routeGraphicsOverlay.graphics.addObject(routeGraphic)
        //                self?.generatedRoute = route
        //            }
        //        } as! (AGSRouteResult?, Error?) -> Void
    }
    
    func routeSymbol() -> AGSSimpleLineSymbol {
        let symbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.yellow, width: 5)
        return symbol
    }
    
    func directionSymbol() -> AGSSimpleLineSymbol {
        let symbol = AGSSimpleLineSymbol(style: .dashDot, color: UIColor.orange, width: 5)
        return symbol
    }
    
    private func symbolForStopGraphic(index: Int) -> AGSSymbol {
        let markerImage = UIImage(named: "BlueMarker")!
        let markerSymbol = AGSPictureMarkerSymbol(image: markerImage)
        markerSymbol.offsetY = markerImage.size.height/2
        
        let textSymbol = AGSTextSymbol(text: "\(index)", color: UIColor.white, size: 20, horizontalAlignment: AGSHorizontalAlignment.center, verticalAlignment: AGSVerticalAlignment.middle)
        textSymbol.offsetY = markerSymbol.offsetY
        
        let compositeSymbol = AGSCompositeSymbol(symbols: [markerSymbol, textSymbol])
        
        return compositeSymbol
    }
    
    func barrierSymbol() -> AGSSimpleFillSymbol {
        return AGSSimpleFillSymbol(style: .diagonalCross, color: UIColor.red, outline: nil)
    }
    
    //MARK: - AGSGeoViewTouchDelegate
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        //normalize geometry
        let normalizedPoint = AGSGeometryEngine.normalizeCentralMeridian(of: mapPoint)!
        
        if segmentedControl.selectedSegmentIndex == 0 {
            //create a graphic for stop and add to the graphics overlay
            let graphicsCount = self.stopGraphicsOverlay.graphics.count
            let symbol = self.symbolForStopGraphic(index: graphicsCount+1)
            let graphic = AGSGraphic(geometry: normalizedPoint, symbol: symbol, attributes: nil)
            self.stopGraphicsOverlay.graphics.add(graphic)
            
            //enable route button
            if graphicsCount > 0 {
                self.routeBBI.isEnabled = true
            }
        }
        else {
            let bufferedGeometry = AGSGeometryEngine.bufferGeometry(normalizedPoint, byDistance: 500)
            let symbol = self.barrierSymbol()
            let graphic = AGSGraphic(geometry: bufferedGeometry, symbol: symbol, attributes: nil)
            self.barrierGraphicsOverlay.graphics.add(graphic)
        }
    }
    
    //MARK: - Actions
    
    @IBAction func clearAction() {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.stopGraphicsOverlay.graphics.removeAllObjects()
            self.routeBBI.isEnabled = false
        }
        else {
            self.barrierGraphicsOverlay.graphics.removeAllObjects()
        }
    }
    
    @IBAction func directionsListAction() {
        self.directionsBottomConstraint.constant = self.isDirectionsListVisible ? -115 : 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            self?.view.layoutIfNeeded()
        }) { [weak self] (finished) -> Void in
            self?.isDirectionsListVisible = !self!.isDirectionsListVisible
        }
    }
    
    func toggleRouteDetails(on:Bool) {
        self.directionsBottomConstraint.constant = on ? -115 : -150
        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            self?.view.layoutIfNeeded()
        }) { [weak self] (finished) -> Void in
            if !on {
                self?.isDirectionsListVisible = false
            }
        }
    }
    
    //MARK: - Navigation
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RouteSettingsSegue" {
            let controller = segue.destination as! RouteParametersViewController
            controller.presentationController?.delegate = self
            controller.preferredContentSize = CGSize(width: 300, height: 125)
            controller.routeParameters = self.routeParameters
        }
        else if segue.identifier == "DirectionsListSegue" {
            self.directionsListViewController = segue.destination as! DirectionsListViewController
            self.directionsListViewController.delegate = self
        }
    }
    
    //MARk: - UIAdaptivePresentationControllerDelegate
    
    private func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        return .none
    }
    
    //MARK: - DirectionsListVCDelegate
    
    func directionsListViewControllerDidDeleteRoute(directionsListViewController: DirectionsListViewController) {
        self.generatedRoute = nil;
        self.routeGraphicsOverlay.graphics.removeAllObjects()
        self.directionsGraphicsOverlay.graphics.removeAllObjects()
    }
    
    func directionsListViewController(directionsListViewController: DirectionsListViewController, didSelectDirectionManuever directionManeuver: AGSDirectionManeuver) {
        //remove previous directions
        self.directionsGraphicsOverlay.graphics.removeAllObjects()
        
        //show the maneuver geometry on the map view
        let directionGraphic = AGSGraphic(geometry: directionManeuver.geometry!, symbol: self.directionSymbol(), attributes: nil)
        self.directionsGraphicsOverlay.graphics.add(directionGraphic)
        
        //zoom to the direction
        self.mapView.setViewpointGeometry(directionManeuver.geometry!.extent, padding: 100, completion: nil)
    }
    
    
    //to start location display, the first time
    //dont forget to add the location request field in the info.plist file
    func startLocationDisplay(autoPanMode:AGSLocationDisplayAutoPanMode) {
        self.mapView.locationDisplay.autoPanMode = autoPanMode
        self.mapView.locationDisplay.start { (error:Error?) in
            
        }
    }
    
    
    
    
    
}

