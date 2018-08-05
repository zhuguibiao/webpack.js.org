---
title: file-loader
source: https://raw.githubusercontent.com/webpack-contrib/file-loader/master/README.md
edit: https://github.com/webpack-contrib/file-loader/edit/master/README.md
repo: https://github.com/webpack-contrib/file-loader
---


[![npm][npm]][npm-url]
[![node][node]][node-url]
[![deps][deps]][deps-url]
[![tests][tests]][tests-url]
[![chat][chat]][chat-url]



处理文件模块的 webpack loader。

## 要求

此模块需要 Node v6.9.0+，运行于 webpack v3 和 webpack v4。

## 起步

你需要预先安装 `file-loader`：

```console
$ npm install file-loader --save-dev
```

在一个 bundle 文件中 import（或 `require`）目标文件：

```js
// bundle 文件
import img from './file.png'
```

然后，在 `webpack` 配置中添加 loader。例如：

```js
// webpack.config.js
module.exports = {
  module: {
    rules: [
      {
        test: /\.(png|jpg|gif)$/,
        use: [
          {
            loader: 'file-loader',
            options: {}
          }
        ]
      }
    ]
  }
}
```

然后，通过你偏爱的方式去运行 `webpack`。将 `file.png` 作为一个文件，生成到输出目录，
（如果指定了选项，则使用指定的命名约定）
并返回文件的 public URI。

_注意：默认情况下，生成文件的文件名，是文件内容的 MD5 哈希值，
并会保留所引用资源的原始扩展名。_

## 选项

### `context`

