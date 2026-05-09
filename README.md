# オダピチ 設計ドキュメント

## 1. プロジェクト概要

本プロジェクトは、研究費獲得プロセスを模したパーティーゲームアプリ「オダピチ」です。
プレイヤーは配られた単語カードを組み合わせて「研究タイトル」を作成し、プレゼンテーションと質疑応答を経て、互いに予算（ポイント）を投票し合います。最も多くの予算を獲得したプレイヤーが勝者となります。

## 2. ディレクトリ構成

主要なソースコードは `lib` 配下に配置されています。

~~~
lib/
├── main.dart                        # エントリーポイント。テーマ設定、AdMob初期化、ConsentScreen/TitleScreenの呼び出し
├── constants/
│   ├── texts.dart                   # アプリ内の定数テキスト管理（ボタン名、メッセージ等）
│   ├── app_colors.dart              # カラーパレット（AppColorsクラス）
│   └── app_text_styles.dart         # テキストスタイル（AppTextStylesクラス）
├── models/                          # データモデル定義
│   ├── card_data.dart               # カード単体のデータ構造（上・中・下の文言）
│   ├── game_settings.dart           # ゲーム設定（プレゼン時間、質疑応答時間）
│   ├── placed_card.dart             # フィールドに配置されたカードの状態（どの段を選択中か）
│   ├── player.dart                  # プレイヤー情報（名前、手札、タイトル、AI採点結果）
│   ├── card_preset.dart             # カードプリセット情報（id、name、path）
│   └── odai_preset.dart             # お題プリセット情報（id、name、odai）
├── screens/                         # 各画面のUIとロジック
│   ├── consent_screen.dart          # 利用規約・プライバシーポリシー同意画面
│   ├── title_screen.dart            # タイトル画面。BGM再生、ゲーム開始・ヘルプ・履歴遷移
│   ├── setup_screen.dart            # 設定画面。人数・名前・時間・プリセット・AI設定
│   ├── game_loop_screen.dart        # メインゲーム画面。カードのドラッグ＆ドロップ操作
│   ├── passing_confirm_screen.dart  # 端末受け渡し確認画面
│   ├── research_title_confirm_screen.dart # 研究タイトル確認画面
│   ├── result_screen.dart           # 結果画面。プレゼン・投票・結果発表のフェーズ管理
│   ├── presentation_screen.dart     # プレゼンテーション・質疑応答画面（タイマー付き）
│   ├── voting_screen.dart           # 予算投票画面
│   ├── result_view.dart             # 最終結果・AI採点表示画面
│   ├── help_screen.dart             # 遊び方説明画面
│   ├── history_screen.dart          # ゲーム履歴表示画面
│   └── settings_screen.dart         # BGM・効果音設定画面
├── widgets/                         # 共通ウィジェット
│   ├── hand_card_widget.dart        # 手札カード表示
│   ├── placed_card_widget.dart      # フィールド配置済みカード（セクション選択可能）
│   ├── common_app_bar.dart          # 共通AppBar（ホーム・ヘルプ・設定ボタン）
│   ├── passing_style_card.dart      # 端末受け渡し画面用カード
│   ├── fancy_button.dart            # グラデーション装飾ボタン
│   ├── title_button.dart            # タイトル画面用ボタン
│   ├── custom_confirm_dialog.dart   # 汎用確認ダイアログ
│   ├── result_confirm_dialog.dart   # 結果確認ダイアログ
│   ├── time_setting_control.dart    # 時間設定スライダー
│   ├── setting_stepper_control.dart # 数値増減コントロール（±ボタン）
│   ├── decorative_band.dart         # 装飾バンド
│   └── custom_banner_ad.dart        # Google AdMobバナー広告
├── features/                        # ドメインロジック（Clean Architecture）
│   ├── setup/
│   │   ├── application/setup_controller.dart       # セットアップ操作の統括
│   │   ├── domain/setup_repository.dart            # セットアップ操作インターフェース
│   │   └── data/setup_repository_impl.dart         # LocalDbを使用した実装
│   ├── game_session/
│   │   └── application/result_session_controller.dart  # 発表→投票→結果のフェーズ管理
│   └── settings/
│       ├── domain/game_settings_repository.dart    # 設定操作インターフェース
│       └── data/game_settings_repository_impl.dart # LocalDbを使用した実装
├── services/
│   ├── api_service.dart             # AWS Lambda API連携（AI採点）
│   └── reward_ad_manager.dart       # Google AdMobリワード広告管理
├── utils/
│   ├── audio_manager.dart           # 効果音再生管理
│   └── consent_manager.dart         # 利用規約同意状態管理
└── data/
    └── local_db.dart                # SQLiteローカル永続化（プレイヤー名・設定・履歴）
~~~

## 3. アーキテクチャ概要

Clean Architecture + Provider/Listenerパターンを採用しています。

~~~
UI層
  ├─ screens/    （画面全体の管理）
  ├─ widgets/    （再利用可能なコンポーネント）
  └─ constants/  （テーマ・テキスト・カラー）

Application層（ロジック）
  ├─ SetupController          （セットアップロジック）
  ├─ ResultSessionController  （ゲーム進行ロジック）
  └─ RewardAdManager          （広告管理）

