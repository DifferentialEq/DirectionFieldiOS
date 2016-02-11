//
//  EditPointsTableViewController.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/28/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import UIKit

class EditPointsTableViewController: UITableViewController {
    var tutorialCompleteTest:Bool = false
    var tutorialComplete:DBtutorial!
    var tutorialSection = 0
    var tutorialOverlay:CAShapeLayer!
    var tutorialView:UIView!
    var matrix:TwoDimMatrix?
    var ev:TwoDimMatrix?
    var evec:[TwoDimMatrix]?
    var pointArray: [CGPoint]?
    var pointsToPass: [CGPoint]?
    var pointsSelected: [Bool]!
    var matrixObject:DBMatrix!


    func startTutorial() {
        dfDBQueue.inDatabase { db in
            self.tutorialComplete = DBtutorial.fetchOne(db, "SELECT * from tutorial")
            if (self.tutorialComplete != nil && self.tutorialComplete!.tutorialcomplete == 1) {
                self.tutorialCompleteTest = true
            }
        }
    }
    
    @IBAction func displayTutorial(sender: UIView!) {
        if tutorialSection == 0 {
            tutorialView = UIView(frame: CGRect(origin: (self.navigationController?.view.frame.origin)!, size: CGSize(width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!)))
            tutorialView.frame = (self.navigationController?.view.frame)!
            tutorialView.userInteractionEnabled = true
            self.navigationController?.view.addSubview(tutorialView)
            self.navigationController?.view.bringSubviewToFront(tutorialView)
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton2 = UIButton()
            tutorialButton2.frame = CGRect(x: 0.0, y: 80.0, width: tutorialOverlay.frame.width, height: 80.0)
            tutorialButton2.addTarget(self, action: "displayTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 120, y: 180, width: 150, height: 200))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "Selecting \"Check all points\" will select all points in the 2nd section. If there are any. Sometimes it appears some points are not selected, but they really are."
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!), cornerRadius: 0.0)
            let tutorialCircle1 = UIBezierPath(roundedRect: CGRect(x: 0, y: 80, width: tutorialOverlay.frame.width, height: 80), cornerRadius: 20)
            tutorialPath1.appendPath(tutorialCircle1)
            tutorialPath1.usesEvenOddFillRule = true
            tutorialOverlay.path = tutorialPath1.CGPath
            tutorialOverlay.fillRule = kCAFillRuleEvenOdd
            tutorialOverlay.fillColor = UIColor.lightGrayColor().CGColor
            tutorialOverlay.opacity = 0.9
            tutorialView.layer.addSublayer(tutorialOverlay)
            tutorialView.addSubview(tutorialButton2)
            tutorialView.addSubview(tutorialText1)
            tutorialSection++
        } else if tutorialSection == 1 {
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton2 = UIButton()
            var yValue:CGFloat = 170.0
            if (pointArray?.count == 0) {
                yValue -= 10.0
            }
            tutorialButton2.frame = CGRect(x: 0 , y: yValue, width: tutorialOverlay.frame.width,height: 100.0)
            tutorialButton2.addTarget(self, action: "displayTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 100, y: 280, width: 200, height: 200))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "Selecting each initial value for the system can be done manually. You can also swipe left to delete points. Warning, they will be deleted from the database."
            if (pointArray?.count > 1){
                tutorialText1.text?.appendContentsOf(" These points are generated for you this first time.")
            }
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!), cornerRadius: 0.0)
            let tutorialCircle1 = UIBezierPath(roundedRect: CGRect(x: 0, y: yValue, width: tutorialOverlay.frame.width, height: 100), cornerRadius: 20)
            tutorialPath1.appendPath(tutorialCircle1)
            tutorialPath1.usesEvenOddFillRule = true
            tutorialOverlay.path = tutorialPath1.CGPath
            tutorialOverlay.fillRule = kCAFillRuleEvenOdd
            tutorialOverlay.fillColor = UIColor.lightGrayColor().CGColor
            tutorialOverlay.opacity = 0.9
            tutorialView.layer.addSublayer(tutorialOverlay)
            tutorialView.addSubview(tutorialButton2)
            tutorialView.addSubview(tutorialText1)
            tutorialSection++
        } else if tutorialSection == 2 {
            let indexes = self.tableView.indexPathsForVisibleRows
            var buttonRect = CGRect(x: 0.0, y: 0.0, width: tutorialOverlay.frame.width, height: tutorialOverlay.frame.height)
            var pathRect = CGRect(origin: CGPoint.zero, size: CGSize.zero)
            var foundDisplayGraphRow = false
            var x:CGFloat = 0
            var y:CGFloat = 0
            for index in indexes! {
                if (index.section == 2) {
                    if index.row == 0 {
                        foundDisplayGraphRow = true
                        let cellDisplay = self.tableView.cellForRowAtIndexPath(index)!
                        x = cellDisplay.frame.origin.x
                        y = cellDisplay.frame.origin.y
                    }
                }
            }
            if (foundDisplayGraphRow){
                buttonRect = CGRect(x: x, y: y, width: tutorialOverlay.frame.width, height: 75)
                pathRect = buttonRect
            }
            
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton2 = UIButton()
            tutorialButton2.frame = buttonRect
            tutorialButton2.addTarget(self, action: "displayTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
            let positionAlterY:CGFloat = (Double(tutorialButton2.frame.origin.y) > Double(300.0)) ? -200.0 : 80.0
            let tutorialText1 = UILabel(frame: CGRect(x: 100, y: tutorialButton2.frame.origin.y + positionAlterY, width: 200, height: 200))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "Finally, selecting display graph will plot the solution curves where t=0 corresponds to those initial values. You will be able to add more points on the next screen."
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!), cornerRadius: 0.0)
            let tutorialCircle1 = UIBezierPath(roundedRect: pathRect, cornerRadius: 20)
            tutorialPath1.appendPath(tutorialCircle1)
            tutorialPath1.usesEvenOddFillRule = true
            tutorialOverlay.path = tutorialPath1.CGPath
            tutorialOverlay.fillRule = kCAFillRuleEvenOdd
            tutorialOverlay.fillColor = UIColor.lightGrayColor().CGColor
            tutorialOverlay.opacity = 0.9
            tutorialView.layer.addSublayer(tutorialOverlay)
            tutorialView.addSubview(tutorialButton2)
            tutorialView.addSubview(tutorialText1)
            tutorialSection++
        } else {
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialView.hidden = true
        }
    }

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTutorial()
        if pointArray == nil {
            pointArray = [CGPoint]()
        }
        pointsSelected = [Bool]()
        // Just created pointArray if it didn't exist prior!
        for (var row = 0; row < pointArray!.count; row++){
            pointsSelected.append(false) // points will all be unselected to start
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if (!tutorialCompleteTest){
            displayTutorial(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return pointArray!.count
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("point", forIndexPath: indexPath)
        if (indexPath.section == 0) {
            cell.textLabel?.text = "Check all points"
        } else if (indexPath.section == 1 && pointArray!.count > 0) {
            let localPoint = pointArray![indexPath.row]
            cell.textLabel?.text = "(" + localPoint.x.description + ", " + localPoint.y.description + ")"
            if (pointsSelected[indexPath.row]) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
        } else {
            cell.textLabel?.text = "Display graph"
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        // Configure the cell...
        
        return cell
    }
    
    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellChosen:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        if (cellChosen.textLabel?.text == "Display graph") {
            performSegueWithIdentifier("segueToGraph", sender: cellChosen)
        } else if (cellChosen.textLabel?.text == "Check all points"){
            for (var i = 0; i < pointArray?.count; i++) {
                let rowToSelect:NSIndexPath = NSIndexPath(forRow: i, inSection: 1);  //slecting 0th row with 0th section
                if let cellToSelect:UITableViewCell = self.tableView.cellForRowAtIndexPath(rowToSelect) {
                    if (cellToSelect.accessoryType == UITableViewCellAccessoryType.None) {
                        self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.None);
                        self.tableView(self.tableView, didSelectRowAtIndexPath: rowToSelect); //Manually trigger the row to select
                    }
                }
            }
        } else {
            if (pointsSelected[indexPath.row] == false) {
                pointsSelected[indexPath.row] = true
                cellChosen.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                pointsSelected[indexPath.row] = false
                cellChosen.accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let cellChosen = sender as! UITableViewCell // the only thing that would trigger the segue!
        if cellChosen.textLabel?.text == "Display graph" {
            return true
        }
        return false
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 1 {
                if ((pointsToPass?.contains(pointArray![indexPath.row])) != nil){
                    let toRemoveAtIndex = pointsToPass?.indexOf(pointArray![indexPath.row])
                    pointsToPass!.removeAtIndex(toRemoveAtIndex!)
                }
                pointsSelected.removeAtIndex(indexPath.row)
                pointArray!.removeAtIndex(indexPath.row) // remove the actual point from the list!
                writeNewPointArray() // writes to DB!
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }

    func writeNewPointArray() -> () {
        var concatPoints = String()
        for (var i = 0; i < (pointArray?.count)! - 1; i++){
            concatPoints += "(" + pointArray![i].x.description + "," + pointArray![i].y
            .description + "),"
        }
        let lastVal = (pointArray?.count)!-1
        if (pointArray?.count)! > 1 {
            concatPoints += "(" + pointArray![lastVal].x.description + "," + pointArray![lastVal].y.description + ")"
        }
        matrixObject.points = concatPoints
        do {
            try dfDBQueue.inDatabase { db in
                try self.matrixObject.update(db)
            }
        } catch {
            //couldn't update points
        }
        
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Check all points"
        } else if (section == 1) {
            return "Select Points to Graph"
        } else {
            return "Display graph"
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let nextController = segue.destinationViewController as! GraphViewController
        pointsToPass = [CGPoint]()
        for (var row = 0; row < pointArray?.count; row++) {
            if ( pointsSelected[row] == true ){
                pointsToPass!.append(pointArray![row])
            }
        }
        print(pointsToPass?.description)
        nextController.pointArray = pointsToPass
        nextController.ev = ev
        nextController.matrix = matrix
        nextController.evec = evec
        nextController.matrixObject = matrixObject
    }
    

}
