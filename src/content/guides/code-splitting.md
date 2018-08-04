---
title: 代码分离
sort: 9
contributors:
  - pksjce
  - pastelsky
  - simon04
  - jonwheeler
  - johnstew
  - shinxi
  - tomtasche
  - levy9527
  - rahulcs
  - chrisVillanueva
  - rafde
  - bartushek
  - shaunwallace
  - skipjack
  - jakearchibald
  - TheDutchCoder
  - rouzbeh84
  - shaodahong
  - sudarsangp
  - kcolton
  - efreitasn
  - EugeneHlushko
  - byzyk
related:
  - title: <link rel=”prefetch/preload”> in webpack
    url: https://medium.com/webpack/link-rel-prefetch-preload-in-webpack-51a52358f84c
  - title: Preload, Prefetch And Priorities in Chrome
    url: https://medium.com/reloading/preload-prefetch-and-priorities-in-chrome-776165961bbf
  - title: Preloading content with rel="preload"
    url: https://developer.mozilla.org/en-US/docs/Web/HTML/Preloading_content
---

T> 本指南继续沿用[起步](/guides/getting-started)和[管理输出](/guides/output-management)中的代码示例。。请确保你至少已熟悉其中提供的示例。

代码分离是 webpack 中最引人注目的特性之一。此特性能够把代码分离到不同的 bundle 中，然后可以按需加载或并行加载这些文件。代码分离可以用于获取更小的 bundle，以及控制资源加载优先级，如果使用合理，会极大影响加载时间。

有三种常用的代码分离方法：

- 入口起点：使用 [`entry`](/configuration/entry-context) 配置手动地分离代码。
- 防止重复：使用 [`SplitChunks`](/plugins/split-chunks-plugin/) 去重和分离 chunk。
- 动态导入：通过模块的内联函数调用来分离代码。


## 入口起点(entry points)

这是迄今为止最简单、最直观的分离代码的方式。不过，这种方式手动配置较多，并有一些陷阱，我们将会解决这些问题。先来看看如何从 main bundle 中分离另一个模块：

__project__

``` diff
webpack-demo
|- package.json
|- webpack.config.js
|- /dist
|- /src
  |- index.js
+ |- another-module.js
|- /node_modules
```

__another-module.js__

``` js
import _ from 'lodash';

console.log(
  _.join(['Another', 'module', 'loaded!'], ' ')
);
```

__webpack.config.js__

``` diff
const path = require('path');

module.exports = {
  mode: 'development',
  entry: {
    index: './src/index.js',
+   another: './src/another-module.js'
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

这将生成如下构建结果：

``` bash
Hash: a948f6cc8219cc2d39a1
Version: webpack 4.7.0
Time: 323ms
            Asset     Size   Chunks             Chunk Names
another.bundle.js  550 KiB  another  [emitted]  another
  index.bundle.js  550 KiB    index  [emitted]  index
Entrypoint index = index.bundle.js
Entrypoint another = another.bundle.js
[./node_modules/webpack/buildin/global.js] (webpack)/buildin/global.js 489 bytes {another} {index} [built]
[./node_modules/webpack/buildin/module.js] (webpack)/buildin/module.js 497 bytes {another} {index} [built]
[./src/another-module.js] 88 bytes {another} [built]
[./src/index.js] 86 bytes {index} [built]
    + 1 hidden module
```

正如前面提到的，这种方法存在一些问题:

- 如果入口 chunks 之间包含重复的模块，那些重复模块都会被引入到各个 bundle 中。
- 这种方法不够灵活，并且不能将核心应用程序逻辑进行动态拆分代码。

以上两点中，第一点对我们的示例来说无疑是个问题，因为之前我们在 `./src/index.js` 中也引入过 `lodash`，这样就在两个 bundle 中造成重复引用。接着，我们通过使用 `SplitChunks` 插件来移除重复的模块。


## 防止重复(prevent duplication)

CommonsChunkPlugin 已经从 webpack v4（代号 legato）中移除。想要了解最新版本是如何处理 chunk，请查看 [SplitChunksPlugin](/plugins/split-chunks-plugin/)。

[`SplitChunks`](/plugins/split-chunks-plugin/) 插件可以将公共的依赖模块提取到已有的入口 chunk 中，或者提取到一个新生成的 chunk。让我们使用这个插件，将之前的示例中重复的 `lodash` 模块去除：

__webpack.config.js__

``` diff
  const path = require('path');

  module.exports = {
    mode: 'development',
    entry: {
      index: './src/index.js',
      another: './src/another-module.js'
    },
    output: {
      filename: '[name].bundle.js',
      path: path.resolve(__dirname, 'dist')
    },
+   optimization: {
+     splitChunks: {
+       chunks: 'all'
+     }
+   }
  };
