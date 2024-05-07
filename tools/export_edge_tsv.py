from tqdm import tqdm
import csv

def replace_all(cell):
    cell = cell.strip()
    if cell.startswith('['):
        cell = cell[1:]
    # Delete 'doi'
    if cell.startswith('doi 1'):
        cell = cell.split(',')[0].replace('doi ', '')
    if cell.startswith('d0i'):
        cell = cell[3:]
    if cell.startswith('doi'):
        cell = cell.replace('doi', '')
    # Delete ');
    if cell[-3:] == "');":
        cell = cell[:-3]
    if not len(cell):
        cell = ''
    if cell[-1] == '\\':
        cell = cell[:-1]
    return cell.strip()

with open('D:/models/citations/edge.txt', 'r', encoding = 'utf-8') as f:
    for line in tqdm(f):
        cells = line.split(',')
        if cells[0] in ['row_id', None, '']:
            continue
        remove_spaces = []
        for cell in cells:
            remove_spaces.append(cell.strip())
        remove_spaces[0] = 0
        remove_spaces[1] = '{0}'.format(remove_spaces[1])
        # From cell
        remove_spaces[2] = remove_spaces[2].replace("'", '"')
        # To cell   Delete leading ' and space
        last_cell = remove_spaces[3][1:].replace('\n', '')
        
        remove_spaces[3] = '"{0}"'.format(replace_all(last_cell))
        if len(remove_spaces[3]) > 12:
            from_node = replace_all(remove_spaces[2])
            if len(from_node) > 10:
                remove_spaces[2] = from_node
                with open('D:/models/citations/{0}.tsv'.format(remove_spaces[1]), 'a', encoding = 'utf-8', newline = '') as edge:
                    edgewriter = csv.writer(edge, delimiter = '\t')
                    edgewriter.writerow(remove_spaces[2:4])