类型：`String`
默认：[`context`](https://webpack.js.org/configuration/entry-context/#context)

指定自定义文件 context。

```js
// webpack.config.js
...
{
  loader: 'file-loader',
  options: {
    name: '[path][name].[ext]',
    context: ''
  }
}
...
```

### `emitFile`

类型：`Boolean`
默认：`true`

如果是 true，生成一个文件（向文件系统写入一个文件）。
如果是 false，loader 会返回 public URI，但_不会_生成文件。
对于服务器端 package，禁用此选项通常很有用。

```js
// bundle file
import img from './file.png'
```

```js
// webpack.config.js
...
{
  loader: 'file-loader',
  options: {
    emitFile: false
  }
}
...
```

### `name`

类型：`String|Function`
默认：`'[hash].[ext]'`

Specifies a custom filename template for the target file(s) using the query
parameter `name`. For example, to copy a file from your `context` directory into
the output directory retaining the full directory structure, you might use:

```js
// webpack.config.js
{
  loader: 'file-loader',
  options: {
    name: '[path][name].[ext]'
  }
}
```

或者，使用一个 `Function`:

```js
// webpack.config.js
...
{
  loader: 'file-loader',
  options: {
    name (file) {
      if (env === 'development') {
        return '[path][name].[ext]'
      }

      return '[hash].[ext]'
    }
  }
}
...
```

_注意：默认情况下，文件会按照你指定的路径和名称输出同一目录中，
且会使用相同的 URI 路径来访问文件。_

### `outputPath`

类型：`String|Function`
默认：`undefined`

Specify a filesystem path where target the file(s) will be placed.

```js
// webpack.config.js
...
{
  loader: 'file-loader',
  options: {
    name: '[path][name].[ext]',
    outputPath: 'images/'
  }
}
...
```

### `publicPath`

类型：`String|Function`
默认：[`__webpack_public_path__`](https://webpack.js.org/api/module-variables/#__webpack_public_path__-webpack-specific-)

Specifies a custom public path for the target file(s).

```js
// webpack.config.js
...
{
  loader: 'file-loader',
  options: {
    name: '[path][name].[ext]',
    publicPath: 'assets/'
  }
}
...
```

### `regExp`

类型：`RegExp`
默认：`undefined`

Specifies a Regular Expression to one or many parts of the target file path.
The capture groups can be reused in the `name` property using `[N]`
[placeholder](https://github.com/webpack-contrib/file-loader#placeholders).

```js
import img from './customer01/file.png'
```

**webpack.config.js**
```js
{
  loader: 'file-loader',
  options: {
    regExp: /\/([a-z0-9]+)\/[a-z0-9]+\.png$/,
    name: '[1]-[name].[ext]'
  }
}
```

_Note: If `[0]` is used, it will be replaced by the entire tested string,
whereas `[1]` will contain the first capturing parenthesis of your regex and so
on..._

### `useRelativePath`

类型：`Boolean`
默认：`false`

指定是否为每个目标文件 context，生成一个相对 URI。

```js
// webpack.config.js
{
  loader: 'file-loader',
  options: {
    useRelativePath: process.env.NODE_ENV === "production"
  }
}
```

## placeholders

### `[ext]`

类型：`String`
默认：`file.extname`

目标文件/资源的文件扩展名。

### `[hash]`

类型：`String`
默认：`'md5'`

指定生成文件内容哈希值的哈希方法。
查看下面的 [Hashes](https://github.com/webpack-contrib/file-loader#hashes)。

### `[N]`

类型：`String`
默认：`undefined`

当前文件名按照查询参数 regExp 匹配后，获得到第 N 个匹配结果

### `[name]`

类型：`String`
默认：`file.basename`

文件/资源的基本名称。

### `[path]`

类型：`String`
默认：`file.dirname`

资源相对于 webpack/config context 的路径。

## Hashes

Custom hashes can be used by specifying a hash with the following format:
 `[<hashType>:hash:<digestType>:<length>]`.

### `digestType`

类型：`String`
默认：`'hex'`

The [digest](https://en.wikipedia.org/wiki/Cryptographic_hash_function) that the
hash function should use. Valid values include: base26, base32, base36,
base49, base52, base58, base62, base64, and hex.

### `hashType`

类型：`String`
默认：`'md5'`

The type of hash that the has function should use. Valid values include: md5,
sha1, sha256, and sha512.

### `length`

类型：`Number`
默认：`9999`

Users may also specify a length for the computed hash.

## Examples

The following examples show how one might use `file-loader` and what the result
would be.

```js
// bundle file
import png from 'image.png'
```

```js
// webpack.config.js
{
  loader: 'file-loader',
  options: {
    name: 'dirname/[hash].[ext]'
  }
}
```

```bash
# result
dirname/0dcbbaa701328ae351f.png
```

---

```js
// webpack.config.js
{
  loader: 'file-loader',
  options: {
    name: '[sha512:hash:base64:7].[ext]'
  }
}
```

```bash
# result
gdyb21L.png
```

---

```js
// bundle file
import png from 'path/to/file.png'
```

```js
// webpack.config.js
{
  loader: 'file-loader',
  options: {
    name: '[path][name].[ext]?[hash]'
  }
}
```

```bash
# result
path/to/file.png?e43b20c069c4a01867c31e98cbce33c9
```

## 贡献

如果你从未阅读过我们的贡献指南，请在上面花点时间。

#### [贡献指南](https://raw.githubusercontent.com/webpack-contrib/file-loader/master/.github/CONTRIBUTING)

## License

#### [MIT](https://raw.githubusercontent.com/webpack-contrib/file-loader/master/LICENSE)

[npm]: https://img.shields.io/npm/v/file-loader.svg
[npm-url]: https://npmjs.com/package/file-loader

[node]: https://img.shields.io/node/v/file-loader.svg
[node-url]: https://nodejs.org

[deps]: https://david-dm.org/webpack-contrib/file-loader.svg
[deps-url]: https://david-dm.org/webpack-contrib/file-loader

[tests]: 	https://img.shields.io/circleci/project/github/webpack-contrib/file-loader.svg
[tests-url]: https://circleci.com/gh/webpack-contrib/file-loader

[cover]: https://codecov.io/gh/webpack-contrib/file-loader/branch/master/graph/badge.svg
[cover-url]: https://codecov.io/gh/webpack-contrib/file-loader

[chat]: https://img.shields.io/badge/gitter-webpack%2Fwebpack-brightgreen.svg
[chat-url]: https://gitter.im/webpack/webpack
