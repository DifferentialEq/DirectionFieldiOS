//
//  MatrixInfoViewController.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/28/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import UIKit

class MatrixInfoViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var matrix:TwoDimMatrix?
    var ev:TwoDimMatrix?
    var evec:[TwoDimMatrix]?
    var pointArray: [CGPoint]?
    var matrixObject:DBMatrix!
    var tutorialCompleteTest:Bool!
    var tutorialSection = 0
    var tutorialComplete:DBtutorial!
    var tutorialOverlay:CAShapeLayer!
    var tutorialView:UIView!
    var warningView:UIView!
    @IBOutlet weak var a11Label: UILabel!
    @IBOutlet weak var a12Label: UILabel!
    @IBOutlet weak var a21Label: UILabel!
    @IBOutlet weak var a22Label: UILabel!
    
    // MARK: - Check if tutorial has been completed
    func startTutorial() {
        dfDBQueue.inDatabase { db in
            self.tutorialComplete = DBtutorial.fetchOne(db, "SELECT * from tutorial")
            if (self.tutorialComplete != nil && self.tutorialComplete!.tutorialcomplete == 1) {
                self.tutorialCompleteTest = true
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    
    @IBAction func tutorialOverMatrixInfo( sender: UIView!) {
        if (tutorialSection == 0) {
            // start the tutorial here!
            tutorialView = UIView(frame: CGRect(origin: (self.navigationController?.view.frame.origin)!, size: CGSize(width: (self.navigationController?.view.frame.width)!, height: (self.navigationController?.view.frame.height)!)))
            tutorialView.frame = (self.navigationController?.view.frame)!
            tutorialView.userInteractionEnabled = true
            self.navigationController?.view.addSubview(tutorialView)
            self.navigationController?.view.bringSubviewToFront(tutorialView)
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton()
            tutorialButton1.frame = CGRect(x: 0.0, y: self.a11Label.frame.origin.y-50, width: tutorialOverlay.frame.width, height: self.a11Label.frame.height+self.a21Label.frame.height+75)
            tutorialButton1.addTarget(self, action: "tutorialOverMatrixInfo:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 0.0, y: tutorialButton1.frame.origin.y + tutorialButton1.frame.height+10, width: tutorialOverlay.frame.width, height: 200))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "Your matrix will be displayed here. It will be formatted to display as complex numbers."
            let tutorialPath1  = UIBezierPath(roundedRect: tutorialView.frame, cornerRadius: 0.0)
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
        } else if (tutorialSection == 1) {
            tutorialView.subviews.forEach({$0.removeFromSuperview()})
            tutorialOverlay.path = nil
            tutorialOverlay = CAShapeLayer()
            tutorialOverlay.frame = tutorialView.frame
            tutorialOverlay.hidden = false
            let tutorialButton1 = UIButton()
            tutorialButton1.frame = CGRect(x: 0.0, y: tutorialOverlay.frame.height-125, width: tutorialOverlay.frame.width, height: 100)
            tutorialButton1.addTarget(self, action: "tutorialOverMatrixInfo:", forControlEvents: UIControlEvents.TouchUpInside)
            let tutorialText1 = UILabel(frame: CGRect(x: 0, y: tutorialOverlay.frame.height-325, width: tutorialOverlay.frame.width, height: 200))
            tutorialText1.numberOfLines = 0
            tutorialText1.lineBreakMode = NSLineBreakMode.ByWordWrapping
            tutorialText1.font = UIFont.systemFontOfSize(16)
            tutorialText1.textColor = UIColor.whiteColor()
            tutorialText1.textAlignment = NSTextAlignment.Center
            tutorialText1.text = "Once you have examined what you need about the matrix or the eigenvectors of the associated system, then you can touch here to continue."
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
            tutorialView.removeFromSuperview()
            tutorialCompleteTest = true // just for this run through
        }
    }
    
    // Here we will create an optional for a DBMatrix if it is nil we will go ahead and 
    // overlay a view that will show the create a matrix stuff with a button that will 
    // then compute the matrix stuff and put the data into the DB and then remove the view and 
    // replace the view with the Matrix Info view
    // If the DBMatrix here is not nil
    // we will show the Matrix Info view Directly
    override func viewDidLoad() {
    }
    override func viewDidAppear(animated: Bool) {
        startTutorial()
        displayMatrix()
    }
    
    func populateData() -> () {
        a11Label.text = matrix?.getValueAt(1, col: 1).description
        a12Label.text = matrix?.getValueAt(1, col: 2).description
        a21Label.text = matrix?.getValueAt(2, col: 1).description
        a22Label.text = matrix?.getValueAt(2, col: 2).description
        if (!tutorialCompleteTest){
            tutorialOverMatrixInfo(self.view)
        }
    }
    
    
    func overlayWarning() {
        warningView = UIView(frame: CGRect(origin: CGPoint.zero, size: self.navigationController!.view.frame.size))
        warningView.backgroundColor = UIColor.redColor()
        let warningText = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        warningText.font = UIFont.boldSystemFontOfSize(18)
        warningText.text = "You have entered a matrix whose eigenvalues are far from 0. This performance of this app on such a matrix is difficult to determine. It may not display at all or it may perform poorly."
        warningText.textAlignment = NSTextAlignment.Center
        warningText.textColor = UIColor.whiteColor()
        warningText.translatesAutoresizingMaskIntoConstraints = false
        warningText.numberOfLines = 0
        warningText.lineBreakMode = NSLineBreakMode.ByWordWrapping
        warningView.addSubview(warningText)
        let warningOK = UIButton(type: UIButtonType.System) as UIButton
        warningOK.translatesAutoresizingMaskIntoConstraints = false
        warningOK.setTitle("Accept", forState: UIControlState.Normal)
        warningOK.addTarget(self, action: "acceptWarning:", forControlEvents: UIControlEvents.TouchUpInside)
        warningOK.frame = CGRect(x: 50, y: 400, width: 200, height: 100)
        warningView.addSubview(warningOK)
        warningView.alpha = 0.9
        var positionDict = Dictionary<String, UIView>()
        positionDict["warningText"] = warningText
        positionDict["warningOK"] = warningOK
        
        let V0constraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=1)-[warningText(300)]-(<=10)-[warningOK(100)]-(>=100)-|", options: [.AlignAllCenterX], metrics: nil, views:positionDict)
        let H0constraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[warningText(300)]-(>=50)-|", options: [], metrics: nil, views: positionDict)
        let H1constraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=1)-[warningOK(200)]-(>=50)-|", options: [], metrics: nil, views: positionDict)
        warningView.addConstraints(V0constraint)
        warningView.addConstraints(H0constraint)
        warningView.addConstraints(H1constraint)
        warningView.hidden = false
        self.navigationController?.view.addSubview(warningView)
    }
    
    func displayMatrix() {
        if (matrix != nil && a11Label != nil) {
            populateData()
        }
    }

    @IBAction func acceptWarning(sender: UIButton!) {
        warningView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController = segue.destinationViewController as! EditPointsTableViewController
        nextViewController.matrix = matrix
        nextViewController.ev = ev
        nextViewController.evec = evec
        nextViewController.pointArray = pointArray // pass the data along! Don't parse again!
        nextViewController.matrixObject = matrixObject
    }
}

extension String {
    // Returns true if the string contains only characters found in matchCharacters.
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersInString: matchCharacters).invertedSet
        return self.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
    }
}

func requiredFormat(test: String, regex: String) -> Bool {
    do {
        let internalRegularExpression = try NSRegularExpression(pattern: regex, options: .CaseInsensitive)
        let matches = internalRegularExpression.matchesInString(test, options: .Anchored, range: NSRange(location: 0, length: test.utf16.count))
        for _ in matches as [NSTextCheckingResult] { // should have only 1 match! and 1 group!
            return true // we have matched!
        }
    } catch {
        return false
    }
    return false
}



