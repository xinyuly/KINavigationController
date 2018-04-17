//
//  KICustomNavAnimation.swift
//  KINavigationController
//
//  Created by xinyu on 2018/4/17.
//  Copyright © 2018年 MaChat. All rights reserved.
//
// 本类主要实现:点击back返回按钮实现的全屏返回效果

import UIKit

class KICustomNavAnimation: NSObject {

    var navigationOperation: UINavigationControllerOperation?
    
    weak var navigationController: UINavigationController? {
        didSet {
            let vc = navigationController?.view.window?.rootViewController
            if vc == navigationController?.tabBarController {
                isTabbar = true
            } else {
                isTabbar = false
            }
        }
    }
    
    /// 导航栏Pop多个控制器时，需删除了多张截图
    var removeCount: Int = 0
    /// 截屏数组
    let screenShotArray = NSMutableArray()
    /// 所属的导航栏有没有TabBarController
    private var isTabbar: Bool?
    
    func removeAllScreenShot() {
        screenShotArray.removeAllObjects()
    }
    
    func removeLastScreenShot() {
        screenShotArray.removeLastObject()
    }
    
}

extension KICustomNavAnimation: UIViewControllerAnimatedTransitioning {
   
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let kScreenWidth = UIScreen.main.bounds.width
        let kScreenHeight = UIScreen.main.bounds.height
        
        let screentImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        let screenImg = self.getScreenshot()
        screentImgView.image = screenImg
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        let toView = transitionContext.view(forKey: .to)
        
        var fromViewEndFrame = transitionContext.finalFrame(for: fromViewController!)
        fromViewEndFrame.origin.x = kScreenWidth
        var fromViewStartFrame = fromViewEndFrame
        let toViewEndFrame = transitionContext.finalFrame(for: toViewController!)
        let toViewStartFrame = toViewEndFrame
        
        let containerView = transitionContext.containerView
        
        if navigationOperation == UINavigationControllerOperation.push {
            screenShotArray.add(screenImg!)
            //这句非常重要，没有这句，就无法正常Push和Pop出对应的界面
            containerView.addSubview(toView!)
            toView?.frame = toViewStartFrame
            
            let nextVC = UIView.init(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight))
            //添加截图
            navigationController?.view.window?.insertSubview(screentImgView, at: 0)
            nextVC.layer.shadowColor = UIColor.black.cgColor
            nextVC.layer.shadowOffset = CGSize(width: -0.8, height: 0)
            nextVC.layer.shadowOpacity = 0.6
            
            navigationController?.view.transform = CGAffineTransform(translationX: kScreenWidth, y: 0)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                self.navigationController?.view.transform = CGAffineTransform(translationX: 0, y: 0)
                screentImgView.center = CGPoint(x: -kScreenWidth/2, y: kScreenHeight/2)
            }, completion: { (finished: Bool) in
                nextVC.removeFromSuperview()
                screentImgView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
        if navigationOperation == .pop {
            fromViewStartFrame.origin.x = 0
            containerView.addSubview(toView!)
            let lastVcImgView = UIImageView.init(frame: CGRect(x: -kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight))
            //Pop多个控制器
            if removeCount > 0 {
                for i in 0..<removeCount {
                    if i == removeCount - 1 {
                        //当删除到要跳转页面的截图时，不再删除，并将该截图作为ToVC的截图展示
                        lastVcImgView.image = screenShotArray.lastObject as? UIImage
                        removeCount = 0
                        break
                    } else {
                        self.screenShotArray.removeLastObject()
                    }
                }
            } else {
                lastVcImgView.image = screenShotArray.lastObject as? UIImage
            }
            screentImgView.layer.shadowColor = UIColor.black.cgColor
            screentImgView.layer.shadowOffset = CGSize(width: -0.8, height: 0)
            screentImgView.layer.shadowOpacity = 0.6
            navigationController?.view.window?.addSubview(lastVcImgView)
            navigationController?.view.addSubview(screentImgView)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                screentImgView.center = CGPoint(x: kScreenWidth*3/2, y: kScreenHeight/2)
                lastVcImgView.center = CGPoint(x: kScreenWidth/2, y: kScreenHeight/2)
            }, completion: { (finished: Bool) in
                lastVcImgView.removeFromSuperview()
                screentImgView.removeFromSuperview()
                self.screenShotArray.removeLastObject()
                transitionContext.completeTransition(true)
            })
            
        }
    }
    
    private func getScreenshot() -> UIImage? {
        guard let top_view = UIApplication.shared.keyWindow?.rootViewController?.view else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(top_view.bounds.size, top_view.isOpaque, 0.0)
        top_view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
