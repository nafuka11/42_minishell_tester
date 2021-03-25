Translations: [English(en)](README.md) [日本語(ja)](README.ja.md)

# 42_minishell_tester

Script for minishell to test and check the results of the leaks command.

## Features
- Easy to add test cases.
  - You can add tests by placing a text file in `cases/`.
- Supports both minishell with and without -c option.
  - Without -c option is simple support. It may not work with some prompt strings.
- Check the results of the leaks command in each test case (source code editing required)

## Usage

Clone this repository to any directory.

### Run the tests

1. Edit `User settings` in `grademe.sh`.

   |Variable name|Description|
   |--|--|
   |MINISHELL_DIR|Directory path where minishell exists (relative or absolute)|
   |MINISHELL_EXE|Minishell executable file name|
   |MINISHELL_PROMPT|Prompt string to be displayed in stderr (if you use -c option, you can leave it unset)|

1. Run the test
   - If you have implemented the -c option to minishell
     ```bash
     ./grademe.sh -c
     ```
     - The "exit" in the exit command should be printed to stderr.
   - If you do not implement the -c option to minishell
     ```bash
     ./grademe.sh
     ```
     - You will need to implement the exit command; the "exit" in the exit command should be printed to stderr.
     - If the prompt is variable or contains ESC in the prompt, it cannot be replaced by sed and the result will not be printed correctly. In that case, use the -c option.
   - Run all test cases with no arguments. You can specify one test case with an argument.
     `. /grademe.sh -h` to check the test cases.

#### How to implement the -c option

- If "-c" is passed to `argv[1]`, run `argv[2]` as a command string without using GNL.
  ```c
  if (argc > 2 && ft_strncmp("-c", argv[1], 3) == 0)
  {
    run_commandline(argv[2]);
  }
  ```

### Check the result of the leaks command

1. Add a rule to your Makefile. This rule will build a minishell that will run the leaks command on the exit.
1. Edit `User settings` in `leaks.sh`

   |Variable name|Description|
   |--|--|
   |MINISHELL_DIR|Directory path where minishell exists (relative or absolute)|
   |MINISHELL_EXE|Minishell executable file name|
   |MAKE_TARGET|Make rule to generate the executable file|

1. Run the test
   - If you have implemented the -c option to minishell
     ```bash
     ./leaks.sh -c
     ```
   - If you do not implement the -c option to minishell
     ```bash
     ./leaks.sh
     ```
   - Run all test cases with no arguments. You can specify one test case with an argument.
     `. /leaks.sh -h` to check the test cases.

#### Makefile, header, and c file examples

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

header file (leaks.h)
```h
# ifndef LEAKS
#  define LEAKS 0
# endif

# if LEAKS

void	end(void) __attribute__((destructor));

# endif
```
c file (leaks.c)
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

### What the script is doing for testing

1. Create and move the test directory `test/`.
1. Run the setup command.
1. Run bash or minishell.
   - Without the -c option, add `; exit` to the command to test and run it.
1. Redirect stdout and stderr to files in `outputs/`.
1. Compare the stdout, stderr, and exit status of bash and minishell.

## About the test case

When you run the tests, you may see a lot of KO at first.
Please create your own test cases and try to run them only, or delete existing test cases.

### How to create test cases
- Create a text file in `cases/`.
- Write the command to be tested and the setup command in the text file separated by commas.
  - This means that the commands to be tested cannot contain commas.
- A newline is required at the end of the file. If there is no newline, the test on the last line will be ignored.

## Cautions
- The purpose of this tester is to prevent regressions by automated testing and to understand the bash specification.
- KO with this tester != KO in review. Please check the test cases, the subject, and the source code, and make your own decision.
- The following test cases are not covered.
  - `$"string"`
  - `` \` ``
  - `$_`
  - `$123`
  - Signals

## Acknowledgements
I would like to thank:
- [ToYeah](https://github.com/ToYeah), who worked on minishell with me, created many test cases for cd, echo, expand, pwd, etc.
