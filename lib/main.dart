// ============================================================
// My Task - シンプルなタスク管理アプリ
// ------------------------------------------------------------
// ・Material Design 3
// ・スマートフォン向け
// ・main.dart だけで完結
// ・StatefulWidget を使用
// ============================================================

import 'package:flutter/material.dart';

// アプリの入口。ここから実行が始まります。
void main() {
  runApp(const MyApp());
}

// ------------------------------------------------------------
// アプリで使う色をここにまとめます。
// 色を変えたいときは、この1か所を直すだけで全体に反映されます。
// ------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFF14B8A6); // メインカラー（ティール）
  static const background = Color(0xFFF8FAFC); // 画面の背景
  static const surface = Color(0xFFFFFFFF); // カードなどの面
  static const textPrimary = Color(0xFF0F172A); // メインの文字
  static const textSecondary = Color(0xFF64748B); // 補足の文字
  static const divider = Color(0xFFE2E8F0); // 区切り線・薄いグレー
  static const textMuted = Color(0xFF94A3B8); // 完了済みの文字など、さらに薄い文字
}

// ------------------------------------------------------------
// タスク1件分のデータを表すクラス
// ------------------------------------------------------------
class Task {
  Task({
    required this.title,
    required this.detail,
    this.isDone = false,
  });

  // 編集で書き換えられるように、final は付けません
  String title; // タスク名
  String detail; // タスクの詳細
  bool isDone; // 完了しているか（チェックボックスで切り替える）
}

// ------------------------------------------------------------
// 追加・編集シートから一覧画面へ返す「結果」
// 「保存」か「削除」かを、この1つのクラスで伝えます。
// ------------------------------------------------------------
class _TaskFormResult {
  // 保存（追加・編集どちらも）
  const _TaskFormResult.save({
    required this.title,
    required this.detail,
    required this.isDone,
  }) : isDelete = false;

  // 削除（中身は使わないので空にしておく）
  const _TaskFormResult.delete()
      : title = '',
        detail = '',
        isDone = false,
        isDelete = true;

  final String title;
  final String detail;
  final bool isDone;
  final bool isDelete; // true なら「削除」
}

// ------------------------------------------------------------
// フィルターの種類（すべて / 未完了 / 完了）
// ------------------------------------------------------------
enum TaskFilter {
  all('すべて'),
  active('未完了'),
  done('完了');

  const TaskFilter(this.label);
  final String label; // チップに表示する文字
}

// ------------------------------------------------------------
// アプリ全体の設定（StatelessWidget: 状態を持たないウィジェット）
// 見た目（テーマ）はここでまとめて決めます。
// ------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 入力欄の枠線（色と太さだけ変えて使い回す）
  OutlineInputBorder _outline(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 色の組み合わせ（カラースキーム）。基準の色を指定して、必要な色だけ上書きする
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outlineVariant: AppColors.divider,
    );

    return MaterialApp(
      title: 'My Task',
      debugShowCheckedModeBanner: false, // 右上の「DEBUG」帯を消す
      theme: ThemeData(
        useMaterial3: true, // Material Design 3 を有効にする
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        dividerColor: AppColors.divider,

        // カード：白・角丸16・薄い影（アプリ内のカードは全部これを使う）
        cardTheme: CardThemeData(
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: const Color(0x1F0F172A), // 薄い影
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias, // タップの波紋を角丸の内側に収める
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // チェックボックス：丸型。未選択はグレー、選択するとティール
        checkboxTheme: CheckboxThemeData(
          shape: const CircleBorder(),
          fillColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.transparent;
          }),
          checkColor: const WidgetStatePropertyAll(Colors.white),
          side: WidgetStateBorderSide.resolveWith((states) {
            return BorderSide(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
              width: 2,
            );
          }),
        ),

        // 下から出てくるシート
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          showDragHandle: true, // 上のつまみ
          dragHandleColor: AppColors.divider,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),

        // 入力欄：薄いグレーの枠、選択中はティールの枠
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          floatingLabelStyle: const TextStyle(color: AppColors.primary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: _outline(AppColors.divider),
          enabledBorder: _outline(AppColors.divider),
          focusedBorder: _outline(AppColors.primary, 2),
          errorBorder: _outline(colorScheme.error),
          focusedErrorBorder: _outline(colorScheme.error, 2),
        ),

        // メインのボタン（塗りつぶし）：ティール
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52), // 大きなタップ領域
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // サブのボタン（枠線）：キャンセルなど
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.divider, width: 1.5),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const TaskListPage(),
    );
  }
}

// ------------------------------------------------------------
// タスク一覧画面（StatefulWidget: 状態が変わる画面）
// ------------------------------------------------------------
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

// 画面の「状態」を管理するクラス。
// ここにあるデータを setState() で変更すると、画面が再描画されます。
class _TaskListPageState extends State<TaskListPage> {
  // 現在選ばれているフィルター（最初は「すべて」）
  TaskFilter _filter = TaskFilter.all;

