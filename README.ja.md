Translations: [English(en)](README.md) [日本語(ja)](README.ja.md)

# 42_minishell_tester

minishellのテスト、leaksチェックを行うスクリプトです。

|:warning: このスクリプトは、現在の課題に準拠していません。|
|:----|
|スクリプトを作った当時はtermcapやreadlineが必須ではなく、`;` や `\` などを実装する必要がありました。<br>現在の課題だとスクリプトが動作しない、あるいはKOになってしまうことがあります。<br>ご了承ください。|

## 特徴
- テストケースの追加が容易
  - `cases/` 下にテキストファイルを配置するとテストを追加できます。
- minishellの-cオプションありなし、どちらにも対応
  - -cオプションなしは簡易対応です。  
    termcapを使用している場合や、termcapを使用しなくともプロンプト文字列によっては動作しないことがあります。
- 各テストケースのleaksチェック（要ソースコード編集）

## 使い方

任意のディレクトリに、このリポジトリをcloneします。

### テスト実行

1. `grademe.sh` の `User settings` を編集します。

   |変数名|説明|
   |--|--|
   |MINISHELL_DIR|minishellが存在するディレクトリパス（相対or絶対）|
   |MINISHELL_EXE|minishellの実行ファイル名|
   |MINISHELL_PROMPT|stderrに表示されるプロンプト文字列（ -c オプションを使う場合、未設定で大丈夫です）|

1. テストを実行します。
   - minishell に -c オプションを実装している場合
     ```bash
     ./grademe.sh -c
     ```
     - exitコマンドの "exit" は stderr に出力する必要があります。
   - minishell に -c オプションを実装していない場合
     ```bash
     ./grademe.sh
     ```
     - exitコマンドを実装する必要があります。exitコマンドの "exit" は stderr に出力する必要があります。
     - プロンプトが可変だったり、プロンプトにESCを含んでいると、sedで置換できず結果が正しく出力されません。  
       その場合は -c オプションを使ってください。
   - 引数なしでテストを全件実行。引数でテストケースを指定できます。  
     `./grademe.sh -h` でテストケースを確認できます。

#### -c 実装方法

- `argv[1]` に"-c"が渡されたら、GNLを使わずに `argv[2]` をコマンド文字列として実行すれば良いです。
  ```c
  if (argc > 2 && ft_strncmp("-c", argv[1], 3) == 0)
  {
    run_commandline(argv[2]);
  }
  ```

### leaksチェック

1. `make 任意のrule` で、minishellをビルドするようにします。このminishellは終了時にleaksコマンドを実行します。
1. `leaks.sh` の `User settings` を編集します。

   |変数名|説明|
   |--|--|
   |MINISHELL_DIR|minishellが存在するディレクトリパス（相対or絶対）|
   |MINISHELL_EXE|minishellの実行ファイル名|
   |MAKE_TARGET|実行ファイルを生成するmakeルール|

1. テストを実行します。
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

headerファイル（leaks.h）
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
#include "leaks.h"

#if LEAKS

void	end(void)
{
	system("leaks minishell_leaks");
}

#endif
```

### テストで行っていること

1. テスト用ディレクトリ `test/` を作成し、移動。
1. セットアップ用コマンドを実行。
1. bash もしくは minishell を実行。
   - -c無しの場合、実行するコマンドに `; exit` を追加して実行します。
1. `outputs/` にstdout, stderrをファイルとして出力。
1. bash と minishell の stdout, stderr, exit statusを比較。

## テストケースについて

テストを実行すると、最初はたくさん KO が出てしまうかもしれません。  
ご自身でテストケースを作ってそれだけ実行してみたり、既存のテストケースを削除したり、いろいろ試してみてください。

### テストケース作成方法
- `cases/` 下にテキストファイルを作成します。
- テキストファイルに、実行するコマンド, セットアップコマンド をカンマ区切りで入力します。
  - これにより実行するコマンドにはカンマを含めることができません。
- ファイルの末尾には改行が必要です。改行がない場合、最後の行のテストが無視されます。

## 注意点
- このテスターの目的は、自動テストによるリグレッションの防止、およびbashの仕様把握です。
- このテスターでKO != レビューでKOです。テストケースと課題の要件、ソースコードを確認して各自で判断してください。
- 以下のテストケースは扱っていません。
  - `$"string"`
  - `` \` ``
  - `$_`
  - `$123`
  - シグナルのテスト

## 謝辞
minishell を一緒に取り組んだ [ToYeah](https://github.com/ToYeah) さんに cd, echo, expand, pwd など多数のテストケースを作成いただきました。

この場を借りて御礼申し上げます。
