---
title: 优化(optimization)
sort: 8
contributors:
  - EugeneHlushko
  - jeremenichelli
  - simon04
  - byzyk
  - madhavarshney
related:
  - title: 'webpack 4: Code Splitting, chunk graph and the splitChunks optimization'
    url: https://medium.com/webpack/webpack-4-code-splitting-chunk-graph-and-the-splitchunks-optimization-be739a861366
---

从 webpack 4 开始，会根据你选择的 `mode` 来执行不同的优化，不过所有的优化还是可以手动配置和重写。


## `optimization.minimize`

`boolean`

告知 webpack 使用 [UglifyjsWebpackPlugin](/plugins/uglifyjs-webpack-plugin/) 压缩 bundle。

`production` 模式下，这里默认是 `true`。

__webpack.config.js__


```js
module.exports = {
  //...
  optimization: {
    minimize: false
  }
};
```

T> 了解 [mode](/concepts/mode/) 工作机制。

## `optimization.minimizer`

`UglifyjsWebpackPlugin | [UglifyjsWebpackPlugin]`

允许你通过提供一个或多个定制过的 [UglifyjsWebpackPlugin](/plugins/uglifyjs-webpack-plugin/) 实例，覆盖默认压缩工具(minimizer)。

__webpack.config.js__


```js
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
  //...
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ /* your config */ })
    ]
  }
};
```

## `optimization.splitChunks`

`object`

对于动态导入模块，默认使用 webpack v4+ 提供的全新的通用分块策略(common chunk strategy)。请在 [SplitChunksPlugin](/plugins/split-chunks-plugin/) 页面中查看配置其行为的可用选项。

## `optimization.runtimeChunk`

`object` `string` `boolean`

将 `optimization.runtimeChunk` 设置为 `true`，会为每个仅含有 runtime 的入口起点，添加一个额外 chunk。
也可以设置为一个字符串值，来使用插件预设模式(preset mode)：

- `single`：创建一个 runtime 文件，来共享所有生成的 chunk。
- `multiple`：将 common chunks 创建为多个 runtime 文件。

通过将 `optimization.runtimeChunk` 设置为 `object`，对象中可以设置只有 `name` 属性，其中属性值可以是名称或者返回名称的函数，用于为 runtime chunks 命名。

默认值是 `false`：每个入口 chunk 中直接嵌入 runtime。

W> 对于每个 runtime chunk，导入的模块会被分别初始化，因此如果你在同一个页面中引用多个入口起点，请注意此行为。你或许应该将其设置为 `single`，或者使用其他只有一个 runtime 实例的配置。

__webpack.config.js__


```js
module.exports = {
  //...
  optimization: {
    runtimeChunk: {
      name: entrypoint => `runtimechunk~${entrypoint.name}`
    }
  }
};
```

## `optimization.noEmitOnErrors`

`boolean`

在编译出错时，使用 `optimization.noEmitOnErrors` 来跳过生成阶段(emitting phase)。这可以确保没有生成出错误资源。而 stats 中所有 assets 中的 `emitted` 标记都是 `false`。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    noEmitOnErrors: true
  }
};
```

W> 如果你正在使用 webpack [CLI](/api/cli/)，在此插件开启时，webpack 处理过程不会因为错误代码而退出。如果你希望在使用 CLI 时 webpack "失败(fail)"，请查看 [`bail` 选项](/api/cli/#advanced-options)。

## `optimization.namedModules`

`boolean: false`

告知 webpack 使用可读取模块标识符(readable module identifiers)，来帮助更好地调试。webpack 配置中如果没有设置此选项，默认会在 [mode](/concepts/mode/) `development` 启用，在 [mode](/concepts/mode/) `production` 禁用。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    namedModules: true
  }
};
```

## `optimization.namedChunks`

`boolean: false`

告知 webpack 使用可读取 chunk 标识符(readable chunk identifiers)，来帮助更好地调试。webpack 配置中如果没有设置此选项，默认会在 [mode](/concepts/mode/) `development` 启用，在 [mode](/concepts/mode/) `production` 禁用。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    namedChunks: true
  }
};
```

## `optimization.nodeEnv`

`string` `bool: false`

告知 webpack 将 `process.env.NODE_ENV` 设置为一个给定字符串。如果 `optimization.nodeEnv` 不是 `false`，则会使用 [DefinePlugin](/plugins/define-plugin/)，`optimization.nodeEnv` __默认值__取决于 [mode](/concepts/mode/)，如果为 falsy 值，则会回退到 `"production"`。

可能的值有：

- 任何字符串：用于设置 `process.env.NODE_ENV` 的值。
- false：不修改/设置 `process.env.NODE_ENV`的值。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    nodeEnv: 'production'
  }
};
```

## `optimization.mangleWasmImports`

`bool: false`

在设置为 `true` 时，告知 webpack 通过将导入修改为更短的字符串，来减少 WASM 大小。这会破坏模块和导出名称。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    mangleWasmImports: true
  }
};
```

## `optimization.removeAvailableModules`

`bool: true`

如果模块已经包含在所有父级模块中，告知 webpack 从 chunk 中检测出这些模块，或移除这些模块。将 `optimization.removeAvailableModules` 设置为 `false` 以禁用这项优化。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    removeAvailableModules: false
  }
};
```

## `optimization.removeEmptyChunks`

`bool: true`

如果 chunk 为空，告知 webpack 检测或移除这些 chunk。将 `optimization.removeEmptyChunks` 设置为 `false` 以禁用这项优化。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    removeEmptyChunks: false
  }
};
```

## `optimization.mergeDuplicateChunks`

`bool: true`

告知 webpack 合并含有相同模块的 chunk。将 `optimization.mergeDuplicateChunks` 设置为 `false` 以禁用这项优化。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    mergeDuplicateChunks: false
  }
};
```

## `optimization.flagIncludedChunks`

`bool`

告知 webpack 确定和标记出作为其他 chunk 子集的那些 chunk，其方式是在已经加载过较大的 chunk 之后，就不再去加载这些 chunk 子集。`optimization.flagIncludedChunks` 默认会在 `production` [mode](/concepts/mode/) 中启用，其他情况禁用。

__webpack.config.js__

```js
module.exports = {
  //...
  optimization: {
    flagIncludedChunks: true
  }
};
```
