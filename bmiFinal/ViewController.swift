//
//  ViewController.swift
//  bmiFinal
//
//  Created by Emmanuel Etti on 2016-03-18.
//  Copyright © 2016 Emmanuel Etti. All rights reserved.
//

import UIKit
import Charts
import Social

class ViewController: UIViewController,ChartViewDelegate{

    @IBOutlet weak var lineChartView: LineChartView!
    let record_key : String = "bmiArray"
    
    var bmiArray = [Double]()
    var weightArray = [String]()
    
    @IBOutlet weak var labelTxt: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults() //set defaults ? localStorage

    override func viewWillAppear(animated: Bool) {
        let myElement = defaults.objectForKey(record_key) as? [[String:Float]] ?? [[String:Float]]()
        var bmiVolatile = [Double]()
        var weightVolatile = [String]()
        if(myElement.count > 0 ){
            for (key) in myElement {
                let bmi = Double(key["bmi"]!)
                let weight  = String(key["weight"]!)
                bmiVolatile.insert(bmi, atIndex: 0)
                weightVolatile.insert(weight, atIndex: 0)
            }
            bmiArray = bmiVolatile
            weightArray = weightVolatile
            self.lineChartView.notifyDataSetChanged();
            setChartData(weightArray)
            print(self.bmiArray)
            labelTxt.text = String(format:"Your current BMI is: %5.2f", myElement.first!["bmi"]!)
        }else{
            self.lineChartView.noDataText = "No data provided"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Format the lineChartView
        self.lineChartView.delegate = self
        // 2
        self.lineChartView.descriptionText = "BMI / Weight"
        // 3
        self.lineChartView.descriptionTextColor = UIColor.whiteColor()
        self.lineChartView.gridBackgroundColor = UIColor.darkGrayColor()
        // 4
        self.lineChartView.fitScreen()
        self.lineChartView.pinchZoomEnabled = true
        
        let share:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareChart")
        navigationItem.rightBarButtonItems = [share]
        
        // Read data stored in local storage
        let myElement = defaults.objectForKey(record_key) as? [[String:Float]] ?? [[String:Float]]()
        if myElement.count > 0 {
            for (key) in myElement {
                let bmi = Double(key["bmi"]!)
                let weight  = String(key["weight"]!)
                self.bmiArray.insert(bmi, atIndex: 0)
                self.weightArray.insert(weight, atIndex: 0)
            }
            setChartData(weightArray)
            self.lineChartView.notifyDataSetChanged();
            labelTxt.text = String(format:"Your current BMI is: %5.2f", myElement.first!["bmi"]!)
        }else{
            self.lineChartView.noDataText = "No data provided"
        }
        
    }
    
    func setChartData(weights : [String]) {
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < weights.count; i++ {
            yVals1.append(ChartDataEntry(value: bmiArray[i], xIndex: i))
        }
        
        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "Body Mass Index")
        set1.axisDependency = .Right // Line will correlate with left axis values
        set1.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set1.setCircleColor(UIColor.redColor()) // our circle will be dark red
        set1.lineWidth = 2.0
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.redColor()
        set1.highlightColor = UIColor.whiteColor()
        set1.drawCircleHoleEnabled = true
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        //4 - pass our bmi in for our x-axis label value along with our dataSets
        let data: LineChartData = LineChartData(xVals: weightArray, dataSets: dataSets)
        data.setValueTextColor(UIColor.whiteColor())
        
        //5 - finally set our data
        self.lineChartView.data = data
        self.lineChartView.setVisibleXRangeMaximum(10);
        self.lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0 ,easingOption: .EaseInBounce)
        let ll = ChartLimitLine(limit: 20.0, label: "Target")
        ll.lineColor = UIColor.brownColor()
        self.lineChartView.rightAxis.addLimitLine(ll)
        
    }

    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print("\(self.weightArray[entry.xIndex) in \(self.bmiArray[entry.xIndex])")
    }
    
    func shareChart(){
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let myElement = self.defaults.objectForKey(record_key) as? [[String:Float]] ?? [[String:Float]]()
        if(myElement.count > 0 ){
            vc.setInitialText(String(format:"Hey guys, my current BMI is: %5.2f", myElement.first!["bmi"]!))
//        let url:String = "http://www.facebook.com"
//        vc.addURL(NSURL(string: "http://www.photolib.noaa.gov/nssl"))
//        let image = UIImage!(self.lineChartView.saveToCameraRoll())
            UIGraphicsBeginImageContext(self.view.bounds.size);
            self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
//        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
            let screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        //        let newurl = NSURL(string: url)
//        vc.addURL(newurl)
            vc.addImage(screenShot)
        }else{
            vc.setInitialText("I haven't calculated my BMI yet.")
        }
        presentViewController(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

