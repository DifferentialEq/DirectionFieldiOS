//
//  TwitterViewController.swift
//  DirectionField
//
//  Created by Eli Selkin on 1/9/16.
//  Copyright © 2016 DifferentialEq. All rights reserved.
//

import UIKit
import TwitterKit
import Twitter

class TwitterViewController: UIViewController {
    var tweetImage:UIImage!
    var tweetMatrix:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Swift
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                // Swift
                let composer = TWTRComposer()
                composer.setText(self.tweetMatrix)
                composer.setImage(self.tweetImage)
                // Called from a UIViewController
                composer.showFromViewController(self) { result in
                    if (result == TWTRComposerResult.Cancelled) {
                    }
                    else {
                    }
                }
            } else {
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        

        // Do any additional setup after loading the view.
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
