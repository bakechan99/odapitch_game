class AppTexts {
  // --- Static Constants (固定の文字列) ---
  
  // Common
  static const String appTitle = "カケンヒゲーム";
  static const String cancel = "キャンセル";
  static const String ok = "OK";
  static const String san = "さん";
  static const String checkPop = "確認";
  static const String cautionBackHome = "タイトル画面に戻りますか？\n\n現在のデータは失われます。";
  static const String goHome = "ホームへ";
  static const String goHelp = "せつめい";
  static const String goSettings = "設定へ";

  // Title Screen
  static const String gameTitle = "オダピチ";
  static const String newGameButton = "はじめる";

  // Setup Screen
  static const String setupTitle = "設定";
  static const String playerCountSection = "プレイヤー";
  static const String presentationTimeSection = "② 時間設定";
  static const String presentationTimeLabel = "プレゼン時間";
  static const String presentationFeedbackLabel = "質疑応答時間";
  static const String cardPresetSection = "③ カードプリセット";
  static const String cardPresetLabel = "使用するカードセット";
  static const String setupPlayerNameSection = "④ プレイヤー名（ドラッグで入替）";
  static const String defaultPlayerName = "プレイヤー";

  static const String startGameButton = "スタート";
  
  // Help Screen
  static const String helpTitle = "ヘルプ";
  static const String helpSetupOverview = "この画面では、ゲーム開始前の設定を行います。";
  static const String helpPlayerCount = "① プレイヤー数：3〜8人で設定できます。";
  static const String helpTimeSettings = "② 時間設定：プレゼン時間と質疑応答時間を10秒刻みで設定できます。";
  static const String helpCardPreset = "③ カードプリセット：使用するカードセットを選択できます。";
  static const String helpPlayerNames = "④ プレイヤー名：名前を編集し、ドラッグで順番を入れ替えられます。";
  static const String helpStartGame = "設定後、「ゲーム開始」を押すとゲームが始まります。";

  // Settings Screen
  static const String settingsTitle = "設定";
  static const String settingsAudioSection = "音声設定";
  static const String settingsBgmEnabled = "BGMを有効にする";
  static const String settingsSeEnabled = "効果音を有効にする";
  static const String settingsBgmVolume = "BGM音量";
  static const String settingsSeVolume = "効果音音量";

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
  static const String hands = "手札";
  
  // Presentation Screen


  // Result Screen
  static const String resultTitle = "結果発表";
  static const String backToTitle = "タイトルへ戻る";
  static const String nextPresenter = "発表の番です";
  static const String nextVoter = "投票の番です";
  static const String presentationStartTitle = "プレゼンを開始します";
  static const String voteConfirmTitle = "投票確認";
  static const String voteSelectionTitle = "最も予算を与えたい研究を選んでください";
  static const String resultHeader = "採択された研究課題は...";
  static const String checkBudget = "この配分で投票しますか？";
  static const String startVoteButton = "START";
  static const String decideBudget = "投票を確定する";
  static const String feedbackTitle = "質疑応答";
  static const String goFeedback = "質疑応答へ進む";
  static const String goNextPlayer = "終了して次の人へ";
  static const String madeTitleHeader = "【研究課題】";

  // Pop-up messages 
  static const String confirmTitle = "本人確認";

  // --- Methods (変数を埋め込む動的な文字列) ---
  
  // Setup Screen
  static String defaultPlayerNameWithIndex(int index) => "$defaultPlayerName$index";
  static String playerCountUnit(int count) => "$count人";
  static String secondsUnit(int sec) => "${sec}秒";

  // Game Loop Screen
  static String nextPlayerMessage(String name) => " $name さんの番です";
  static String areYouReady(String name) => "$nameさんで間違いありませんか？";
  static String turnTitle(String name) => "$name のターン";

  // Result Screen
  static String nextPlayerStandby(String name) => "$name さん";
  static String presentationTitle(String name) => "$name さんの発表";
  static String presentationTimeMsg(int seconds) => "時間は$seconds秒です。";
  static String timeLeft(int seconds) => "残り $seconds 秒";
  static String votingTitle(String name) => "$name の投票";
  static String confirmVote(String name) => "$name さんに投票しますか？";
  static String winnerName(String name) => "👑 $name";
  static String voteCount(int votes) => "獲得票数: $votes 票";
  static String remainBudget(int remainingBudget) => "残り予算: $remainingBudget 万円 / 100 万円";
  
  // 研究タイトルを整形して返す
  static String researchTitle(String title) => "【研究課題】$title";
}