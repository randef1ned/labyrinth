import os
os.environ['R_HOME'] = 'C:/Program Files/R/R-4.3.1'
from rpy2.robjects import r
import rpy2.robjects as robjects
from filter_words import run_stopword_statistics
from tqdm import tqdm
import pandas as pd

text_split = r.load('output/stopwords/text_split.Rdata')
text_split = robjects.r('text_split')
list_text = []
for text in tqdm(text_split):
    t = []
    for word in text:
        t.append(word)
    if len(t) > 0:
        list_text.append(t)

stop_words = run_stopword_statistics(list_text, N_s = 1000)
stop_words.to_csv('output/stopwords/entropy.csv')
