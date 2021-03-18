# 42_minishell_tester

minishellのテスト、leaksチェックを行うスクリプトです。

## 特徴
- テストケースの追加が容易
  - `cases/` 下にテキストファイルを配置するとテストを追加できます。
- leaksチェック

## 実行方法

任意のディレクトリに、このリポジトリをcloneします。

### テスト実行

1. `grademe.sh` の `User settings` を編集します。

   |変数名|説明|
   |--|--|
   |MINISHELL_DIR|minishellが存在するディレクトリパス（相対or絶対）|
   |MINISHELL_EXE|minishellの実行ファイル名|
   |MINISHELL_PROMPT|プロンプト文字列（ -c オプションを使う場合未設定で大丈夫です）|

1. テストを実行します。
   - minishell に -c オプションを実装している場合
     ```bash
     ./grademe.sh -c
     ```
   - minishell に -c オプションを実装していない場合
     ```bash
     ./grademe.sh
     ```
     置換で頑張っているため、テストケースによっては動作しない可能性があります。
   - 引数なしでテストを全件実行。引数でテストケースを指定できます。
     `./grademe.sh -h` でテストケースを確認できます。

#### -c 実装方法

- `argv[1]` に"-c"が渡されたら、GNLを使わずに引数で渡された文字列を実行すれば良いです。
  ```c
  if (argc > 2 && ft_strncmp("-c", argv[1], 3) == 0)
  {
    run_commandline(argv[2]);
  }
  ```

### leaksチェック

1. `make 任意のrule` で、minishell終了時にleaksコマンドが実行されるようにします。
1. `leaks.sh` の `User settings` を編集します。

   |変数名|説明|
   |--|--|
   |MINISHELL_DIR|minishellが存在するディレクトリパス（相対or絶対）|
   |MINISHELL_EXE|minishellの実行ファイル名|
   |MAKE_TARGET|実行ファイルを生成するmakeルール|

1. テストを実行する。
   - minishell に -c オプションを実装している場合
     ```bash
     ./leaks.sh -c
     ```
   - minishell に -c オプションを実装していない場合
     ```bash
     ./leaks.sh
     ```
   - 引数なしでテストを全件実行。引数でテストケースを指定できます。
     `./leaks.sh -h` でテストケースを確認できます。

#### Makefile, header, cファイル例

Makefile
```Makefile
NAME_LEAKS	:= minishell_leaks
SRCS_LEAKS	:= leaks.c

ifdef LEAKS
NAME		:= $(NAME_LEAKS)
endif

leaks	:
	$(MAKE) CFLAGS="$(CFLAGS) -D LEAKS=1" SRCS="$(SRCS) $(SRCS_LEAKS)" LEAKS=TRUE
```

headerファイル
```h
# ifndef LEAKS
#  define LEAKS 0
# endif

# if LEAKS

void	end(void) __attribute__((destructor));

# endif
```
cファイル（leaks.c）
```c
#include <stdlib.h>
#include "debug.h"

#if LEAKS

void	end(void)
{
	system("leaks minishell_leaks");
}

#endif
```

## テストケースについて

最初はたくさんエラーが出てしまうと思います。
ご自身でテストケースを作ってそれだけ実行してみたり、既存のテストケースを削除したり、いろいろ試してみてください。

### テストケース作成方法
- `cases/` 下にテキストファイルを作成します。
- テキストファイルに、実行するコマンド, セットアップコマンド をカンマ区切りで入力します。
  - これにより実行するコマンドにはカンマを含めることができません。
- ファイルの末尾には改行が必要です。改行がない場合、最後の行のテストが無視されます。

### 注意点
- このテスターの目的は、自動テストによるデグレの防止、およびbashの仕様把握です。
- このテスターでKO != レビューでKOです。テストケースと課題の要件、ソースコードを確認して各自で判断してください。
- 以下のテストケースは扱っていません。
  - `$"string"`
  - `` \` ``
  - `$_`
  - `$123`
  - シグナルのテスト
