# Lab 0: files, folders and the terminal

Time: 25 minutes

Goal: open the course in VS Code, use the terminal to look around, and see that a CSV file is just text.

You need: VS Code installed and the course folder extracted (see [SETUP.md](../SETUP.md)).

## Step 1. Open the course folder in VS Code

1. Open VS Code.
2. Choose File, then Open Folder.
3. Pick the course folder (for example `C:\training\contact-centre-data-day1`) and click Select Folder.
4. If VS Code asks "Do you trust the authors of the files in this folder?", click Yes.

You should see: the file list on the left shows `README.md`, `SETUP.md`, `data`, `module-0-tools` and more.

## Step 2. Open the terminal

1. Choose Terminal, then New Terminal. A panel opens at the bottom.
2. Look at the last line in the panel. That is the prompt.

You should see something like:

```text
PS C:\training\contact-centre-data-day1>
```

The last part is the folder you are in. It should end with the course folder name.

If it says something else, close the terminal panel (click the bin icon), make sure you opened the course folder in step 1, and open a new terminal.

## Step 3. List what is in the folder

Type this and press Enter:

```powershell
dir
```

You should see a list that includes `data`, `module-0-tools`, `work`, `README.md` and `SETUP.md`.

> [!NOTE]
> What this does: `dir` asks the computer to show the contents of the current folder, the same as opening the folder in Explorer.

## Step 4. Move into a folder and back out

Type these one at a time:

```powershell
cd data
dir
cd ..
dir
```

You should see: after `cd data` the prompt ends with `\data` and the list shows files like `calls.csv`. After `cd ..` the prompt is back to the course folder.

If you get an error like "Cannot find path", you were not in the course folder. Type `cd ..` until the prompt ends with the course folder name, then try again.

## Step 5. Check Python

Type:

```powershell
python --version
```

You should see something like `Python 3.12.4`. The exact numbers do not matter as long as it starts with 3.

If Windows opens the Microsoft Store, or you see "Python was not found", tell your trainer. The fix is in the [troubleshooting page](../appendix/troubleshooting.md).

## Step 6. Make your first file

1. In the left panel, click the `work` folder to select it.
2. Click the New File icon (a page with a plus), type `hello.txt` and press Enter.
3. In the editor, type `This is my first file.` and press Ctrl+S to save.
4. In the terminal, type:

   ```powershell
   type work\hello.txt
   ```

You should see: `This is my first file.`

> [!NOTE]
> What this does: `type` prints what is inside a file. You wrote the words in the editor, saved them to disk, and now the terminal reads them back. The editor and the terminal are two views of the same file.

## Step 7. See what a CSV file really is

1. In the left panel, open `data`, then `practice`, then click `calls_sample.csv`.
2. Read the first three lines in the editor.

You should see:

```text
call_id,queue_id,arrived_at,wait_sec,talk_sec,hold_sec,wrap_sec,outcome
1,1,2026-10-01 07:05:10,5,240,0,30,answered
2,1,2026-10-01 07:12:44,12,310,20,45,answered
```

The first line holds the column names. Every other line is one call, and the commas separate its values.

3. Now find `calls_sample.csv` in Windows Explorer and double-click it. It opens in Excel as a table.

> [!NOTE]
> What this does: it shows the same data in two ways. Excel hides the commas and draws a grid. VS Code shows the raw text. Python and databases read the raw text.

## Step 8. Read the data like a detective

Look at the file in VS Code and answer these in your head or on paper:

1. How many columns does each call have?
2. What do you think `wait_sec` means?
3. Call 4 has `talk_sec` of 0 and an outcome of `abandoned`. What do you think happened on that call?

<details>
<summary>Answers</summary>

1. Eight columns.
2. How many seconds the caller waited before an agent answered (or before they gave up).
3. The caller hung up before an agent answered, so there was no conversation and talk time is 0.

</details>

## Check yourself

1. What does `cd ..` do?
2. What is the difference between a file and a folder?
3. Why does a CSV file look different in Excel and in VS Code?

<details>
<summary>Answers</summary>

1. It moves the terminal one folder up.
2. A folder holds files and other folders. A file holds information.
3. It is the same text. Excel turns the commas into a grid. VS Code shows the text as it is.

</details>

## Done?

If your terminal shows the course folder, `dir` works and you opened a CSV file, you are ready for Module 1.
