from pathlib import Path
import xml.etree.ElementTree as ET
from bs4 import BeautifulSoup
import csv
from tqdm import tqdm


info_file = open('original_data/clinicaltrials/trials_info.csv', 'w', newline = '')
info_writer = csv.writer(info_file)
itv_file = open('original_data/clinicaltrials/intervention.csv', 'w', newline = '')
itv_writer = csv.writer(itv_file)

info_writer.writerow(['NCT_ID', 'brief_title', 'official_title', 'summary', 'description', 'phase', 'study_type', 'study_allocation', 
                      'study_masking', 'study_enrollment', 'post_date', 'start_date', 'completion_date', 'result_reference', 'result_doi'])
itv_writer.writerow(['NCT_ID', 'intervention'])

# Get the list of XML files
xml_files = list(Path('original_data/clinicaltrials/xmls').glob('**/*.xml'))

# Iterate through XML files with a progress bar
for file in tqdm(xml_files, desc = "Processing XML files"):
    # Parse the XML file
    with open(file, 'r') as x:
        content = x.read()
    soup = BeautifulSoup(content, 'lxml')

    # Extract the title
    brief_title = soup.find('brief_title')
    if brief_title: 
        brief_title = brief_title.text.replace('\r', '').replace('\n', '')
    else:
        continue
    official_title = soup.find('official_title')
    official_title = official_title.text.replace('\r', '').replace('\n', '') if official_title else ''
    summary = soup.find('brief_summary')
    summary = ' '.join(summary.text.replace('\r', '').replace('\n', '').split()) if summary else ''
    description = soup.find('detailed_description')
    description = ' '.join(description.text.replace('\r', '').replace('\n', '').split()) if description else ''
    phase = soup.find('phase')
    if phase: 
        phase = ' '.join(phase.text.replace('\r', '').replace('\n', '').split())
    else:
        continue
    if phase == 'N/A': continue
    study_type = soup.find('study_type')
    if study_type: 
        study_type = ' '.join(study_type.text.replace('\r', '').replace('\n', '').split())
    else:
        continue
    study_allocation = soup.find('allocation')
    study_allocation = ' '.join(study_allocation.text.replace('\r', '').replace('\n', '').split()) if study_allocation else ''
    study_masking = soup.find('masking')
    study_masking = ' '.join(study_masking.text.replace('\r', '').replace('\n', '').split()) if study_masking else ''
    study_enrollment = soup.find('enrollment')
    study_enrollment = ' '.join(study_enrollment.text.replace('\r', '').replace('\n', '').split()) if study_enrollment else ''
    result_reference = soup.find('results_reference')
    result_reference = ' '.join(result_reference.text.replace('\r', '').replace('\n', '').split()) if result_reference else ''
    doi = result_reference.split('doi: ')[-1]
    post_date = soup.find('study_first_posted')
    post_date = post_date.text.replace('\r', '').replace('\n', '') if post_date else ''
    start_date = soup.find('start_date')
    start_date = start_date.text.replace('\r', '').replace('\n', '') if start_date else ''
    completion_date = soup.find('completion_date')
    completion_date = completion_date.text.replace('\r', '').replace('\n', '')  if completion_date else ''
    intervention = soup.find_all('intervention_name')

    info_writer.writerow([file.stem, brief_title, official_title, summary, description, phase, study_type, study_allocation, 
                          study_masking, study_enrollment, post_date, start_date, completion_date, result_reference, doi])
    # Extract the "intervention" section
    for drug in intervention:
        drug = ' '.join(drug.text.replace('\r', '').replace('\n', '').split())
        # Write the interventions to the CSV file
        itv_writer.writerow([file.stem, drug])

info_file.close()
itv_file.close()