  // サンプルデータ
  final List<Task> _tasks = [
    Task(title: '買い物に行く', detail: '牛乳・卵・パンを買う'),
    Task(title: '書類を提出する', detail: '今日の17時までに事務室へ'),
    Task(title: '部屋を片付ける', detail: '机の上と本棚を整理する'),
    Task(title: 'メールを返信する', detail: '先生からの連絡に返事をする'),
  ];

  // フィルターに合わせて、表示するタスクだけを取り出す
  List<Task> get _visibleTasks {
    switch (_filter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.active:
        return _tasks.where((task) => !task.isDone).toList();
      case TaskFilter.done:
        return _tasks.where((task) => task.isDone).toList();
    }
  }

  // 未完了・完了の件数（フィルターに関係なく、全タスクから数える）
  int get _activeCount => _tasks.where((task) => !task.isDone).length;
  int get _doneCount => _tasks.where((task) => task.isDone).length;

  // チェックボックスの切り替え
  void _toggleTask(Task task, bool? value) {
    setState(() {
      task.isDone = value ?? false;
    });
  }

  // 追加・編集の共通処理：下からシート（ボトムシート）を開く
  //   task が null     → 「タスク追加」モード
  //   task が渡された  → 「タスク編集」モード
  // シートの見た目（角丸・色・つまみ）は、上の ThemeData で設定済みです。
  Future<void> _openTaskSheet({Task? task}) async {
    final result = await showModalBottomSheet<_TaskFormResult>(
      context: context,
      isScrollControlled: true, // キーボードが出ても隠れないよう高さを自由にする
      builder: (context) => _TaskFormSheet(task: task),
    );

    // キャンセル（シートを閉じただけ）なら null が返ってくるので何もしない
    if (result == null) return;

    setState(() {
      if (result.isDelete) {
        // 削除：一覧から取り除く
        _tasks.remove(task);
      } else if (task == null) {
        // 追加：新しい Task を作って一覧に加える
        _tasks.add(
          Task(
            title: result.title,
            detail: result.detail,
            isDone: result.isDone,
          ),
        );
      } else {
        // 編集：既存の Task を書き換える
        task.title = result.title;
        task.detail = result.detail;
        task.isDone = result.isDone;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _visibleTasks;

    return Scaffold(
      // AppBar は使わず、ヘッダーも一緒にスクロールする一覧の中に置きます。
      // SafeArea は、ステータスバー（時計など）と重ならないようにするためのものです。
      body: SafeArea(
        bottom: false,
        child: ListView(
          // 左右は20、下はボタンと重ならないよう広めに余白をとる
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
          children: [
            // ---------- ヘッダー ----------
            const Text(
              'My Task',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'やることを、ひとつずつ。', // サブタイトル
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // ---------- 進捗カード（未完了・完了の件数） ----------
            // 追加・編集・削除・完了切替のたびに setState で再描画されるので、
            // 件数も自動で最新になります。
            _SummaryCard(activeCount: _activeCount, doneCount: _doneCount),
            const SizedBox(height: 20),

            // ---------- フィルターチップ ----------
            // Wrap は、横に入りきらないとき自動で次の行に折り返してくれます
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in TaskFilter.values)
                  FilterChip(
                    label: Text(filter.label),
                    selected: _filter == filter,
                    showCheckmark: false, // 選択中のチェックマークは出さない
                    shape: const StadiumBorder(), // 完全な角丸（Pill型）
                    side: BorderSide.none,
                    backgroundColor: AppColors.divider, // 未選択：薄いグレー
                    selectedColor: AppColors.primary, // 選択中：ティール
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _filter == filter
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    // 押しやすいように、文字のまわりの余白を広めにする
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _filter = filter;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ---------- タスク一覧 ----------
            // 表示するタスクがないときは、メッセージを出す
            if (tasks.isEmpty)
              const _EmptyMessage()
            else
              for (final task in tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12), // カード同士の間隔
                  child: _TaskCard(
                    task: task,
                    onChanged: (value) => _toggleTask(task, value),
                    // 「編集」ボタンが押されたら、編集モードでシートを開く
                    onEdit: () => _openTaskSheet(task: task),
                  ),
                ),
          ],
        ),
      ),

      // ---------- 右下のボタン ----------
      // extended は「アイコン＋文字」付きの、横長で楕円形のボタン
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskSheet(), // task を渡さない = 追加モード
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const StadiumBorder(), // 楕円形
        icon: const Icon(Icons.add),
        label: const Text(
          'タスク追加',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 進捗カード：未完了・完了の件数を横に並べて表示
// ------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.activeCount, required this.doneCount});

  final int activeCount; // 未完了の件数
  final int doneCount; // 完了の件数

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            // 左：未完了（目立たせたいのでティール）
            Expanded(
              child: _SummaryItem(
                label: '未完了',
                count: activeCount,
                color: AppColors.primary,
              ),
            ),
            // 真ん中の縦線
            Container(width: 1, height: 44, color: AppColors.divider),
            // 右：完了
            Expanded(
              child: _SummaryItem(
                label: '完了',
                count: doneCount,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 進捗カードの中の1項目（ラベル＋大きな数字＋「件」）
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        // 数字だけ大きく、「件」は小さく
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$count',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const TextSpan(
                text: ' 件',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// タスクが1件もないときに表示するメッセージ
// ------------------------------------------------------------
class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'タスクはありません',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// タスク1件分のカード
// ------------------------------------------------------------
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onChanged,
    required this.onEdit,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit; // 「編集」ボタンが押されたときの処理

  @override
  Widget build(BuildContext context) {
    // 角丸・影・白背景は、ThemeData の cardTheme で設定済み
    return Card(
      child: InkWell(
        // カード全体がタップ領域（大きなタップ領域）
        onTap: () => onChanged(!task.isDone),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
          child: Row(
            children: [
              // チェックボックス（大きめにして押しやすく）
              // 丸型・色は ThemeData の checkboxTheme で設定済み
              Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  value: task.isDone,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              // タスク名と詳細
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700, // 太字
                        height: 1.3,
                        // 完了したら打ち消し線＋薄い色にする
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (task.detail.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.detail,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // カード右側の「編集」ボタン（目立ちすぎないよう、グレーの文字だけ）
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(56, 48), // 押しやすい大きさは確保
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('編集'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// タスク追加・編集 共通のボトムシート（下から出てくる入力画面）
//   task が null     → 追加モード（「タスク追加」）
//   task が渡された  → 編集モード（「タスク編集」）
// 入力値は、このシート自身の State（TextEditingController など）で管理します。
// ------------------------------------------------------------
class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({this.task});

  final Task? task; // 編集するタスク（追加のときは null）

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  // 編集モードかどうか
  bool get _isEdit => widget.task != null;

  // 入力欄の中身を管理するもの（State で保持）
  // 編集モードなら、最初から今の値を入れておく
  late final _titleController =
      TextEditingController(text: widget.task?.title ?? '');
  late final _detailController =
      TextEditingController(text: widget.task?.detail ?? '');

  // 完了状態（編集モードのチェックボックス用）
  late bool _isDone = widget.task?.isDone ?? false;

  // タスク名が未入力のときに、エラー表示を出すかどうか
  bool _showTitleError = false;

  // シートが閉じられるときに controller を片付ける（お約束）
  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  // 「追加する」「変更を保存」ボタンの処理
  void _submit() {
    final title = _titleController.text.trim();

    // タスク名は必須：空ならエラーを出して、ここで終了
    if (title.isEmpty) {
      setState(() {
        _showTitleError = true;
      });
      return;
    }

    // 入力した内容を、呼び出し元（一覧画面）へ返す
    Navigator.of(context).pop(
      _TaskFormResult.save(
        title: title,
        detail: _detailController.text.trim(),
        isDone: _isDone,
      ),
    );
  }

  // 「タスクを削除」ボタンの処理（編集モードのみ）
  void _delete() {
    Navigator.of(context).pop(const _TaskFormResult.delete());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // キーボードの高さ分だけ下に余白を入れて、入力欄が隠れないようにする
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      // 画面が小さくても、はみ出さずスクロールできるようにする
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 中身の高さだけ使う
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            Text(
              _isEdit ? 'タスク編集' : 'タスク追加',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // タスク名（必須）
            // 枠線などの見た目は、ThemeData の inputDecorationTheme で設定済み
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next, // Enterで次の欄へ
              decoration: InputDecoration(
                labelText: 'タスク名（必須）',
                // エラーのときだけメッセージを表示（null なら表示なし）
                errorText: _showTitleError ? 'タスク名を入力してください' : null,
              ),
              onChanged: (_) {
                // 入力が始まったらエラー表示を消す
                if (_showTitleError) {
                  setState(() {
                    _showTitleError = false;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // 詳細（任意）
            TextField(
              controller: _detailController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '詳細（任意）',
                alignLabelWithHint: true,
              ),
            ),

            // 完了状態の切り替え（編集モードのときだけ表示）
            if (_isEdit) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _isDone,
                onChanged: (value) {
                  setState(() {
                    _isDone = value ?? false;
                  });
                },
                title: const Text(
                  '完了にする',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading, // 左側に表示
              ),
            ],
            const SizedBox(height: 24),

            // ボタン：モードによって中身を切り替える
            if (_isEdit) ...[
              // 編集モード：「変更を保存」と「タスクを削除」
              FilledButton(
                onPressed: _submit,
                child: const Text('変更を保存'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  // 削除は、テーマのエラー色（赤系）にする
                  foregroundColor: Theme.of(context).colorScheme.error,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('タスクを削除'),
              ),
            ] else
              // 追加モード：「キャンセル」と「追加する」を横に並べる
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      // 何も返さずに閉じる（呼び出し元には null が届く）
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('追加する'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
