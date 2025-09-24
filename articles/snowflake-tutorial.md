---
title: "Snowflakeに入門してみる①"
emoji: "❄️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["snowflake", "dwh", "data"]
published: true
---

職種がデータエンジニアに変わり、Snowflakeをガッツリ触ることになりそうです。
せっかくなので公式チュートリアルを主に自分用にまとめ直しつつ、自分なりの見解も添えてみました。
公式の引用がメインですが、重要なポイントをピックアップできた気もするのでかいつまんで眺めていただけたら嬉しいです。

https://docs.snowflake.com/ja/user-guide-getting-started

:::message
SQLを実行してデータ探索を行うような実践的チュートリアルになる予定だったのですが
思いの外ドキュメントの分量が多く、そこまで到達できませんでした。
そうした内容を期待されている方は次回の記事をお待ちください。
:::

## Snowflakeとは？

そもそもSnowflakeがどんなものか、ざっと調べた内容をまとめておきます。

- クラウドベースのSaaS型データウェアハウス（DWH）であり、ハードウェアやソフトウェアの導入・管理が不要
- 類似製品にAmazon Redshift、Google BigQuery、Azure Synapse Analyticsなどがある
- コンピュートリソースとストレージが分離
- 各クラスターはすべてのストレージにアクセスでき、それぞれを独立して拡張可能
- このアーキテクチャーにより、アクセスの競合を防ぎ、ストレージへのアクセスが統一されつつ（[シェアード・エブリシング方式](https://www.fujitsu.com/jp/products/software/resources/feature-stories/postgres/enterprisepostgres14sp1-scaleout-architecture/#chapter02-01)のメリットを得つつ）も、一方でノードの拡張を可能にする（[シェアード・ナッシング方式](https://www.fujitsu.com/jp/products/software/resources/feature-stories/postgres/enterprisepostgres14sp1-scaleout-architecture/#chapter02-02)の利点も併せ持つ）

## Snowflakeの優位性

以下のようなメリットが得られるようです。

- **高いスケーラビリティ**: [仮想ウェアハウス](https://docs.snowflake.com/ja/user-guide/warehouses)という計算リソース（クラスター）を追加したり、そのサイズや数を自動で増減させたりすることで、目的・組織に応じて負荷対策が可能
- **高速なパフォーマンス**: 各クラスターが並列処理を行い、負荷に応じて最適化される。また、複数の層でキャッシュを保持することで、即座に応答可能。[マイクロパーティショニング](https://docs.snowflake.com/ja/user-guide/tables-clustering-micropartitions)により、面倒なチューニングなしで検索が最適化される
- **柔軟なデータ管理**: 異なる組織間でデータを共有したり（Data Sharing）、地域間でデータを複製したり（Data Replication）できる。また、ゼロコピー・クローンやタイムトラベル機能により、データ管理の効率化と履歴からのデータ復旧が可能
- **従量課金**: ウェアハウスが稼働している時間のみ費用が発生する従量課金モデルのため、費用を抑えることができる
  - クラスターごとに消費リソースが最適化されている前提で、不要なコストも削減できそう

## [始める前に](https://docs.snowflake.com/ja/user-guide/setup)

早速、公式チュートリアルに沿って進めていきます。

### アクセス方法

- 【推奨】ブラウザベースのウェブインターフェイス [Snowsight](https://docs.snowflake.com/ja/user-guide/ui-snowsight)
  - [インターネットの使用](https://docs.snowflake.com/ja/user-guide/connecting#label-connecting-snowsight-internet)
  - [プライベート接続の使用](https://docs.snowflake.com/ja/user-guide/connecting#label-connecting-snowsight-private-connectivity)
  - [クイックツアー](https://docs.snowflake.com/ja/user-guide/ui-snowsight-quick-tour)でできることがざっくりわかる
- [SnowSQL](https://docs.snowflake.com/ja/user-guide/snowsql)、Snowflakeコマンドラインクライアント
- [Snowflake CLI](https://docs.snowflake.com/ja/developer-guide/snowflake-cli/index)、開発者中心のワークロードのためのコマンドラインクライアント
- Snowflakeコネクターとドライバー、およびサードパーティのクライアントサービスとアプリケーションを使用して開発されたアプリケーション

推奨されている[Snowsight](https://docs.snowflake.com/ja/user-guide/ui-snowsight)（ブラウザ利用）を試してみます。

### アカウント作成

[こちら](https://signup.snowflake.com/?utm_cta=trial-en-www-homepage-top-right-nav-ss-evg&amp;_ga=2.74406678.547897382.1657561304-1006975775.1656432605&amp;_gac=1.254279162.1656541671.Cj0KCQjw8O-VBhCpARIsACMvVLPE7vSFoPt6gqlowxPDlHT6waZ2_Kd3-4926XLVs0QvlzvTvIKg7pgaAqd2EALw_wcB)から無料トライアルに申し込めます。支払い方法の登録は不要です。個人情報の入力後、届いたメールに従ってアカウントを有効化します。
30日間無料かつ、400ドル分のクエリ実行などに使えるクレジットが貰えます（ありがたい…！）。
[料金プランページ](https://www.snowflake.com/ja/pricing-options/)を見る限り、マルチテナント環境を避けたい場合のみ、営業に問い合わせてのアカウント作成が必要なようです。

無事にアカウントが作成できたら、そのままSnowsightに遷移できました。この際に[アカウント識別子](https://docs.snowflake.com/ja/user-guide/admin-account-identifier)（以後、アカウントID）が与えられます。
次の要件で一意となるようです。

> アカウント識別子は、 [組織](https://docs.snowflake.com/ja/user-guide/organizations) 内だけでなく、Snowflakeがサポートする [クラウドプラットフォーム](https://docs.snowflake.com/ja/user-guide/intro-cloud-platforms) と [クラウドリージョン](https://docs.snowflake.com/ja/user-guide/intro-regions) のネットワーク全体で、Snowflakeアカウントを一意に識別します。
> 優先アカウント識別子は、アカウント _名_ の前に組織名（例: `myorg-account123` ）を付けたものです。Snowflakeが割り当てた _ロケーター_ をアカウント識別子として使用することもできますが、このレガシ形式の使用は 推奨されません 。

## [Snowsight クイックツアー](https://docs.snowflake.com/ja/user-guide/ui-snowsight-quick-tour)

詳細は見出しのリンク先にまとめられてますが、Snowsightでは次のようなことができます。

> Snowsight では、データ分析とエンジニアリングタスクの実行、クエリとデータロードおよび変換アクティビティのモニター、Snowflakeデータベースオブジェクトの探索、コストの管理、ユーザーとロールの追加などのSnowflakeデータベースの管理を実行できます。

:::message
「チャートとダッシュボードでクエリ結果を視覚化する」という記述もあり、DWHだけでなくBIダッシュボード機能まで集約されていることが改めてわかります。
:::
## [重要な概念およびアーキテクチャ](https://docs.snowflake.com/ja/user-guide/intro-key-concepts)

優位性の項で説明した部分もありますが、特に重要と感じた部分を書き出しておきます。

> Snowflakeのサービスのコンポーネントすべて（オプションのコマンドラインクライアント、ドライバー、コネクタを除く）は、パブリッククラウドインフラストラクチャで実行されます。

アカウント作成時に AWS・GCP・Azureのいずれかのクラウドプラットフォームを選択することからもわかるように、オンプレミスでの実行は前提とされていません。

:::message
[アカウントを跨いでのフェイルオーバーもできる](https://docs.snowflake.com/ja/user-guide/account-replication-intro)ようです。となると、アカウントAで選択したプラットフォーム（例えば AWS）で障害が発生した場合、即時にデータをアカウントBの他のプラットフォーム（例えばGCP）で利用するように切り替えてサービス運用を維持する、みたいなこともできそうです。
:::

### 独自アーキテクチャ

Snowflakeの独自のアーキテクチャは、従来の共有ディスク型とシェアードナッシング型のハイブリッドであり、以下の3つの主要な層で構成されています。

#### データベースストレージ

データがロードされると、Snowflakeが自動的に最適化、圧縮、列指向形式に変換し、クラウドストレージに保存します。ユーザーはこれらのデータに直接アクセスできず、SQLクエリを通じてのみ操作可能です。

#### クエリ処理

「仮想ウェアハウス」と呼ばれるMPPコンピューティングクラスターでクエリが実行されます。各仮想ウェアハウスは独立しているため、他のウェアハウスのパフォーマンスに影響を与えることはありません。

#### クラウドサービス

プラットフォーム全体の調整を行うサービス層です。認証、インフラ管理、メタデータ管理、クエリの最適化、アクセス制御といった主要な機能がこの層で処理されます。

### その他

ウェブUI、コマンドラインクライアント、各種ドライバーやコネクタなど、多様な方法でサービスに接続できるため、データの統合が容易になります。

## [サポート対象のクラウドプラットフォーム](https://docs.snowflake.com/ja/user-guide/intro-cloud-platforms)

3つのレイヤー（ストレージ、コンピューティング、およびクラウドサービス）のすべてが次のクラウドプラットフォームのいずれでもホストでき、リージョンの指定が必要となります。複数のSnowflakeアカウントを同一のクラウドプラットフォームにホストすることも、バラバラにホストすることも可能とのことです。
:::message alert
クラウドプラットフォームごとに一部の機能が利用できないという制限事項がありますので、注意が必要です。
:::

:::message
Snowflakeに限ったことではなく公式も述べていますが、異なるプラットフォーム・リージョン間でのデータ伝送は通信速度を遅らせる可能性があります。
:::

### データロード

- [Snowflake独自のステージを利用する](https://docs.snowflake.com/ja/guides-overview-loading-data)（ストレージではなく、ステージで合っています。イメージを掴むには[こちらの記事](https://blog.serverworks.co.jp/2025/07/07/155121)が参考になりました）
- S3、Google Cloud Storageなどプラットフォームのストレージを利用する

> 異なるプラットフォーム間でステージングされたファイルからデータをロードする場合、データ転送請求料金が適用される場合があります。詳細については、 [データ転送のコストについて](https://docs.snowflake.com/ja/user-guide/cost-understanding-data-transfer) をご参照ください。

### HITRUST CSF 証明

この証明は、規制順守とリスク管理におけるSnowflakeのセキュリティ体制を強化し、Business Critical（またはそれ以上）のSnowflakeエディションに適用されます。詳細については、 Snowflake セキュリティおよびトラストセンター をご覧ください。

## [サポートされているクラウドリージョン](https://docs.snowflake.com/ja/user-guide/intro-regions)

> nowflakeがサポートするすべての [クラウドプラットフォーム](https://docs.snowflake.com/ja/user-guide/intro-cloud-platforms) でリージョンをサポートしており、3つのグローバルな地理的セグメント（北米/南米、ヨーロッパ/中東、およびアジア太平洋/中国）にグループ化されています。

:::message
東京リージョンはAWS & Azure、大阪リージョンは AWSのみ[サポート対象となっています](https://docs.snowflake.com/ja/user-guide/intro-regions#asia-pacific-china)。
:::

![](/images/snowflake-tutorial/snowflake-regions.png)
*公式ドキュメントより*

:::message
[アカウントやリージョンを跨いでのデータレプリケーションも可能なよう](https://docs.snowflake.com/ja/user-guide/account-replication-intro)ですが、データ伝送速度に加えて他国の法律にも合致したデータが格納されているか、確認が必要ですね。
:::

## [エディション（プラン）](https://docs.snowflake.com/ja/user-guide/intro-editions)

料金プランです。必要に応じて[比較表](https://docs.snowflake.com/ja/user-guide/intro-editions#feature-edition-matrix)を確認するのが良いと思います。

### エディションの確認方法

> Snowsight：Admin » Accounts を選択します。
> SQL：SHOW ACCOUNTS コマンドを実行します。
>
> アカウントのエディションを変更する場合は、 Snowflakeサポート にお問い合わせください。

## [リリース](https://docs.snowflake.com/ja/user-guide/intro-releases)

ダウンタイムなしで透過的に更新されるとのことです 🙌 リリースノートは[こちら](https://docs.snowflake.com/ja/release-notes/new-features)です。
[毎週2つ](https://docs.snowflake.com/ja/user-guide/intro-releases#release-types-weekly)という頻度でリリースがあること、[段階的リリースが行われる](https://docs.snowflake.com/ja/user-guide/intro-releases#staged-release-process)こと、以下のタイミングで動作変更を含むリリースがされることは抑えておきたいです。

> 毎月（11月と12月を除く）、Snowflakeはその月における毎週の総合リリースの1つを選択して、動作の変更を導入します。動作変更のために選択される週次リリースは異なる場合がありますが、通常はその月の3回目または4回目のリリースです。

## [主な機能の概要](https://docs.snowflake.com/ja/user-guide/intro-supported-features)
多機能すぎて紹介しきれませんが、Snowflake独自っぽい観点や、特に気になった点だけ箇条書きにしておきます。

- [Icebergテーブル](https://docs.snowflake.com/ja/user-guide/tables-iceberg)
  - [Snowflake×Icebergを採用すべきか迷った時に読む記事](https://zenn.dev/dataheroes/articles/24009ab6970e48)が詳しいです
- [地理空間データのサポート](https://docs.snowflake.com/ja/sql-reference/data-types-geospatial)
- アカウントと一般的な管理、リソースとシステム使用状況のモニター、およびデータのクエリのための [Snowsight](https://docs.snowflake.com/ja/user-guide/ui-snowsight-quick-tour) 
- [SnowSQL （Pythonベースのコマンドラインクライアント）](https://docs.snowflake.com/ja/user-guide/snowsql)
- ウェアハウスの [作成、サイズ変更（ダウンタイムなし）、一時停止、およびドロップ](https://docs.snowflake.com/ja/user-guide/warehouses) を含む、 GUI またはコマンドラインからの仮想ウェアハウスの管理
- [Snowflake Extension for Visual Studio Code](https://docs.snowflake.com/ja/user-guide/vscode-ext) --- Snowflake Extension for Visual Studio Code をインストール、構成、および使用するための詳細な手順
- [StreamlitアプリをSnowflakeでネイティブに](https://docs.snowflake.com/ja/developer-guide/streamlit/about-streamlit) 実行し、機械学習やデータサイエンスのためのカスタムWebアプリを作成、共有できます
- [プロシージャおよびユーザー定義関数（UDFs）](https://docs.snowflake.com/ja/developer-guide/extensibility) を、いくつかのプログラミング言語のうちの1つでハンドラを使って開発することをサポート
- 他のSnowflakeアカウントとの、 [セキュリティで保護されたオブジェクトでのデータ共有](https://docs.snowflake.com/ja/guides-overview-sharing) と、 [セキュリティで保護されていないビューでのデータ共有](https://docs.snowflake.com/ja/guides-overview-sharing) の両方をサポート:
  - 消費する他のアカウントへのデータの提供
  - 他のアカウントから提供されたデータの利用
- [Snowflake Data Clean Rooms](https://docs.snowflake.com/ja/user-guide/cleanrooms/introduction) を使用する共同研究者が、プライバシー保護された環境でデータを共有することをサポート
- 異なる リージョン および クラウドプラットフォーム にある複数のSnowflakeアカウントにわたる 複製とフェールオーバー のサポート
  - Snowflakeアカウント間（同じ組織内）でオブジェクトを複製し、オブジェクトと格納されたデータの同期を維持します
  - ビジネス継続性と障害復旧のために、1つ以上のSnowflakeアカウントへのフェールオーバーを構成します

:::message
個人的に[ユーザー定義関数（UDF）をPythonで記述できる](https://docs.snowflake.com/ja/developer-guide/stored-procedures-vs-udfs#supported-handler-languages)=Pandasでも扱えるのは嬉しいポイントに感じます。[BigQueryはSQLかJavaScript限定](https://cloud.google.com/bigquery/docs/user-defined-functions?hl=ja)なので、表現の幅が広がりそうです。
:::

## [データライフサイクルの概要](https://docs.snowflake.com/ja/user-guide/data-lifecycle)

[COPY INTO](https://docs.snowflake.com/ja/sql-reference/sql/copy-into-table)と[CLONE](https://docs.snowflake.com/ja/sql-reference/sql/create-clone)はSnowflake独自の概念ですが、それ以外は特に変わったことはないと思います。[継続的なデータ保護](https://docs.snowflake.com/ja/user-guide/data-cdp)もAWS・GCP・Azureなどのクラウドプラットフォームと同様です。

![](/images/snowflake-tutorial/data-lifecycle.png)
*一般的なRDBMSのデータライフサイクルとほぼ同様*

## コンプライアンス対応の表明

[規制コンプライアンス](https://docs.snowflake.com/ja/user-guide/intro-compliance)のページにて、世界各国の要件を満たしている旨の記載がありました。

## おわりに
やっと長〜い概要・概念のセクションが終わりました。お疲れ様でした。
次回の記事では、より実践的な公式チュートリアルを触ってみる予定です。お楽しみに！