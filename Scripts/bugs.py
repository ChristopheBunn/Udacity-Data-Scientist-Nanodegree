import pandas as pd
bugs = pd.read_csv('ml-bugs.csv')
print(bugs)
print("\nbugs is of type {}".format(type(bugs)))

num_total = bugs['Species'].size
print("\nThere are a total of {} bugs.".format(num_total))

species = bugs.groupby(['Species'])['Species'].count()
print("\n{} Species:\n{}".format(num_total, species))

colors = bugs.groupby(['Color'])['Color'].count()
print("\n{} Colors:\n{}".format(num_total, colors))

blue_bugs = bugs[bugs['Color'] == 'Blue'].groupby(['Species'])['Species'].count()
not_blue_bugs = bugs[bugs['Color'] != 'Blue'].groupby(['Species'])['Species'].count()

brown_bugs = bugs[bugs['Color'] == 'Brown'].groupby(['Species'])['Species'].count()
not_brown_bugs = bugs[bugs['Color'] != 'Brown'].groupby(['Species'])['Species'].count()

green_bugs = bugs[bugs['Color'] == 'Green'].groupby(['Species'])['Species'].count()
not_green_bugs = bugs[bugs['Color'] != 'Green'].groupby(['Species'])['Species'].count()

length17_bugs = bugs[bugs['Length (mm)'] < 17].groupby(['Species'])['Species'].count()
not_length17_bugs = bugs[bugs['Length (mm)'] >= 17].groupby(['Species'])['Species'].count()

length20_bugs = bugs[bugs['Length (mm)'] < 20].groupby(['Species'])['Species'].count()
not_length20_bugs = bugs[bugs['Length (mm)'] >= 20].groupby(['Species'])['Species'].count()

print("\nspecies, colors, and lengths are of type {}".format(type(species)))

# --------------------------------------------------------------------

import math

def entropy(elements):
    
    counts = list()
    counts_sum = 0
    entropy = 0
    
    for element in elements.iteritems():
        counts.append(element[1])         # put all counts in a list
        counts_sum += element[1]          # add all counts
        
    #print("elements = {}".format(elements))
    #print("counts = {}, sum = {}".format(counts, counts_sum))
    
    for count in counts:
        probability = count / counts_sum
        entropy -= probability*math.log2(probability)
        
    return pd.Series(data = [counts_sum, entropy], index = ['total', 'entropy'])

def information_gain(parent, child1, child2):
    p = entropy(parent)
    num_p = p['total']
    p_entropy = p['entropy']
    
    c1 = entropy(child1)
    num_c1 = c1['total']
    c1_entropy = c1['entropy']
    
    c2 = entropy(child2)
    num_c2 = c2['total']
    c2_entropy = c2['entropy']
    
    return p_entropy - (num_c1/num_p*c1_entropy + num_c2/num_p*c2_entropy)

# --------------------------------------------------------------------

print("Split Blue Information Gain = {}".format(round(information_gain(species, blue_bugs, not_blue_bugs), 5)))
print("Split Brown Information Gain = {}".format(round(information_gain(species, brown_bugs, not_brown_bugs), 5)))
print("Split Green Information Gain = {}".format(round(information_gain(species, green_bugs, not_green_bugs), 5)))
print("Split < 17 Information Gain = {}".format(round(information_gain(species, length17_bugs, not_length17_bugs), 5)))
print("Split < 20 Information Gain = {}".format(round(information_gain(species, length20_bugs, not_length20_bugs), 5)))