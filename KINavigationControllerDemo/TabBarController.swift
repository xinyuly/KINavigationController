//
//  TabBarController.swift
//  KINavigationController
//
//  Created by xinyu on 2018/4/17.
//  Copyright © 2018年 MaChat. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addNavigationController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func addNavigationController() {
        let vc1 = ViewController()
        vc1.title = "Scale"
        let navVC1 = KINavigationController(rootViewController: vc1)
        navVC1.type = .scale
        self.addChildViewController(navVC1)
        
        let vc2 = ViewController()
        vc2.title = "Normal"
        let navVC2 = KINavigationController(rootViewController: vc2)
        navVC2.type = .normal
        self.addChildViewController(navVC2)
        
        let vc3 = ViewController()
        vc3.title = "Translation"
        let navVC3 = KINavigationController(rootViewController: vc3)
        navVC3.type = .translation
        self.addChildViewController(navVC3)
        
    }

}
