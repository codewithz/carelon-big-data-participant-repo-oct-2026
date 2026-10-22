# Part 1: a list
queues = ["Billing", "Claims", "Eligibility", "Provider Line"]
print("Queues:", queues)
print("How many:", len(queues))
print("First one:", queues[0])

queues.append("Web Chat")
print("After adding one:", len(queues))

for name in queues:
    print("-", name)

# Part 2: a dictionary
offered = {"Billing": 573, "Claims": 592, "Eligibility": 413, "Provider Line": 354}
answered = {"Billing": 524, "Claims": 541, "Eligibility": 378, "Provider Line": 324}
print("Billing offered:", offered["Billing"])

# Part 3: a function
def answer_rate(answered_calls, offered_calls):
    return round(answered_calls / offered_calls * 100, 1)

print("Billing answer rate:", answer_rate(524, 573))

# Part 4: everything together
for name in offered:
    rate = answer_rate(answered[name], offered[name])
    print(name, rate, "percent")
    if offered[name] > 500:
        print("   busy queue")
