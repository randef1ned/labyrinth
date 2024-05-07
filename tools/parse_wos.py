# -*- coding: utf-8 -*-
from pathlib import Path
import csv
from tqdm import tqdm
from collections import OrderedDict
import sqlite3
# import tqdm_pathos
from tqdm.contrib.concurrent import process_map

# set data paths
#data_dir = Path('D:/Data/Downloads')
data_dir = Path('F:/backup/WOS/Downloads')

# TODO: restore this line
# db = mysql.connector.connect(host = 'localhost', user = 'root', password = 'root', database = 'wos')
# db = sqlite3.connect('F:/labyrinth-ext/original_data/wos/info.db')
db = sqlite3.connect('D:/models/info.db')
cursor = db.cursor()

"""
# prepare for the mesh synonyms
mesh_synonyms = {}
with open(Path('data/mesh/mesh.csv').absolute(), 'r', newline = '', encoding = 'utf-8') as f:
    mesh_reader = csv.reader(f)
    next(mesh_reader, None)
    for mesh in mesh_reader:
        mesh_synonyms[mesh[1]] = mesh[0]
    del mesh_reader"""

# read the menu file
drugs = {}
with open(Path('output/query_words.txt').absolute(), 'r', encoding='utf-8') as drug_file:
    drug_list = drug_file.readlines()
    drug_line_id = 0
    for drug in drug_list:
        drug_line_id += 1
        synonyms = drug.strip().replace(' OR ', '|').replace('"', '').split('|')
        for synonym in synonyms:
            drugs[synonym] = drug_line_id

