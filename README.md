# flutter\_3d_ball

一个自动旋转的仿3D球体

![](https://rzrobert.github.io/2021/11/01/Flutter%E5%AE%9E%E7%8E%B0%E8%87%AA%E6%97%8B%E8%BD%AC%E7%9A%84%E4%BC%AA3D%E7%90%83/3dBall.gif)

## 特性
+ 支持手动/自动转动
+ 支持暂停/继续转动控制
+ 支持高亮处理部分标签

## Getting Started

```
RBallView(
  isAnimate: provider.curIndex == 0,
  isShowDecoration: false,
  mediaQueryData: MediaQuery.of(context),
  keywords: snapshot.data,
  highlight: [snapshot.data[0]],
  onTapRBallTagCallback: (RBallTagData data) {
    print('点击回调：${data.tag}');
  },
),
```
