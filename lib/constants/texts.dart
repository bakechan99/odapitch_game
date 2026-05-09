class AppTexts {
  // --- Static Constants (固定の文字列) ---

  // Common
  static const String appTitle = "オダピチ";
  static const String cancel = "戻る";
  static const String ok = "OK";
  static const String san = "さん";
  static const String checkPop = "確認";
  static const String cautionBackHome = "タイトル画面に戻りますか？\n\n現在のデータは失われます。";
  static const String goHome = "ホームへ";
  static const String goHelp = "あそびかた";
  static const String goHistory = "りれき";
  static const String goSettings = "設定へ";
  static const String goTerms = "利用規約";
  static const String goPrivacyPolicy = "プライバシーポリシー";
  static const String legalMenuTitle = "規約・プライバシーポリシー";

  static const String termsUrl =
      'https://aged-tang-ba3.notion.site/31f5dfc57a728092b5bdc6f33f6dc9e2?source=copy_link';
  static const String privacyPolicyUrl =
      'https://aged-tang-ba3.notion.site/31f5dfc57a7280498570c56e9eaaf875?source=copy_link';

  // 同意画面
  static const String consentDescription =
      'ゲームを開始する前に、以下の書類をご確認ください。\n'
      '「同意してはじめる」を押すと、利用規約およびプライバシーポリシーに同意したものとみなします。\n'
      '※本アプリのアイデアは、北大CoSTEPが開発した「カケンヒカードゲーム」を参照しています。';
  static const String consentAgreeButton = '同意してはじめる';

  // Title Screen
  static const String gameTitle = "オダピチ";
  static const String newGameButton = "はじめる";
  static const String creditMenuTitle = "クレジット";
  static const String appVersion = "1.0.1";
  static const String creditBody =
      '※本アプリのアイデアは、北大CoSTEPが開発した'
      '「カケンヒカードゲーム」を参照しています。';

  // Setup Screen
  static const String setupTitle = "設定";
  static const String playerCountSection = "ープレイヤー数ー";
  static const String presentationTimeSection = "② 時間設定";
  static const String presentationTimeLabel = "プレゼン時間";
  static const String presentationFeedbackLabel = "質疑応答時間";
  static const String cardPresetSection = "ーカードプリセットー";
  static const String cardPresetLabel = "カードセット";
  static const String odaiPresetSection = "④ お題プリセット";
  static const String odaiPresetLabel = "お題";
  static const String setupPlayerNameSection = "ープレイヤー名（ドラッグで入れ替え）ー";
  static const String defaultPlayerName = "プレイヤー";

  static const String startGameButton = "スタート";

  // Help Screen
  static const String helpTitle = "あそびかた";
  static const String helpSetupOverview =
      "配られたカードに書かれている\n単語を組み合わせて\nお題に沿った文章を作ろう！";
  static const String helpPlayerCount = "（カードは全て使わなくてもOK）";
  static const String helpTimeSettings =
      "全員の文章が完成したら\n みんなに発表！\n発表を聞いたらほかの人に\n持ち点を分配しよう！";
  static const String helpCardPreset = "もらった点数の合計によって\n順位を決定！\n1位目指して頑張ろう！";
  static const String helpPlayerNames = "④ プレイヤー名：名前を編集し、ドラッグで順番を入れ替えられます。";
  static const String helpStartGame = "設定後、「ゲーム開始」を押すとゲームが始まります。";

  // Settings Screen
  static const String settingsTitle = "設定";
  static const String settingsAudioSection = "音声設定";
  static const String settingsBgmEnabled = "BGMを有効にする";
  static const String settingsSeEnabled = "効果音を有効にする";
  static const String settingsBgmVolume = "BGM";
  static const String settingsSeVolume = "効果音";

  // Game Loop Screen
  static const String dragInstruction = "研究タイトルを決めてください";
  static const String handEmpty = "手札をここにドラッグしてください";
  static const String confirmResearchTitle = "この研究タイトルでよろしいですか？";
  static const String nextPlayerButton = "次のプレイヤーへ";
  static const String turnMessageSuffix = "の番です";
  static const String passSmartphoneMessage = "スマホを渡してください";
  static const String startTurnButton = "OK";
  static const String areYouReadySuffix = "さんで間違いありませんか？";
  static const String turnTitleSuffix = " のターン";
  static const String researchAreaHeader = "【研究タイトル】 ドラッグで並び替え  タップで文字選択";
  static const String decideButton = "決定";
  static const String hands = "ドラッグで並び替え  タップで文字選択";

  // Presentation Screen

  // Result Screen
  static const String resultTitle = "結果発表";
  static const String backToTitle = "タイトルへ戻る";
  static const String nextPresenter = "発表の番です";
  static const String nextVoter = "投票の順番です";
  static const String voteBudget = "資金を割り振ってください";
  static const String presentationStartTitle = "プレゼンを開始します";
  static const String voteConfirmTitle = "投票確認";
  static const String voteSelectionTitle = "最も予算を与えたい研究を選んでください";
  static const String resultHeader = "採択された研究課題は...";
  static const String checkBudget = "投票を確定しますか？";
  static const String startVoteButton = "START";
  static const String decideBudget = "次へ";
  static const String feedbackTitle = "質疑応答";
  static const String presentationLabel = "発表時間";
  static const String qaLabel = "質疑応答";
  static const String goFeedback = "質疑応答へ進む";
  static const String goNextPlayer = "終了して次の人へ";
  static const String goToQa = "次のプレイヤーに進む";
  static const String goToVoting = "投票画面に進む";
  static const String presentationTimerLabel = "プレゼン時間";
  static const String qaTimerLabel = "質疑応答時間";
  static const String madeTitleHeader = "【研究課題】";
  static const String rankFirstEmoji = "🥇 ";
  static const String rankSecondEmoji = "🥈 ";
  static const String rankThirdEmoji = "🥉 ";
  static const String aiEvaluationPrefix = "AI評価 : ";
  static const String aiFeedbackPrefix = "講評";
  static const String aiNoFeedback = "評価なし";
  static const String aiOverallReviewLabel = "AI総評";

  // Pop-up messages
  static const String confirmTitle = "このタイトルでよろしいですか？";

  // --- Methods (変数を埋め込む動的な文字列) ---

  // Setup Screen
  static String defaultPlayerNameWithIndex(int index) =>
      "$defaultPlayerName$index";
  static String playerCountUnit(int count) => "$count";
  static String secondsUnit(int sec) => "${sec}秒";
  static String timerFormat(int sec) =>
      "${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}";

  // Game Loop Screen
  static String nextPlayerMessage(String name) => " $name さんの番です";
  static String areYouReady(String name) => "$nameさんで間違いありませんか？";
  static String turnTitle(String name) => "$name さんのターン";

  // Result Screen
  static String nextPlayerStandby(String name) => "$name さん";
  static String presentationTitle(String name) => "$name さんの発表";
  static String presentationTimeMsg(int seconds) => "時間は$seconds秒です。";
  static String timeLeft(int seconds) => "残り $seconds 秒";
  static String votingTitle(String name) => "$name の投票";
  static String confirmVote(String name) => "$name さんに投票しますか？";
  static String winnerName(String name) => "👑 $name";
  static String voteCount(int votes) => "獲得票数: $votes 票";
  static String remainBudget(int remainingBudget) =>
      "残り予算: $remainingBudget 万円 / 100 万円";
  static String odaitheme(String odai) => "お題：$odai";
  static String researcherName(String name) => "$name";
  static String budgetAmount(int amount) => "$amount\u00A0万円";
  static String rankPosition(int rank) => "${rank}";
  static String amountOnly(int amount) => "$amount";
  static String aiScoreLabel(Object score) => " × $score 倍";
  static String aiFeedbackLabel(String feedback) =>
      "$aiFeedbackPrefix: $feedback";
  // 研究タイトルを整形して返す
  static String researchTitle(String title) => "【研究課題】$title";
}
