//
//  GraphViewController.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/31/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import UIKit
import TwitterKit


class GraphViewController: UIViewController, UITextFieldDelegate {
    var tutorialCompleteTest:Bool = false
    var tutorialSection = 0
    var tutorialOverlay:CAShapeLayer!
    var tutorialView:UIView!
    var tutorialComplete:DBtutorial!
    var translation:CGPoint = CGPoint.zero
    var totalScale:CGFloat = 1
    var scaleEvents:Int = 0
    var translationEvents:Int = 0
    var lineLayer: CAShapeLayer!
    var drawingScreen: UIImageView!
    var matrix:TwoDimMatrix?
    var ev:TwoDimMatrix?
    var evec:[TwoDimMatrix]?
    var pointArray: [CGPoint]? // This has only the points we selected!
    var matrixObject:DBMatrix!
    var red:Float = 0.0
    var green:Float = 0.0
    var blue:Float = 0.0
    var alpha:Float = 1.0 // default opaque black
    var solutionColor: UIColor {
        return UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
    }
    var vectorFieldColor: UIColor = UIColor(colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    var vectorFieldWidth:CGFloat = 1.0
    var scale:CGFloat = 1.0
    var lineWidth:CGFloat = 1.0
    var solutionWidth:CGFloat = 2.0
    var numTicksPerQuadrant:CGFloat = 10
    var offset:CGPoint = CGPoint.zero
    var tickValue:CGFloat = 0.1
    var arrowLength:Float = 10.0
    var arrowHeight:Float = 10.0
    var showDots = false
    var showAxes = true
    var showBorder = true
    var showArrows = true
    var showNumbers = true
    var showTickmarks = true
    var solutions = [Solution]()
    var vectorField = [Solution]()
    
    var colorRedVal:Float = 0.0
    var colorGreenVal:Float = 0.0
    var colorBlueVal:Float = 0.0
    var colorMix:UIColor {
        get {
            return UIColor(colorLiteralRed: colorRedVal, green: colorGreenVal, blue: colorBlueVal, alpha: 1.0)
        }
    }
    var arrowLengthVal:Float = 10.0
    var arrowHeightVal:Float = 10.0
    var showDotsVal:Bool = false
    var showAxesVal:Bool = true
    var showBorderVal:Bool = true
    var showArrowsVal:Bool = true
    var showNumbersVal:Bool = true
    var showTickmarksVal:Bool = true
    @IBOutlet weak var xInput:UITextField!
    @IBOutlet weak var yInput:UITextField!
    var colorRed:UISlider!
    var colorGreen:UISlider!
    var colorBlue:UISlider!
    var sliderArrowH:UISlider!
    var sliderArrowL:UISlider!
    var switchDots:UISwitch!
    var switchAxes:UISwitch!
    var switchBorder:UISwitch!
    var switchNumbers:UISwitch!
    var switchTickmarks:UISwitch!
    var switchArrows:UISwitch!
    var viewArrow:UIImageView!
    var colorView:UIView!
    var optionsView:UIView!
    var optionsDict = Dictionary<String, UIView>()

    override func viewWillAppear(animated: Bool) {
        // oops this occurs after viewDidLoad! Can't use this to get the info from the database
    }
    
    func startTutorial() {
        dfDBQueue.inDatabase { db in
            self.tutorialComplete = DBtutorial.fetchOne(db, "SELECT * from tutorial")
            if (self.tutorialComplete != nil && self.tutorialComplete!.tutorialcomplete == 1) {
                self.tutorialCompleteTest = true
            }
        }
    }

    func finishTutorial() {
        dfDBQueue.inDatabase { db in
            let tutorialComplete:DBtutorial = DBtutorial(complete: 1)
            do {
                try tutorialComplete.insert(db)
            } catch {
                tutorialComplete.tutorialcomplete = 1
                try! tutorialComplete.update(db)
            }
        }
    }
    
    @IBAction func longPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Began) {
            addTrajectoryPoint(sender.locationOfTouch(0, inView: self.drawingScreen))
        }
    }
    
    @IBAction func panMotion(recognizer: UIPanGestureRecognizer) {
        translation = recognizer.translationInView(self.drawingScreen)
        translationEvents++
        if translationEvents == 3 {
            pan(translation)
            recognizer.setTranslation(CGPoint.zero, inView: drawingScreen)
            translationEvents = 0
        }
    }
    
    func pan(distance: CGPoint) {
        // here CGpoint is a distance
        offset.x -= (round((90*distance.x / self.drawingScreen.frame.width)) * tickValue * scale)
        offset.x = offset.x.roundToPlaces(3)
        
        offset.y += (round((90*distance.y / self.drawingScreen.frame.height)) * tickValue * scale)
        offset.y = offset.y.roundToPlaces(3)

        if (offset.y < -100) {
            offset.y = -100;
        }
        if (offset.x < -100) {
            offset.x = -100;
        }
        if (offset.y > 100) {
            offset.y = 100;
        }
        if (offset.x > 100) {
            offset.x = 100;
        }
        for sol in solutions {
            sol.isDrawn = false
        }
        self.drawingScreen.subviews.forEach({ $0.removeFromSuperview() })
        self.drawingScreen.image = UIImage()
        if (showBorder){
            self.drawingScreen.image = drawBorder(self.drawingScreen)
        }
        if (showNumbers){
            self.drawingScreen.image = drawNumbers(self.drawingScreen)
        }
        if (showTickmarks){
            self.drawingScreen.image = drawTicks(self.drawingScreen)
        }
        if (showAxes){
            self.drawingScreen.image = drawAxes(self.drawingScreen)
        }
        self.drawingScreen.image = drawSolutions(self.drawingScreen)
    }
    
    @IBAction func pinchzoomMotion(sender: UIPinchGestureRecognizer) {
        totalScale *= sender.scale
        scaleEvents++
        if (scaleEvents == 3) {
            pinchZoom(totalScale)
            totalScale = 1
            scaleEvents = 0
            sender.scale = 1
        }
    }
    
    func pinchZoom(ts: CGFloat){
        scale /= ts
        scale = scale.roundToPlaces(2)
        
        if scale <= 0.01 {
            scale = 0.01
        }
        if scale >= 50 {
            scale = 50
        }
        for sol in solutions {
            sol.isDrawn = false
        }
        self.drawingScreen.subviews.forEach({ $0.removeFromSuperview() })
        self.drawingScreen.image = UIImage()
        if (showBorder){
            self.drawingScreen.image = drawBorder(self.drawingScreen)
        }
        if (showNumbers){
            self.drawingScreen.image = drawNumbers(self.drawingScreen)
        }
        if (showTickmarks){
            self.drawingScreen.image = drawTicks(self.drawingScreen)
        }
        if (showAxes){
            self.drawingScreen.image = drawAxes(self.drawingScreen)
        }
        self.drawingScreen.image = drawSolutions(self.drawingScreen)
    }
    
    func drawBorder(image: UIImageView) -> UIImage {
        UIGraphicsBeginImageContext(image.frame.size)
        image.image?.drawInRect(CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.height))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, lineWidth)
        CGContextStrokeRect(context, CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.width))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawAxes(image: UIImageView) -> UIImage {
        let centerX = image.frame.width / 2.0
        let centerY = image.frame.height / 2.0
        UIGraphicsBeginImageContext(image.frame.size)
        image.image?.drawInRect(CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.height))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextSetLineWidth(context, lineWidth)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, centerX, 0)
        CGContextAddLineToPoint(context, centerX, image.frame.height)
        CGContextMoveToPoint(context, 0, centerY)
        CGContextAddLineToPoint(context, image.frame.width, centerY)
        CGContextStrokePath(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func drawTicks(image: UIImageView) -> UIImage {
        UIGraphicsBeginImageContext(image.frame.size)
        image.image?.drawInRect(CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.height))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, lineWidth)
        let centerX = image.frame.width / 2.0
        let centerY = image.frame.height / 2.0
        let tickSeparation = round(centerX / numTicksPerQuadrant)
        CGContextBeginPath(context)
        for (var i:CGFloat = 0; i < centerX; i += tickSeparation) {
            CGContextMoveToPoint(context, centerX + i, centerY-2)
            CGContextAddLineToPoint(context, centerX + i, centerY+2)
            CGContextMoveToPoint(context, centerX - i, centerY-2)
            CGContextAddLineToPoint(context, centerX - i, centerY+2)
            CGContextMoveToPoint(context, centerX - 2, centerY-i)
            CGContextAddLineToPoint(context, centerX + 2, centerY-i)
            CGContextMoveToPoint(context, centerX - 2, centerY+i)
            CGContextAddLineToPoint(context, centerX + 2, centerY+i)
            
        }
        CGContextStrokePath(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawNumbers(image: UIImageView) -> UIImage {
        UIGraphicsBeginImageContext(image.frame.size)
        image.image?.drawInRect(CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.height))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, lineWidth)
        let textFont: UIFont = UIFont(name: "Helvetica", size: 7)!
        let textColor: UIColor = UIColor.blueColor()
        let textFontAttr = [ NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor ]
        let centerX = image.frame.width / 2.0
        let centerY = image.frame.height / 2.0
        let tickSeparation = round(centerX / numTicksPerQuadrant)
        CGContextBeginPath(context)
        var ticks:CGFloat = 1.0
        for (var i:CGFloat = tickSeparation; i < centerX; i += 2*tickSeparation) {
            let pointPosX:NSString = NSString(string: (offset.x + (ticks *  tickValue * scale)).roundToPlaces(3).description)
            let pointNegX:NSString = NSString(string: (offset.x - (ticks *  tickValue * scale)).roundToPlaces(3).description)

            let pointPosY:NSString = NSString(string: (offset.y + (ticks *  tickValue * scale)).roundToPlaces(3).description)
            let pointNegY:NSString = NSString(string: (offset.y - (ticks *  tickValue * scale)).roundToPlaces(3).description)
            pointPosX.drawAtPoint(CGPoint(x: centerX+i, y: centerY+5), withAttributes: textFontAttr)
            pointNegY.drawAtPoint(CGPoint(x: centerX+5, y: centerY+i), withAttributes: textFontAttr)
            pointNegX.drawAtPoint(CGPoint(x: centerX-i, y: centerY+5), withAttributes: textFontAttr)
            pointPosY.drawAtPoint(CGPoint(x: centerX+5, y: centerY-i), withAttributes: textFontAttr)
            ticks += 2
        }
        CGContextStrokePath(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func addTrajectoryPoint(XY:CGPoint) -> () {
        let coordPoint = convertTouchToCoordinate(XY)
        pointArray!.append(coordPoint)
        solutions = addPoint(solutions, point: coordPoint)
        writePointsToDB()
        self.drawingScreen.image = drawSolutions(self.drawingScreen)
    }
    
    func writePointsToDB() -> Bool {
        var listPoints:String = ""
        for (var i = 0; i < pointArray!.count - 1; i++) {
            listPoints.appendContentsOf("(" + pointArray![i].x.description + "," + pointArray![i].y.description + "),")
        }
        let xVal = pointArray![(pointArray?.count)!-1].x.description
        let yVal = pointArray![(pointArray?.count)!-1].y.description
        listPoints.appendContentsOf("(" + xVal + "," + yVal + ")")
        matrixObject.points = listPoints
        do {
            try dfDBQueue.inDatabase { db in
                try self.matrixObject.update(db)
            }
        } catch {
            
        }
        return true
    }
    
    func convertCoordinateToPhysical(XY: CGPoint) -> (CGPoint) {
        let screenHalfHeight = ((self.drawingScreen.image?.size.height )!) / 2.0
        let screenHalfWidth = ((self.drawingScreen.image?.size.width )!) / 2.0
        // let's do this by proportion
        let distanceOnHalfScreen = tickValue * numTicksPerQuadrant * scale
        let proportionOnScreenX = ((XY.x - offset.x) / distanceOnHalfScreen)
        // print ("X: " + XY.x.description + " is " + proportionOnScreenX.description + " of Distance: " + distanceOnHalfScreen.description)
        let proportionOnScreenY = ((XY.y - offset.y) / distanceOnHalfScreen)
        return CGPoint(x:  screenHalfWidth + (proportionOnScreenX * screenHalfWidth), y: screenHalfHeight - (proportionOnScreenY * screenHalfHeight) )
    }
    
    func convertTouchToCoordinate(XY: CGPoint) -> (CGPoint) {
        let screenHalfHeight = ((self.drawingScreen.image?.size.height )!) / 2.0
        let screenHalfWidth = ((self.drawingScreen.image?.size.width )!) / 2.0
        let proportionOfHalfX = ( abs(screenHalfWidth - XY.x) / screenHalfWidth ) * (XY.x  < screenHalfWidth ? -1 : 1)
        let proportionOfHalfY = ( abs(screenHalfHeight - XY.y) / screenHalfHeight ) * (XY.y  > screenHalfHeight ? -1 : 1)
        let xValue = scale * proportionOfHalfX + offset.x
        let yValue = scale * proportionOfHalfY + offset.y
        return CGPoint(x: xValue.roundToPlaces(5), y: yValue.roundToPlaces(5))
        
    }

    func drawSolutions(image: UIImageView) -> UIImage {
        UIGraphicsBeginImageContext(image.frame.size)
        image.image?.drawInRect(CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.height))
        image.clipsToBounds = true
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, solutionColor.CGColor)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, solutionWidth)
        let linePath = UIBezierPath()
        let beginPoints = UIBezierPath()
        let endPoints = UIBezierPath()
        for sol in solutions {
            let t0 = sol.getXY(0)
            var getNext = false
            var previous = CGPoint.zero
            if (!sol.isDrawn && sol.pointsAtT.count > 0) {
                sol.isDrawn = true
                let arrayStart = convertCoordinateToPhysical(sol.pointsAtT[0])
                linePath.moveToPoint(arrayStart)
                for point in sol.pointsAtT {
                    let newPoint = convertCoordinateToPhysical(point)
                    if (newPoint.x < image.frame.width+500 && newPoint.x >= -500 && newPoint.y < image.frame.height + 500 && newPoint.y >= -500) {
                        if approxEqual(point, RHS: t0, epsilon: 0.00001) {
                            getNext = true
                            previous = newPoint
                            beginPoints.moveToPoint(newPoint)
                            beginPoints.addLineToPoint(newPoint)
                        } else if (getNext){
                            getNext = false
                            endPoints.moveToPoint(newPoint)
                            endPoints.addLineToPoint(newPoint)
                            // make the arrowhead
                            let dy = newPoint.y - previous.y
                            let dx = newPoint.x - previous.x
                            if (showArrows) {
                                let blueArrow = UIImage(named: "blueArrow")
                                let blueView = UIImageView(image: blueArrow)
                                blueView.frame = CGRect(origin: newPoint, size: CGSize(width: CGFloat(arrowLength), height: CGFloat(arrowHeight)))
                                blueView.center = previous
                                image.addSubview(blueView)
                            
                                if (dx != 0){
                                    blueView.transform = CGAffineTransformMakeRotation(atan(dy/dx))
                                    if (dy >= 0 && dx <= 0) || (dy <= 0 && dx <= 0) {
                                        blueView.transform = CGAffineTransformRotate(blueView.transform, CGFloat(M_PI))
                                    }
                                }
                            }
                        }
                        linePath.addLineToPoint(newPoint)
                        linePath.moveToPoint(newPoint)
                    } else {
                        linePath.moveToPoint(newPoint)
                    }
                }
            }
        }
        CGContextAddPath(context, linePath.CGPath)
        CGContextStrokePath(context)
        if (showDots) {
            CGContextAddPath(context, beginPoints.CGPath)
            CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, 5.0)
            CGContextStrokePath(context)
            CGContextAddPath(context, endPoints.CGPath)
            CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, 5.0)
            CGContextStrokePath(context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func unitVectorFromPointSlope(point: CGPoint, dy: CGFloat, dx: CGFloat) -> CGPoint {
        var result:CGPoint = CGPoint()
        if dx == 0 {
            result.x = point.x
            if (dy > 0){
                result.y = point.y + tickValue
            } else {
                result.y = point.y - tickValue
            }
        } else {
            let tanθ = dy/dx // slope == hypotenuse
            let secSqθ = 1 + tanθ * tanθ
            let cosSqθ = 1 / secSqθ
            let sinSqθ = 1 - cosSqθ
            var cosθ = sqrt(cosSqθ)
            var sinθ = sqrt(sinSqθ)
            if (dy <= 0) {
                sinθ *= -1
            }
            if (dx <= 0) {
                cosθ *= -1
            }
            result.x = point.x + cosθ * tickValue * scale
            result.y = point.y + sinθ * tickValue * scale
        }
        return result
    }
    
    
    // Add coordinate point on coordinate axes not touch axes
    func addPoint(var whichArray:[Solution], point: CGPoint) -> ([Solution]) {
        do {
            
            // test if matrix is imaginary so we need iSolution or just Solution
            let Rs = [(self.ev?.getValueAt(1, col: 1))!, (self.ev?.getValueAt(2, col: 1))!]
            let Pt = [point.x, point.y]
            
            if (self.ev?.getValueAt(1, col: 1).imaginary != 0.0) || (self.ev?.getValueAt(2, col: 1).imaginary != 0.0) {
                let Lambda0 = ev!.getValueAt(2, col: 1).real
                let Mu0 = self.ev!.getValueAt(2, col: 1).imaginary
                let A00 = self.evec![0].getValueAt(1, col: 1).real
                let B00 = self.evec![0].getValueAt(1, col: 1).imaginary
                let A01 = self.evec![0].getValueAt(2, col: 1).real
                let B01 = self.evec![0].getValueAt(2, col: 1).imaginary
                let imaginary = iSolution(x: Pt, Rs: Rs, EigVecs: self.evec!, As: [A00, A01], Bs: [B00, B01], mu: Mu0, lambda: Lambda0)
                try imaginary.determineCs()
                dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                    imaginary.isDrawn = true
                    imaginary.generatePoints();
                    imaginary.generateDerivatives()
                    imaginary.isDrawn = false // now we can draw it
                    whichArray.append(imaginary)
                }
                return whichArray
            } else {
                let real = Solution(x: Pt, Rs: [(self.ev?.getValueAt(1, col: 1))!, (self.ev?.getValueAt(2, col: 1))!], EigVecs: self.evec!)
                try real.determineCs()
                dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                    real.isDrawn = true
                    real.generatePoints()
                    real.generateDerivatives()
                    real.isDrawn = false // now we can draw it
                    whichArray.append(real)
                }
                return whichArray
            }
        } catch {
            // could not add!
            return whichArray
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        xInput.resignFirstResponder()
        yInput.resignFirstResponder()
    }
    
    // MARK: - Taken from http://www.globalnerdy.com/2015/04/27/how-to-program-an-ios-text-field-that-takes-only-numeric-input-or-specific-characters-with-a-maximum-length/
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return prospectiveText.containsOnlyCharactersIn("0123456789.+-")
    }
    
    // get rid of keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingScreen = self.view.viewWithTag(1) as! UIImageView
        drawingScreen.clipsToBounds = true
        let buttonOptions = self.view.viewWithTag(2) as! UIButton
        let xInput = self.view.viewWithTag(4) as! UITextField
        let yInput = self.view.viewWithTag(6) as! UITextField
        let buttonAddPoint = self.view.viewWithTag(7) as! UIButton
        let buttonDrawDirectionField = self.view.viewWithTag(8) as! UIButton
        let buttonScreenShot = self.view.viewWithTag(9) as! UIButton
        let buttonTweet = self.view.viewWithTag(10) as! UIButton
        buttonOptions.addTarget(self, action: "graphOptionsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonAddPoint.addTarget(self, action: "addButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonDrawDirectionField.addTarget(self, action: "generateVectorField:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonScreenShot.addTarget(self, action: "takeScreenShot:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonTweet.addTarget(self, action: "tweet:", forControlEvents: UIControlEvents.TouchUpInside)
        xInput.delegate = self
        yInput.delegate = self
        xInput.keyboardType = UIKeyboardType.NumbersAndPunctuation
        yInput.keyboardType = UIKeyboardType.NumbersAndPunctuation
        //let minWidthHeight = round(min(view.frame.width, view.frame.height))

        self.drawingScreen.subviews.forEach({ $0.removeFromSuperview() })
        self.drawingScreen.image = UIImage()
        if pointArray == nil {
            pointArray = [CGPoint]()
        }
        for point in pointArray! {
            solutions = addPoint(solutions, point: point)
            self.drawingScreen.image = drawSolutions(self.drawingScreen)
        }
        if (showBorder){
            self.drawingScreen.image = drawBorder(self.drawingScreen)
        }
        if (showNumbers){
            self.drawingScreen.image = drawNumbers(self.drawingScreen)
        }
        if (showTickmarks){
            self.drawingScreen.image = drawTicks(self.drawingScreen)
        }
        if (showAxes){
            self.drawingScreen.image = drawAxes(self.drawingScreen)
        }
        self.drawingScreen.image = drawSolutions(self.drawingScreen)
        // Do any additional setup after loading the view.
        startTutorial()
        if (!tutorialCompleteTest){
            showTutorial(self.view)
        }
    }
    // take screen shot
    // - Mark - http://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-a-image
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContext(self.drawingScreen.bounds.size)
        self.drawingScreen.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenShotImage
    }
    
    func image (image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
    }
    
    @IBAction func takeScreenShot (sender: UIButton!) {
        let shot = screenShot()
        UIImageWriteToSavedPhotosAlbum(shot, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    @IBAction func tweet (sender: UIButton!) {
        // taken into prepareforsegue because that was being done before this action!
    }
    @IBAction func showTutorial(sender: UIView!) {
        if tutorialSection == 0 {
            tutorialView = UIView(frame: CGRect(origin: (self.navigationController?.view.frame.origin)!, size: CGSize(width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!)))
            tutorialView.frame = (self.navigationController?.view.frame)!
            tutorialView.userInteractionEnabled = true
            self.navigationController?.view.addSubview(tutorialView)
            self.navigationController?.view.bringSubviewToFront(tutorialView)
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton()
            tutorialButton1.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 200))
            tutorialButton1.addTarget(self, action: "showTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 0, y: tutorialButton1.frame.height+5, width: 300, height: 240))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "This is the most major component of the application. On the drawing screen you can long press to add an initial value to your functions. You can pan up/down/left/right with your finger. You can pinch and zoom too."
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!), cornerRadius: 0.0)
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
        } else if tutorialSection == 1 {
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton()
            let buttonAddPoint = self.view.viewWithTag(7) as! UIButton
            tutorialButton1.frame = CGRect(origin: CGPoint(x: drawingScreen.frame.origin.x, y: buttonAddPoint.frame.origin.y), size: CGSize(width: drawingScreen.frame.width, height: 40))
            tutorialButton1.addTarget(self, action: "showTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 20, y:60, width: 300, height: 150))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "This row of can add a specific point that you could not add by touch. It's practically impossible to add a specific point."
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!), cornerRadius: 0.0)
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
        } else if tutorialSection == 2 {
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton()
            let buttonDrawDirectionField = self.view.viewWithTag(8) as! UIButton
            tutorialButton1.frame = buttonDrawDirectionField.frame
            tutorialButton1.addTarget(self, action: "showTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 20, y:180, width: 300, height: 150))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "Here you can display the vector field of the functions you have inputted. You will see a general behavior of the curves."
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!), cornerRadius: 0.0)
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
        } else if tutorialSection == 3 {
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton()
            let buttonOptions = self.view.viewWithTag(2) as! UIButton
            tutorialButton1.frame = buttonOptions.frame
            tutorialButton1.addTarget(self, action: "showTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 20, y: 180, width: 300, height: 150))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "This will open a window of graph options, such as showing or not showing the arrows on the curves or the color of the solution curves."
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!), cornerRadius: 0.0)
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
        } else {
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialOverlay = nil
            tutorialView.hidden = true
            finishTutorial()
        }
    }

    @IBAction func generateVectorField(sender:UIButton!) {
        let intervalWidth = drawingScreen.frame.width / 5
        let intervalHeight = drawingScreen.frame.height / 5
        for (var i:CGFloat = 0.0; i <= drawingScreen.frame.width; i += intervalWidth ) {
            for (var j:CGFloat = 0.0; j <= drawingScreen.frame.height; j += intervalHeight ) {
                let pointForVF = CGPoint(x: i,y: j)
                let realPoint = convertTouchToCoordinate(pointForVF)
                vectorField = addPoint(vectorField, point: realPoint)
            }
        }
        
        // a little loop to wait for all dispatched solutions to return
        var finished = false
        while !finished {
            for curve in vectorField {
                if curve.pointsAtT.count != 101 {
                    finished = false
                    break
                }
                if curve.derivativesAtT.count  != 101 {
                    finished = false
                    break
                }
            }
            finished = true
        }
        
        // problem with the fact that addPoint is sending these things out on a side queue and therefore we'll have to wait
        // I can't find out if there's a particular, "wait until the queue is finished type of thing"
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(NSEC_PER_SEC)/2)
        dispatch_after(time, dispatch_get_main_queue()) {
            self.drawingScreen.image = self.drawVectorField(self.drawingScreen)
        }
    }
    
    func drawVectorField(image: UIImageView) -> (UIImage) {
        UIGraphicsBeginImageContext(image.frame.size)
        image.image?.drawInRect(CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.height))
        image.clipsToBounds = true
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, vectorFieldColor.CGColor)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, vectorFieldWidth)
        let linePath = UIBezierPath()
        for sol in vectorField {
            if (!sol.isDrawn && sol.pointsAtT.count > 0) {
                sol.isDrawn = true
                if (sol.derivativesAtT.count == sol.pointsAtT.count) {
                    for (var i = 0; i < sol.derivativesAtT.count; i++) {
                        let currentPoint = convertCoordinateToPhysical(sol.pointsAtT[i])
                            // we are a point in bounds
                            linePath.moveToPoint(currentPoint)
                            var unitEndPoint = unitVectorFromPointSlope(sol.pointsAtT[i], dy: sol.derivativesAtT[i], dx: 1.0)
                            unitEndPoint = convertCoordinateToPhysical(unitEndPoint)
                            linePath.addLineToPoint(unitEndPoint)
                        }
                    }
                }
            }
