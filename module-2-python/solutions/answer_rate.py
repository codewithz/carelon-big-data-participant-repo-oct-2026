# Answer rate for one queue
queue_name = "Eligibility"
offered = 413
answered = 378

answer_rate = answered / offered * 100
abandoned = offered - answered
abandon_rate = abandoned / offered * 100

print("Queue:", queue_name)
print("Offered:", offered)
print("Answered:", answered)
print("Abandoned:", abandoned)
print("Answer rate:", round(answer_rate, 1), "percent")
print("Abandon rate:", round(abandon_rate, 1), "percent")
