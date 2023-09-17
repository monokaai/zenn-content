---
title: "GitHub CLIでローカルと同名のリモートリポジトリをササっと作成"
emoji: "🙌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["githubcli"]
published: true
---

これまでGitHubのWEB UIでリポジトリを作るのが面倒だったので、[GitHub CLI](https://docs.github.com/ja/github-cli/github-cli/about-github-cli)を使ってみました。

# インストール
`brew install gh`で完了です。

```
% which gh
/opt/homebrew/bin/gh
```

# 認証

インストール後`gh auth login`を実行し、GitHubアカウントにログインします。

```
monokaai@MacBook-Air zenn-content % gh auth login
? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: 598A-0703 // ブラウザ上でコード入力
Press Enter to open github.com in your browser...
✓ Authentication complete.
- gh config set -h github.com git_protocol https
✓ Configured git protocol
✓ Logged in as monokaai
```

# ローカルリポジトリの初期化
ローカルのディレクトリに移動し、`git init`でリポジトリを初期化します（まだ行っていない場合）。

# ghコマンドでリモートリポジトリを作成
ローカルリポジトリにしたいディレクトリに移動して、ghコマンドで同名のリモートリポジトリを作成します。
```
$ cd my_local_repository
$ gh repo create --source $(git rev-parse --show-toplevel) --public // プライベートリポジトリの場合は--private
```

# ローカルの変更をプッシュ
いつも通りコミットして、リモートリポジトリにプッシュします。
```
git add .
git commit -m "Initial commit"
git push -u origin master
```
これで、ローカルのディレクトリがGitHubに新しいリモートリポジトリとしてプッシュされました。

# 参考リンク
[ローカルの Git リポジトリに対応するリモート GitHub リポジトリを作成するコマンド](https://terashim.com/posts/create-github-repo/)
[git rev-parseを使いこなす](https://qiita.com/karupanerura/items/721962bb7da3e34187e1)