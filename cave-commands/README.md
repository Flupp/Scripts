cave commands
=============

In addition to built-in commands, cave will also look in the directories named
in the colon-separated CAVE_COMMANDS_PATH environment variable, or, if unset,
`/usr/libexec/cave/commands`. Any executables in this path will also be
available as commands (with any file extension stripped); these executables may
use the $CAVE environment variable to get access to the main cave program.
