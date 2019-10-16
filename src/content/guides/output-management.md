---
title: 管理输出
sort: 4
contributors:
  - skipjack
  - TheDutchCoder
  - sudarsangp
  - JGJP
  - EugeneHlushko
---

T> 本指南继续沿用 [`管理资源`](/guides/asset-management) 指南中的代码示例。

到目前为止，我们都是在 `index.html` 文件中手动引入所有资源，然而随着应用程序增长，并且一旦开始 [在文件名中使用 hash](/guides/caching) 并输出 [多个 bundle](/guides/code-splitting)，如果继续手动管理 `index.html` 文件，就会变得困难起来。然而，通过一些插件可以使这个过程更容易管控。

## 预先准备

首先，调整一下我们的项目：

__project__

``` diff
  webpack-demo
  |- package.json
  |- webpack.config.js
  |- /dist
  |- /src
    |- index.js
+   |- print.js
  |- /node_modules
```

我们在 `src/print.js` 文件中添加一些逻辑：

__src/print.js__

``` js
export default function printMe() {
  console.log('I get called from print.js!');
}
```

并且在 `src/index.js` 文件中使用这个函数：

__src/index.js__

``` diff
  import _ from 'lodash';
+ import printMe from './print.js';

  function component() {
    var element = document.createElement('div');
+   var btn = document.createElement('button');

    element.innerHTML = _.join(['Hello', 'webpack'], ' ');

+   btn.innerHTML = '点击这里，然后查看 console！';
+   btn.onclick = printMe;
+
+   element.appendChild(btn);

    return element;
  }

  document.body.appendChild(component());
```

还要更新 `dist/index.html` 文件，来为 webpack 分离入口做好准备：

__dist/index.html__

``` diff
  <!doctype html>
  <html>
    <head>
-     <title>管理资源</title>
+     <title>管理输出</title>
+     <script src="./print.bundle.js"></script>
    </head>
    <body>
-     <script src="./bundle.js"></script>
+     <script src="./app.bundle.js"></script>
    </body>
  </html>
```

现在调整配置。我们将在 entry 添加 `src/print.js` 作为新的入口起点（`print`），然后修改 output，以便根据入口起点定义的名称，动态地产生 bundle 名称：

__webpack.config.js__

``` diff
  const path = require('path');

  module.exports = {
-   entry: './src/index.js',
+   entry: {
+     app: './src/index.js',
+     print: './src/print.js'
+   },
    output: {
-     filename: 'bundle.js',
+     filename: '[name].bundle.js',
      path: path.resolve(__dirname, 'dist')
    }
  };
```

执行 `npm run build`，然后看到生成如下：

``` bash
...
          Asset     Size  Chunks                    Chunk Names
  app.bundle.js   545 kB    0, 1  [emitted]  [big]  app
print.bundle.js  2.74 kB       1  [emitted]         print
...
```

我们可以看到，webpack 生成 `print.bundle.js` 和 `app.bundle.js` 文件，这也和我们在 `index.html` 文件中指定的文件名称相对应。如果你在浏览器中打开 `index.html`，就可以看到在点击按钮时会发生什么。

但是，如果我们更改了我们的一个入口起点的名称，甚至添加了一个新的入口，会发生什么？会在构建时重新命名生成的 bundle，但是我们的 `index.html` 文件仍然引用旧的名称。让我们用 [`HtmlWebpackPlugin`](/plugins/html-webpack-plugin) 来解决这个问题。


## 设置 HtmlWebpackPlugin

首先安装插件，并且调整 `webpack.config.js` 文件：

``` bash
npm install --save-dev html-webpack-plugin
```

__webpack.config.js__

``` diff
  const path = require('path');
+ const HtmlWebpackPlugin = require('html-webpack-plugin');

  module.exports = {
    entry: {
      app: './src/index.js',
      print: './src/print.js'
    },
+   plugins: [
+     new HtmlWebpackPlugin({
+       title: '管理输出'
+     })
+   ],
    output: {
      filename: '[name].bundle.js',
      path: path.resolve(__dirname, 'dist')
    }
  };
```

在我们构建之前，你应该了解，虽然在 `dist/` 文件夹我们已经有了 `index.html` 这个文件，然而 `HtmlWebpackPlugin` 还是会默认生成它自己的 `index.html` 文件。也就是说，它会用新生成的 `index.html` 文件，替换我们的原有文件。我们看下执行 `npm run build` 后会发生什么：

``` bash
...
           Asset       Size  Chunks                    Chunk Names
 print.bundle.js     544 kB       0  [emitted]  [big]  print
   app.bundle.js    2.81 kB       1  [emitted]         app
      index.html  249 bytes          [emitted]
...
```

如果在代码编辑器中打开 `index.html`，你会看到 `HtmlWebpackPlugin` 创建了一个全新的文件，所有的 bundle 会自动添加到 html 中。

如果你想要了解 `HtmlWebpackPlugin` 插件提供的全部的功能和选项，你就应该阅读 [`HtmlWebpackPlugin`](https://github.com/jantimon/html-webpack-plugin) 仓库中的源码。

还可以看下 [`html-webpack-template`](https://github.com/jaketrent/html-webpack-template)，除了提供默认模板之外，还提供了一些额外的功能。


## 清理 `/dist` 文件夹

你可能已经注意到，由于遗留了之前的指南和代码示例，我们的 `/dist` 文件夹显得相当杂乱。webpack 将生成文件并放置在 `/dist` 文件夹中，但是它不会追踪哪些文件是实际在项目中用到的。

通常比较推荐的做法是，在每次构建前清理 `/dist` 文件夹，这样只会生成用到的文件。让我们实现这个需求。

[`clean-webpack-plugin`](https://www.npmjs.com/package/clean-webpack-plugin) 是一个流行的清理插件，安装和配置它。

``` bash
npm install --save-dev clean-webpack-plugin
```

__webpack.config.js__

``` diff
  const path = require('path');
  const HtmlWebpackPlugin = require('html-webpack-plugin');
+ const { CleanWebpackPlugin } = require('clean-webpack-plugin');

  module.exports = {
    entry: {
      app: './src/index.js',
      print: './src/print.js'
    },
    plugins: [
+     new CleanWebpackPlugin(),
      new HtmlWebpackPlugin({
        title: '管理输出'
      })
    ],
    output: {
      filename: '[name].bundle.js',
      path: path.resolve(__dirname, 'dist')
    }
  };
```

现在，执行 `npm run build`，检查 `/dist` 文件夹。如果一切顺利，现在只会看到构建后生成的文件，而没有旧文件！


## manifest

你可能会很感兴趣，webpack 和 webpack 插件似乎“知道”应该哪些文件生成。答案是，webpack 通过 manifest，可以追踪所有模块到输出 bundle 之间的映射。如果你想要知道如何以其他方式来控制 webpack [`输出`](/configuration/output)，了解 manifest 是个好的开始。

通过 [`WebpackManifestPlugin`](https://github.com/danethurber/webpack-manifest-plugin) 插件，可以将 manifest 数据提取为一个容易使用的 json 文件。

我们不会在此展示一个如何在项目中使用此插件的完整示例，你可以在 [manifest](/concepts/manifest) 概念页面深入阅读，以及在 [缓存](/guides/caching) 指南中，了解它与长效缓存有何关系。


## 结论

现在，你已经了解如何向 HTML 动态添加 bundle，让我们深入 [开发环境](/guides/development) 指南。或者如果你想要深入更多相关高级话题，我们推荐你前往 [代码分离](/guides/code-splitting) 指南。
