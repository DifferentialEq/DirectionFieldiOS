//
//  EigenvectorViewController.swift
//  DirectionField
//
//  Created by Eli Selkin on 1/10/16.
//  Copyright © 2016 DifferentialEq. All rights reserved.
//

import UIKit

class EigenvectorViewController: UIViewController {
    var eigenValue:Complex!
    var eigenVector:TwoDimMatrix!
    var tutorialView:UIView!
    var tutorialCompleteTest:Bool!
    @IBOutlet weak var EVEC1: UILabel!
    @IBOutlet weak var EVEC2: UILabel!
    @IBOutlet weak var EigValueLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EVEC1.text = eigenVector.getValueAt(1, col: 1).description
        EVEC2.text = eigenVector.getValueAt(2, col: 1).description
        EigValueLabel.text = eigenValue.description
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