```

这里我们使用 [`SplitChunks`](/plugins/split-chunks-plugin/) 之后，现在应该可以看出，`index.bundle.js` 中已经移除了重复的依赖模块。需要注意的是，CommonsChunkPlugin 插件将 `lodash` 分离到单独的 chunk，并且将其从 main bundle 中移除，减轻了大小。执行 `npm run build` 查看效果：

``` bash
Hash: ac2ac6042ebb4f20ee54
Version: webpack 4.7.0
Time: 316ms
                          Asset      Size                 Chunks             Chunk Names
              another.bundle.js  5.95 KiB                another  [emitted]  another
                index.bundle.js  5.89 KiB                  index  [emitted]  index
vendors~another~index.bundle.js   547 KiB  vendors~another~index  [emitted]  vendors~another~index
Entrypoint index = vendors~another~index.bundle.js index.bundle.js
Entrypoint another = vendors~another~index.bundle.js another.bundle.js
[./node_modules/webpack/buildin/global.js] (webpack)/buildin/global.js 489 bytes {vendors~another~index} [built]
[./node_modules/webpack/buildin/module.js] (webpack)/buildin/module.js 497 bytes {vendors~another~index} [built]
[./src/another-module.js] 88 bytes {another} [built]
[./src/index.js] 86 bytes {index} [built]
    + 1 hidden module
```

以下是由社区提供的，一些对于代码分离很有帮助的插件和 loaders：

- [`mini-css-extract-plugin`](/plugins/mini-css-extract-plugin): 用于将 CSS 从主应用程序中分离。
- [`bundle-loader`](/loaders/bundle-loader): 用于分离代码和延迟加载生成的 bundle。
- [`promise-loader`](https://github.com/gaearon/promise-loader): 类似于 `bundle-loader` ，但是使用的是 promises。

[`CommonsChunkPlugin`](/plugins/commons-chunk-plugin) 插件还可以通过使用[显式的 vendor chunks](/plugins/commons-chunk-plugin/#explicit-vendor-chunk) 功能，从应用程序代码中分离 vendor 模块。


## 动态导入(dynamic imports)

当涉及到动态代码拆分时，webpack 提供了两个类似的技术。对于动态导入，第一种，也是推荐选择的方式是，使用符合 [ECMAScript 提案](https://github.com/tc39/proposal-dynamic-import) 的 [`import()` 语法](/api/module-methods#import-)。第二种，则是使用 webpack 特定的 [`require.ensure`](/api/module-methods#require-ensure)。让我们先尝试使用第一种……

W> `import()` 调用会在内部用到 [promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)。如果在旧有版本浏览器中使用 `import()`，记得使用 一个 polyfill 库（例如 [es6-promise](https://github.com/stefanpenner/es6-promise) 或 [promise-polyfill](https://github.com/taylorhakes/promise-polyfill)），来 shim `Promise`。

在我们开始本节之前，先从配置中移除掉多余的 [`entry`](/concepts/entry-points/) 和 [`optimization.splitChunks`](/plugins/split-chunks-plugin)，因为接下来的演示中并不需要它们：

__webpack.config.js__

``` diff
  const path = require('path');

  module.exports = {
    mode: 'development',
    entry: {
+     index: './src/index.js'
-     index: './src/index.js',
-     another: './src/another-module.js'
    },
    output: {
      filename: '[name].bundle.js',
+     chunkFilename: '[name].bundle.js',
      path: path.resolve(__dirname, 'dist')
    },
-   optimization: {
-     splitChunks: {
-       chunks: 'all'
-     }
-   }
  };
```

注意，这里使用了 `chunkFilename`，它决定非入口 chunk 的名称。想了解 `chunkFilename` 更多信息，请查看 [output 相关文档](/configuration/output/#output-chunkfilename)。接着，更新我们的项目，移除掉那些现在不会用到的文件：

__project__

``` diff
webpack-demo
|- package.json
|- webpack.config.js
|- /dist
|- /src
  |- index.js
