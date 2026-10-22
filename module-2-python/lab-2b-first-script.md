# Lab 2B: your first Python file

Time: 20 minutes

Goal: save instructions in a file, run the file, change it, and read an error message.

You need: VS Code open on the course folder, a terminal at the bottom, and Lab 2A finished.

A file of Python instructions is called a script. Python runs the script from the first line to the last.

## Step 1. Create the file

1. In the left panel, click the `work` folder.
2. Click the New File icon, type `answer_rate.py` and press Enter.
3. Type these lines into the file. Type them rather than pasting, because typing helps you notice the pieces. Press Enter at the end of each line, and use a blank line where you see one.

```python
# Answer rate for one queue
queue_name = "Billing"
offered = 573
answered = 524

answer_rate = answered / offered * 100

print("Queue:", queue_name)
print("Offered:", offered)
print("Answered:", answered)
print("Answer rate:", round(answer_rate, 1), "percent")
```

4. Press Ctrl+S to save.

> [!NOTE]
> What this does: the first line starts with `#`, which makes it a comment. Python ignores comments, and people use them to leave notes. The next three lines put values into jars. The `answer_rate` line does the sum. The `print` lines show the results.

## Step 2. Run it

Make sure the terminal prompt ends with the course folder name. Then type:

```powershell
python work\answer_rate.py
```

You should see:

```text
Queue: Billing
Offered: 573
Answered: 524
Answer rate: 91.4 percent
```

If you see `can't open file`, you are probably in the wrong folder. Type `cd` followed by the path of the course folder, or close the terminal and open a new one from VS Code.

## Step 3. Change a value and run again

1. In the file, change the three values to the Eligibility queue: `queue_name = "Eligibility"`, `offered = 413` and `answered = 378`.
2. Save with Ctrl+S. Forgetting to save is the most common reason a change appears to do nothing.
3. Run the file again with the same command.

You should see:

```text
Queue: Eligibility
Offered: 413
Answered: 378
Answer rate: 91.5 percent
```

> [!NOTE]
> What this does: the script did the same job with different inputs. This is why programs are useful. You change one line and get a new answer without redoing any sums.

## Step 4. Break it on purpose

1. In the file, delete the closing quote in `print("Queue:", queue_name)`, so the line becomes `print("Queue:, queue_name)`.
2. Save and run the file.

You should see an error ending with:

```text
SyntaxError: unterminated string literal (detected at line 8)
```

3. Put the quote back, save and run again. The correct output returns.

> [!NOTE]
> What this does: Python could not find where the text ended. The last line of an error names the problem, and the line number tells you where to look.

## Step 5. Add two lines of your own

1. Add these two lines directly below the `answer_rate = ...` line:

```python
abandoned = offered - answered
abandon_rate = abandoned / offered * 100
```

2. Add this line directly below `print("Answered:", answered)`:

```python
print("Abandoned:", abandoned)
```

3. Add this line at the very bottom of the file:

```python
print("Abandon rate:", round(abandon_rate, 1), "percent")
```

4. Save and run.

You should see:

```text
Queue: Eligibility
Offered: 413
Answered: 378
Abandoned: 35
Answer rate: 91.5 percent
Abandon rate: 8.5 percent
```

The order of the output follows the order of your `print` lines. If a number is different, check the three values at the top of the file.

> [!NOTE]
> What this does: `offered - answered` is every call that was not answered. Those calls were abandoned. Python reads from top to bottom, so `abandoned` must be created before `abandon_rate` uses it.

If your file does not work, compare it with [solutions/answer_rate.py](solutions/answer_rate.py).

## Check yourself

1. Why must you press Ctrl+S before running?
2. What does the `#` at the start of a line do?
3. What happens if a line uses a jar that has not been created yet?

<details>
<summary>Answers</summary>

1. Python runs the file saved on disk, not the unsaved text in the editor.
2. It turns the line into a comment that Python ignores.
3. Python stops with a `NameError` that names the missing jar.

</details>

## Done?

Next is [Lab 2C](lab-2c-lists-and-dictionaries.md).
