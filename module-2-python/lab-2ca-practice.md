# Lab 2CA: practise on your own

Time: 25 minutes

Goal: write loops, a function and a condition yourself, with hints, until they feel normal.

You need: Lab 2C finished.

In Lab 2C you copied code. Here you write it. Each task gives you a goal, the output to aim for, and hints that get more direct. Try the task before you open a hint. Getting it wrong and fixing it is how this sticks. If you are stuck after the third hint, open the answer, read it, then close it and type it from memory.

> [!TIP]
> This is learning to drive. Lab 2C was the instructor driving while you watched the road. Now you hold the wheel, and the instructor has a hand near the brake.

Create a new file `work/practice_queues.py`. Put these two dictionaries at the top. They are the same ones from Lab 2C.

```python
offered = {"Billing": 573, "Claims": 592, "Eligibility": 413, "Provider Line": 354}
answered = {"Billing": 524, "Claims": 541, "Eligibility": 378, "Provider Line": 324}
```

Add each task below the one before it. Run after every task: `python work\practice_queues.py`

> [!NOTE]
> Run the file after each task. The output of the earlier tasks stays on screen too, so look at the bottom for the new lines. If you want less noise, put a `#` at the start of the earlier `print` lines to switch them off.

## Task 1. Abandoned calls per queue

Goal: for each queue, print the number of abandoned calls. Abandoned means offered minus answered.

Aim for:

```text
Billing abandoned: 49
Claims abandoned: 51
Eligibility abandoned: 35
Provider Line abandoned: 30
```

<details>
<summary>Hint 1</summary>

You need a loop that visits every queue name. In Lab 2C, Part 4 did that with `for name in offered:`.

</details>

<details>
<summary>Hint 2</summary>

Inside the loop (indented), make a jar called `abandoned` and put `offered[name]` minus `answered[name]` into it.

</details>

<details>
<summary>Hint 3</summary>

Then `print(name, "abandoned:", abandoned)`. Check that every line inside the loop starts with four spaces.

</details>

<details>
<summary>Answer</summary>

```python
for name in offered:
    abandoned = offered[name] - answered[name]
    print(name, "abandoned:", abandoned)
```

</details>

## Task 2. A function for the abandon rate

Goal: write a function called `abandon_rate` that takes abandoned calls and offered calls and returns the percentage, rounded to 1 decimal place. Test it on Billing.

Aim for:

```text
Billing abandon rate: 8.6
```

<details>
<summary>Hint 1</summary>

Look at `answer_rate` in Lab 2C, Part 3. Your function has the same shape: `def`, a name, two ingredients in brackets, a colon, and an indented `return` line.

</details>

<details>
<summary>Hint 2</summary>

The calculation is abandoned divided by offered, times 100, inside `round( ..., 1)`.

</details>

<details>
<summary>Hint 3</summary>

To test it, call it with Billing's numbers inside a print: `print("Billing abandon rate:", abandon_rate(49, 573))`. The test line is not indented, because it is outside the function.

</details>

<details>
<summary>Answer</summary>

```python
def abandon_rate(abandoned_calls, offered_calls):
    return round(abandoned_calls / offered_calls * 100, 1)

print("Billing abandon rate:", abandon_rate(49, 573))
```

</details>

## Task 3. Flag the queues that need attention

Goal: loop over all queues, work out each abandon rate using your function, print it, and print `   needs attention` underneath when the rate is above 8.5. The indented message starts with three spaces so it lines up.

Aim for:

```text
Billing 8.6 percent
   needs attention
Claims 8.6 percent
   needs attention
Eligibility 8.5 percent
Provider Line 8.5 percent
```

<details>
<summary>Hint 1</summary>

Copy the loop from Task 1 and add a line that works out `rate` by calling `abandon_rate(abandoned, offered[name])`.

</details>

<details>
<summary>Hint 2</summary>

Print `name, rate, "percent"`. Then add an `if` line: `if rate > 8.5:` and end it with a colon.

</details>

<details>
<summary>Hint 3</summary>

The `print("   needs attention")` line goes under the `if`, pushed in one more level. That means eight spaces from the left edge: four for the loop and four more for the `if`. Draw the boxes: the loop box contains the `if` box.

</details>

<details>
<summary>Answer</summary>

```python
for name in offered:
    abandoned = offered[name] - answered[name]
    rate = abandon_rate(abandoned, offered[name])
    print(name, rate, "percent")
    if rate > 8.5:
        print("   needs attention")
```

</details>

## Task 4. Count the flagged queues

Goal: print how many queues need attention, once, after the loop has finished.

Aim for:

```text
Queues needing attention: 2
```

<details>
<summary>Hint 1</summary>

You need a counter. A counter is a jar that starts at 0 before the loop. Write `flagged = 0` above the loop, at the left edge.

</details>

<details>
<summary>Hint 2</summary>

Inside the `if`, add one to it: `flagged = flagged + 1`. Read it right to left: take the jar, add 1, put it back in the jar.

</details>

<details>
<summary>Hint 3</summary>

The final print must not be indented at all. If it is indented, it runs once per queue instead of once at the end. This is the box idea from Lab 2C.

</details>

<details>
<summary>Answer</summary>

```python
flagged = 0
for name in offered:
    abandoned = offered[name] - answered[name]
    rate = abandon_rate(abandoned, offered[name])
    if rate > 8.5:
        flagged = flagged + 1
print("Queues needing attention:", flagged)
```

This repeats the loop on purpose. Your Task 3 loop can stay in the file as it is. You will see its output too.

</details>

## Task 5. Challenge: a function that gives a label

Goal: write a function `rating` that takes a rate and returns the text `"needs attention"` if it is above 8.5, otherwise `"ok"`. Then loop over the queues and print each name with its rating.

Aim for:

```text
Billing needs attention
Claims needs attention
Eligibility ok
Provider Line ok
```

<details>
<summary>Hint 1</summary>

The function has one ingredient: `rate`. Inside it, use an `if` and a `return`.

</details>

<details>
<summary>Hint 2</summary>

Put `return "needs attention"` under the `if`, and `return "ok"` on the next line, back at the same level as the `if`. When the `if` is true, the function hands back the first answer and stops. Otherwise it carries on to the second.

</details>

<details>
<summary>Hint 3</summary>

In the loop, work out the rate with `abandon_rate(...)` as before, then `print(name, rating(rate))`.

</details>

<details>
<summary>Answer</summary>

```python
def rating(rate):
    if rate > 8.5:
        return "needs attention"
    return "ok"

for name in offered:
    rate = abandon_rate(offered[name] - answered[name], offered[name])
    print(name, rating(rate))
```

</details>

## If you got stuck on the same error three times

Check these in order:

1. Does the line before the indented block end with a colon?
2. Do all lines in the block start with the same number of spaces?
3. Is a line that should run once at the end pushed in by mistake, or the other way round?
4. Are your brackets and quotes all closed?

## Check yourself

1. Which Task 4 line must stay at the left edge, and why?
2. What does `flagged = flagged + 1` do?
3. What happens in a function when `return` runs?

<details>
<summary>Answers</summary>

1. `flagged = 0` and the final print. The first must run once before the loop starts, and the last once after it ends.
2. It takes the number in the jar, adds 1, and puts the new number back in the same jar.
3. The function stops and hands the value back to the line that called it.

</details>

## Done?

Compare with [solutions/practice_queues.py](solutions/practice_queues.py) if you like. Next is [Lab 2D](lab-2d-read-a-csv.md), where you load real data.
