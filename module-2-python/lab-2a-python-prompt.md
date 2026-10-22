# Lab 2A: the Python prompt

Time: 15 minutes

Goal: type Python and see the answer straight away, so you know what each idea does before you save anything in a file.

You need: VS Code open on the course folder with a terminal at the bottom. Your prompt should end with the course folder name. If it starts with `(.venv)`, that is fine and expected.

## Step 1. Start Python

In the terminal type:

```powershell
python
```

You should see a few lines about the Python version, then a new prompt:

```text
>>>
```

The `>>>` means Python is waiting for you. Anything you type now is Python, not a terminal command.

If you see `Python was not found` or the Microsoft Store opens, stop and ask your trainer.

## Step 2. Print a message

Type the line below, then press Enter:

```python
print("Hello, contact centre")
```

You should see:

```text
Hello, contact centre
```

> [!NOTE]
> What this does: `print` shows whatever is in the brackets on the screen. The quotes tell Python it is text, not an instruction.

## Step 3. Use it as a calculator

Type each line, one at a time, pressing Enter after each:

```python
2 + 3
573 - 49
```

You should see `5` and then `524`.

Python answers straight away because you typed an expression and it shows the result.

## Step 4. Put a number in a jar

```python
calls = 573
calls
calls * 2
```

You should see:

```text
573
1146
```

> [!NOTE]
> What this does: `calls = 573` puts 573 into a jar named `calls`. Typing `calls` on its own shows what is in the jar. `calls * 2` uses the jar like the number inside it. Nothing printed after the first line because putting something in a jar gives no answer.

## Step 5. Put text in a jar

```python
queue_name = "Billing"
queue_name
print(queue_name, "had", calls, "calls")
```

You should see:

```text
'Billing'
Billing had 573 calls
```

Notice that typing `queue_name` on its own shows quotes (`'Billing'`), but `print` shows plain words. The quotes mean "this is text".

## Step 6. Work out an answer rate

The answer rate is the share of calls that were answered.

```python
answered = 524
answered / calls * 100
round(answered / calls * 100, 1)
```

You should see:

```text
91.44851657940663
91.4
```

> [!NOTE]
> What this does: `/` divides and `*` multiplies. Python follows the same order as school maths, left to right. `round(number, 1)` keeps one number after the decimal point. Because `calls` and `answered` are jars, you can change what is in them and repeat the calculation.

## Step 7. Make a mistake on purpose

Type this, without the closing quote:

```python
print("Hello)
```

You should see an error ending with:

```text
SyntaxError: unterminated string literal (detected at line 1)
```

> [!NOTE]
> What this does: Python read an opening quote and never found the closing one. The error is not a disaster. Python tells you the problem on the last line. This is the most common beginner mistake.

## Step 8. Leave Python

```python
exit()
```

You should see your normal terminal prompt again (the one ending with the folder name, not `>>>`).

## Check yourself

1. What is the difference between `calls = 573` and `calls * 2`?
2. Why does `queue_name` show `'Billing'` with quotes?
3. What did the error message tell you?

<details>
<summary>Answers</summary>

1. The first puts 573 in the jar called `calls`. The second uses the number in the jar and multiplies it by 2, without changing the jar.
2. The quotes show it is text and not a number or a command.
3. That a piece of text was opened with a quote and never closed.

</details>

## Done?

If you got the answer `91.4` you are ready for [Lab 2B](lab-2b-first-script.md).
