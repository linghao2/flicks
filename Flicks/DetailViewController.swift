//
//  DetailViewController.swift
//  Flicks
//
//  Created by LING HAO on 3/30/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var backgrounImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    var flick : Dictionary<String, AnyObject?>!
    var detailImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgrounImageView.image = detailImage
        titleLabel.text = flick["title"] as? String
        if let rating = flick["vote_average"] as? NSNumber {
            ratingLabel.text = rating.stringValue
        }
        overviewLabel.text = flick["overview"] as? String
        
        let before = overviewLabel.frame.size
        overviewLabel.sizeToFit()
        let after = overviewLabel.frame.size
        let diffHeight = after.height - before.height
        
        let width = scrollView.frame.size.width
        let height = scrollView.frame.size.height + diffHeight
        scrollView.contentSize = CGSize(width: width, height: height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
