---
title: mocha-loader
source: https://raw.githubusercontent.com/webpack-contrib/mocha-loader/master/README.md
edit: https://github.com/webpack-contrib/mocha-loader/edit/master/README.md
repo: https://github.com/webpack-contrib/mocha-loader
---


[![npm][npm]][npm-url]
[![node][node]][node-url]
[![deps][deps]][deps-url]
[![tests][tests]][tests-url]
[![chat][chat]][chat-url]



mocha 模块的 webpack loader

## 要求

此模块需要 Node v6.9.0+ 和 webpack v4.0.0+。

## 起步

你需要预先安装 `mocha-loader`：

```console
$ npm install mocha-loader --save-dev
```

然后，在 `webpack` 配置中添加 loader。例如：

```js
// webpack.config.js
module.exports = {
  entry: './entry.js',
  output: {
    path: __dirname,
    filename: 'bundle.js'
  },
  module: {
    rules: [{
      test: /test\.js$/,
      use: 'mocha-loader',
      exclude: /node_modules/,
    }]
  }
}
```

然后在应用程序中 `import` 目标文件：

```js
// src/entry.js
import test from './test'
```

然后，通过你偏爱的方式去运行 `webpack`。

## 示例

你可以通过如下方式使用 loader：

### CLI

```console
webpack --module-bind 'mocha-loader!./test'
```

### require 引用

```js
import test from 'mocha-loader!./test'
```

## 贡献

如果你从未阅读过我们的贡献指南，请在上面花点时间。

#### [贡献指南](https://raw.githubusercontent.com/webpack-contrib/mocha-loader/master/.github/CONTRIBUTING)

## License

#### [MIT](https://raw.githubusercontent.com/webpack-contrib/mocha-loader/master/LICENSE)

[npm]: https://img.shields.io/npm/v/mocha-loader.svg
[npm-url]: https://npmjs.com/package/mocha-loader

[node]: https://img.shields.io/node/v/mocha-loader.svg
[node-url]: https://nodejs.org

[deps]: https://david-dm.org/webpack-contrib/mocha-loader.svg
[deps-url]: https://david-dm.org/webpack-contrib/mocha-loader

[tests]: 	https://img.shields.io/circleci/project/github/webpack-contrib/mocha-loader.svg
[tests-url]: https://circleci.com/gh/webpack-contrib/mocha-loader

[cover]: https://codecov.io/gh/webpack-contrib/mocha-loader/branch/master/graph/badge.svg
[cover-url]: https://codecov.io/gh/webpack-contrib/mocha-loader

[chat]: https://img.shields.io/badge/gitter-webpack%2Fwebpack-brightgreen.svg
[chat-url]: https://gitter.im/webpack/webpack
