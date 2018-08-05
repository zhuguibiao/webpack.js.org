---
title: CompressionWebpackPlugin
source: https://raw.githubusercontent.com/webpack-contrib/compression-webpack-plugin/master/README.md
edit: https://github.com/webpack-contrib/compression-webpack-plugin/edit/master/README.md
repo: https://github.com/webpack-contrib/compression-webpack-plugin
---
提供带 Content-Encoding 编码的压缩版的资源

## 安装

```bash
npm i -D compression-webpack-plugin
```

## 使用

**webpack.config.js**
```js
const CompressionPlugin = require("compression-webpack-plugin")

module.exports = {
  plugins: [
    new CompressionPlugin(...options)
  ]
}
```

## 选项

|Name|Type|Default|Description|
|:--:|:--:|:-----:|:----------|
|**[`test`](#test)**|`{RegExp\|Array<RegExp>}`|`.`|处理所有匹配此 `{RegExp\|Array<RegExp>}` 的资源|
|**[`include`](#include)**|`{RegExp\|Array<RegExp>}`|`undefined`|Files to `include`|
|**[`exclude`](#exclude)**|`{RegExp\|Array<RegExp>}`|`undefined`|Files to `exclude`|
|**[`cache`](#cache)**|`{Boolean\|String}`|`false`|Enable file caching|
|**[`asset`](#asset)**|`{String}`|`[path].gz[query]`|目标资源名称。`[file]` 会被替换成原始资源名称。`[path]` 会被替换成原始资源路径，`[query]` 会被替换成原始查询字符串|
|**[`filename`](#filename)**|`{Function}`|`false`|一个 `{Function}` `(asset) => asset` 函数，接收原始资源名称（通过 `asset` 选项）返回新的资源名称|
|**[`algorithm`](#algorithm)**|`{String\|Function}`|`gzip`|可以是 `(buffer, cb) => cb(buffer)` 或者是使用 `zlib` 里面的算法的 `{String}`|
|**[`threshold`](#threshold)**|`{Number}`|`0`|只处理比这个值大的资源。按字节计算|
|**[`minRatio`](#minratio)**|`{Number}`|`0.8`|只有压缩率比这个值小的资源才会被处理|
|**[`deleteOriginalAssets`](#deleteoriginalassets)**|`{Boolean}`|`false`|是否删除原始资源|

##

**webpack.config.js**
```js
[
  new CompressionPlugin({
    test: /\.js/
  })
]
```

### `include`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    include: /\/includes/
  })
]
```

### `exclude`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    exclude: /\/excludes/
  })
]
```

### `cache`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    cache: true
  })
]
```

### `asset`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    asset: '[path].gz[query]'
  })
]
```

### `filename`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    filename (asset) {
      asset = 'rename'
      return asset
    }
  })
]
```

### `algorithm`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    algorithm: 'gzip'
  })
]
```

### `threshold`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    threshold: 0
  })
]
```

### `minRatio`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    minRatio: 0.8
  })
]
```

### `deleteOriginalAssets`

**webpack.config.js**
```js
[
  new CompressionPlugin({
    deleteOriginalAssets: true
  })
]
```

## 维护人员

<table>
  <tbody>
  <tr>
    <td align="center">
      <a href="https://github.com/d3viant0ne">
        <img width="150" height="150" src="https://github.com/d3viant0ne.png?v=3&s=150">
        </br>
        Joshua Wiens
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/bebraw">
        <img width="150" height="150" src="https://github.com/bebraw.png?v=3&s=150">
        </br>
        Juho Vepsäläinen
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/michael-ciniawsky">
        <img width="150" height="150" src="https://github.com/michael-ciniawsky.png?v=3&s=150">
        </br>
        Michael Ciniawsky
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/evilebottnawi">
        <img width="150" height="150" src="https://github.com/evilebottnawi.png?v=3&s=150">
        </br>
        Alexander Krasnoyarov
      </a>
    </td>
  </tr>
  <tbody>
</table>


[npm]: https://img.shields.io/npm/v/compression-webpack-plugin.svg
[npm-url]: https://npmjs.com/package/compression-webpack-plugin

[node]: https://img.shields.io/node/v/compression-webpack-plugin.svg
[node-url]: https://nodejs.org

[deps]: https://david-dm.org/webpack-contrib/compression-webpack-plugin.svg
[deps-url]: https://david-dm.org/webpack-contrib/compression-webpack-plugin

[test]: https://secure.travis-ci.org/webpack-contrib/compression-webpack-plugin.svg
[test-url]: http://travis-ci.org/webpack-contrib/compression-webpack-plugin

[cover]: https://codecov.io/gh/webpack-contrib/compression-webpack-plugin/branch/master/graph/badge.svg
[cover-url]: https://codecov.io/gh/webpack-contrib/compression-webpack-plugin

[chat]: https://img.shields.io/badge/gitter-webpack%2Fwebpack-brightgreen.svg
[chat-url]: https://gitter.im/webpack/webpack

