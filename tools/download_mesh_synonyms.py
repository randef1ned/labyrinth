from pathlib import Path
import csv
from tqdm import tqdm
from selenium import webdriver
from time import sleep
from selenium.webdriver.common.by import By
from time import time
from json import loads
from bs4 import BeautifulSoup

options = webdriver.ChromeOptions()
options.add_argument('--no-sandbox')
options.add_argument('--no-default-browser-check')
options.add_argument('--no-first-run')
options.add_argument('--disable-default-apps')

options.binary_location = "D:/software/ungoogled-chromium/chrome.exe"

driver = webdriver.Chrome(options = options,
                          executable_path = "D:/software/ungoogled-chromium/chromedriver.exe")
driver.get("https://www.cochranelibrary.com/advanced-search/mesh")

sleep(2)

with open(Path('original_data/mesh/mesh.txt').absolute(), 'r') as f:
    mesh_list = f.readlines()
with open(Path('data/mesh/mesh.csv'), 'w', newline = '', encoding = 'utf-8') as detail_file:
    detail_writer = csv.writer(detail_file)
    detail_writer.writerow(['mesh_id', 'term'])

for mesh in tqdm(mesh_list, desc = 'Parsing'):
    mesh = mesh.strip().split('\t')
    mesh_id = mesh[0]
    mesh_term = mesh[-1]
    if mesh_id == 'mesh_id':
        continue

    url = 'https://www.cochranelibrary.com/delegate/scolarismesh/api/mesh/search?searchTerm={0}&searchUid={1}&_={2}'.format(mesh_term, mesh_id, int(time()))
    driver.get(url)
    sleep(0.2)
    page_content = BeautifulSoup(driver.page_source, 'lxml')
    page_content = loads(page_content.text)
    synonyms = page_content['exactMatches']
    if len(synonyms):
        synonyms = synonyms[0]['synonyms']
    else:
        continue
    with open(Path('data/mesh/mesh.csv'), 'a', newline = '', encoding = 'utf-8') as detail_file:
        detail_writer = csv.writer(detail_file)
        synonyms = synonyms.split(';')
        detail_writer.writerow([mesh_id, mesh_term.lower()])
        for syn in synonyms:
            syn = syn.strip()
            if len(syn):
                detail_writer.writerow([mesh_id, syn.lower()])

