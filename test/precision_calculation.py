"""
   Descp: This file is used to measure the sentimental precision

   Created on: 23-may-2019
   Copyright 2019 Youssef 'FRYoussef' El Faqir El Rhazoui
        <f.r.youssef@hotmail.com>
"""
import os
import pandas as pd

data_path = "test"
total = 0
well_classified = 0
bad_classified = 0
not_classified = 0

clasification_res = pd.read_csv(os.path.join(data_path, "clasification_result.csv"), sep=";", header=0)
manual_anno = pd.read_csv(os.path.join(data_path, "manual_annotation.csv"), sep=",", header=0)

total = len(clasification_res.index)

for i, row in clasification_res.iterrows():
    supports = manual_anno.iloc[i][0]
    supports = supports.split(";")
    classified = True
    correctly = True
    for support in supports:
        party = support.split("=")

        if int(row[party[0]]) > 0 and party[1] == '+':
            correctly = correctly and True 
        elif int(row[party[0]]) > 0 and party[1] == '-':
            correctly = correctly and False
        elif int(row[party[0]]) < 0 and party[1] == '+':
            correctly = correctly and False
        elif int(row[party[0]]) < 0 and party[1] == '-':
            correctly = correctly and True
        elif int(row[party[0]]) == 0:
            classified = False
            break

    if classified and correctly:
        well_classified += 1
    elif classified and not correctly:
        bad_classified += 1
    else:
        not_classified += 1
        

if well_classified + bad_classified + not_classified == total:
    print('ok')
else:
    print('not ok')

with open(os.path.join(data_path, 'statistics.txt'), 'w') as file:
    file.write(f'Total sentences = {total}\n')
    file.write(f'Well classified = {well_classified} --> {well_classified/total * 100}\n')
    file.write(f'Bad classified = {bad_classified} --> {bad_classified/total * 100}\n')
    file.write(f'Not classified = {not_classified} --> {not_classified/total * 100}\n')