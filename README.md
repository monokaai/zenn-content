# Zenn CLI

* [📘 How to use](https://zenn.dev/zenn/articles/zenn-cli-guide)

## インストール手順

- **前提**: Node.js 18+ がインストールされていること。
- 依存関係をインストール:

```bash
make install
```

初回セットアップ（`articles/` や `books/` ディレクトリ作成など）:

```bash
make init
```

## Makefile の使い方

- **記事を作成**:

```bash
make article SLUG=my-first TITLE="初めてのZenn" TYPE=tech
```

- **本を作成**:

```bash
make book SLUG=my-book TITLE="Zenn本のタイトル"
```

- **プレビューを起動**:

```bash
make preview
```

### ターゲット一覧

- **install**: 依存関係をインストール（`npm install`）。
- **init**: Zenn の初期化（`zenn init`）。
- **article**: 新規記事の作成（必須: `SLUG`, `TITLE`。任意: `TYPE=tech|idea`）。
- **book**: 新規本の作成（必須: `SLUG`, `TITLE`）。
- **preview**: プレビューサーバを起動（ブラウザを自動で開く）。

詳細は公式ガイドを参照してください: [Zenn CLI Guide](https://zenn.dev/zenn/articles/zenn-cli-guide)

記法についてはこちらの[公式記事](https://zenn.dev/zenn/articles/markdown-guide#%E3%83%A1%E3%83%83%E3%82%BB%E3%83%BC%E3%82%B8)が参考になります。
