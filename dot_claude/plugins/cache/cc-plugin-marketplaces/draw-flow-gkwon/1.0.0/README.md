# draw-flow-plugin

## 条件

- claude-codeのバージョン2.1以上。

## 準備

1. pluginで利用する方法
2. ローカルにダウンロードする方法

### 1. pluginで利用する方法

https://ghe.corp.yahoo.co.jp/myamate/cc-plugin-marketplace 参考

### 2. ローカルにダウンロードする方法

1. レポジトリをダウンロードする。
2. `skills/draw-flow-diagram` を`~/.claude/skills/`の配下におく

## 実際の利用のイメージ

1. claude-codeを起動する。
2. `/draw-flow-diagram-excellence <class-name> <method-name>`でフローを確認したい関数を指定する。(クラス名は省略できる)
3. intelliJのMermaidフラグインなどを利用して描画する


