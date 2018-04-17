//
//  ViewController.swift
//  KINavigationController
//
//  Created by xinyu on 2018/4/17.
//  Copyright © 2018年 MaChat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: CGRect(x: 30, y: 100, width: 60, height: 40))
        textLabel.text = String(format:"%d",(navigationController?.viewControllers.count)!)
        return textLabel
    } ()
    
    lazy var nextButton: UIButton = {
       let nextButton = UIButton(frame: CGRect(x: 60, y: 200, width: 60, height: 40))
        nextButton.addTarget(self, action: #selector(nextViewController), for: .touchUpInside)
        nextButton.setTitle("下一页", for: .normal)
        nextButton.backgroundColor = UIColor.lightGray
        
       return nextButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initSubViews()
    }
    
    func initSubViews() {
        view.addSubview(textLabel)
        view.addSubview(nextButton)
        let button = UIButton(frame: CGRect(x: 60, y: 400, width: 100, height: 40))
        button.setTitle("回到首页", for: .normal)
        view.addSubview(button)
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(popViewController), for: .touchUpInside)
        
        view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255))/255.00, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1)
        
        guard let navi = navigationController else { return }
        if navi.viewControllers.count > 1 {
            self.showLeftBarItem(imageName: "icon_nav_back", highlightedImage: "icon_nav_back", selector: #selector(back))
        }
        
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    @objc func nextViewController() {
        let vc = ViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func popViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func showLeftBarItem(imageName: String, highlightedImage:String,selector:Selector? ) {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btn.setImage(UIImage(named: imageName), for: .normal)
        btn.setImage(UIImage(named: highlightedImage), for: .highlighted)
        if selector != nil {
            btn.addTarget(self, action: selector!, for: .touchUpInside)
        }
        let item = UIBarButtonItem.init(customView: btn)
        self.navigationItem.leftBarButtonItem = item
    }

}

