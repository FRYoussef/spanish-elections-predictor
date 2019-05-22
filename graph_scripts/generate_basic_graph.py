"""
   Descp: This file is used to generate graphs from top10_population_cities.csv, trends.csv, and count_list.csv

   Created on: 08-may-2019
   Copyright 2019 Youssef 'FRYoussef' El Faqir El Rhazoui
        <f.r.youssef@hotmail.com>
"""
import os
import sys
import networkx as nx
import pandas as pd

data_path = 'datawarehouse'
word_list = ''

def normalize(x: int, values: list) -> int:
    if max(values) - min(values) == 0:
        return 1
    
    return (x - min(values)) / (max(values) - min(values))

# Word list upon create graphs
dir_list = os.listdir(os.path.join(data_path, 'raw'))
dir_list.remove('trends')
dir_list.remove('tweets')
if len(dir_list) == 0:
    print("Please, first create a word list, then run cleanWords.R and finally, run this script")
    sys.exit()

print("Please, select a word list to create graphs: ")
for i, _file in enumerate(dir_list, 0):
    print(f"{i}. {_file}")
word_list = int(input("Enter a number: "))
if word_list < 0 or word_list >= len(dir_list):
    print(f"{word_list} is not an allowed value")
    sys.exit()
word_list = dir_list[word_list]


# Let's load cities as a dataframe
df = pd.read_csv(os.path.join(data_path, "top10_population_cities.csv"), sep=";", header=0)

# Graph's nodes filling
print("Adding cities as graph's nodes ...")
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
        latitude = row['Latitude'],
        supportPP = 0,
        supportPSOE = 0,
        supportCs = 0,
        supportPodemos = 0,
        supportVox = 0
    ), axis=1)

# Add trends as node attr
graph_list = list()
for i, filename in enumerate(os.listdir(os.path.join(data_path, 'raw', 'trends')), 0):
    date = filename.split('trends_')[1]
    date = date.split('.')[0]
    graph_list.append(base_graph.copy())
    graph_list[i].graph['date'] = date
    graph_list[i].graph['supportPP']      = 0
    graph_list[i].graph['supportPSOE']    = 0
    graph_list[i].graph['supportCs']      = 0 
    graph_list[i].graph['supportPodemos'] = 0
    graph_list[i].graph['supportVox']     = 0

    # load trends
    df = pd.read_csv(os.path.join(data_path, 'raw', 'trends', filename), sep=";", header=0)

    # Add trends as node attr
    for node_id, label in graph_list[i].nodes(data='label'):
        dff = df[df['City'] == label]
        trends = set(dff['name'])
        graph_list[i].nodes[node_id]['trends'] = trends

# Let's link nodes. An edge will infer between A and B if both of them get the same trending topic
print("Linking graph's nodes ...")
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

# Normalize edge weights
print('Calculating political support ...')
norm_list = list()
for graph in graph_list:
    weights = list(zip(*graph.edges(data='weight')))
    map_norm_edge = {(ni << 32) + nj: normalize(weight, weights[2]) for (ni, nj, weight) in graph.edges(data='weight')}
    norm_list.append(map_norm_edge)

# Asign politician support
# P_support = sum((support_i + support_j) * norm_weight_i_j)
for i, graph in enumerate(graph_list, 0):
    file_name = os.path.join(data_path, 'raw', word_list, f"{graph.graph['date']}.csv")
    df = pd.read_csv(file_name, sep=";", header=0)

    for n_j in graph.nodes:
        df_j = df[df['City'] == graph.nodes[n_j]['label']]
        for n_k in graph.nodes:
            if not graph.has_edge(n_j, n_k):
                continue
            
            df_k = df[df['City'] == graph.nodes[n_k]['label']]
            edge_id = (n_j << 32) + n_k
            edge_id = edge_id if edge_id in norm_list[i] else (n_k << 32) + n_j

            # city political support
            graph.nodes[n_j]['supportPP']      += int((int(df_j['Support_PP'].iloc[0]) + int(df_k['Support_PP'].iloc[0])) * norm_list[i][edge_id])
            graph.nodes[n_j]['supportPSOE']    += int((int(df_j['Support_PSOE'].iloc[0]) + int(df_k['Support_PSOE'].iloc[0])) * norm_list[i][edge_id])
            graph.nodes[n_j]['supportCs']      += int((int(df_j['Support_Cs'].iloc[0]) + int(df_k['Support_Cs'].iloc[0])) * norm_list[i][edge_id])
            graph.nodes[n_j]['supportPodemos'] += int((int(df_j['Support_Podemos'].iloc[0]) + int(df_k['Support_Podemos'].iloc[0])) * norm_list[i][edge_id])
            graph.nodes[n_j]['supportVox']     += int((int(df_j['Support_VOX'].iloc[0]) + int(df_k['Support_VOX'].iloc[0])) * norm_list[i][edge_id])

            # statal political support
            graph.graph['supportPP']      += graph.nodes[n_j]['supportPP']
            graph.graph['supportPSOE']    += graph.nodes[n_j]['supportPSOE'] 
            graph.graph['supportCs']      += graph.nodes[n_j]['supportCs'] 
            graph.graph['supportPodemos'] += graph.nodes[n_j]['supportPodemos']
            graph.graph['supportVox']     += graph.nodes[n_j]['supportVox']

#write result
print('Writing results ...')
result_path = os.path.join(data_path, 'graphs', word_list)
if not os.path.exists(result_path):
    os.makedirs(result_path)

for graph in graph_list:
    file_name = f"graph_{graph.graph['date']}.graphml"
    nx.write_graphml_xml(graph, os.path.join(result_path, file_name))

print(f"Finished, data stored in: {result_path}")