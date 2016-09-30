//
//  CTFGoNoGoView.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/28/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit

enum CTFGoNoGoState {
    case Blank
    case Cross
    case HorizontalCue
    case VerticalCue
    case HorizontalNoGo
    case VerticalNoGo
    case HorizontalGo
    case VerticalGo
}

protocol CTFGoNoGoViewDelegate {
    func goNoGoViewDidTap(goNoGoView: CTFGoNoGoView)
}

class CTFGoNoGoView: UIView {

    let crossView = UIImageView(image: UIImage(named: "cross"))
    let horizontalRectangle = UIView(frame: CGRectMake(0, 0, 200, 100))
    let verticalRectangle = UIView(frame: CGRectMake(0, 0, 100, 200))
    var delegate: CTFGoNoGoViewDelegate?
    
    var goColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
    var noGoColor = UIColor(red: 41.0/255.0, green: 128.0/255.0, blue: 185.0/255.0, alpha: 1.0)
    
    
    func configureHorizontalViewForState(state: CTFGoNoGoState) {
        self.horizontalRectangle.hidden = !(
            state == .HorizontalCue ||
                state == .HorizontalGo ||
                state == .HorizontalNoGo
        )
        
        if state == .HorizontalGo {
            horizontalRectangle.backgroundColor = self.goColor
        }
        else if self.state == .HorizontalNoGo {
            horizontalRectangle.backgroundColor = self.noGoColor
        }
        else {
            horizontalRectangle.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func configureVerticalViewForState(state: CTFGoNoGoState) {
        self.verticalRectangle.hidden = !(
            state == .VerticalCue ||
                state == .VerticalGo ||
                state == .VerticalNoGo
        )
        
        if state == .HorizontalGo {
            verticalRectangle.backgroundColor = self.goColor
        }
        else if self.state == .HorizontalNoGo {
            verticalRectangle.backgroundColor = self.noGoColor
        }
        else {
            verticalRectangle.backgroundColor = UIColor.whiteColor()
        }
    }
    
    var state: CTFGoNoGoState = .Blank {
        didSet {
            self.crossView.hidden = !(self.state == .Cross)
            self.configureVerticalViewForState(self.state)
            self.configureHorizontalViewForState(self.state)
            self.userInteractionEnabled = (
                self.state == .VerticalGo ||
                    self.state == .VerticalNoGo ||
                    self.state == .HorizontalGo ||
                    self.state == .HorizontalNoGo
            )
            
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.setupView()
    }
    
    func setupView() {
//        self.backgroundColor = UIColor.blueColor()
        
        self.crossView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(self.crossView)
        
        self.horizontalRectangle.layer.borderColor = UIColor.blackColor().CGColor
        self.horizontalRectangle.layer.borderWidth = 4.0
        self.addSubview(self.horizontalRectangle)
        
        self.verticalRectangle.layer.borderColor = UIColor.blackColor().CGColor
        self.verticalRectangle.layer.borderWidth = 4.0
        self.addSubview(self.verticalRectangle)
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(CTFGoNoGoView.screenTapped))
        self.addGestureRecognizer(tapRec)
        self.userInteractionEnabled = false
        
    }
    
    override func layoutSubviews() {
        self.crossView.center = self.center
        self.horizontalRectangle.center = self.center
        self.verticalRectangle.center = self.center
    }
    
    func screenTapped() {
        
        self.delegate?.goNoGoViewDidTap(self)
        
    }
    
    
    
    
    
    
    
    
    
//    override func sizeThatFits(size: CGSize) -> CGSize {
//        let minDimension: CGFloat = min(size.height, size.width)
//        return CGSizeMake(minDimension, minDimension)
//    }
    
//    override func intrinsicContentSize() -> CGSize {
//        return CGSizeMake(375.0, 375.0)
//    }

}
