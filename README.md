VIM TestRunner Plugin
=====================

[![Build Status](https://travis-ci.org/ToadJamb/vim_test_runner.svg?branch=master)](https://travis-ci.org/ToadJamb/vim_test_runner)

This plugin runs your tests without leaving vim using named pipes.
The recommended setup is tmux combined with vim so that you can see
the test output on the same screen without having to leave the editor.


Requirements
------------

* Ruby


Installation
------------

[Vundle](https://github.com/gmarik/vundle) is recommended for plugin management.

When using [Vundle](https://github.com/gmarik/vundle), simply add
the following line to your .vimrc:

		Bundle 'ToadJamb/vim_test_runner'


KeyBindings
-----------

Add the following to your .vimrc to add a keybinding using your leader key:

		map <silent> <leader>t :call TriggerTest()<CR>
		map <silent> <leader>r :call TriggerPreviousTest()<CR>


Add the following to your .vimrc to add a keybinding using a custom vim command:

		command tt :execute TriggerTest()
		command tr :execute TriggerPreviousTest()


Usage
-----

Create a named pipe:

		$ mkfifo [file_path]

`file_path` may be any one of the following
(in order of significance to test runner):

1. ~/.[project root folder].test_runner
2. [project path]/.test_runner
3. ~/.test_runner

From your project root, run the test runner using Ruby:

		$ ruby ~/.vim/bundle/vim_test_runner/test_runner

If you used the keybindings above, `<leader>t` will set the test that you run.
Once a test has been set, `<leader>r` may be used to re-run that test regardless
of what buffer you're in or which line you're on. When you're ready to run a
different test, navigate to the file and line that you want to run
and hit `<leader>t` again to tell TestRunner to run the new test.

Running a file on line one will exclude the line number, thereby running all
specs in the file.


### Normal files

vim_test_runner will work with normal files, as well,
but they are not as robust and should only be used when named pipes
are not available (i.e. on windows platforms).

Normal files follow the same naming conventions as named pipes.

The biggest drawback is that the file is overwritten every time
parameters are read from it. This means that commands will not 'stack'
as they will with named pipes. At best, you can queue up one more comand.
The first one in will be the one that is kept.


Configuration
-------------

### Redefining Commands

TestRunner uses the file extension to determine which test to run.
Sensible defaults are included for Ruby (`bundle exec rspec [file] -l [line]`)
and Cucumber (`bundle exec cucumber [file] -l [line] -r features`).

If these defaults do not work for your project, you can create a yaml file to
tell TestRunner how to run your tests.

Substitution is done on `%f` (file name) and `%l` (line number).

The following examples result in the same commands being used to run the specs:

single line:

		rb: ruby_tester %f %l

multi-line:

		rb:
			- ruby_tester %f %l

explicit:

		rb:
			- ruby_tester %f %l
			- %l

The last version is recommended for test runners that allow you to specify line
numbers. This is so that TestRunner can leave out the line number when the
cursor is on the first line.

For example, the current implementation of the Ruby command would look like
this in the yaml file:

		rb:
			- bundle exec rspec %f %l
			- -l %l

Multiple commands may be included in the yaml file. The following example
overrides the Ruby command and adds one for JavaScript:

		rb:
			- bundle exec test %f %l
			- -l %l
		js:
			- npm test


### Yaml location

The yaml file may be created in one of two locations.

* The project root. This file is named `.test_runner.yaml`.
* Your home folder. This file is named
	`.[project_root_folder].test_runner.yaml`.

As an example, if your project is located at `/root/path/my_project` and you
wanted to use a yaml file in your home folder,
it would be named `.my_project.test_runner.yaml`.


Notes
-----

The canonical repo for this plugin lives
[here](https://www.bitbucket.org/ToadJamb/vim_test_runner), NOT on github.
It is on github only to ease use of installation via
[Vundle](https://github.com/gmarik/vundle).
