# arc(hive)

`arc` is a tool for storing small snippets.

## Usage

```sh
$ arc fib.rb
```

Opens your editor in a file called `fib/main.rb` (stored next to the
arc-executable).

When you later want to open the snippet again, you don't need to
extension (it will figure it out by itself):

```sh
$ arc fib
```

You can list all snippets:

```sh
$ arc -l
```

And search for them (only on Mac):

```sh
$ arc -s canvas
```

Bash completion is also available.

