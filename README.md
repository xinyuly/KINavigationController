# NavigationDemo
三种popViewController的效果,例如淘宝、京东的“整体返回”效果

效果图：

![image](https://github.com/xinyuly/KINavigationController/blob/master/translation.gif)

实现思路：

1.创建Pan手势识别器

2.实现手势的相应事件

3.创建截图需要的backgroundView和作为遮罩的blackMask，存放截图所需的数组

4.在push前截图，并保存

5.重写常用的pop方法,在pop前删除相应的截图

```
override func popViewController(animated: Bool) -> UIViewController?
override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?
override func popToRootViewController(animated: Bool) -> [UIViewController]? 
 
```
到此处能实现手势整体返回的效果，要实现点击返回按钮也能整体返回，需要自定义返回动画。实现协议`UIViewControllerAnimatedTransitioning`。

6.让navigationController遵守UINavigationControllerDelegate实现下面的方法，在方法里面可根据operation判断需要自定义的类型(pop/push)

```
 func navigationController(_ navigationController: UINavigationController, 
 animationControllerFor operation: UINavigationControllerOperation, 
 from fromVC: UIViewController,
  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
```

7.使用一个类实现UIViewControllerAnimatedTransitioning协议

```
func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval

//定义动画
func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
```


