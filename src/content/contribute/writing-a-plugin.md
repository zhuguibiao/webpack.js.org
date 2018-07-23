---
title: 编写一个插件
sort: 4
contributors:
  - tbroadley
  - iamakulov
  - byzyk
---

插件向第三方开发者提供了 webpack 引擎中完整的能力。使用阶段式的构建回调，开发者可以引入它们自己的行为到 webpack 构建流程中。创建插件比创建 loader 更加高级，因为你将需要理解一些 webpack 底层的内部特性来做相应的钩子，所以做好阅读一些源码的准备！

## 创建插件

`webpack` 插件由「具名 JavaScript class(named JavaScript class)」构成：

- 定义 `apply` 方法。
- 指定一个绑定到 webpack 自身的[事件钩子](/api/compiler-hooks/)。
- 使用 webpack 提供的 plugin API 操作构建结果。

```javascript
class MyExampleWebpackPlugin {
  // 定义 `apply` 方法
  apply(compiler) {
    // 指定要追加的事件钩子函数
    compiler.hooks.compile.tapAsync(
      'afterCompile',
      (compilation, callback) => {
        console.log('This is an example plugin!');
        console.log('Here’s the `compilation` object which represents a single build of assets:', compilation);

        // 使用 webpack 提供的 plugin API 操作构建结果
        compilation.addModule(/* ... */);

        callback();
      }
    );
  }
}
```

## 基本插件架构

插件是由「具有 `apply` 方法的 prototype 对象」所实例化出来的。这个 `apply` 方法在安装插件时，会被 webpack compiler 调用一次。`apply` 方法可以接收一个 webpack compiler 对象的引用，从而可以在回调函数中访问到 compiler 对象。一个简单的插件结构如下：

```javascript
class HelloWorldPlugin {
  constructor(options) {
    this.options = options;
  }

  apply(compiler) {
    compiler.hooks.done.tap('HelloWorldPlugin', () => {
      console.log('Hello World!');
      console.log(this.options);
    });
  }
}

module.exports = HelloWorldPlugin;
```

然后，要使用这个插件，在你的 webpack 配置的 `plugin` 数组中添加一个实例：

```javascript
// webpack.config.js
var HelloWorldPlugin = require('hello-world');

module.exports = {
  // ... 这里是其他配置 ...
  plugins: [
    new HelloWorldPlugin({setting: true})
  ]
};
```

## Compiler and Compilation

Among the two most important resources while developing plugins are the `compiler` and `compilation` objects. Understanding their roles is an important first step in extending the webpack engine.

- The `compiler` object represents the fully configured webpack environment. This object is built once upon starting webpack, and is configured with all operational settings including options, loaders, and plugins. When applying a plugin to the webpack environment, the plugin will receive a reference to this compiler. Use the compiler to access the main webpack environment.

- A `compilation` object represents a single build of versioned assets. While running webpack development middleware, a new compilation will be created each time a file change is detected, thus generating a new set of compiled assets. A compilation surfaces information about the present state of module resources, compiled assets, changed files, and watched dependencies. The compilation also provides many hooks at which a plugin can perform custom actions.

These two components are an integral part of any webpack plugin (especially a `compilation`), so developers will benefit by familiarizing themselves with these source files:

- [Compiler Source](https://github.com/webpack/webpack/blob/master/lib/Compiler.js)
- [Compilation Source](https://github.com/webpack/webpack/blob/master/lib/Compilation.js)

## 访问 compilation 对象

compiler 暴露一组钩子，提供对每个新的编译对象(compilation)的引用。反过来，编译对象(compilation)提供了额外的事件钩子函数，用于钩入到构建流程的很多步骤中。

```javascript
class HelloCompilationPlugin {
  apply(compiler) {
    // 置回调来访问 compilation 对象：
    compiler.hooks.compilation.tap('HelloCompilationPlugin', (compilation) => {
      // 现在，设置回调来访问 compilation 中的步骤：
      compilation.hooks.optimize.tap('HelloCompilationPlugin', () => {
        console.log('Hello compilation!');
      });
    });
  }
}

module.exports = HelloCompilationPlugin;
```

这里列出 `compiler`, `compilation` 和其他重要对象上可用钩子，请查看 [插件 API](/api/plugins/) 文档。

## 异步事件钩子

一些事件钩子是异步的。除了 `tap`，这里还有 `tapAsync` 和 `tapPromise` 方法。可以通过使用这些方法，来执行异步操作：

```javascript
class HelloAsyncPlugin {
  apply(compiler) {
    // tapAsync() 基于回调(callback-based)
    compiler.hooks.emit.tapAsync('HelloAsyncPlugin', function(compilation, callback) {
      setTimeout(function() {
        console.log('Done with async work...');
        callback();
      }, 1000);
    });

    // tapPromise() 基于 promise(promise-based)
    compiler.hooks.emit.tapPromise('HelloAsyncPlugin', (compilation) => {
      return doSomethingAsync()
        .then(() => {
          console.log('Done with async work...');
        });
    });

    // 原先基本的 tap() 也在这里列出：
    compiler.hooks.emit.tap('HelloAsyncPlugin', () => {
      // 这里没有异步任务
      console.log('Done with sync work...');
    });
  }
}

module.exports = HelloAsyncPlugin;
```

## 示例

一旦能我们深入理解 webpack compiler 和每个独立的 compilation，我们依赖 webpack 引擎将有无限多的事可以做。我们可以重新格式化已有的文件，创建衍生的文件，或者制作全新的生成文件。

让我们来写一个简单的示例插件，生成一个叫做 `filelist.md` 的新文件；文件内容是所有构建生成的文件的列表。这个插件大概像下面这样：

```javascript
class FileListPlugin {
  apply(compiler) {
    compiler.hooks.emit.tapAsync('FileListPlugin', (compilation, callback) => {
      // 在生成文件中，创建一个头部字符串：
      var filelist = 'In this build:\n\n';

      // 遍历所有编译过的资源文件，
      // 对于每个文件名称，都添加一行内容。
      for (var filename in compilation.assets) {
        filelist += ('- '+ filename +'\n');
      }

      // 将这个列表作为一个新的文件资源，插入到 webpack 构建中：
      compilation.assets['filelist.md'] = {
        source() {
          return filelist;
        },
        size() {
          return filelist.length;
        }
      };

      callback();
    });
  }
}

module.exports = FileListPlugin;
```

## 底层原理

在底层，webpack 使用 [Tapable](https://github.com/webpack/tapable) 创建和执行钩子。以下是运行原理：

```javascript
import { SyncHook, AsyncSeriesHook } from 'tapable';

class SomeWebpackInternalClass {
  constructor() {
    this.hooks = {
      // 创建钩子：
      compilation: new SyncHook(),
      run: new AsyncSeriesHook(),
    };
  }

  someMethod() {
    // 调用一个钩子：
    this.hooks.run.call();

    // 调用另外一个钩子：
    // （这是一个异步钩子，所以 webpack 会传递一个回调给这个钩子）
    this.hooks.run.callAsync(() => {
      // 在所有触碰函数(tap function)都结束执行时，调用回调函数
    });
  }
}
```

这里是多种类型的钩子，只是触碰函数(tap function)的执行方式略有不同。请在[Tapable 文档](https://github.com/webpack/tapable#hook-types) 中查看细节描述。