- |- another-module.js
|- /node_modules
```

现在，我们不再使用静态导入 `lodash`，而是通过使用动态导入来分离一个 chunk：

__src/index.js__

``` diff
- import _ from 'lodash';
-
- function component() {
+ function getComponent() {
-   var element = document.createElement('div');
-
-   // Lodash, now imported by this script
-   element.innerHTML = _.join(['Hello', 'webpack'], ' ');
+   return import(/* webpackChunkName: "lodash" */ 'lodash').then(_ => {
+     var element = document.createElement('div');
+     var _ = _.default;
+
+     element.innerHTML = _.join(['Hello', 'webpack'], ' ');
+
+     return element;
+
+   }).catch(error => 'An error occurred while loading the component');
  }

- document.body.appendChild(component());
+ getComponent().then(component => {
+   document.body.appendChild(component);
+ })
```

注意，在注释中使用了 `webpackChunkName`。这样做会导致我们的 bundle 被命名为 `lodash.bundle.js` ，而不是 `[id].bundle.js` 。想了解更多关于 `webpackChunkName` 和其他可用选项，请查看 [`import()` 相关文档](/api/module-methods/#import-)。让我们执行 webpack，查看 `lodash` 是否会分离到一个单独的 bundle：

``` bash
Hash: a3f7446ffbeb7fb897ff
Version: webpack 4.7.0
Time: 316ms
                   Asset      Size          Chunks             Chunk Names
         index.bundle.js  7.88 KiB           index  [emitted]  index
vendors~lodash.bundle.js   547 KiB  vendors~lodash  [emitted]  vendors~lodash
Entrypoint index = index.bundle.js
[./node_modules/webpack/buildin/global.js] (webpack)/buildin/global.js 489 bytes {vendors~lodash} [built]
[./node_modules/webpack/buildin/module.js] (webpack)/buildin/module.js 497 bytes {vendors~lodash} [built]
[./src/index.js] 394 bytes {index} [built]
    + 1 hidden module
```

由于 `import()` 会返回一个 promise，因此它可以和 [`async` 函数](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)一起使用。但是，需要使用像 Babel 这样的预处理器和 [Syntax Dynamic Import Babel Plugin](https://babeljs.io/docs/plugins/syntax-dynamic-import/#installation)。下面是如何通过 `async` 函数简化代码：

__src/index.js__

``` diff
- function getComponent() {
+ async function getComponent() {
-   return import(/* webpackChunkName: "lodash" */ 'lodash').then(_ => {
-     var element = document.createElement('div');
-
-     element.innerHTML = _.join(['Hello', 'webpack'], ' ');
-
-     return element;
-
-   }).catch(error => 'An error occurred while loading the component');
+   var element = document.createElement('div');
+   const _ = await import(/* webpackChunkName: "lodash" */ 'lodash');
+
+   element.innerHTML = _.join(['Hello', 'webpack'], ' ');
+
+   return element;
  }

  getComponent().then(component => {
    document.body.appendChild(component);
  });
```


## 预取/预加载模块

webpack 4.6.0+ 添加了预取/预加载功能的支持

在声明 import 时使用这些内置指令，可以让 webpack 输出“资源提示(Resource Hint)”，来告知浏览器：

- 预取(prefetch)：将来导航下可能需要的资源
- 预加载(preload): 当前导航下可能需要资源

下面这个预取(prefetch)的简单示例中，有一个 `HomePage` 组件，其内部渲染一个 `LoginButton` 组件，然后在点击后按需加载 `LoginModal` 组件。

__LoginButton.js__

```js
//...
import(/* webpackPrefetch: true */ 'LoginModal');
```

这会生成 `<link rel="prefetch" href="login-modal-chunk.js">` 并追加到页面头部，指示着浏览器在闲置时间预取 `login-modal-chunk.js` 文件。

T> 只要父 chunk 完成加载，webpack 就会添加预取提示。

和预取指令相比，预加载指令有许多不同之处：

- 预加载 chunk 会在父 chunk 加载时，以并行方式开始加载。预取 chunk 会在父 chunk 加载结束后开始加载。
- 预加载 chunk 具有中等优先级，并立即下载。预取 chunk 在浏览器闲置时下载。
- 预加载 chunk 会在父 chunk 中立即请求。预取 chunk 在未来使用时才会请求。
- 浏览器支持程度不同。

下面这个预加载(preload)的简单示例中，有一个 `Component`，依赖于一个较大的 library，所以应该将其分离到一个独立的 chunk 中。

这里的图表组件 `ChartComponent` 需要依赖体积巨大的 `ChartingLibrary`。它会在渲染时显示一个 `LoadingIndicator(加载进度条)` 组件，然后立即按需导入 `ChartingLibrary`：

__ChartComponent.js__

```js
//...
import(/* webpackPreload: true */ 'ChartingLibrary');
```

在页面使用 `ChartComponent` 时，在请求 ChartComponent.js 的同时，charting-library-chunk 也会通过 `<link rel="preload">` 去预先请求。假定 page-chunk 体积很小，很快就被加载好，页面此时就会显示 `LoadingIndicator(加载进度条)` ，等到 `charting-library-chunk` 加载完成，LoadingIndicator 组件才消失。在启动时仅需要很少的加载时间，因为只进行单次请求，而不是两次请求。尤其是高延迟环境下的加载时间。

T> 不正确地使用 webpackPreload 会有损性能，请谨慎使用。


## bundle 分析(bundle analysis)

如果我们以分离代码作为开始，那么就以检查模块作为结束，分析输出结果是很有用处的。[官方分析工具](https://github.com/webpack/analyse) 是一个好的初始选择。下面是一些社区支持(community-supported)的可选工具：

- [webpack-chart](https://alexkuz.github.io/webpack-chart/): webpack 数据交互饼图。
- [webpack-visualizer](https://chrisbateman.github.io/webpack-visualizer/): 可视化并分析你的 bundle，检查哪些模块占用空间，哪些可能是重复使用的。
- [webpack-bundle-analyzer](https://github.com/webpack-contrib/webpack-bundle-analyzer): 一款分析 bundle 内容的插件及 CLI 工具，以便捷的、交互式、可缩放的树状图形式展现给用户。


## 下一步

关于「如何在真正的应用程序和[缓存](/guides/caching)中 `import()` 导入」以及学习「如何更加高效地分离代码」的具体示例，请查看[懒加载](/guides/lazy-loading)。
