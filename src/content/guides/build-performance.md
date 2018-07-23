---
title: 构建性能
sort: 17
contributors:
  - sokra
  - tbroadley
  - byzyk
  - madhavarshney
---

本指南包含一些改进构建/编译性能的实用技巧。

---

## 常规

无论你正在 [development](/guides/development) 或构建 [production](/guides/production)，以下做法应该帮助到你达到最佳。


### 保持版本最新

使用最新的 webpack 版本。我们会经常进行性能优化。 webpack 的最新稳定版本是：

[![latest webpack version](https://img.shields.io/npm/v/webpack.svg?label=webpack&style=flat-square&maxAge=3600)](https://github.com/webpack/webpack/releases)

保持最新的 __Node.js__ 也能够保证性能。除此之外，保证你的包管理工具 (例如 `npm` 或者 `yarn` ) 为最新也能保证性能。较新的版本能够建立更高效的模块树以及提高解析速度。


### Loaders

将 loaders 应用于最少数的必要模块中。而不是:

```js
module.exports = {
  //...
  module: {
    rules: [
      {
        test: /\.js$/,
        loader: 'babel-loader'
      }
    ]
  }
};
```

使用 `include` 字段仅将 loader 模块应用在实际需要用其转换的位置中：

```js
module.exports = {
  //...
  module: {
    rules: [
      {
        test: /\.js$/,
        include: path.resolve(__dirname, 'src'),
        loader: 'babel-loader'
      }
    ]
  }
};
```


### Bootstrap

每个额外的 loader/plugin 都有启动时间。尽量少使用不同的工具。


### 解析

以下几步可以提供解析速度:

- 尽量减少 `resolve.modules`, `resolve.extensions`, `resolve.mainFiles`, `resolve.descriptionFiles` 中类目的数量，因为他们会增加文件系统调用的次数。
- 如果你不使用 symlinks ，可以设置 `resolve.symlinks: false` (例如 `npm link` 或者 `yarn link`).
- 如果你使用自定义解析 plugins ，并且没有指定 context 信息，可以设置 `resolve.cacheWithContext: false` 。


### Dlls

使用 `DllPlugin` 将更改不频繁的代码进行单独编译。这将改善引用程序的编译速度，即使它增加了构建过程的复杂性。


### Smaller = Faster

减少编译的整体大小，以提高构建性能。尽量保持 chunks 小巧。

- 使用 更少/更小 的库。
- 在多页面应用程序中使用 `CommonsChunkPlugin`。
- 在多页面应用程序中以 `async` 模式使用 `CommonsChunkPlugin ` 。
- 移除不使用的代码。
- 只编译你当前正在开发部分的代码。


### Worker Pool

`thread-loader` 可以将非常消耗资源的 loaders 转存到 worker pool 中。

W> 不要使用太多的 workers ，因为 Node.js 的 runtime 和 loader 有一定的启动开销。最小化 workers 和主进程间的模块传输。进程间通讯(IPC)是非常消耗资源的。


### 持久化缓存

使用 `cache-loader` 启用持久化缓存。使用 `package.json` 中的 `"postinstall"` 清除缓存目录。


### 自定义 plugins/loaders

这里不对它们配置的性能问题作过多赘述。

---


## Development

下面步骤对于 _development_ 特别有用。


### 增量编译

使用 webpack 的监听模式。不要使用其他工具来监听你的文件和调用 webpack 。在监听模式下构建会记录时间戳并将信息传递给编译让缓存失效。

在某些设置中，监听会回退到轮询模式。有许多监听文件会导致 CPU 大量负载。在这些情况下，你可以使用 `watchOptions.poll` 来增加轮询的间隔。


### 在内存中编译

以下几个实用工具通过在内存中进行代码的编译和资源的提供，但并不写入磁盘来提高性能:

- `webpack-dev-server`
- `webpack-hot-middleware`
- `webpack-dev-middleware`

### stats.toJson 加速

webpack 4 默认使用 `stats.toJson()` 输出大量数据。除非在增量步骤中做必要的统计，否则请避免获取 `stats` 对象的部分内容。`webpack-dev-server` 在 v3.1.3 以后的版本，包含一个重要的性能修复，即最小化每个增量构建步骤中，从 stats 对象获取的数据量。

### Devtool

需要注意的是不同的 `devtool` 的设置，会导致不同的性能差异。

- `"eval"` 具有最好的性能，但并不能帮助你转译代码。
- 如果你能接受稍差一些的 mapping 质量，可以使用 `cheap-source-map` 选项来提高性能
- 使用 `eval-source-map` 配置进行增量编译。

=> 在大多数情况下，`cheap-module-eval-source-map` 是最好的选择。


### 避免在生产环境下才会用到的工具

某些实用工具， plugins 和 loaders 都只能在构建生产环境时才有用。例如，在开发时使用 `UglifyJsPlugin` 来压缩和修改代码是没有意义的。以下这些工具在开发中通常被排除在外:

- `UglifyJsPlugin`
- `ExtractTextPlugin`
- `[hash]`/`[chunkhash]`
- `AggressiveSplittingPlugin`
- `AggressiveMergingPlugin`
- `ModuleConcatenationPlugin`


### 最小化入口 chunk

webpack 只会在文件系统中生成已经更新的 chunk 。对于某些配置选项(HMR, `[name]`/`[chunkhash]` in `output.chunkFilename`, `[hash]`)来说，除了更新的 chunks 无效之外，入口 chunk 也不会生效。

应当在生成入口 chunk 时，尽量减少入口 chunk 的体积，以提高性能。下述代码块将只提取包含 runtime 的 chunk ，_其他 chunk 都作为子模块_:

```js
new CommonsChunkPlugin({
  name: 'manifest',
  minChunks: Infinity
});
```

### 避免额外的优化步骤

webpack 通过执行额外的算法任务，来优化输出的体积和加载性能。这些优化适用于小心代码库，但是在大型代码库中却非常耗费性能：

```js
module.exports = {
  // ...
  optimization: {
    removeAvailableModules: false,
    removeEmptyChunks: false,
    splitChunks: false,
  }
};
```

### 输出文件不再携带路径信息

webpack 会在输出文件中生成路径信息。然而在打包数千个模块的项目中，会导致造成垃圾回收性能压力。在 `options.output.pathinfo` 设置中关闭：

```js
module.exports = {
  // ...
  output: {
    pathinfo: false
  }
};
```

### Node.js 版本

最新稳定版本的 Node.js 及其 ES2015 `Map` 和 `Set` 实现，出现一些 [性能回退](https://github.com/nodejs/node/issues/19769)。其修复版本已经合并到 master 分支，但是有些已经发布的正式版本无法应用到这些修复内容。同时，为了充分利用增量构建速度，请尝试使用 8.9.x 版本（8.9.10 - 9.11.1 之间的版本存在性能问题）。webpack 已经开始大量使用这些 ES2015 数据结构，因此选择这些版本也将改善初始构建时间。

### TypeScript loader

现在，`ts-loader` 已经开始使用 TypeScript 内置 watch mode API，可以明显减少每次迭代时重新构建的模块数量。`experimentalWatchApi` 与普通 TypeScript watch mode 共享同样的逻辑，并且在开发环境使用时非常稳定。此外开启 `transpileOnly`，用于真正快速增量构建。

```js
module.exports = {
  // ...
  test: /\.tsx?$/,
  use: [
    {
      loader: 'ts-loader',
      options: {
        transpileOnly: true,
        experimentalWatchApi: true,
      },
    },
  ],
};
```

注意：`ts-loader` 文档建议使用 `cache-loader`，但是这实际上会由于使用硬盘写入而减缓增量构建速度。

为了重新获得类型检查，请使用 [`ForkTsCheckerWebpackPlugin`](https://www.npmjs.com/package/fork-ts-checker-webpack-plugin)。

ts-loader 的 github 仓库中有一个 [完整示例](https://github.com/TypeStrong/ts-loader/tree/master/examples/fast-incremental-builds)

---


## Production

以下步骤在 _production_ 中非常有用。

W> __不要为了非常小的性能增益，牺牲你应用程序的质量！__ 请注意，优化代码质量在大多数情况下比构建性能更重要。


### 多个编译时

当进行多个编译时，以下工具可以帮助到你:

- [`parallel-webpack`](https://github.com/trivago/parallel-webpack): 它允许编译工作在 worker 池中进行。
- `cache-loader`: 缓存可以在多个编译时之间共享。


### Source Maps

Source maps 真的很消耗资源。你真的需要他们？

---


## 工具相关问题

下列工具存在某些可能会降低构建性能的问题。


### Babel

- 项目中的 preset/plugins 数量最小化。


### TypeScript

- 在单独的进程中使用 `fork-ts-checker-webpack-plugin` 进行类型检查。
- 配置 loaders 跳过类型检查。
- 使用 `ts-loader` 时，设置 `happyPackMode: true` / `transpileOnly: true`。


### Sass

- `node-sass` 中有个来自 Node.js 线程池的阻塞线程的 bug。 当使用 `thread-loader` 时，需要设置 `workerParallelJobs: 2`。
