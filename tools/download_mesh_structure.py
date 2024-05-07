from pathlib import Path
import csv
from tqdm import tqdm
from selenium import webdriver
from time import sleep
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from time import time
from json import loads
from bs4 import BeautifulSoup

options = webdriver.ChromeOptions()
options.add_argument('--no-sandbox')
options.add_argument('--no-default-browser-check')
options.add_argument('--no-first-run')
options.add_argument('--disable-default-apps')
options.add_argument('--no-proxy-server')

options.binary_location = "D:/software/ungoogled-chromium/chrome.exe"

driver = webdriver.Chrome(options = options, service = Service("D:/software/ungoogled-chromium/chromedriver.exe"))
driver.get("https://meshb.nlm.nih.gov/treeView")
sleep(2)

structure_file = open(Path('data/mesh/structure.csv'), 'w', newline = '', encoding = 'utf-8')
writer = csv.writer(structure_file)
writer.writerow(['from_id', 'from_desc', 'to_id', 'to_desc'])

# find parent node
while True:
    parent_node = driver.find_element(By.XPATH, '//ul[@class="treeItem"]/li/a[@id="tree__node_C"]/./..')
    expand_buttons = parent_node.find_elements(By.XPATH, '//i[@class="fa fa-plus-circle treeCollapseExpand fakeLink"]')
    hidden = []
    for expand_button in expand_buttons:
        h = True
        try:
            driver.execute_script("arguments[0].scrollIntoView();", expand_button)
            h = bool('none' in expand_button.get_attribute('style'))
            hidden.append(h)
        except:
            pass
        if not h:
            # expand_button.click()
            driver.execute_script("arguments[0].click();", expand_button)
            sleep(1)
    if len(expand_buttons) == sum(hidden):
        break
    sleep(12)

# read all html
all_nodes = driver.find_element(By.XPATH, '//div[@class="container"]/ul[@class="treeItem"]').get_attribute("innerHTML")
soup = BeautifulSoup(all_nodes, 'html5lib')

all_links = soup.find_all('a')
all_mesh_ids = []
all_descs = []
for link in all_links:
    try:
        mesh_id = link['href'].split('=')[-1]
        desc = link.span.text
        # parent nodes
        # a.li.ul
        parent = link.parent.parent.parent.a
        parent_id = parent['href'].split('=')[-1] if parent.has_attr('href') else ''
        parent_desc = parent.span.text
        print([parent_id, parent_desc, mesh_id, desc])
        writer.writerow([parent_id, parent_desc, mesh_id, desc])
    except:
        pass

structure_file.close()
