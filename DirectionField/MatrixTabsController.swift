//
//  MatrixTabsController.swift
//  DirectionField
//
//  Created by Eli Selkin on 1/10/16.
//  Copyright © 2016 DifferentialEq. All rights reserved.
//

import UIKit

class MatrixTabsController: UITabBarController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var matrix:TwoDimMatrix?
    var ev:TwoDimMatrix?
    var evec:[TwoDimMatrix]?
    var pointArray: [CGPoint]?
    var matrixObject:DBMatrix!

    // MARK: - CREATE NEW MATRIX VIEW
    var OverlayCreateMatrix:UIView!
    // MARK: - CREATE NEW MATRIX FIELDS
    @IBOutlet weak var textField1:UITextField!
    @IBOutlet weak var textField2:UITextField!
    @IBOutlet weak var textField3:UITextField!
    @IBOutlet weak var textField4:UITextField!
    
    // MARK: - TUTORIAL VARIABLES
    // Tutorial variables
    var tutorialComplete:DBtutorial!
    var tutorialCompleteTest:Bool = false
    // Tutorial views
    var tutorialView:UIView!
    var tutorialOverlay:CAShapeLayer!
    // Counter for mouse clicks
    var tutorialSection:Int = 0

    // MARK: - Check if tutorial has been completed
    func startTutorial() {
        dfDBQueue.inDatabase { db in
            self.tutorialComplete = DBtutorial.fetchOne(db, "SELECT * from tutorial")
            if (self.tutorialComplete != nil && self.tutorialComplete!.tutorialcomplete == 1) {
                self.tutorialCompleteTest = true
            }
        }
    }
    
    // MARK: - CREATE NEW MATRIX (ACTUAL MATRIX)
    func createOverlay() -> () {
        // create a new View and overlay it into the navbar properties
        OverlayCreateMatrix = UIView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height)))
        OverlayCreateMatrix.backgroundColor = UIColor.blackColor()
        OverlayCreateMatrix.alpha = 0.95
        self.navigationController?.view.addSubview(OverlayCreateMatrix)
        self.navigationController?.view.bringSubviewToFront(OverlayCreateMatrix)
        
        // Create 4 text fields to position in the view
        textField1 = UITextField()
        textField1.backgroundColor = UIColor.whiteColor()
        textField1.translatesAutoresizingMaskIntoConstraints = false
        textField1.keyboardType = UIKeyboardType.NumbersAndPunctuation
        textField1.delegate = self
        
        textField2 = UITextField()
        textField2.backgroundColor = UIColor.whiteColor()
        textField2.translatesAutoresizingMaskIntoConstraints = false
        textField2.keyboardType = UIKeyboardType.NumbersAndPunctuation
        textField2.delegate = self
        
        textField3 = UITextField()
        textField3.backgroundColor = UIColor.whiteColor()
        textField3.translatesAutoresizingMaskIntoConstraints = false
        textField3.keyboardType = UIKeyboardType.NumbersAndPunctuation
        textField3.delegate = self
        
        textField4 = UITextField()
        textField4.backgroundColor = UIColor.whiteColor()
        textField4.translatesAutoresizingMaskIntoConstraints = false
        textField4.keyboardType = UIKeyboardType.NumbersAndPunctuation
        textField4.delegate = self
        
        
        let labelMatrix = UILabel()
        labelMatrix.text = "Enter your matrix:"
        labelMatrix.translatesAutoresizingMaskIntoConstraints = false
        labelMatrix.textColor = UIColor.whiteColor()
        labelMatrix.sizeToFit()
        
        let calculateButton = UIButton(type: UIButtonType.System) as UIButton
        calculateButton.translatesAutoresizingMaskIntoConstraints = false
        calculateButton.setTitle("Calculate!", forState: UIControlState.Normal)
        calculateButton.addTarget(self, action: "calculateMatrix:", forControlEvents: UIControlEvents.TouchUpInside) // function is calculateMatrix()
        
        let cancelButton = UIButton(type: UIButtonType.System) as UIButton
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelMatrix:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // How we access the | in the constraint
        OverlayCreateMatrix.addSubview(labelMatrix)
        OverlayCreateMatrix.addSubview(calculateButton)
        OverlayCreateMatrix.addSubview(cancelButton)
        OverlayCreateMatrix.addSubview(textField1)
        OverlayCreateMatrix.addSubview(textField2)
        OverlayCreateMatrix.addSubview(textField3)
        OverlayCreateMatrix.addSubview(textField4)
        
        var textFieldDict = Dictionary<String, UIView>()
        textFieldDict["label0"] = labelMatrix
        textFieldDict["button0"] = calculateButton
        textFieldDict["button1"] = cancelButton
        textFieldDict["text1"] = textField1
        textFieldDict["text2"] = textField2
        textFieldDict["text3"] = textField3
        textFieldDict["text4"] = textField4
        
        let H0constraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[label0(300)]-|", options: [], metrics: nil, views:textFieldDict)
        OverlayCreateMatrix.addConstraints(H0constraint)
        
        let H1constraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=10)-[text1(100)]-[text2(100)]-(>=10)-|", options: [], metrics: nil, views:textFieldDict)
        OverlayCreateMatrix.addConstraints(H1constraint)
        let H2constraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=10)-[text3(100)]-[text4(100)]-(>=10)-|", options: [], metrics: nil, views:textFieldDict)
        OverlayCreateMatrix.addConstraints(H2constraint)
        let H3constraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[button0(70)]-(<=10)-[button1(70)]-(>=10)-|", options: [], metrics: nil, views: textFieldDict)
        OverlayCreateMatrix.addConstraints(H3constraint)
        let V0constraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(100)-[label0(50)]-(<=10)-[text1(40)]-(<=10)-[text3(40)]-[button0(50)]", options: [.AlignAllLeading], metrics: nil, views:textFieldDict)
        OverlayCreateMatrix.addConstraints(V0constraint)
        let V1constraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(100)-[label0(50)]-(>=10)-[text2(40)]-(<=10)-[text4(40)]-[button1(50)]", options: [], metrics: nil, views:textFieldDict)
        OverlayCreateMatrix.addConstraints(V1constraint)
        
        OverlayCreateMatrix.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        OverlayCreateMatrix.addGestureRecognizer(tapGesture)
    }
    @IBAction func handleTap (sender: UITapGestureRecognizer) {
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        textField4.resignFirstResponder()
    }
    @IBAction func cancelMatrix(sender: UIButton!) {
        OverlayCreateMatrix.hidden = true
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        textField4.resignFirstResponder()
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - CREATE NEW MATRIX TUTORIAL
    @IBAction func tutorialOverCreate(sender: UIView!) {
        if (tutorialSection == 0) {
            // start the tutorial here!
            tutorialView = UIView(frame: CGRect(origin: OverlayCreateMatrix.frame.origin, size: CGSize(width: OverlayCreateMatrix.frame.width, height: OverlayCreateMatrix.frame.height)))
            tutorialView.frame = OverlayCreateMatrix.frame
            tutorialView.userInteractionEnabled = true
            OverlayCreateMatrix.addSubview(tutorialView)
            OverlayCreateMatrix.bringSubviewToFront(tutorialView)
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton2 = UIButton()
            tutorialButton2.frame = CGRect(x: 50, y: 150, width: 100, height: 50)
            tutorialButton2.addTarget(self, action: "tutorialOverCreate:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 0, y: textField1.frame.origin.y+50, width: OverlayCreateMatrix.frame.width, height: 150))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "In each of these boxes, enter a valid real-valued decimal."
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: OverlayCreateMatrix.frame.width, height: OverlayCreateMatrix.frame.height), cornerRadius: 0.0)
            let tutorialCircle1 = UIBezierPath(roundedRect: tutorialButton2.frame, cornerRadius: 20)
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
        } else if (tutorialSection == 1) {
            tutorialOverlay.path = nil
            tutorialView.subviews.forEach({$0.removeFromSuperview()}) // get rid of the junk from the previous tutorial screen
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton(frame: CGRect(x: 100, y: 260, width: 150, height: 50))
            tutorialButton1.addTarget(self, action: "tutorialOverCreate:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 100, y: 320, width: 200, height: 150))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.text = "Once completed, click the calculate button and you will be taken to the underlying info screen"
            let tutorialPath1  = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.layer.frame.width, height: self.view.layer.frame.height), cornerRadius: 0.0)
            let tutorialCircle1 = UIBezierPath(roundedRect: CGRect(x: 50, y: 260, width: 150, height: 50), cornerRadius: 20)
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
            tutorialView.subviews.forEach({$0.removeFromSuperview()}) // get rid of the junk from the previous tutorial screen
            tutorialView.hidden = true
        }
    }
    
    func calculateMatrix(sender:UIButton!) {
        // get data from textFields
        let formatString = "^([+-]?[0-9]*[.]?[0-9]+)$"
        if ((textField1 != nil && textField2 != nil && textField3 != nil && textField4 != nil) && (requiredFormat(textField1.text!, regex: formatString) && requiredFormat(textField2.text!, regex: formatString) && requiredFormat(textField3.text!, regex: formatString) && requiredFormat(textField4.text!, regex: formatString))) {
            let A11Complex = Complex(r: (textField1.text! as NSString).floatValue, i: 0.0)
            let A12Complex = Complex(r: (textField2.text! as NSString).floatValue, i: 0.0)
            let A21Complex = Complex(r: (textField3.text! as NSString).floatValue, i: 0.0)
            let A22Complex = Complex(r: (textField4.text! as NSString).floatValue, i: 0.0)
            matrix = TwoDimMatrix(a11: A11Complex, a12: A12Complex, a21: A21Complex, a22: A22Complex, a13: Complex(r: 0.0, i: 0.0), a23: Complex(r: 0.0, i: 0.0)) as TwoDimMatrix?
            (evec, ev) = try! eigenVectors(matrix!)
            OverlayCreateMatrix.hidden = true
            // insert into DB
            matrixObject = DBMatrix(matrixName: (matrix?.description)!, eigenValue1: (ev?.getValueAt(1, col: 1).description)!, eigenValue2: (ev?.getValueAt(2, col: 1).description)!, eigenVector1: evec![0].description, eigenVector2: evec![1].description, points: "")
            do {
                try dfDBQueue.inDatabase { db in
                    try self.matrixObject.insert(db)
                }
            } catch {
                
            }
            textField1.resignFirstResponder()
            textField2.resignFirstResponder()
            textField3.resignFirstResponder()
            textField4.resignFirstResponder()
        }
        sendInfoToViewControllers()
        
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


    // MARK: - START THE VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        startTutorial() // get the setup to test in this go around we will be showing the tutorial
        if matrix == nil {
            let matrixController = self.viewControllers![0] as! MatrixInfoViewController
            matrixController.tutorialCompleteTest = self.tutorialCompleteTest
            createOverlay()
            if (!tutorialCompleteTest) {
                tutorialOverCreate(self.view)
            }
        } else {
            sendInfoToViewControllers()
        }
    }
    func sendInfoToViewControllers() {
        let matrixController = self.viewControllers![0] as! MatrixInfoViewController
        let eig1Controller = self.viewControllers![1] as! EigenvectorViewController
        let eig2Controller = self.viewControllers![2] as! EigenvectorViewController
        matrixController.matrix = self.matrix
        matrixController.ev = self.ev
        matrixController.evec = self.evec
        matrixController.tutorialCompleteTest = self.tutorialCompleteTest
        matrixController.pointArray = self.pointArray
        matrixController.matrixObject = self.matrixObject
        eig1Controller.eigenVector = self.evec![0]
        eig1Controller.eigenValue = self.ev?.getValueAt(1, col: 1)
        eig1Controller.tutorialCompleteTest = self.tutorialCompleteTest
        eig2Controller.eigenVector = self.evec![1]
        eig2Controller.eigenValue = self.ev?.getValueAt(2, col: 1)
        eig2Controller.tutorialCompleteTest = self.tutorialCompleteTest
        matrixController.displayMatrix()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: - SEGUE TO CORRECT VIEWCONTROLLERS
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    

}