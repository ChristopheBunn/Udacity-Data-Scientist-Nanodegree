names =  input("Enter a list of comma-separated names:").title().split(',')
assignments =  input("Enter a list of comma-separated numbers of missing assignments:").split(',')
grades =  input("Enter a list of comma-separated grades:").split(',')

# message string to be used for each student
# HINT: use .format() with this string in your for loop
message = "Hi {},\n\nThis is a reminder that you have {} assignments left to \
submit before you can graduate. You're current grade is {} and can increase \
to {} if you submit all assignments before the due date.\n\n"

# write a for loop that iterates through each set of names,
# assignments, and grades to print each student's message
input_tuples = zip(names, assignments, grades)

for name, num_assignments, grade in input_tuples:
    print(message.format(name, int(num_assignments), int(grade), int(grade) + int(num_assignments)*2))