Domain層（ビジネスルール）
  ├─ SetupRepository          （セットアップ操作インターフェース）
  └─ GameSettingsRepository   （設定操作インターフェース）

Data層（永続化・API）
  ├─ LocalDb      （SQLiteローカルストレージ）
  ├─ ApiService   （AWS Lambda連携）
  └─ AudioManager （効果音管理）
~~~

## 4. 画面遷移図

~~~
graph TD
    Consent[ConsentScreen<br>利用規約同意画面] -->|同意| Title
    Title[TitleScreen<br>タイトル画面] -->|新規ゲーム| Setup[SetupScreen<br>設定画面]
    Title -->|ヘルプ| Help[HelpScreen<br>遊び方画面]
    Title -->|履歴| History[HistoryScreen<br>履歴画面]
    Title -->|設定| Settings[SettingsScreen<br>設定画面]
    Setup -->|ゲーム開始| GameLoop[GameLoopScreen<br>メインゲーム画面]

    subgraph GameLoopLogic [ゲームループ]
        Pass[PassingConfirmScreen<br>端末受け渡し] -->|確認| Play[プレイ画面<br>カード配置]
        Play -->|確認| Confirm[ResearchTitleConfirmScreen<br>タイトル確認]
        Confirm -->|次のプレイヤー| Pass
    end

    GameLoop -->|全員終了| Result[ResultScreen<br>結果管理]

    subgraph ResultLogic [結果・投票フェーズ]
        Pres[PresentationScreen<br>プレゼン & 質疑応答] --> Vote[VotingScreen<br>予算投票]
        Vote --> Ranking[ResultView<br>結果発表・AI採点]
    end

    Result --> Pres
    Ranking -->|タイトルへ戻る| Title
~~~

## 5. データモデル詳細

~~~
Player (player.dart)
ゲームに参加するユーザーを表します。

name (String): プレイヤー名。
hand (List<CardData>): 現在の手札。
selectedCards (List<PlacedCard>): フィールドに配置し、タイトルとして採用したカードのリスト。
researchTitle (String): selectedCards を連結して生成される研究タイトル文字列。
aiScore (int?): AI採点スコア。
aiFeedback (String?): AIフィードバックテキスト。

CardData (card_data.dart)
cards.json から読み込まれるカードデータです。

id (int): 一意のID。
top (String): 上段のテキスト（キーワード）。
middle (String): 中段のテキスト（接続詞）。
bottom (String): 下段のテキスト（締めの言葉）。

PlacedCard (placed_card.dart)
フィールドに置かれたカードの状態を管理します。

card (CardData): 元のカードデータ。
selectedSection (int): 0=上段, 1=中段, 2=下段。ユーザーのタップにより変更可能。

GameSettings (game_settings.dart)
presentationTimeSec (int): プレゼンテーションの持ち時間。
qaTimeSec (int): 質疑応答の持ち時間。
playerCount (int): プレイヤー数。

CardPreset (card_preset.dart)
id (int): 一意のID。
name (String): プリセット名。
path (String): カードデータファイルパス。
odaiPath (String): お題データファイルパス。

OdaiPreset (odai_preset.dart)
id (int): 一意のID。
name (String): プリセット名。
odai (String): お題テキスト。
~~~

## 6. 主要な機能

- **ドラッグ&ドロップカード操作** - GameLoopScreen で手札からフィールドへカードをドラッグして配置
- **タップセクション選択** - PlacedCardWidget で上中下の3セクションから選択可能
- **AI採点機能** - ApiService で AWS Lambda API へリクエストし、研究タイトルの評価・フィードバックを取得
- **リワード広告** - AI機能使用時に広告表示（RewardAdManager）
- **ゲーム履歴保存** - LocalDb に SQLite で永続化
- **マルチプレイヤー対応** - 複数プレイヤーの順番管理
- **プリセット機能** - カードとお題を複数のプリセットから選択可能
- **統一UI/UX** - CommonAppBar、Constants（色・テキスト・スタイル）で一貫性確保

## 7. 現状の課題とTODO

~~~
アセットの依存関係:
title_screen.dart や result_screen.dart で audio (mp3) や images (png) を参照していますが、
ファイルが存在しない場合に例外キャッチでログ出力する実装になっています。
本番ビルド前にリソースの配置確認が必要です。

プレイヤー数の上限と色:
result_view.dart 内の _getPlayerColor メソッドで定義されている色は限定数です。
プレイヤー数を拡張する場合はカラーパレットの追加が必要です。

ドラッグ&ドロップの操作性:
game_loop_screen.dart にて、カードの隙間（Gap）に対する判定エリア（_buildGapTarget）を
透明なContainerで確保していますが、判定エリアの微調整（ちらつき防止）に関するコメントが残っています。
実機での操作感を確認し、必要に応じて調整が必要です。

ハードコーディングされた文字列:
多くのテキストは AppTexts クラスに集約されていますが、一部の画面に直接文字列が記述されている箇所があります。
多言語対応や保守性のために AppTexts への移行が推奨されます。
~~~
