//
//  SelectMatrixOrNewController.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import UIKit
import GRDB


class SelectMatrixOrNewController: UITableViewController {
    var tutorialCompleteTest:Bool = false
    var tutorialComplete:DBtutorial!
    var tutorialSection = 0
    var tutorialOverlay:CAShapeLayer!
    var tutorialView:UIView!
    var createNewRectOrigin:CGPoint = CGPoint.zero
    var matrixRectOrigin:CGPoint = CGPoint.zero
    
    //var refreshControl:UIRefreshControl!
    var matrixList = [DBMatrix]()
    func loadMatrices() {
        // just get the names
        matrixList = dfDBQueue.inDatabase { db in
            DBMatrix.fetchAll(db, "SELECT * FROM matrices")
        }
    }
    
    func startTutorial() {
        dfDBQueue.inDatabase { db in
                self.tutorialComplete = DBtutorial.fetchOne(db, "SELECT * from tutorial")
                if (self.tutorialComplete != nil && self.tutorialComplete!.tutorialcomplete == 1) {
                    self.tutorialCompleteTest = true
            }
        }
    }
    
    
    @IBAction func nextTutorialSelection(sender:UIButton!) {
        if tutorialSection == 0 {
        } else if (tutorialSection == 1) {
            tutorialOverlay.path = nil
            tutorialView.subviews.forEach({$0.removeFromSuperview()}) // delete all subviews by themselves. Clear up the screen for next view
            let tutorialButton2 = UIButton(frame: CGRect(origin: CGPoint(x: matrixRectOrigin.x, y: matrixRectOrigin.y+60), size: CGSize(width: tutorialOverlay.frame.width, height: 50)))
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.layer.frame.width)!, height: (self.navigationController?.view.layer.frame.height)!), cornerRadius: 0.0)
            let tutorialCircle1 = UIBezierPath(roundedRect: tutorialButton2.frame, cornerRadius: 20)
            tutorialButton2.translatesAutoresizingMaskIntoConstraints = false
            tutorialButton2.addTarget(self, action: "nextTutorialSelection:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText2 = UILabel(frame: CGRect(x: 100, y: 280, width: 200, height: 150))
            tutorialText2.font = UIFont.systemFontOfSize(16)
            tutorialText2.textColor = UIColor.whiteColor()
            tutorialText2.numberOfLines = 0
            tutorialText2.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText2.text = "Once a matrix is created (this one we made for you), it will be listed here and you can select it from this list. You can swipe left to delete matrices you've created."
            tutorialPath1.appendPath(tutorialCircle1)
            tutorialPath1.usesEvenOddFillRule = true
            tutorialOverlay.path = tutorialPath1.CGPath
            tutorialOverlay.fillRule = kCAFillRuleEvenOdd
            tutorialOverlay.fillColor = UIColor.lightGrayColor().CGColor
            tutorialOverlay.opacity = 0.9
            tutorialView.layer.addSublayer(tutorialOverlay)
            tutorialView.addSubview(tutorialButton2)
            tutorialView.addSubview(tutorialText2)
            tutorialSection++
        } else {
            tutorialOverlay.path = nil
            tutorialView.subviews.forEach({$0.removeFromSuperview()}) // delete all subviews by themselves. Clear up the screen for next view
            tutorialView.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
//        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        loadMatrices()
        tableView.reloadData()

        startTutorial()
        let indexes = self.tableView.indexPathsForVisibleRows
        if (!tutorialCompleteTest) {
            for index in indexes! {
                if (index.section == 0) {
                    if (index.row == 0) {
                        let cell = tableView.cellForRowAtIndexPath(index)
                        createNewRectOrigin = (cell?.frame.origin)!
                    }
                } else if (index.section == 1) {
                    if (index.row == 0) {
                        // first matrix
                        let cell = tableView.cellForRowAtIndexPath(index)
                        matrixRectOrigin = (cell?.frame.origin)!
                    }
                }
            }
            // start the tutorial here!
            tutorialView = UIView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: (self.navigationController?.view.layer.frame.width)!, height: (self.navigationController?.view.layer.frame.height)!)))
            tutorialView.userInteractionEnabled = true
            self.navigationController?.view.addSubview(tutorialView)
            self.navigationController?.view.bringSubviewToFront(tutorialView)
            self.navigationController?.view.sendSubviewToBack(self.tableView)
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton(frame: CGRect(origin: CGPoint(x: createNewRectOrigin.x, y: createNewRectOrigin.y+60), size: CGSize(width: tutorialOverlay.frame.width, height: 50)))
            tutorialButton1.addTarget(self, action: "nextTutorialSelection:", forControlEvents: UIControlEvents.TouchUpInside)
            tutorialButton1.translatesAutoresizingMaskIntoConstraints = false
            let tutorialText1 = UILabel(frame: CGRect(x: 100, y: 180, width: 200, height: 100))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.text = "When you select \"Create a new matrix\" you will enter a 2x2 matrix corresponding to a real-valued coefficient matrix"
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.layer.frame.width)!, height: (self.navigationController?.view.layer.frame.height)!), cornerRadius: 0.0)
            let tutorialCircle1 = UIBezierPath(roundedRect: tutorialButton1.frame, cornerRadius: 20)
            tutorialPath1.appendPath(tutorialCircle1)
            tutorialPath1.usesEvenOddFillRule = true
            tutorialOverlay.path = tutorialPath1.CGPath
            tutorialOverlay.fillRule = kCAFillRuleEvenOdd
            tutorialOverlay.fillColor = UIColor.lightGrayColor().CGColor
            tutorialOverlay.opacity = 0.9
            tutorialView.layer.addSublayer(tutorialOverlay)
            tutorialView.addSubview(tutorialButton1)
            tutorialView.addSubview(tutorialText1)
            tutorialSection++
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        loadMatrices()
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
           // pull from SQLite the matrices
            return matrixList.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if indexPath.section == 1 {
            cell.textLabel?.text = matrixList[indexPath.row].matrixName
        } else {
            cell.textLabel?.text = "Create a new matrix"
        }
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "CREATE A MATRIX"
        } else {
            return "SELECT A MATRIX"
        }
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
                    // remove from DB
                let matrix = matrixList[indexPath.row].matrixName
                do {
                    try dfDBQueue.inDatabase { db in
                        let matrixFound = DBMatrix.fetchOne(db, key: ["MatrixName":matrix])
                        try matrixFound?.delete(db)
                        self.matrixList.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                } catch {
                }
            }
        }
    }


    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Gather the data from the matrices DB here
        
        let nextViewController = segue.destinationViewController as! MatrixTabsController
        
        if let indexPath = self.tableView.indexPathForSelectedRow { // if let!
            if indexPath.section == 1 {
                // do something with the selected matrix!
                let matrixObjectToParse = matrixList[indexPath.row]
                nextViewController.matrixObject = matrixObjectToParse
                let matrixParsed = parseMatrixName(matrixObjectToParse.matrixName)
                let ev1Parsed = try! Complex(realimag: matrixObjectToParse.eigenValue1)
                let ev2Parsed = try! Complex(realimag: matrixObjectToParse.eigenValue2)
                let ev = TwoDimMatrix(a11: ev1Parsed, a21: ev2Parsed)
                var evecs = [TwoDimMatrix]()
                let points = parsePoints(matrixObjectToParse.points)
                evecs.append(parseEV(matrixObjectToParse.eigenVector1))
                evecs.append(parseEV(matrixObjectToParse.eigenVector2))
                nextViewController.matrix = matrixParsed
                nextViewController.evec = evecs
                nextViewController.ev = ev
                nextViewController.pointArray = points
            } else {
               
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func parsePoints(pointsList: String) -> ([CGPoint]) {
        var parsedPoints = [CGPoint]()
        do {
            let internalRegularExpression = try NSRegularExpression(pattern: "[(]([+-]?[0-9]*[.]?[0-9]+)[,]([+-]?[0-9]*[.]?[0-9]+)[)]", options: .CaseInsensitive)
            let matches = internalRegularExpression.matchesInString(pointsList, options: [], range: NSRange(location: 0, length: pointsList.utf16.count))
            for match in matches as [NSTextCheckingResult] {
                let x:NSString = ((pointsList as NSString).substringWithRange(match.rangeAtIndex(1))) as String
                let xval:Double = x.doubleValue
                let y:NSString = ((pointsList as NSString).substringWithRange(match.rangeAtIndex(2))) as String
                let yval:Double = y.doubleValue
                let xy = CGPoint(x: xval, y: yval)
                parsedPoints.append(xy)
            }
        } catch {
            // don't add points
        }
        return parsedPoints // may be empty
    }

    func parseEV(matrix: String) -> (TwoDimMatrix) {
        let parsedMatrix:TwoDimMatrix = TwoDimMatrix(a11: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0))
        var counter = 0
        do {
            let internalRegularExpression = try NSRegularExpression(pattern: "([+-]?[0-9]*[.]?[0-9]+[+-][0-9]*[.]?[0-9]+[i])", options: .CaseInsensitive)
            let matches = internalRegularExpression.matchesInString(matrix, options: [], range: NSRange(location: 0, length: matrix.utf16.count))
            for match in matches as [NSTextCheckingResult] {
                let complexNumber:NSString = (matrix as NSString).substringWithRange(match.rangeAtIndex(1))
                switch(counter) {
                case 0:
                    try parsedMatrix.setValueAt(1, col: 1, val: Complex(realimag: complexNumber as String))
                case 1:
                    try parsedMatrix.setValueAt(2, col: 1, val: Complex(realimag: complexNumber as String))
                default:
                    break
                }
                counter++
            }
        } catch {
            
        }
        return parsedMatrix
    }
    
    func parseMatrixName(matrix: String) -> (TwoDimMatrix?) {
        let parsedMatrix:TwoDimMatrix = TwoDimMatrix()
        var counter = 0
        do {
            let internalRegularExpression = try NSRegularExpression(pattern: "([+-]?[0-9]*[.]?[0-9]+[+-][0-9]*[.]?[0-9]+[i])", options: .CaseInsensitive)
            let matches = internalRegularExpression.matchesInString(matrix, options: [], range: NSRange(location: 0, length: matrix.utf16.count))
            for match in matches as [NSTextCheckingResult] {
                let complexNumber:NSString = (matrix as NSString).substringWithRange(match.rangeAtIndex(1))
                switch(counter) {
                case 0:
                    try parsedMatrix.setValueAt(1, col: 1, val: Complex(realimag: complexNumber as String))
                case 1:
                    try parsedMatrix.setValueAt(1, col: 2, val: Complex(realimag: complexNumber as String))
                case 2:
                    try parsedMatrix.setValueAt(1, col: 3, val: Complex(realimag: complexNumber as String))
                case 3:
                    try parsedMatrix.setValueAt(2, col: 1, val: Complex(realimag: complexNumber as String))
                case 4:
                    try parsedMatrix.setValueAt(2, col: 2, val: Complex(realimag: complexNumber as String))
                case 5:
                    try parsedMatrix.setValueAt(2, col: 3, val: Complex(realimag: complexNumber as String))
                default:
                    break
                }
                counter++
            }
        } catch {

        }
        return parsedMatrix as TwoDimMatrix?
    }
    

}
