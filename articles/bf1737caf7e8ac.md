---
title: "RDS→BigQuery を連携する DWH を構築した時の話"
emoji: "🛠️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["データ分析", "DWH", "RDS", "Glue", "BigQuery"]
published: false
publication_name: sun_asterisk
---

:::message
今日の記事は [Sun\* Advent Calendar 2024](https://adventar.org/calendars/10035) 13 日目です！
:::

# はじめに

こんにちは！
2024 年 4 月から Sun\*でバックエンドエンジニアとして働いている[monokaai](https://github.com/monokaai)こと鈴木康輔です。
入社から早くも半年が経ってしまいました（もう年末だなんて信じられません。。）

Sun\*では、モバイルヘルスケアアプリ開発のプロジェクトに参画してサーバーサイド（主に NestJS）を担当しています。
このプロジェクトでは会員数の増加に伴い、DB データの利活用を促進する目的でデータウェアハウス（以下、DWH）を構築したいという要望がありました。
DWH 構築は初めての経験だったので、要件定義や技術選定で考えたことを中心にまとめます。

# 背景

私自身の簡単な自己紹介と、私が DWH を構築するプロジェクトに関わることになった背景を簡単に説明します。

私は、元々 Python をメイン言語としており、レコメンド施策・分析業務にも 1 年ほど携わっていた時期がありました。このため、データ利活用するために必要なポイントを経験から整理できると期待され、声がかかりました。

ただし、インフラ構築の経験はほぼ無く、本プロジェクトの参画中に Terraform で軽微な修正を担当していた程度で、DWH のインフラ構成の良し悪しを判断できるような経験はありませんでした。

しかしながら、データ分析の業務経験があるメンバーが他にいなかったのもあり、最終的にデータ利活用に向けての DWH に格納するデータの整理など要件定義から関わることになりました。

# 要件

クライアントの主な要件は以下でした。

- 個人情報保護の観点で、データのマスキングは必須（ユーザー名の除去、誕生日を年代に変換するなど）
- 社内の別プロジェクトでも DWH を構築しており、その構成に寄せて元 DB→S3→DWH という構成にして欲しい
  - 別プロジェクトからは S3 上のデータを閲覧してもらう前提があった
  - S3 に格納される時点でデータマスキングが実施されている必要がある
- アプリ DB だけでなく、それ以外のデータ連携にも追加対応しやすい構成にしてほしい（当然ですね）

S3 上のデータを別プロジェクトの方に閲覧してもらうという要件は当初のものになります。
データの移行が完了した現在では、DWH 内に設定したグループ単位にデータ閲覧可能な範囲を設定するようにガバナンスが進んでおり、最終的には別プロジェクトの方々も 直接 DWH へ（許可された部分にだけ）アクセスできる形になりそうです。

また前提として RDS for MySQL および DynamoDB をアプリ DB として利用しており、リードレプリカ上でのデータ分析は DWH 構築以前から行っていました。
アプリからもリードレプリカを利用するのでアクセス集中を避けつつ、エンジニア以外の方でも分析しやすい環境が欲しいというモチベーションもありました。

# 技術選定

最初に考えるのはどのサービスにデータを入れるかだと思います。
AWS には[RedShift](https://aws.amazon.com/jp/redshift/)や[Athena](https://aws.amazon.com/jp/athena/)がありますし、Google Cloud だと[BigQuery](https://cloud.google.com/bigquery?hl=ja)になるでしょう。

アプリインフラが AWS 上に構築されていたので、RedShift や Athena の検討もしましたが、後述の理由により最終的に BigQuery を選定しました。
決め手としては、私含めて利用経験者が数名いたことと、他の案やコストなど総合して、デメリットが相対的に少なかったことです。
また作成した SQL クエリの保存・共有もでき、テーブル単位での権限設定などデータガバナンスの設定もしやすい点も嬉しいです。

## 最終構成

採用したインフラ構成・処理フローは以下です！かなりシンプルですね。

```mermaid
graph TD
    A[RDS for MySQL] -->|Job定期実行・データ取得| B[Glue ジョブ]
    B -->|データマスキング・保存| C[S3]
    C -->|データ転送| D[BigQuery Data Transfer]
    D -->|データ格納・分析|E[BigQuery]

```

この構成のメリット ⭕️・デメリット ❌ は次の通りです。

- ⭕️ 要件にマッチする中では最もシンプルな構成。[BigQuery Data Transfer の利用料金は無料](https://cloud.google.com/bigquery-transfer/pricing?hl=ja)なので、Glue を実行した時間と S3、BigQuery のみで構築・運用が行えコストも低く抑えられる
- ❌ Glue によるデータ抽出は元 DB のスキーマ変更を検知しないので、変更時には手動でジョブスクリプトも修正してやる必要がある

採用はしませんでしたが、以下のような案もありましたので同様にメリット・デメリットを並べておきます。

- [Datastream for BigQuery](https://cloud.google.com/datastream-for-bigquery?hl=ja)を使う
  - ⭕️ ニアリアルタイム更新が可能かつオートスケーリングで設定も非常に簡単そう。スキーマ変更にも追従してくれる上、マスキングの設定も可能
  - ❌ **今回は S3 を経由する要件にマッチしませんでしたが、この制限がなければ工数も圧倒的に短くなりそうだったので採用したと思います。**（[データがかなり大規模になるとつらみも出てくるようです](https://zenn.dev/wed_engineering/articles/97508aead20a12#%E9%81%8B%E7%94%A8%E3%82%92%E3%81%97%E3%81%A6%E3%81%BF%E3%81%A6%E3%81%AE%E3%83%9D%E3%82%A4%E3%83%B3%E3%83%88%E3%82%84%E8%BE%9B%E3%81%84%E3%81%A8%E3%81%93%E3%82%8D)）
- AWS Batch + ECS on Fargate でデータ取得・整形を行う
  - ⭕️ DWH 以外の処理も実行したくなった時に任せるためのサーバーを追加できる（Lambda を ECS に置換する話もあったため）
  - ❌ データ分析単体の要件としては構成が複雑になりすぎる
- 分析ツールに Amazon Athena や Redshift Spectrum を使う
  - ⭕️ Google Cloud へのデータ転送が不要で、AWS 側のデータ分析用サービスで完結できる
  - ❌ Athena だとデータガバナンスを単体で定義できず[Lake Formation](https://aws.amazon.com/jp/lake-formation/)が必要そうで、DB 以外のデータとの連携も面倒になりそう。Redshift(Spectrum)はより柔軟だが、クラスタ管理が必要でコストも高くなる懸念あり

## 苦労した点

- データ抽出に利用する Glue を初めて使ったこと（Glue 自体の解説はここでは省きますが、[AWS Glue 入門（１章 データ基盤と Glue の概要）](https://qiita.com/Mikoto_Hashimoto/items/35b2de805af855b17b6d)がわかりやすく、助けられました！）
  :::details RDS からデータ取得・整形して S3 に Parquet 形式でエクスポートするサンプルコード

  ```
  import sys
  from datetime import date
  from typing import Dict, Optional, Union

  import boto3
  from awsglue.context import GlueContext
  from awsglue.job import Job
  from awsglue.utils import getResolvedOptions
  from pyspark.context import SparkContext
  from pyspark.sql import DataFrame, SparkSession
  from pyspark.sql.functions import col, udf
  from pyspark.sql.types import StringType

  # 環境変数の取得
  args: Dict[str, str] = getResolvedOptions( # Glue ジョブ内で利用したい環境変数を指定
  sys.argv,
  ["JOB_NAME", "env", "region", "output_bucket_name", "connection_name"],
  )
  env: str = args["env"] if "env" in args else "local"
  region_name: str = args["region"] if "region" in args else "ap-northeast-1"
  output_bucket_name: str = args["output_bucket_name"]
  connection_name: str = args["connection_name"]

  # コンテキストやセッションの初期化
  glueContext: GlueContext = GlueContext(SparkContext.getOrCreate())
  spark: SparkSession = glueContext.spark_session

  # Glue データカタログから接続情報を取得
  glue_client = boto3.client("glue")
  connection = glue_client.get_connection(Name=connection_name)
  connection_properties = connection["Connection"]["ConnectionProperties"]
  jdbc_url = connection_properties["JDBC_CONNECTION_URL"]
  db_user = connection_properties["USERNAME"]
  db_pass = connection_properties["PASSWORD"]
  db_name = jdbc_url.split("/")[-1]

  # ジョブの開始
  job = Job(glueContext)
  job.init(args["JOB_NAME"], args)

  # テーブル一覧を PySpark の DataFrame として取得し、リストに変換
  jdbc_url += "?characterEncoding=utf8&useSSL=true&&rewriteBatchedStatements=true"
  properties: Dict[str, str] = {
  "user": db_user,
  "password": db_pass,
  "driver": "com.mysql.cj.jdbc.Driver",
  }

  query = f"(SELECT \* FROM information_schema.tables WHERE table_schema = '{db_name}') AS tables"
  tables_df: DataFrame = spark.read.jdbc(url=jdbc_url, table=query, properties=properties)
  table_names = tables_df.select("table_name").rdd.flatMap(lambda x: x).collect()
  print("Table_names", table_names)

  def get_age_group(target_col: Optional[Union[date, str]]) -> str:
  """誕生日を元に年代を取得する関数"""
      pass

  def mask_and_export(
  spark: SparkSession, table: str, jdbc_url: str, properties: Dict[str, str]
  ) -> None:
  df: DataFrame = spark.read.jdbc(url=jdbc_url, table=table, properties=properties)
      # マスキング処理
      if table == "users":
          df = df.withColumn("age_groups", age_decade_udf(col("birthday")))
          df = df.drop("name", "birthday")

      # Parquet形式でエクスポート
      output_path = f"s3://{output_bucket_name}/{table}"
      df.write.mode("overwrite").format("parquet").save(output_path)

  age_decade_udf = udf(get_age_group, StringType())

  # テーブルごとに S3 へデータをエクスポート
  for table in table_names:
  mask_and_export(spark, table, jdbc_url, properties)

  # ジョブの完了
  job.commit()
  ```

  :::

  - [ローカル開発環境の構築](https://docs.aws.amazon.com/ja_jp/glue/latest/dg/aws-glue-programming-etl-libraries.html)の導入がスムーズにいかず、AWS コンソール上での開発がメインになってしまった
  - 並列処理が可能な PySpark 環境でジョブを動かしたが、Pandas の DataFrame と記法が異なり慣れない
  - 上記の組み合わせでデバッグ工数が大きくなってしまった…

- [クロスアカウントアクセス](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html)が発生したこともあり、IAM ロールのアクセス権限管理に少し悩んだ

# おわりに

最後まで記事をお読みいただき、ありがとうございました！少しでもお役に立てば嬉しいです。
明日は Tamaki Masanori さんによるプロジェクトマネジメントについてのお話しです。
お楽しみに！
