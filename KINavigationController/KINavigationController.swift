//
//  KINavigationController.swift
//  KINavigationController
//
//  Created by xinyu on 2018/4/17.
//  Copyright © 2018年 MaChat. All rights reserved.
//

import UIKit

//导航控制器返回样式
enum TransformType: Int {
   case normal = 0
   case scale = 1  //缩放模式
   case translation = 2 //平移模式
}

class KINavigationController: UINavigationController {
   
    var canDragBack: Bool = true
    var type: TransformType = .normal
    fileprivate var startTouch: CGPoint?
    fileprivate var blackMask: UIView?
    fileprivate var backgroundView: UIView?
    fileprivate var lastScreenShotView: UIImageView?
    fileprivate var isMoving: Bool?
    private let screenShotsList = NSMutableArray()
    private let customAnimation = KICustomNavAnimation()
    
    private var TOP_VIEW: UIView?  {
        //当控制器没有初始化结束时，获取的keyWindow值为空
        get { return UIApplication.shared.keyWindow?.rootViewController?.view }
    }
    private let kScreenWidth = UIScreen.main.bounds.width
    private let kScreenHeight = UIScreen.main.bounds.height
    private let kMAXWidth =  UIScreen.main.bounds.width   //Maximum width to move
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(paningGestureReceive(recoginzer:)))
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
        //实现侧滑返回
        interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.screenShotsList.count == 0 {
            let screenshot = getScreenshot()
            if screenshot != nil {
                screenShotsList.add(screenshot!)
            }
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let screenshot = getScreenshot()
        if screenshot != nil {
            screenShotsList.add(screenshot!)
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        screenShotsList.removeLastObject()
        return super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        var removeCount = 0
        for i in stride(from: viewControllers.count, to: 0, by: -1) {
            if viewController == viewControllers[i] {
                break
            }
            screenShotsList.removeLastObject()
            removeCount = removeCount+1
        }
        customAnimation.removeCount = removeCount
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        screenShotsList.removeAllObjects()
        customAnimation.removeAllScreenShot()
        return super.popToRootViewController(animated: animated)
    }
    
    //MARK: - Private Methods
    func getScreenshot() -> UIImage? {
        guard let top_view = TOP_VIEW else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(top_view.bounds.size, top_view.isOpaque, 0.0)
        top_view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    //  设置最后一张截图随着手指变化的位置和透明度
    func moveView(withX:CGFloat) {
        var x = withX
        x = (x > kMAXWidth) ? kMAXWidth : x
        x = (x<0) ? 0: x
        
        var frame = TOP_VIEW?.frame
        frame?.origin.x = x
        TOP_VIEW?.frame = frame!
        
        let scale = CGFloat((x/6400)+0.95)
        let alpha = CGFloat(0.4 - (x/800))
        blackMask?.alpha = alpha
        
        if self.type == .scale {
            lastScreenShotView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else if (self.type == .translation) {
            x = -kScreenWidth*0.6 + x/1.3
            x = (x>0) ? 0 : x
            lastScreenShotView?.transform = CGAffineTransform(translationX: x, y: 0)
        }
    }
    
    //MARK: - Events
    @objc func paningGestureReceive(recoginzer:UIPanGestureRecognizer) {
        //如果只有一个控制器或者不允许全屏返回，return
        if self.viewControllers.count <= 1 || !canDragBack {
            return
        }
        
        let touchPoint = recoginzer.location(in: UIApplication.shared.keyWindow)
        
        switch recoginzer.state {
        case .began:
            isMoving = true
            startTouch = touchPoint
            if backgroundView == nil {
                let frame = TOP_VIEW?.frame
                backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: (frame?.size.width)!, height: (frame?.size.height)!))
                TOP_VIEW?.superview?.insertSubview(backgroundView!, belowSubview: TOP_VIEW!)
                
                blackMask = UIView(frame: CGRect(x: 0, y: 0, width: (frame?.size.width)!, height: (frame?.size.height)!))
                blackMask?.backgroundColor = UIColor.black
                backgroundView?.addSubview(blackMask!)
            }
            backgroundView?.isHidden = false
            if lastScreenShotView != nil {
                lastScreenShotView?.removeFromSuperview()
            }
            
            let lastScreenShot = screenShotsList.lastObject as! UIImage
            lastScreenShotView = UIImageView(image: lastScreenShot)
            backgroundView?.insertSubview(lastScreenShotView!, belowSubview: blackMask!)
            
           break
        case .ended:
            //手势结束，判断是返回还是回到原位
            if touchPoint.x - (startTouch?.x)! > 50 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.moveView(withX: self.kMAXWidth)
                }, completion: { (finished:Bool) in
                    self.popViewController(animated: false)
                    var frame = self.TOP_VIEW?.frame
                    frame?.origin.x = 0
                    self.TOP_VIEW?.frame = frame!
                    self.isMoving = false
                    self.backgroundView?.isHidden = true
                    // End paning,remove last screen shot
                    self.customAnimation.removeLastScreenShot()
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.moveView(withX: 0)
                }, completion: { (finished:Bool) in
                    self.isMoving = false
                    self.backgroundView?.isHidden = true
                })
            }
           return //直接返回，不在往下执行
        case .cancelled:
            UIView.animate(withDuration: 0.3, animations: {
                self.moveView(withX: 0)
            }, completion: { (finished:Bool) in
                self.isMoving = false
                self.backgroundView?.isHidden = true
            })
            return
        default:
            break
        }
        if isMoving! {
            self.moveView(withX: touchPoint.x - (startTouch?.x)!)
        }
    }
}

extension KINavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        customAnimation.navigationController = self
        customAnimation.navigationOperation = operation
        
        return customAnimation
    }
}

extension KINavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.viewControllers.count <= 1 || !canDragBack {
            return false
        }
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            
            return true
        }
        return true
    }
}
