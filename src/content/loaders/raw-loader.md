---
title: raw-loader
source: https://raw.githubusercontent.com/webpack-contrib/raw-loader/master/README.md
edit: https://github.com/webpack-contrib/raw-loader/edit/master/README.md
repo: https://github.com/webpack-contrib/raw-loader
---


[![npm][npm]][npm-url]
[![node][node]][node-url]
[![deps][deps]][deps-url]
[![tests][tests]][tests-url]
[![chat][chat]][chat-url]



可以将文件作为字符串导入的 webpack loader。

## 要求

模块需要 Node v6.9.0+ 和 webpack v4.0.0+。

## 起步

你需要预先安装 `raw-loader`：

```console
$ npm install raw-loader --save-dev
```

在然后 `webpack` 配置中添加 loader：

```js
import txt from './file.txt';
```

```js
// webpack.config.js
module.exports = {
  module: {
    rules: [
      {
        test: /\.txt$/,
        use: 'raw-loader'
      }
    ]
  }
}
```

或者，通过命令行使用：

```console
$ webpack --module-bind 'txt=raw-loader'
```

然后，运行 `webpack`。

## License

#### [MIT](https://raw.githubusercontent.com/webpack-contrib/raw-loader/master/LICENSE)

[npm]: https://img.shields.io/npm/v/raw-loader.svg
[npm-url]: https://npmjs.com/package/raw-loader

[node]: https://img.shields.io/node/v/raw-loader.svg
[node-url]: https://nodejs.org

[deps]: https://david-dm.org/webpack-contrib/raw-loader.svg
[deps-url]: https://david-dm.org/webpack-contrib/raw-loader

[tests]: 	https://img.shields.io/circleci/project/github/webpack-contrib/raw-loader.svg
[tests-url]: https://circleci.com/gh/webpack-contrib/raw-loader

[cover]: https://codecov.io/gh/webpack-contrib/raw-loader/branch/master/graph/badge.svg
[cover-url]: https://codecov.io/gh/webpack-contrib/raw-loader

[chat]: https://img.shields.io/badge/gitter-webpack%2Fwebpack-brightgreen.svg
[chat-url]: https://gitter.im/webpack/webpack