# wrap the main function
def parse(file_info):
    file_path, drug_id = file_info

    with open(file_path.absolute(), 'r', encoding = 'utf-8-sig') as f:
        operator = ''
        infos = {
            'title': '', 'doi': '', 'abstract': '', 'keywords_str': '', 'category': '', 'area': '', 'pub_month': '', 'pub_year': '', 'nation': '', 'pub_type': '', 'cites': '', 'refs': []
        }
        # read exported wos data
        while wos_line := f.readline():
            wos_line = wos_line.rstrip()
            
            # deal with the empty lines
            line_value = wos_line[2:]
            if (not len(wos_line)) and (not len(line_value)):
                continue
            # deal with the line break in WOS file
            if len(wos_line[0:2].strip()):
                operator = wos_line[0:2]
            # save the title
            if operator == 'TI':
                infos['title'] += ' ' + line_value.lower()
            # save the doi
            elif operator == 'DI':
                infos['doi'] += ' ' + line_value.lower()
            # save the abstract
            elif operator == 'AB':
                infos['abstract'] += line_value.lower()
            # save the keywords
            elif operator in ['DE', 'ID']:
                if wos_line[0:2] == 'ID':
                    infos['keywords_str'] += '; '
                infos['keywords_str'] += line_value.lower()
            # save the publication date
            elif operator == 'PD':
                infos['pub_month'] = line_value
            elif operator == 'PY':
                infos['pub_year'] = line_value
            # save the publication type
            elif operator == 'DT':
                infos['pub_type'] = line_value.lower()
            # save the references
            elif operator == 'CR':
                line_value = line_value.replace(', DOI ', '|').split('|')
                if len(line_value) > 1:
                    infos['refs'].append(line_value[-1].lower())
            # save the research areas
            elif operator == 'SC':
                infos['area'] = line_value
            # save the categories
            elif operator == 'WC':
                infos['category'] = line_value
            # save the total cite times
            elif operator == 'TC':
                infos['cites'] = line_value
            # save the nationality
            elif operator == 'RP':
                corresponder_list = line_value.split(';')
                nation_list = set()
                for corresponder in corresponder_list:
                    corr_info = corresponder.split(',')
                    corr_info = corr_info[-1].replace('.', ' ').strip()
                    if 'USA' in corr_info:
                        corr_info = 'USA'
                    nation_list.add(corr_info)
                infos['nation'] = ';'.join(nation_list)
            # if encountered "END" mark, then proceed the read data
            elif operator == 'ER':
                # remove the leading spaces in infos dictionary
                for key, value in infos.items():
                    if isinstance(value, list):
                        infos[key] = [v.strip().replace('  ', ' ') for v in value]
                    else:
                        infos[key] = value.strip().replace('  ', ' ')
                
                # if no doi, then delete it
                doi = infos['doi']
                title = infos['title']
                abstract = infos['abstract']
                keywords_str = infos['keywords_str']
                if not len(doi):
                    continue

                # if the article is 'Correction', then delete it
                if infos['pub_type'] in ['correction', 'news item', 'note', 'retracted publication', 'retraction', 'biographical-item']:
                    continue

                # split keywords_str to keywords and remove duplicates
                # https://stackoverflow.com/questions/48283295/how-to-remove-case-insensitive-duplicates-from-a-list-while-maintaining-the-ori
                keywords_list = [k.strip() for k in infos['keywords_str'].split(';')]
                keywords = set()
                for keyword in keywords_list:
                    if len(keyword):
                        keywords.add(keyword.lower())
                keywords_str = ';'.join(keywords)
                
                # if no keywords appears in either abstract, title, or keywords, then delete it
                main_text = ' '.join([abstract, keywords_str, title]).upper()
                skip_this = True
                for drug_name, drug_line_id in drugs.items():
                    if drug_line_id == drug_id and drug_name in main_text:
                        skip_this = False
                        break
                if skip_this:
                    continue

                # merge the date
                month = infos['pub_month'].split('-')[0].replace(infos['pub_year'], '')
                if not any([char.isdigit() for char in month]):
                    month += ' 1'
                month += ' ' + infos['pub_year']
                infos['pub_date'] = month.replace('  ', ' ').strip()

                # save the details and edge lists
                journal_id = doi.split('/')[0]
                paper_id = '/'.join(doi.split('/')[1:])
                # do not remove duplicate records
                # remove duplicated records after insertion
                
                # replace the disease names (in mesh terms) to mesh ID
                """
                for synonym, mesh_id in mesh_synonyms.items():
                    synonym = ' {0} '.format(synonym)
                    mesh_id = ' MESHMESH{0} '.format(mesh_id)
                    title = title.replace(synonym, mesh_id)
                    abstract = abstract.replace(synonym, mesh_id)
                    keywords_str = keywords_str.replace(synonym, mesh_id)"""
            
                sql = "INSERT INTO `info` (`drug_id`, `doi`, `title`, `abstract`, `keywords`, `study_category`, `pub_date`, `nation`, `research_areas`, `pub_type`, `cite_count`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                val = (drug_id, doi, title, abstract, keywords_str, infos['category'], infos['pub_date'], infos['nation'], infos['area'], infos['pub_type'], infos['cites'])
                cursor.execute(sql, val)

                # TODO: restore these lines
                #rows = [(drug_id, infos['doi'], edge) for edge in infos['refs']]
                #sql = "INSERT INTO `edge` (`drug_id`, `paper`, `ref`) VALUES (%s, %s, %s)"
                #cursor.executemany(sql, rows)

            # if encountered "BEGIN" mark, then initialize the data
            elif operator == 'PT':
                infos = {
                    'doi': '', 'title': '', 'abstract': '', 'keywords_str': '', 'category': '', 'area': '', 'pub_month': '', 'pub_year': '', 'nation': '', 'pub_type': '', 'cites': '', 'refs': []
                }
    

# list all files in data directory
if __name__ == '__main__':
    drug_files = [[x, int(x.parent.name)] for x in list(data_dir.rglob('**/*.txt')) if x.is_file()]
    drug_id = list(range(len(drug_files)))

    # tqdm_pathos.map(parse, drug_files, n_cpus = 14)
    # for drug in tqdm(drug_files):
    #     parse(drug)
    for drug in tqdm(drug_id):
        parse(drug_files[drug])
        if drug % 20 == 0:
            db.commit()
    db.close()

