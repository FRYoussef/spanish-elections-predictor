"""
   Descp: This file is used to generate graphs from cities.csv, trends.csv, and count_list.csv

   Created on: 08-may-2019
   Copyright 2019 Youssef 'FRYoussef' El Faqir El Rhazoui
        <f.r.youssef@hotmail.com>
"""
import os
import networkx as nx
import pandas as pd

data_path = 'datawarehouse'

# Let's load cities as a dataframe
df = pd.read_csv(os.path.join(data_path, "cities.csv"), sep=";", header=0)

# Graph's nodes filling
base_graph = nx.Graph()
df.apply(lambda row: base_graph.add_node
    (
        int(row['Woeid']),
        id = int(row['Woeid']),
        label = row['Name'],
        province = row['Province'],
        region = row['Autonomous_Community'],
        population = row['Population'],
        longitude = row['Longitude'],
        latitude = row['Latitude']
    ), axis=1)

# Add trends as node attr
graph_list = list()
for i, filename in enumerate(os.listdir(os.path.join(data_path, 'raw', 'trends')), 0):
    date = filename.split('trends_')[1]
    date = date.split('.')[0]
    graph_list.append(base_graph.copy())
    graph_list[i].graph['date'] = date

    # load trends
    df = pd.read_csv(os.path.join(data_path, 'raw', 'trends', filename), sep=";", header=0)

    # Add trends as node attr
    for node_id in graph_list[i].nodes:
        dff = df[df['woeid'] == node_id]
        trends = set(dff['name'])
        graph_list[i].nodes[node_id]['trends'] = trends

# Let's link nodes. An edge will infer between A and B if both of them get the same trending topic
for graph in graph_list:
    node_list = list(graph.nodes(data='trends'))
    for i, (node_i, trends_i) in enumerate(node_list, 0):
        for j in range(i+1, len(node_list)):
            weight = len(trends_i.intersection(node_list[j][1]))
            graph.add_edge(node_i, node_list[j][0], weight = weight)

# clean trend sets
for graph in graph_list:
    for node in graph.nodes:
        del graph.nodes[node]['trends']