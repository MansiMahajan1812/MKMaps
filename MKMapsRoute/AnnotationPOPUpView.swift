//
//  AnnotationPOPUpView.swift
//  MKMapsRoute
//
//  Created by Mansi Mahajan on 7/27/18.
//  Copyright © 2018 Mansi Mahajan. All rights reserved.
//

import UIKit

class AnnotationPOPUpView: UIView {

   
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var name: UILabel!
   
    
    internal var preferredContentSize:CGSize{
        if stackView != nil{
            let val = stackView.sizeThatFits(self.bounds.size)
            print(val)
            return val
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
