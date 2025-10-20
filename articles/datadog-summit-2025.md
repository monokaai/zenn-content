---
title: "Datadog SUMMIT 2025参加レポ"
emoji: "👏"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["datadog", "データエンジニアリング", "データ活用"]
published: false
publication_name: spectee
---

## はじめに

こんにちは！今月からSpecteeでデータエンジニアとして勤務している鈴木です。
入社早々に、2025/10/16の[Datadog Summit Tokyo 2025](https://events.datadoghq.com/ja/summits/datadog-summit-tokyo/) に参加させてもらうことができました。社内でもDatadog活用を推進しているため、得られた知見・感想をまとめたいと思います。

## 基調講演

## 特に気になった機能

直近でリリースされたサービスの紹介なども交えながら、プロダクト展開に関するビジョンが熱く語られていました。いくつかの機能が個人的に目を惹いたので、順番に紹介します。

### Bits AI

ログ監視・開発・セキュリティチェックなどを横断的に行えるAIエージェント機能です。
次の特徴があり、運用ではアラート初期対応・バグ調査の自動化まで任せられるそうです。

- インシデント検知・仮説のリストアップ
- 仮説検証の並列実行・調査結果のサマリー作成
- 原因特定・修正対応
- 24時間対応

![Untitled](/images/datadog-summit-2025/bits_triage.png)
*インシデント→仮説検証の並列実行→原因特定までがフローチャートで可視化される様子*

原因の特定に至らなかった場合でも後述のオンコール機能と連携できるため
人が速やかに対応を引き継げます。
また、デプロイ後のエラー状況を監視して自動でRevertしたり、カナリアリリースとともにエラー率を計測する機能もありました。

### オンコール

オンコールは[Datadog Incident Response](https://www.datadoghq.com/product/incident-management/)の一部として提供される、インシデント対応を統合したプラットフォームです。
Bits AIとの連携に限らず、以下の機能により運用負荷が軽減とインシデント解解決速度の向上が期待できそうです。

- 監視、ページング、インシデント管理の一元化
- オンコール対応のスケジューリング機能（自動ローテーション）とエスカレーションルールによる24時間体制の監視
- [モバイルアプリ](https://www.datadoghq.com/ja/blog/datadog-mobile-app/)を活用して、どこからでもインシデント状況の把握が可能

### LLM Observability

開発における生成AIの活用に留まらず、サービスにエージェントを組み込むプロダクトもどんどん増えていますよね。
一方でハルシネーションを含む入出力の不安定さや、モデル評価の困難さなどの課題に直面すると思います。
特に複数のLLMモデルから構成されるサービスではシステム全体の複雑度が増すため、開発速度が大きく低下するという問題がベンダー講演でも触れられていました。

[LLM Observability](https://www.datadoghq.com/product/llm-observability/)を利用することで、これらの課題にアプローチできるとのことでした。

![Untitled](/images/datadog-summit-2025/llm_observability1.png)
*LLMの入出力がUI上で一元管理できる*

参加したワークショップでは

- 入力、出力、レイテンシ、トークン使用量や各ステップでのエラーの追跡
- アプリケーション全体のパフォーマンス監視に与えた影響とLLMの稼働状況の監視
- 本番環境の実データをマスキングして開発環境に適用できるため、スムーズにPDCAを回せる
- LLMの生成結果の検証自体にもLLMを導入し、開発者の負担を軽減できる
などの効果があるとされていました。

## おわりに

単なるログデータ収集プラットフォームに留まらず、AI駆動を推進するDatadogの方向性が明確に感じられました。
また自身での運用はこれからのため、基本機能以外にもどんなことができるかのイメージが大きく広がりました

[公式のラーニングセンター](https://learn.datadoghq.com/?_gl=1*uul937*_gcl_aw*R0NMLjE3NjA1NzkzMDEuQ2owS0NRandqTDNIQmhDZ0FSSXNBUFVnN2E3a05DX3lXXy1SWjZYTDBPMmtXQ1ZpV1o1Y2ZCcXA5SFM1SlhrYzdLbEF1TTdJOEhXWlBPNGFBaVhNRUFMd193Y0I.*_gcl_au*MjQ1NzI3OTIxLjE3NjAwNjAwMzM.*_ga*NjQyMzExNTczLjE3NjA5MjI0Mzc.*_ga_KN80RDFSQK*czE3NjA5NDI5MzIkbzEwJGcxJHQxNzYwOTQ4NTE1JGo1OSRsMCRoNjI2NDcwNTM3*_fplc*MDUwaTNrYSUyQmhveFF1bGYlMkJoRzI5VjZJUU10aXI0ODgzVG8yVmo3QWtZaiUyRiUyQmxKazhtTzhNU1VkOEQyOEFxdGNHNk5sRGg1YU8lMkJKaXhEdnY0cGRxYjgwcjAzejV4SmcxT0ZSSm0xTGhOR0QyTSUyQiUyRnN6JTJCb2s2TklNc25MeVpyUSUzRCUzRA..)もあり、ワークショップで利用するためのアカウントは無料で提供されるのがありがたいですね。
引き続きキャッチアップを進めて、社内のデータ活用推進に寄与したいと思います！