//        }
        CGContextAddPath(context, linePath.CGPath)
        CGContextStrokePath(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func addButtonPressed(sender:UIButton!) {
        let formatString = "^([+-]?[0-9]*[.]?[0-9]+)$"
        if (xInput == nil || yInput == nil) {
            return
        }
        if !requiredFormat(xInput.text!, regex: formatString) {
            xInput.backgroundColor = UIColor.lightGrayColor()
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 4 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.xInput.backgroundColor = UIColor.whiteColor()
                }
            return
        }
        if !requiredFormat(yInput.text!, regex: formatString) {
            yInput.backgroundColor = UIColor.lightGrayColor()
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 4 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.yInput.backgroundColor = UIColor.whiteColor()
            }
            return
        }
        
        // strings are formatted correctly
        let xValue = (xInput.text! as NSString).floatValue
        let yValue = (yInput.text! as NSString).floatValue
        xInput.text! = ""
        yInput.text! = ""
        let coordPoint = CGPoint(x: CGFloat(xValue), y: CGFloat(yValue))
        solutions = addPoint(solutions, point: coordPoint)
        pointArray!.append(coordPoint)
        writePointsToDB()
        self.drawingScreen.image = drawSolutions(self.drawingScreen)
    }
    
    @IBAction func graphOptionsPressed(sender:UIButton!) {
        optionsView = UIView()
        switchAxes = UISwitch()
        switchDots = UISwitch()
        switchBorder = UISwitch()
        switchArrows = UISwitch()
        switchNumbers = UISwitch()
        switchTickmarks = UISwitch()
        // popover a view overlay
        optionsView.backgroundColor = UIColor.whiteColor()
        optionsView.alpha = 0.9
        optionsView.frame = self.view.frame
        optionsView.bounds = optionsView.frame
        optionsView.hidden = false
        self.view.addSubview(optionsView)
        // make changes
        let buttonMakeChanges = UIButton(type: UIButtonType.System) as UIButton
        buttonMakeChanges.setTitle("Save Changes", forState: UIControlState.Normal)
        buttonMakeChanges.translatesAutoresizingMaskIntoConstraints = false
        optionsView.addSubview(buttonMakeChanges)
        optionsDict["buttonMakeChanges"] = buttonMakeChanges
        buttonMakeChanges.addTarget(self, action: "getFinalStates:", forControlEvents: UIControlEvents.TouchUpInside)

        // cancel
        let cancelButton = UIButton(type: UIButtonType.System) as UIButton
        cancelButton.setTitle("Cancel Changes", forState: UIControlState.Normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        optionsView.addSubview(cancelButton)
        optionsDict["cancelButton"] = cancelButton
        cancelButton.addTarget(self, action: "revertStates:", forControlEvents: UIControlEvents.TouchUpInside)

        // dots
        let labelDots = UILabel()
        labelDots.translatesAutoresizingMaskIntoConstraints = false
        labelDots.text = "Show Dots"
        switchDots.translatesAutoresizingMaskIntoConstraints = false
        switchDots.setOn(showDots, animated: true)
        switchDots.on = showDots
        switchDots.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(labelDots)
        optionsView.addSubview(switchDots)
        optionsDict["labelDots"] = labelDots
        optionsDict["switchDots"] = switchDots
        
        // axes
        let labelAxes = UILabel()
        labelAxes.translatesAutoresizingMaskIntoConstraints = false
        labelAxes.text = "Show Axes"
        switchAxes.translatesAutoresizingMaskIntoConstraints = false
        switchAxes.setOn(showAxes, animated: true)
        switchAxes.on = showAxes
        switchAxes.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(labelAxes)
        optionsView.addSubview(switchAxes)
        optionsDict["labelAxes"] = labelAxes
        optionsDict["switchAxes"] = switchAxes

        
        // Border
        let labelBorder = UILabel()
        labelBorder.translatesAutoresizingMaskIntoConstraints = false
        labelBorder.text = "Show Border"
        switchBorder.translatesAutoresizingMaskIntoConstraints = false
        switchBorder.setOn(showBorder, animated: true)
        switchBorder.on = showBorder
        switchBorder.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(labelBorder)
        optionsView.addSubview(switchBorder)
        optionsDict["labelBorder"] = labelBorder
        optionsDict["switchBorder"] = switchBorder

        
        // Arrows
        let labelArrows = UILabel()
        labelArrows.translatesAutoresizingMaskIntoConstraints = false
        labelArrows.text = "Show Arrows"
        switchArrows.translatesAutoresizingMaskIntoConstraints = false
        switchArrows.setOn(showArrows, animated: true)
        switchArrows.on = showArrows
        switchArrows.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(labelArrows)
        optionsView.addSubview(switchArrows)
        optionsDict["labelArrows"] = labelArrows
        optionsDict["switchArrows"] = switchArrows

        // Numbers
        let labelNumbers = UILabel()
        labelNumbers.translatesAutoresizingMaskIntoConstraints = false
        labelNumbers.text = "Show Numbers"
        switchNumbers.translatesAutoresizingMaskIntoConstraints = false
        switchNumbers.setOn(showNumbers, animated: true)
        switchNumbers.on = showNumbers
        switchNumbers.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(labelNumbers)
        optionsView.addSubview(switchNumbers)
        optionsDict["labelNumbers"] = labelNumbers
        optionsDict["switchNumbers"] = switchNumbers

        // Tickmarks
        let labelTickmarks = UILabel()
        labelTickmarks.translatesAutoresizingMaskIntoConstraints = false
        labelTickmarks.text = "Show Tickmarks"
        switchTickmarks.translatesAutoresizingMaskIntoConstraints = false
        switchTickmarks.setOn(showTickmarks, animated: true)
        switchTickmarks.on = showTickmarks
        switchTickmarks.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(labelTickmarks)
        optionsView.addSubview(switchTickmarks)
        optionsDict["labelTickmarks"] = labelTickmarks
        optionsDict["switchTickmarks"] = switchTickmarks
        
        
        // sliderArrowLength
        let labelArrowL = UILabel()
        labelArrowL.text = "Arrow Length"
        labelArrowL.translatesAutoresizingMaskIntoConstraints = false
        sliderArrowL = UISlider()
        sliderArrowL.maximumValue = 50.0
        sliderArrowL.minimumValue = 0.0
        sliderArrowL.value = arrowLength
        sliderArrowL.translatesAutoresizingMaskIntoConstraints = false
        optionsView.addSubview(sliderArrowL)
        optionsView.addSubview(labelArrowL)
        optionsDict["labelArrowL"] = labelArrowL
        optionsDict["sliderArrowL"] = sliderArrowL
        // sliderArrowHeight
        let labelArrowH = UILabel()
        labelArrowH.text = "Arrow Height"
        labelArrowH.translatesAutoresizingMaskIntoConstraints = false
        sliderArrowH = UISlider()
        sliderArrowH.maximumValue = 50.0
        sliderArrowH.minimumValue = 0.0
        sliderArrowH.value = arrowHeight
        sliderArrowH.translatesAutoresizingMaskIntoConstraints = false
        sliderArrowH.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        sliderArrowL.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(sliderArrowH)
        optionsView.addSubview(labelArrowH)
        optionsDict["labelArrowH"] = labelArrowH
        optionsDict["sliderArrowH"] = sliderArrowH
        
        // color picker
        let labelRed = UILabel()
        labelRed.text = "Solution line color Red:"
        labelRed.translatesAutoresizingMaskIntoConstraints = false
        colorRed = UISlider()
        colorRed.translatesAutoresizingMaskIntoConstraints = false
        colorRed.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        colorRed.maximumValue = 1.0
        colorRed.minimumValue = 0.0
        colorRed.value = red
        optionsView.addSubview(labelRed)
        optionsView.addSubview(colorRed)
        optionsDict["colorRed"] = colorRed
        optionsDict["labelRed"] = labelRed
        let labelBlue = UILabel()
        labelBlue.text = "Blue:"
        labelBlue.translatesAutoresizingMaskIntoConstraints = false
        colorBlue = UISlider()
        colorBlue.maximumValue = 1.0
        colorBlue.minimumValue = 0.0
        colorBlue.value = blue
        colorBlue.translatesAutoresizingMaskIntoConstraints = false
        colorBlue.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        optionsView.addSubview(labelBlue)
        optionsView.addSubview(colorBlue)
        optionsDict["colorBlue"] = colorBlue
        optionsDict["labelBlue"] = labelBlue
        let labelGreen = UILabel()
        labelGreen.text = "Green:"
        labelGreen.translatesAutoresizingMaskIntoConstraints = false
        colorGreen = UISlider()
        colorGreen.maximumValue = 1.0
        colorGreen.minimumValue = 0.0
        colorGreen.value = green
        colorGreen.translatesAutoresizingMaskIntoConstraints = false
        optionsView.addSubview(labelGreen)
        optionsView.addSubview(colorGreen)
        optionsDict["colorGreen"] = colorGreen
        optionsDict["labelGreen"] = labelGreen
        colorGreen.addTarget(self, action: "getStates:", forControlEvents: UIControlEvents.ValueChanged)
        colorView = UIView()
        colorView.backgroundColor = colorMix
        colorView.translatesAutoresizingMaskIntoConstraints = false
        optionsView.addSubview(colorView)
        optionsDict["colorView"] = colorView
        
        let hConstraintButton = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[buttonMakeChanges(>=50)]-(<=10)-|", options: [], metrics: nil, views: optionsDict)
        let vConstraintButton = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(<=50)-[buttonMakeChanges(50)]", options: [], metrics: nil, views: optionsDict)
        let hConstraintDots = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelDots(<=100)]-(<=1)-[switchDots(>=30)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintDots0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[buttonMakeChanges]-(>=5)-[labelDots(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintDots1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[buttonMakeChanges]-(>=5)-[switchDots(>=20)]", options: [], metrics: nil, views: optionsDict)
        let hConstraintAxes = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelAxes(<=100)]-(<=1)-[switchAxes(>=30)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintAxes0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelDots]-(>=5)-[labelAxes(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintAxes1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[switchDots]-(>=5)-[switchAxes(>=20)]", options: [], metrics: nil, views: optionsDict)
        let hConstraintBorder = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelBorder(<=100)]-(<=1)-[switchBorder(>=30)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintBorder0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelAxes]-(>=5)-[labelBorder(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintBorder1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[switchAxes]-(>=5)-[switchBorder(>=20)]", options: [], metrics: nil, views: optionsDict)
        let hConstraintArrows = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelArrows(<=150)]-(<=1)-[switchArrows(>=30)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintArrows0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelBorder]-(>=5)-[labelArrows(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintArrows1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[switchBorder]-(>=5)-[switchArrows(>=20)]", options: [], metrics: nil, views: optionsDict)
        let hConstraintNumbers = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelNumbers(<=150)]-(<=1)-[switchNumbers(>=30)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintNumbers0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelArrows]-(>=5)-[labelNumbers(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintNumbers1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[switchArrows]-(>=5)-[switchNumbers(>=20)]", options: [], metrics: nil, views: optionsDict)
        let hConstraintTickmarks = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelTickmarks(<=150)]-(<=1)-[switchTickmarks(>=30)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintTickmarks0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelNumbers]-(>=5)-[labelTickmarks(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintTickmarks1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[switchNumbers]-(>=5)-[switchTickmarks(>=20)]", options: [], metrics: nil, views: optionsDict)
        if (self.view.frame.height >= 600) {
            let hConstraintArrowL = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelArrowL(<=150)]-(<=1)-[sliderArrowL(>=100)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
            let vConstraintArrowL0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelTickmarks]-(>=5)-[labelArrowL(>=20)]", options: [], metrics: nil, views: optionsDict)
            let vConstraintArrowL1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[switchTickmarks]-(>=5)-[sliderArrowL(>=20)]", options: [], metrics: nil, views: optionsDict)
            let hConstraintArrowH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelArrowH(<=150)]-(<=1)-[sliderArrowH(>=100)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
            let vConstraintArrowH0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelArrowL]-(>=5)-[labelArrowH(>=20)]", options: [], metrics: nil, views: optionsDict)
            let vConstraintArrowH1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[sliderArrowL]-(>=5)-[sliderArrowH(>=20)]", options: [], metrics: nil, views: optionsDict)
            optionsView.addConstraints(hConstraintArrowL)
            optionsView.addConstraints(vConstraintArrowL0)
            optionsView.addConstraints(vConstraintArrowL1)
            optionsView.addConstraints(hConstraintArrowH)
            optionsView.addConstraints(vConstraintArrowH0)
            optionsView.addConstraints(vConstraintArrowH1)

        }
        let hConstraintRed = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelRed(>=50)]-(<=1)-[colorRed(>=100)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        var vConstraintRed0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelArrowH]-(>=5)-[labelRed(>=20)]", options: [], metrics: nil, views: optionsDict)
        var vConstraintRed1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[sliderArrowH]-(>=5)-[colorRed(>=20)]", options: [], metrics: nil, views: optionsDict)
        if (self.view.frame.height < 600) {
            vConstraintRed0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelTickmarks]-(>=5)-[labelRed(>=20)]", options: [], metrics: nil, views: optionsDict)
            vConstraintRed1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[switchTickmarks]-(>=5)-[colorRed(>=20)]", options: [], metrics: nil, views: optionsDict)
        }
        
        let hConstraintGreen = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelGreen(<=75)]-(<=1)-[colorGreen(>=100)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintGreen0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelRed]-(>=5)-[labelGreen(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintGreen1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[colorRed]-(>=5)-[colorGreen(>=20)]", options: [], metrics: nil, views: optionsDict)

        let hConstraintBlue = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[labelBlue(<=50)]-(<=1)-[colorBlue(>=100)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintBlue0 = NSLayoutConstraint.constraintsWithVisualFormat("V:[labelGreen]-(>=5)-[labelBlue(>=20)]", options: [], metrics: nil, views: optionsDict)
        let vConstraintBlue1 = NSLayoutConstraint.constraintsWithVisualFormat("V:[colorGreen]-(>=5)-[colorBlue(>=20)]", options: [], metrics: nil, views: optionsDict)

        
        let hConstraintMix = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[colorView(>=30)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintMix = NSLayoutConstraint.constraintsWithVisualFormat("V:[colorBlue]-(>=5)-[colorView(>=30)]", options: [], metrics: nil, views: optionsDict)
        
        let hConstraintCancel = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[cancelButton(>=50)]-(<=10)-|", options: [.AlignAllCenterY], metrics: nil, views: optionsDict)
        let vConstraintCancel = NSLayoutConstraint.constraintsWithVisualFormat("V:[colorView]-(>=5)-[cancelButton(>=20)]", options: [], metrics: nil, views: optionsDict)
        
        optionsView.addConstraints(hConstraintButton)
        optionsView.addConstraints(vConstraintButton)
        optionsView.addConstraints(hConstraintDots)
        optionsView.addConstraints(vConstraintDots0)
        optionsView.addConstraints(vConstraintDots1)
        optionsView.addConstraints(hConstraintAxes)
        optionsView.addConstraints(vConstraintAxes0)
        optionsView.addConstraints(vConstraintAxes1)
        optionsView.addConstraints(hConstraintBorder)
        optionsView.addConstraints(vConstraintBorder0)
        optionsView.addConstraints(vConstraintBorder1)
        optionsView.addConstraints(hConstraintArrows)
        optionsView.addConstraints(vConstraintArrows0)
        optionsView.addConstraints(vConstraintArrows1)
        optionsView.addConstraints(hConstraintNumbers)
        optionsView.addConstraints(vConstraintNumbers0)
        optionsView.addConstraints(vConstraintNumbers1)
        optionsView.addConstraints(hConstraintTickmarks)
        optionsView.addConstraints(vConstraintTickmarks0)
        optionsView.addConstraints(vConstraintTickmarks1)
        optionsView.addConstraints(hConstraintRed)
        optionsView.addConstraints(vConstraintRed0)
        optionsView.addConstraints(vConstraintRed1)
        optionsView.addConstraints(hConstraintBlue)
        optionsView.addConstraints(vConstraintBlue0)
        optionsView.addConstraints(vConstraintBlue1)
        optionsView.addConstraints(hConstraintGreen)
        optionsView.addConstraints(vConstraintGreen0)
        optionsView.addConstraints(vConstraintGreen1)
        optionsView.addConstraints(hConstraintMix)
        optionsView.addConstraints(vConstraintMix)
        optionsView.addConstraints(hConstraintCancel)
        optionsView.addConstraints(vConstraintCancel)
        

    }
    @IBAction func getStates(sender: UIView!) -> () {
        colorRedVal = colorRed.value
        colorGreenVal = colorGreen.value
        colorBlueVal = colorBlue.value
        colorView.backgroundColor = colorMix
        arrowHeightVal = sliderArrowH.value
        arrowLengthVal = sliderArrowL.value
        showDotsVal = switchDots.on
        showAxesVal = switchAxes.on
        showBorderVal = switchBorder.on
        showArrowsVal = switchArrows.on
        showNumbersVal = switchNumbers.on
        showTickmarksVal = switchTickmarks.on
        if (!showArrowsVal) {
            sliderArrowH.enabled = false
            sliderArrowL.enabled = false
        } else {
            sliderArrowH.enabled = true
            sliderArrowL.enabled = true
        }
        
    }
    
    @IBAction func getFinalStates(sender: UIButton!) -> () {
        red = colorRedVal
        blue = colorBlueVal
        green = colorGreenVal
        arrowHeight = arrowHeightVal
        arrowLength = arrowLengthVal
        showDots = showDotsVal
        showAxes = showAxesVal
        showArrows = showArrowsVal
        showBorder = showBorderVal
        showNumbers = showNumbersVal
        showTickmarks = showTickmarksVal
        optionsView.hidden = true
        self.drawingScreen.subviews.forEach({ $0.removeFromSuperview() })
        if (showBorder){
            self.drawingScreen.image = drawBorder(self.drawingScreen)
        }
        if (showNumbers){
            self.drawingScreen.image = drawNumbers(self.drawingScreen)
        }
        if (showTickmarks){
            self.drawingScreen.image = drawTicks(self.drawingScreen)
        }
        if (showAxes){
            self.drawingScreen.image = drawAxes(self.drawingScreen)
        }
        self.drawingScreen.image = drawSolutions(self.drawingScreen)
    }

    @IBAction func revertStates(sender: UIButton!) -> () {
        colorRedVal = red
        colorRed.value = 0.0
        colorBlueVal = blue
        colorBlue.value = 0.0
        colorGreenVal = green
        colorGreen.value = 0.0
        arrowHeightVal = arrowHeight
        sliderArrowH.value = 10.0
        arrowLengthVal = arrowLength
        sliderArrowL.value = 10.0
        showDotsVal = showDots
        switchDots.on = showDots
        showAxesVal = showAxes
        switchAxes.on = showAxes
        showBorderVal = showBorder
        switchBorder.on = showBorder
        showNumbersVal = showNumbers
        switchNumbers.on = showNumbers
        showTickmarksVal = showTickmarks
        switchTickmarks.on = showTickmarks
        optionsView.hidden = true
        // don't redraw
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tweetImage = screenShot()
        UIImageWriteToSavedPhotosAlbum(tweetImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
        let nextViewController = segue.destinationViewController as!TwitterViewController
        nextViewController.tweetImage = tweetImage
        nextViewController.tweetMatrix = matrix?.description
    }

}

// MARK - Credit - http://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
// Sebastian & Sandy
extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
extension Float32 {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Float32 {
        let divisor = powf(10.0, Float32(places))
        return Float32(round(self * divisor) / divisor)
    }
}
extension CGFloat {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> CGFloat {
        let divisor = powf(10.0, Float32(places))
        return CGFloat(round(self * CGFloat(divisor)) / CGFloat(divisor))
    }
}

