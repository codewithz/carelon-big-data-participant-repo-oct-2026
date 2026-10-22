# Module 0: Your tools

Time: 40 minutes

Before any data work, you need to feel comfortable with four things: files, folders, the terminal and VS Code. This module is short and nothing here is hard. Everything else in the course builds on it.

## Files and folders

A file holds information. A folder holds files and other folders. You already use both every day.

> [!TIP]
> Think of a filing cabinet. Each drawer is a folder. Each document inside is a file. A path is the address that says which drawer and which document, for example `C:\training\contact-centre-data-day1\data\calls.csv`.

A path read from left to right goes from the biggest container to the smallest. `C:` is the drive, `training` is a folder on it, and so on, down to the file name at the end.

## The terminal

The terminal is a window where you give the computer instructions by typing them instead of clicking.

> [!TIP]
> Clicking is like pointing at a menu in a restaurant. The terminal is like telling the waiter exactly what you want. It feels slower for one dish and much faster when you want the same thing fifty times.

You type a command and press Enter. The computer runs it and prints the answer underneath. The line where you type is called the prompt. It shows which folder you are currently in.

You will use four commands today.

| Command | What it does | Example |
| --- | --- | --- |
| `dir` | Lists what is in the current folder | `dir` |
| `cd` | Moves into a folder ("change directory") | `cd data` |
| `cd ..` | Moves back out, one folder up | `cd ..` |
| `python` | Runs a Python program | `python work\hello.py` |

## What is a program?

A program is a list of instructions written in a language the computer understands. Python is one such language. You write the instructions in a text file, and then you ask Python to follow them.

> [!TIP]
> A program is a recipe. The file is the recipe card. Running the program is cooking the dish. Change the card and the next dish changes.

## CSV files

You will meet CSV files all day. A CSV file is a table saved as plain text, with a comma between each value. The name means "comma separated values". Excel can open it as a table. Notepad shows what is really inside.

## VS Code

VS Code is the program you will use to write code. Think of it as Notepad with extras: it colours the words so you can read them, and it has a terminal built in at the bottom. When you open a folder in VS Code and then open its terminal, the terminal starts in that folder. That saves you typing paths.

## Lab 0: files, folders and the terminal

Go to [Lab 0](lab-0-terminal.md) and do the steps in order.
