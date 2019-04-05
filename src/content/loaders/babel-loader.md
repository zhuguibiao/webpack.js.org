---
title: babel-loader
source: https://raw.githubusercontent.com/babel/babel-loader/master/README.md
edit: https://github.com/babel/babel-loader/edit/master/README.md
repo: https://github.com/babel/babel-loader
---




此 package 允许你使用 [Babel](https://github.com/babel/babel) 和 [webpack](https://github.com/webpack/webpack) 转译 `JavaScript` 文件。

**注意**：请在 Babel [Issues](https://github.com/babel/babel/issues) tracker 上报告输出时遇到的问题。

## 安装

> webpack 4.x | babel-loader 8.x | babel 7.x

```bash
npm install -D babel-loader @babel/core @babel/preset-env webpack
```

## 用法

webpack 文档：[loaders](https://webpack.js.org/loaders/)

在 webpack 配置对象中，需要将 babel-loader 添加到 module 列表中，就像下面这样：

```javascript
module: {
  rules: [
    {
      test: /\.m?js$/,
      exclude: /(node_modules|bower_components)/,
      use: {
        loader: 'babel-loader',
        options: {
          presets: ['@babel/preset-env']
        }
      }
    }
  ]
}
```

## 选项

查看 `babel` [选项](https://babeljs.io/docs/en/options)。

你可以使用 [`options`](https://webpack.js.org/configuration/module/#rule-options-rule-query) 属性，来向 loader 传递 options 选项：

```javascript
module: {
  rules: [
    {
      test: /\.m?js$/,
      exclude: /(node_modules|bower_components)/,
      use: {
        loader: 'babel-loader',
        options: {
          presets: ['@babel/preset-env'],
          plugins: ['@babel/plugin-proposal-object-rest-spread']
        }
      }
    }
  ]
}
```

此 loader 也支持下面这些 loader 特有的选项：

* `cacheDirectory`：默认值为 `false`。当有设置时，指定的目录将用来缓存 loader 的执行结果。之后的 webpack 构建，将会尝试读取缓存，来避免在每次执行时，可能产生的、高性能消耗的 Babel 重新编译过程(recompilation process)。如果设置了一个空值 (`loader: 'babel-loader?cacheDirectory'`) 或者 `true` (`loader: 'babel-loader?cacheDirectory=true'`)，loader 将使用默认的缓存目录 `node_modules/.cache/babel-loader`，如果在任何根目录下都没有找到 `node_modules` 目录，将会降级回退到操作系统默认的临时文件目录。

* `cacheIdentifier`：默认是由 `@babel/core` 版本号，`babel-loader` 版本号，`.babelrc` 文件内容（存在的情况下），环境变量 `BABEL_ENV` 的值（没有时降级到 `NODE_ENV`）组成的一个字符串。可以设置为一个自定义的值，在 identifier 改变后，来强制缓存失效。

* `cacheCompression`: Default `true`. When set, each Babel transform output will be compressed with Gzip. If you want to opt-out of cache compression, set it to `false` -- your project may benefit from this if it transpiles thousands of files.

* `customize`: Default `null`. The path of a module that exports a `custom` callback [like the one that you'd pass to `.custom()`](#customized-loader). Since you already have to make a new file to use this, it is recommended that you instead use `.custom` to create a wrapper loader. Only use this is you _must_ continue using `babel-loader` directly, but still want to customize.

## 疑难解答

### babel-loader 很慢！

确保转译尽可能少的文件。你可能使用 `/\.m?js$/` 来匹配，这样也许会去转译 `node_modules` 目录或者其他不需要的源代码。

要排除 `node_modules`，参考文档中的 `loaders` 配置的 `exclude` 选项。

你也可以通过使用 `cacheDirectory` 选项，将 babel-loader 提速至少两倍。这会将转译的结果缓存到文件系统中。

### Babel 在每个文件都插入了辅助代码，使代码体积过大！

Babel 对一些公共方法使用了非常小的辅助代码，比如 `_extend`。默认情况下会被添加到每一个需要它的文件中

你可以引入 Babel runtime 作为一个独立模块，来避免重复引入。

下面的配置禁用了 Babel 自动对每个文件的 runtime 注入，而是引入 `@babel/plugin-transform-runtime` 并且使所有辅助代码从这里引用。

更多信息请查看 [文档](https://babeljs.io/docs/plugins/transform-runtime/)。

**注意**：你必须执行 `npm install -D @babel/plugin-transform-runtime` 来把它包含到你的项目中，然后使用 `npm install @babel/runtime` 把 `@babel/runtime` 安装为一个依赖。

```javascript
rules: [
  // 'transform-runtime' 插件告诉 Babel
  // 要引用 runtime 来代替注入。
  {
    test: /\.m?js$/,
    exclude: /(node_modules|bower_components)/,
    use: {
      loader: 'babel-loader',
      options: {
        presets: ['@babel/preset-env'],
        plugins: ['@babel/plugin-transform-runtime']
      }
    }
  }
]
```

#### **注意**：transform-runtime 和自定义 polyfills (例如 Promise library)

由于 [@babel/plugin-transform-runtime](https://github.com/babel/babel/tree/master/packages/babel-plugin-transform-runtime) 包含了一个 polyfill，含有自定义的 [regenerator-runtime](https://github.com/facebook/regenerator/blob/master/packages/regenerator-runtime/runtime.js) 和 [core-js](https://github.com/zloirock/core-js), 下面使用 `webpack.ProvidePlugin` 来配置 shimming 的常用方法将没有作用：

```javascript
// ...
        new webpack.ProvidePlugin({
            'Promise': 'bluebird'
        }),
// ...
```

下面这样的写法也没有作用：

```javascript
require('@babel/runtime/core-js/promise').default = require('bluebird');

var promise = new Promise;
```

它其实会生成下面这样 (使用了 `runtime` 后)：

```javascript
'use strict';

var _Promise = require('@babel/runtime/core-js/promise')['default'];

require('@babel/runtime/core-js/promise')['default'] = require('bluebird');

var promise = new _Promise();
```

前面的 `Promise` library 在被覆盖前已经被引用和使用了。

一种可行的办法是，在你的应用程序中加入一个“引导(bootstrap)”步骤，在应用程序开始前先覆盖默认的全局变量。

```javascript
// bootstrap.js

require('@babel/runtime/core-js/promise').default = require('bluebird');

// ...

require('./app');
```

### `babel` 的 Node.js API 已经被移到 `babel-core` 中。（The Node.js API for `babel` has been moved to `babel-core`.）

如果你收到这个信息，这说明你有一个已经安装的 `babel` npm package，并且在 webpack 配置中使用 loader 简写方式（在 webpack 2.x 版本中将不再支持这种方式）。
```javascript
  {
    test: /\.m?js$/,
    loader: 'babel',
  }
```

webpack 将尝试读取 `babel` package 而不是 `babel-loader`。

想要修复这个问题，你需要卸载 `babel` npm package，因为它在 Babel v6 中已经被废除。（安装 `@babel/cli` 或者 `@babel/core` 来替代它）
在另一种场景中，如果你的依赖于 `babel` 而无法删除它，可以在 webpack 配置中使用完整的 loader 名称来解决：
```javascript
  {
    test: /\.m?js$/,
    loader: 'babel-loader',
  }
```

## Customized Loader

`babel-loader` exposes a loader-builder utility that allows users to add custom handling
of Babel's configuration for each file that it processes.

`.custom` accepts a callback that will be called with the loader's instance of
`babel` so that tooling can ensure that it using exactly the same `@babel/core`
instance as the loader itself.

In cases where you want to customize without actually having a file to call `.custom`, you
may also pass the `customize` option with a string pointing at a file that exports
your `custom` callback function.

### Example

```js
// Export from "./my-custom-loader.js" or whatever you want.
module.exports = require("babel-loader").custom(babel => {
  function myPlugin() {
    return {
      visitor: {},
    };
  }

  return {
    // Passed the loader options.
    customOptions({ opt1, opt2, ...loader }) {
      return {
        // Pull out any custom options that the loader might have.
        custom: { opt1, opt2 },

        // Pass the options back with the two custom options removed.
        loader,
      };
    },

    // Passed Babel's 'PartialConfig' object.
    config(cfg) {
      if (cfg.hasFilesystemConfig()) {
        // Use the normal config
        return cfg.options;
      }

      return {
        ...cfg.options,
        plugins: [
          ...(cfg.options.plugins || []),

          // Include a custom plugin in the options.
          myPlugin,
        ],
      };
    },

    result(result) {
      return {
        ...result,
        code: result.code + "\n// Generated by some custom loader",
      };
    },
  };
});
```

```js
// And in your Webpack config
module.exports = {
  // ..
  module: {
    rules: [{
      // ...
      loader: path.join(__dirname, 'my-custom-loader.js'),
      // ...
    }]
  }
};
```

### `customOptions(options: Object): { custom: Object, loader: Object }`

Given the loader's options, split custom options out of `babel-loader`'s
options.


### `config(cfg: PartialConfig): Object`

Given Babel's `PartialConfig` object, return the `options` object that should
be passed to `babel.transform`.


### `result(result: Result): Result`

Given Babel's result object, allow loaders to make additional tweaks to it.


## License
[MIT](https://couto.mit-license.org/)
