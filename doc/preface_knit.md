- [1. From human memory to activation diffusion
  network](#from-human-memory-to-activation-diffusion-network)
- [2. Unique advantages of human cognitive
  abilities](#unique-advantages-of-human-cognitive-abilities)
- [3. Simulating Human Cognitive Abilities: The Way
  Forward](#simulating-human-cognitive-abilities-the-way-forward)
- [4. Simulating human knowledge representation using large-scale
  medical knowledge
  networks](#simulating-human-knowledge-representation-using-large-scale-medical-knowledge-networks)
- [5. Conclusion](#conclusion)
- [References](#references)

## 1. From human memory to activation diffusion network

Memory is a fundamental cognitive process that allows the brain to
store, acquire, and recall information. It serves as a temporary storage
system when sensory cues disappear ([Benjamin
2007](#ref-benjamin_memory_2007)). Memory plays a crucial role in
encoding, storing, retaining, and recalling everything from simple
sensory data to complex knowledge and experiences. Additionally, memory
is the basis for learning, planning, and decision-making ([Benjamin
2007](#ref-benjamin_memory_2007); [Nussenbaum, Prentis, and Hartley
2020](#ref-nussenbaum_memorys_2020)). Specifically, it enables us to
learn from past experiences and simulate potential future outcomes,
thereby influencing current behavior and future actions ([Schacter et
al. 2012](#ref-schacter_future_2012)).

The formation of memories, their recall, and reasoning based on them
involve a combination of systems and physiological processes that allow
humans to adapt well to their environment ([Schacter et al.
2012](#ref-schacter_future_2012); [Camina and Güell
2017](#ref-camina_neuroanatomical_2017); [Nairne and Pandeirada
2016](#ref-nairne_adaptive_2016)).Memory formation comprises three
stages: information perception, encoding, and storage ([Atkinson and
Shiffrin 1968](#ref-atkinson_human_1968)). These stages correspond to
three types of memory: (1) sensory memory ([Atkinson and Shiffrin
1968](#ref-atkinson_human_1968)) briefly stores raw physical stimuli
from primary receptors such as vision and hearing; (2) short-term memory
(STM) ([Baddeley 2000](#ref-baddeley_episodic_2000)) involves the
transient storage and manipulation of information, allowing individuals
to temporarily memorize small amounts of data to perform current and
future tasks; (3) long-term memory (LTM) ([Camina and Güell
2017](#ref-camina_neuroanatomical_2017)) is the long-term storage of
information, divided into episodic and implicit memory. Episodic memory
consists of knowledge processed and recalled at a conscious level, such
as personal experiences and specialized knowledge, while implicit memory
encompasses skills and habits expressed without conscious awareness,
such as fear, riding a bicycle, heart rate regulation, and other
conditioned reflexes ([Smith and Grossman
2008](#ref-smith_multiple_2008)). In contrast to the limited-capacity
sensory memory and STM, LTM is a more complex cognitive system with an
unlimited capacity for long-term storage and retrieval of a wide range
of information, including factual knowledge and personal experiences.

Memory can also be categorized into contextual memory, referring to an
individual’s personal experiences, and semantic memory, referring to
textual knowledge about concepts ([Renoult et al.
2019](#ref-renoult_knowing_2019)). Storing contextual and semantic
knowledge allows individuals to construct new knowledge based on past
experiences, facilitating their survival ([Kazanas and Altarriba
2015](#ref-kazanas_survival_2015)). In addition to storing information
and memories, LTM plays an important role in learning and reasoning. It
can automatically relate relationships and attributes between objects
([Nairne and Pandeirada 2016](#ref-nairne_adaptive_2016)), giving
individuals the ability to use stored skills and concepts to make
rational decisions by evaluating different choices in various
environments and predicting possible outcomes ([Camina and Güell
2017](#ref-camina_neuroanatomical_2017)).

The formation and consolidation of LTM involve several brain regions,
including the prefrontal lobe, associated with working memory and
situational memory in LTM ([Blumenfeld and Ranganath
2019](#ref-blumenfeld_lateral_2019)), and the temporal lobe, associated
with semantic memory in LTM ([Simmons and Martin
2009](#ref-simmons_anterior_2009)). The hippocampus acts as a relay
station for information ([Squire and Zola-Morgan
1991](#ref-squire_medial_1991)) and can integrate situational memory
into the semantic memory knowledge network stored in LTM ([Renoult et
al. 2019](#ref-renoult_knowing_2019)). Consequently, even for the same
concept or knowledge, the knowledge network formed by different
individuals can vary.

Each individual has unique experiences and backgrounds, leading to
different understandings and reactions when interpreting the same
information. LTM is stored as a vast and complex semantic network, which
includes various types of interconnected nodes, such as concepts,
memories, and experiences ([Collins and Loftus
1975](#ref-collins_spreading_activation_1975)). Other kinds of memories
or experiences are also integrated into this network; for example, an
individual’s representation of abstract concepts (e.g., time) may be
based on physical sensations ([Casasanto and Boroditsky
2008](#ref-casasanto_time_2008)). In such cases, individuals associate
time with their experiences, forming their knowledge network. This form
of organization is named semantic networks or knowledge networks,
emphasizing how information is interconnected and organized according to
meaning ([Lehmann 1992](#ref-lehmann_semantic_1992)).

In this article, we use the term **semantic network** to represent the
form of memory storage and organization in LTM, while **knowledge
network** refers to an artificially built knowledge network. In a
semantic network, concepts are represented as nodes, and
concept-to-concept relationships are represented as edges between nodes,
with edge weights indicating the strength of the association. A higher
edge weight implies a closer relationship between two nodes, typically
resulting in a higher recall rate after receiving a stimulus ([Anderson
1983](#ref-anderson_spreading_1983)). Learning and memorizing new
knowledge and experiences involve building new edges or reinforcing
existing ones. This organization facilitates information retrieval by
enabling individuals to jump from one concept to another in the network
and simultaneously activate neighboring nodes to form knowledge
connections, even if there is no direct correlation between them
([Lehmann 1992](#ref-lehmann_semantic_1992)). An interesting example is
that in the semantic network of some police officers, black people
produce a strong association with weapons, and this association is even
stronger if the police officer is sleep-deprived ([James
2018](#ref-james_stability_2018)). Another example is that an
individual’s preference for Coca-Cola or McDonald’s is determined by
their attitude and reflected in their semantic network ([Lee and Kim
2013](#ref-lee_comparison_2013); [Karpinski, Steinman, and Hilton
2005](#ref-karpinski_attitude_2005)).

Homogeneous networks consist of nodes with similar properties or
characteristics ([Mhatre and Rosenberg
2004](#ref-mhatre_homogeneous_2004)). Nodes represented as the same kind
of elements and edges connected nodes with high correlations, which
jointly creating a homogeneous network. The two examples mentioned above
illustrate that different individuals form different LTMs, and the
memory contents stored in their LTMs do not satisfy homogeneity.

Moving from one concept to an unrelated concept is impossible in a
homogeneous network. The process by which individuals store their
memories in the same semantic network and retrieve information from LTM
is often described as spreading activation, and this network is also
called the spreading activation network ([Sharifian and Samani
1997](#ref-sharifian_hierarchical_1997)). In this network model, if an
initial node is activated, this activation state spreads to other nodes
along connected edges. This diffusion process can quickly span multiple
network layers, extensively activating the concepts and memories
associated with the initial node. When a node receives activation above
a certain threshold, it is fully activated like neurons. Otherwise, it
will not be activated. This may lead to the recall of specific memories,
the formation of decisions, or the generation of problem-solving
strategies.

As mentioned earlier, some unrelated concepts in a semantic network may
have relatively strong associations. The implicit association test (IAT)
paradigm proposed by Greenwald can effectively test the edge connections
between nodes of an individual in a semantic network ([Greenwald,
McGhee, and Schwartz 1998](#ref-greenwald_measuring_1998); [Greenwald et
al. 2009](#ref-greenwald_understanding_2009)). This paradigm tests the
strength of association in the human brain between two nodes, i.e., the
edge weights. The mechanisms of association and activation in activation
diffusion networks depend on the strength of association between nodes.
If the strength is high, the probability of activation is relatively
high; if the strength is low, there is a higher probability of
non-activation. This theory partly explains the forgetting phenomenon
that occurs in human memory. Additionally, activation diffusion networks
enable individuals to retrieve necessary information, reorganize their
memories, and apply knowledge to the same or different situations. In
summary, activation diffusion networks effectively account for the
dynamic nature of memory retrieval and use.

## 2. Unique advantages of human cognitive abilities

Compared to computer programs, humans possess an ability to think about
problems from different perspectives and exhibit greater flexibility in
knowledge association ([Lehmann 1992](#ref-lehmann_semantic_1992)).
Therefore, humans have the advantage of applying knowledge from one
domain to another seemingly unrelated domain. For example, concepts from
biology can be transferred to economics ([Lawlor et al.
2008](#ref-lawlor_mendelian_2008)), economic models to the field of
electronic information ([Han et al. 2019](#ref-han_rational_2019)), and
linguistic concepts to neuroscience ([Mayberry et al.
2018](#ref-mayberry_neurolinguistic_2018)) and computer science ([H.
Zhang et al. 2023](#ref-zhang_algorithm_2023)). This characteristic has
led humans to create many cross-disciplinary fields, such as artificial
intelligence, computational biology, neuropolitics, and bioinformatics.
Humans can use intuition and creative thinking to solve problems, and
this ability to think across domains allows them to make new connections
between different areas, thereby building new disciplinary knowledge.

The human brain contains approximately 100 billion neurons and roughly
the same number of glial cells ([Bartheld, Bahney, and Herculano-Houzel
2016](#ref-von_bartheld_search_2016)), of each connected to thousands of
others via synapses ([Herculano-Houzel
2009](#ref-herculano_houzel_human_2009)). Neurons and glial cells form
extremely complex networks. Neurons communicate via the all-or-none
principle ([Pareti 2007](#ref-pareti_all_or_none_2007)), and glial cells
play crucial roles in central nervous system formation, neuronal
differentiation, synapse formation ([Allen and Lyons
2018](#ref-allen_glia_2018)), regulation of neuroinflammatory immunity
([Yang and Zhou 2019](#ref-yang_neuroinflammation_2019)), and
neurological diseases like dementia ([Kim, Choi, and Yoon
2020](#ref-kim_neuron_glia_2020)), in addition to their traditional
supportive functions ([Wolosker et al.
2008](#ref-wolosker_d_amino_2008)). Such complexity lays the foundation
for an individual’s ability to process information, experience emotions,
maintain awareness, and exhibit creativity.

Drawing on the fundamentals of human cognition, artificial neural
networks have been simulated using computers to mimic the brain’s
information processing. They emulate human cognitive abilities to some
extent, excelling in tasks like learning, decision-making, and pattern
recognition that humans are naturally proficient at ([Agatonovic-Kustrin
and Beresford 2000](#ref-agatonovic_kustrin_basic_2000); [Parisi
1997](#ref-parisi_artificial_1997)). The simulation of human cognitive
abilities has shown great potential ([Parisi
1997](#ref-parisi_artificial_1997); [Zahedi
1991](#ref-zahedi_introduction_1991)). However, the neurons used in deep
learning and artificial neural networks are highly abstract, and the
architecture is unable to account for the neurons ([Cichy and Kaiser
2019](#ref-cichy_deep_2019)). Therefore, this field has focused more
attention on fitting data rather than interpreting it ([Pichler and
Hartig 2023](#ref-pichler_machine_2023)).

Currently, the field of deep learning is more concerned with fitting
data, the effect of fitting is used as a guiding criterion in this
field, rather than integrating cognitive mechanisms discovered by
neuroscience ([Chavlis and Poirazi 2021](#ref-chavlis_drawing_2021)).
Much of the progress in deep learning over recent decades can be
attributed to the application of backpropagation, often used with
optimization methods to update weights and minimize the loss function.
However, while neural networks and deep learning are biologically
inspired approaches, the biological rationality of backpropagation
remains questionable, as activated neurons do not acquire features
through backpropagation ([Whittington and Bogacz
2019](#ref-whittington_theories_2019); [Lillicrap et al.
2020](#ref-lillicrap_backpropagation_2020); [Aru, Suzuki, and Larkum
2020](#ref-aru_cellular_2020)). Currently, two mainstream learning
mechanisms have been identified in the human brain using
electrophysiological methods: Hebbian learning ([Munakata and Pfaffly
2004](#ref-munakata_hebbian_2004)) and reinforcement learning
([Botvinick et al. 2019](#ref-botvinick_reinforcement_2019)).
Additionally, synaptic pruning may be related to learning ([Halassa and
Haydon 2010](#ref-halassa_integrated_2010)), and epigenetic mechanisms
also play an important role ([Changeux, Courrège, and Danchin
1973](#ref-changeux_theory_1973)). Although Hebbian learning,
reinforcement learning, and attempts to migrate human cognitive
mechanisms have been applied in deep learning for years, they still
cannot perfectly reproduce human learning features ([Volzhenin,
Changeux, and Dumas 2022](#ref-volzhenin_multilevel_2022)).
Comparatively, the energy consumption when using neural networks for
reasoning is huge ([Desislavov, Martínez-Plumed, and Hernández-Orallo
2023](#ref-desislavov_trends_2023)), in contrast to the human brain’s
lower energy usage for training and reasoning ([Attwell and Laughlin
2001](#ref-attwell_energy_2001)).

Another example is the attention mechanism in neural networks, inspired
by human attention ([Vaswani et al. 2023](#ref-vaswani_attention_2023)).
Attention is a cognitive ability that selectively receives information
with limited resources ([Nelson Cowan et al.
2005](#ref-cowan_capacity_2005)). It’s a complex biological process
involving multiple brain regions, encompassing not only selective
attention but also coordinated consciousness, memory, and cognition.
Selective attention mechanisms are associated with short-term memory,
where only 3-5 chunks of original stimuli can enter during a single
session ([N. Cowan 2001](#ref-cowan_magical_2001)), with attention
lasting just a few seconds to minutes ([Polti, Martin, and Van
Wassenhove 2018](#ref-polti_effect_2018)). This selective mechanism
allows humans to focus on targets with limited resources, reducing
cognitive resource consumption ([Buschman and Kastner
2015](#ref-buschman_behavior_2015)), refining elements deposited into
memory ([Chun and Turk-Browne 2007](#ref-chun_interactions_2007)),
delimiting the problem space, and narrowing memory retrieval in
problem-solving situations ([Wiley and Jarosz
2012](#ref-wiley_working_2012)). Human intuition about numbers may also
relate to attention ([Kutter et al. 2023](#ref-kutter_distinct_2023)).
Thus, selective attention is crucial for cognitive activities like
perception, memory, and decision-making.

Attention mechanisms in deep learning, inspired by human selective
attention, which have been successfully integrated into various
frameworks ([Niu, Zhong, and Yu 2021](#ref-niu_review_2021)), greatly
improving performance in tasks like natural language processing (NLP),
computer vision, and speech recognition ([B. Zhang, Xiong, and Su
2020](#ref-zhang_neural_2020); [Guo et al.
2022](#ref-guo_attention_2022); [Ding et al.
2021](#ref-ding_deep_2021)). In recent years, the Transformer model,
relying on self-attention mechanisms to process data, has demonstrated
superior performance across various tasks ([Vaswani et al.
2023](#ref-vaswani_attention_2023); [Khan et al.
2022](#ref-khan_transformers_2022)). Its multi-head attention mechanism
performs multiple parallel self-attention computations with different
parameters, allowing the model to capture information from different
subspaces and improving fitting efficiency and accuracy ([Liu, Liu, and
Han 2021](#ref-liu_multi_head_2021)). Practically, with the Transformer,
neural networks have made significant progress in areas like NLP and
vision tasks.

Attention mechanisms in deep learning are implemented through
mathematical functions that assign weights to different elements of the
input data ([Niu, Zhong, and Yu 2021](#ref-niu_review_2021); [De Santana
Correia and Colombini 2022](#ref-de_santana_correia_attention_2022)).
However, a subset of studies has found that the attention mechanism in
deep learning cannot fully simulate human attention and lacks the
cognitive and emotional context that human attention encompasses ([Lai
et al. 2021](#ref-lai_understanding_2021)). Despite these differences,
artificial neural networks have been successfully applied in several
fields, including image and speech recognition, natural language
processing, robot control, gaming, and decision support systems. These
applications demonstrate the power of artificial neural networks in
dealing with complex problems and simulating certain human cognitive
processes while highlighting the unique advantages of models that
simulate human cognitive abilities.

## 3. Simulating Human Cognitive Abilities: The Way Forward

In recent years, the Transformer model has excelled in various tasks
that rely on self-attentive mechanisms for data processing ([Vaswani et
al. 2023](#ref-vaswani_attention_2023); [Khan et al.
2022](#ref-khan_transformers_2022)). It departs from traditional
recurrent neural networks (RNNs) and convolutional neural networks
(CNNs), favoring a comprehensive utilization of attentional mechanisms
to process sequential data. The Transformer’s attention model is
primarily applied through self-attention and multi-head attention
mechanisms. The self-attention mechanism considers all other elements in
the sequence when processing each input element, enabling the model to
capture long-range dependencies within the sequence ([Vig and Belinkov
2019](#ref-vig_analyzing_2019)). Each element is transformed into query
(*q*), key (*k*), and value (*v*) vectors, representing the current
lexical element, other lexical elements, and the information contained
in the lexical element, respectively. The attention score is computed by
calculating the similarity scores of *q* and *k*, and weighted summing
over *v*. Recently, LLMs have employed the Transformer’s framework,
demonstrating an improved simulation of human cognition.

LLMs are large-scale simulations of human cognitive functions ([Binz and
Schulz 2023](#ref-binz_turning_2023)), and their emergence mark a
significant advancement in computers’ ability to simulate human
cognition. LLMs possess enhanced reasoning capabilities, and Claude 3,
released this month by Anthropic, exhibits self-awareness through
contextual understanding in a needle-in-a-haystack task ([Anthropic
2024](#ref-anthropic_claude_2024); [Kuratov et al.
2024](#ref-kuratov_search_2024)). In zero-shot problem scenarios, LLMs’
reasoning abilities without prior knowledge surpass those of humans, who
rely on analogies for reasoning ([Webb, Holyoak, and Lu
2023](#ref-webb_emergent_2023)). Furthermore, LLMs can comprehend
others’ beliefs, goals, and mental states with an accuracy of up to 80%.
Notably, GPT-4, considered the most advanced LLM, can achieve 100%
accuracy in theory of mind (ToM) tasks after suitable prompting,
indicating a human-like level of ToM ([Thaler
1988](#ref-thaler_anomalies_1988)).

LLMs can also simulate human behavior observed in experiments, such as
the ultimatum game ([Thaler 1988](#ref-thaler_anomalies_1988)),
garden-path sentences ([Ferreira, Christianson, and Hollingworth
2001](#ref-ferreira_misinterpretations_2001)), loss aversion ([Kimball
1993](#ref-kimball_standard_1993)), and reactions to the Milgram
electric shock experiment ([Blass 1999](#ref-blass_milgram_1999); [Aher,
Arriaga, and Kalai 2022](#ref-aher_using_2022)). Additionally, LLMs
exhibit cognitive biases or errors that humans typically demonstrate,
such as additive bias ([Winter et al. 2023](#ref-winter_more_2023)),
where individuals default to adding or modifying existing content rather
than deleting or pushing back when problem-solving ([Adams et al.
2021](#ref-adams_people_2021)). LLMs produce various human cognitive
effects, including priming effects and biases ([Koo et al.
2023](#ref-koo_benchmarking_2023); [Shaki, Kraus, and Wooldridge
2023](#ref-shaki_cognitive_2023)), suggesting that LLMs mimicking human
cognitive processes may possess cognitive abilities approaching the
human level.

In specific domains, LLMs closely mimic human-specific abilities. For
instance, ChatGPT’s accuracy in medical diagnosis and providing feasible
medical advice in complex situations is comparable to that of human
physicians ([Hopkins et al. 2023](#ref-hopkins_artificial_2023)). The
performance metrics show that it diagnoses up to 93.3% of common
clinical cases correctly ([Hirosawa et al.
2023](#ref-hirosawa_diagnostic_2023)). Furthermore, in standardized
clinical decision-making tasks, ChatGPT achieves an accuracy rate close
to 70% ([Rao et al. 2023](#ref-rao_assessing_2023)), similar to the
expected level of third-year medical students in the United States
([Gilson et al. 2023](#ref-gilson_how_2023)). Due to GPT-4’s superior
ToM, it correctly answered 90% of soft skill questions ([Brin et al.
2023](#ref-brin_comparing_2023)), demonstrating excellent clinical
skills.

However, ChatGPT’s ability to handle complex questions remains
unsatisfactory compared to widely used technologies like Google search
([Hopkins et al. 2023](#ref-hopkins_artificial_2023)). It cannot fully
replicate professional clinicians’ decision-making abilities when faced
with complex problems, primarily due to its text-based training data,
resulting in less satisfactory performance in non-text-based tasks ([Y.
Zhang et al. 2024](#ref-zhang_unexpectedly_2024)). Furthermore, in
patient care and other medically related domains, it sometimes generates
false or misleading information, potentially causing doctors, nurses, or
caregivers to make erroneous decisions, endangering patients’ lives ([Z.
Ji et al. 2023](#ref-ji_survey_2023)).

LLMs often contain billions to hundreds of billions of parameters,
making it difficult to implement debugging and understand their
decision-making processes ([Z. Ji et al. 2023](#ref-ji_survey_2023);
[Khullar, Wang, and Wang 2024](#ref-khullar_large_2024)). Therefore,
developing relatively interpretable models is a viable alternative at
the moment. These models are trained in specific areas of expertise,
possessing prior knowledge and learning not exclusively from samples.
Recently, the life2vec model successfully predicted the relationship
between early mortality and aspects of an individual’s personality
traits, demonstrating relatively good predictive efficacy ([Savcisens et
al. 2023](#ref-savcisens_using_2023)). The model provides clinicians and
family physicians with insights and assistance that can help patients
better manage their lifespan, showcasing the potential of specialized
models.

## 4. Simulating human knowledge representation using large-scale medical knowledge networks

In summary, we have found that computer models simulating human
cognitive abilities tend to achieve very good model fitting results,
such as Transformer-based neural network models like LLMs. While LLMs
perform satisfactorily in a wide range of contexts, there are multiple
aspects that have not been addressed adequately in addition to the
aforementioned medical issues.

LLMs require an enormous number of parameters and a vast amount of
training data, consuming substantial computational resources during the
training process ([S. Zhang et al. 2022](#ref-zhang_opt_2022)). Even
after training, reasoning with LLMs consumes significant computational
resources ([Samsi et al. 2023](#ref-samsi_words_2023)). Furthermore,
LLMs produce a large carbon footprint ([S. Zhang et al.
2022](#ref-zhang_opt_2022); [Faiz et al.
2023](#ref-faiz_llmcarbon_2023)) and require considerable water
consumption for cooling ([George, A.S.Hovan George, and A.S.Gabrio
Martin 2023](#ref-george_environmental_2023)), exacerbating
environmental concerns and extreme climate events. As computational
power is concentrated in a few labs, LLM also exacerbates inequality
issues and prevents most labs from gaining LLMs ([S. Zhang et al.
2022](#ref-zhang_opt_2022)).

LLMs are often considered black boxes, making it difficult to understand
and explain their operating mechanisms. Recently, OpenAI has
demonstrated early forms of artificial intelligence in LLMs by
increasing their parameters and training sample size ([OpenAI et al.
2023](#ref-openai_gpt_4_2023); [Bubeck et al.
2023](#ref-bubeck_sparks_2023); [Schaeffer, Miranda, and Koyejo
2023](#ref-schaeffer_are_2023); [Wei et al.
2022](#ref-wei_emergent_2022)), challenging many scholars’ perceptions.
Some have argued that it resembles the Chinese room problem, where LLMs
do not emerge intelligence but rather acquire deeper features of
language, as consciousness may be a special form of language ([Hamid
2023](#ref-hamid_chatgpt_2023)). Others contend that the emergent
intelligence of LLMs is merely wishful thinking by researchers
([Schaeffer, Miranda, and Koyejo 2023](#ref-schaeffer_are_2023)).
Alternatively, it has been proposed that LLMs resemble human societies,
where a large number of individuals collectively exhibit abilities that
individuals do not possess, with emergent capabilities resulting from
complex relationships between numerous data points, akin to ant colony
algorithms.

We suspect the possible reasons for their emergence regarding the
capabilities demonstrated by LLMs. As noted earlier, developing
relatively interpretable specialized models would maximize usability and
transparency, making them safer for clinical applications. Over the past
decades, humans have accumulated substantial historical experience in
fighting diseases and a large number of low-practice-value papers and
monographs ([Hanson et al. 2023](#ref-hanson_strain_2023)). Translating
this experience into clinical resources in bulk has become an important
issue in modern medical research.

We observed that clinicians tend to treat patients automatically based
on their diseases while considering comorbidities the patients may have,
e.g., heart disease, high cholesterol, and bacterial infections. We
aimed to develop a model that could simulate this ability while
maintaining model interpretability. Therefore, we adapted the original
spreading activation model by replacing the LTM with a knowledge network
and substituting the memory search and inference with a random walk
approach to simulate human abilities.

LLMs are often trained using knowledge from publications, and the
promising life2vec model uses medical information from Danish citizens.
Here, we use medical texts to build knowledge networks to train our
models. A knowledge network is a large-scale, graph-structured database
that abstracts core concepts and relationships in reality, allowing AI
systems to understand complex relationships and reason about them. It
can integrate various data sources and types to represent relationships
between elements and their properties. Knowledge networks abstract the
real world for AI systems ([Martin and Baggio
2020](#ref-martin_modelling_2020)), enabling them to solve complex tasks
and reason about the world ([S. Ji et al. 2022](#ref-ji_survey_2022)).

Biomedical knowledge is characterized using formalism, an abstraction
process of the human brain to model systems formally and mathematically
([Phillips 2020](#ref-phillips_sheavinguniversal_2020)). Although
biomedical knowledge does not use formulas to describe biological
processes like mathematics, physics, and chemistry, knowledge networks
can establish the mechanisms involved in biological processes ([Martin
and Baggio 2020](#ref-martin_modelling_2020)). For example, biologists
usually use nodes to represent genes and edges to represent regulatory
relationships between genes.

Once the knowledge network is having constructed, we can simulate how
humans utilize LTM by choosing the random walk approach. Numerous
studies have shown that random walk can effectively simulate human
semantic cognition ([S. Ji et al. 2022](#ref-ji_survey_2022); [Kumar,
Steyvers, and Balota 2021](#ref-kumar_semantic_2021)) and is consistent
with the human memory retrieval process. Compared to the outputs of
spreading activation, that of computer-simulated random walks showed
higher correlation with the spreading activation model’s results
([Abbott, Austerweil, and Griffiths 2015](#ref-abbott_random_2015);
[Zemla and Austerweil 2018](#ref-zemla_estimating_2018); [Siew
2019](#ref-siew_spreadr_2019)). Furthermore, brain scientists have used
random walk algorithms to explore theoretical concepts ([Abbott,
Austerweil, and Griffiths 2015](#ref-abbott_random_2015); [Siew
2019](#ref-siew_spreadr_2019)) or simulate specific human cognitive
behaviors to reduce experimental errors introduced by external
environments ([Abbott, Austerweil, and Griffiths
2015](#ref-abbott_random_2015); [Zemla and Austerweil
2018](#ref-zemla_estimating_2018)).

Similar to the repeated, random selection of various possible solutions
in the human brain, the random walk simulates the random events that
exists in individual problem-solving and decision-making processes. As a
diffusion model, it is applicable to a wide range of situations, even
computer-simulated human societies ([Park et al.
2023](#ref-park_generative_2023)), demonstrating the broad applicability
of such computer models to many different biological scenarios.

## 5. Conclusion

Humans excel at employing existing problem-solving strategies ([Kaula
1995](#ref-kaula_problem_1995)). With the rapid advancement of computer
technology, there has been a surge in research articles on drug
repositioning aided by computational biology and bioinformatics. Figure
demonstrates that the relative number of articles on drug repositioning
included in PubMed, shows an increasing trend over the years with a more
significant rise in recent years. The calculation method also exhibits
the same increasing trend. The *banana* metric has proven effective in
quantifying and analyzing research interest trends across various
fields, which is defined as the number of articles retrieved using
*banana* as a keyword per year ([Dalmaijer et al.
2021](#ref-dalmaijer_banana_2021)).

<div class="figure">

<img src="img/banana.png" alt="\label{fig:banana}**Bibliometric analysis for drug repurposing. **Drug repurposing gains significant attention since 2010. We adopted banana scale to depict this trend." width="100%" />
<p class="caption">
**Bibliometric analysis for drug repurposing. **Drug repurposing gains
significant attention since 2010. We adopted banana scale to depict this
trend.
</p>

</div>

We observed that clinicians tend to treat patients symptomatically based
on their diseases while considering other comorbidities the patients may
have, for example, heart disease, hyperlipidemia, and bacterial
infections. We aimed to develop a model that could simulate this ability
while maintaining interpretability. Therefore, we adapted the original
spreading activation theory by replacing the LTM with a knowledge
network and substituting the memory search and inference with a random
walk approach to simulate human abilities.

## References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-abbott_random_2015" class="csl-entry">

Abbott, Joshua T., Joseph L. Austerweil, and Thomas L. Griffiths. 2015.
“Random Walks on Semantic Networks Can Resemble Optimal Foraging.”
*Psychological Review* 122 (3): 558–69.
<https://doi.org/10.1037/a0038693>.

</div>

<div id="ref-adams_people_2021" class="csl-entry">

Adams, Gabrielle S., Benjamin A. Converse, Andrew H. Hales, and Leidy E.
Klotz. 2021. “People Systematically Overlook Subtractive Changes.”
*Nature* 592 (7853): 258–61.
<https://doi.org/10.1038/s41586-021-03380-y>.

</div>

<div id="ref-agatonovic_kustrin_basic_2000" class="csl-entry">

Agatonovic-Kustrin, S, and R Beresford. 2000. “Basic Concepts of
Artificial Neural Network (ANN) Modeling and Its Application in
Pharmaceutical Research.” *Journal of Pharmaceutical and Biomedical
Analysis* 22 (5): 717–27.
<https://doi.org/10.1016/S0731-7085(99)00272-1>.

</div>

<div id="ref-aher_using_2022" class="csl-entry">

Aher, Gati, Rosa I. Arriaga, and Adam Tauman Kalai. 2022. “Using Large
Language Models to Simulate Multiple Humans and Replicate Human Subject
Studies.” <https://doi.org/10.48550/ARXIV.2208.10264>.

</div>

<div id="ref-allen_glia_2018" class="csl-entry">

Allen, Nicola J., and David A. Lyons. 2018. “Glia as Architects of
Central Nervous System Formation and Function.” *Science (New York,
N.Y.)* 362 (6411): 181–85. <https://doi.org/10.1126/science.aat0473>.

</div>

<div id="ref-anderson_spreading_1983" class="csl-entry">

Anderson, John R. 1983. “A Spreading Activation Theory of Memory.”
*Journal of Verbal Learning and Verbal Behavior* 22 (3): 261–95.
<https://doi.org/10.1016/S0022-5371(83)90201-3>.

</div>

<div id="ref-anthropic_claude_2024" class="csl-entry">

Anthropic. 2024. “The Claude 3 Model Family: Opus, Sonnet, Haiku.”
<https://www-cdn.anthropic.com/de8ba9b01c9ab7cbabf5c33b80b7bbc618857627/Model_Card_Claude_3.pdf>.

</div>

<div id="ref-aru_cellular_2020" class="csl-entry">

Aru, Jaan, Mototaka Suzuki, and Matthew E. Larkum. 2020. “Cellular
Mechanisms of Conscious Processing.” *Trends in Cognitive Sciences* 24
(10): 814–25. <https://doi.org/10.1016/j.tics.2020.07.006>.

</div>

<div id="ref-atkinson_human_1968" class="csl-entry">

Atkinson, R. C., and R. M. Shiffrin. 1968. “Human Memory: A Proposed
System and Its Control Processes.” In *Psychology of Learning and
Motivation*, 2:89–195. Elsevier.
<https://doi.org/10.1016/S0079-7421(08)60422-3>.

</div>

<div id="ref-attwell_energy_2001" class="csl-entry">

Attwell, David, and Simon B. Laughlin. 2001. “An Energy Budget for
Signaling in the Grey Matter of the Brain.” *Journal of Cerebral Blood
Flow & Metabolism* 21 (10): 1133–45.
<https://doi.org/10.1097/00004647-200110000-00001>.

</div>

<div id="ref-baddeley_episodic_2000" class="csl-entry">

Baddeley, Alan. 2000. “The Episodic Buffer: A New Component of Working
Memory?” *Trends in Cognitive Sciences* 4 (11): 417–23.
<https://doi.org/10.1016/S1364-6613(00)01538-2>.

</div>

<div id="ref-von_bartheld_search_2016" class="csl-entry">

Bartheld, Christopher S. von, Jami Bahney, and Suzana Herculano-Houzel.
2016. “The Search for True Numbers of Neurons and Glial Cells in the
Human Brain: A Review of 150 Years of Cell Counting.” *The Journal of
Comparative Neurology* 524 (18): 3865–95.
<https://doi.org/10.1002/cne.24040>.

</div>

<div id="ref-benjamin_memory_2007" class="csl-entry">

Benjamin, Aaron S. 2007. “Memory Is More Than Just Remembering:
Strategic Control of Encoding, Accessing Memory, and Making Decisions.”
In *Psychology of Learning and Motivation*, 48:175–223. Elsevier.
<https://doi.org/10.1016/S0079-7421(07)48005-7>.

</div>

<div id="ref-binz_turning_2023" class="csl-entry">

Binz, Marcel, and Eric Schulz. 2023. “Turning Large Language Models into
Cognitive Models.” arXiv. <https://doi.org/10.48550/arXiv.2306.03917>.

</div>

<div id="ref-blass_milgram_1999" class="csl-entry">

Blass, Thomas. 1999. “The Milgram Paradigm After 35 Years: Some Things
We Now Know about Obedience to Authority.” *Journal of Applied Social
Psychology* 29 (5): 955–78.
<https://doi.org/10.1111/j.1559-1816.1999.tb00134.x>.

</div>

<div id="ref-blumenfeld_lateral_2019" class="csl-entry">

Blumenfeld, Robert S., and Charan Ranganath. 2019. “The Lateral
Prefrontal Cortex and Human Long-Term Memory.” *Handbook of Clinical
Neurology* 163: 221–35.
<https://doi.org/10.1016/B978-0-12-804281-6.00012-4>.

</div>

<div id="ref-botvinick_reinforcement_2019" class="csl-entry">

Botvinick, Matthew, Sam Ritter, Jane X. Wang, Zeb Kurth-Nelson, Charles
Blundell, and Demis Hassabis. 2019. “Reinforcement Learning, Fast and
Slow.” *Trends in Cognitive Sciences* 23 (5): 408–22.
<https://doi.org/10.1016/j.tics.2019.02.006>.

</div>

<div id="ref-brin_comparing_2023" class="csl-entry">

Brin, Dana, Vera Sorin, Akhil Vaid, Ali Soroush, Benjamin S. Glicksberg,
Alexander W. Charney, Girish Nadkarni, and Eyal Klang. 2023. “Comparing
ChatGPT and GPT-4 Performance in USMLE Soft Skill Assessments.”
*Scientific Reports* 13 (1): 16492.
<https://doi.org/10.1038/s41598-023-43436-9>.

</div>

<div id="ref-bubeck_sparks_2023" class="csl-entry">

Bubeck, Sébastien, Varun Chandrasekaran, Ronen Eldan, Johannes Gehrke,
Eric Horvitz, Ece Kamar, Peter Lee, et al. 2023. “Sparks of Artificial
General Intelligence: Early Experiments with GPT-4.” arXiv.
<https://doi.org/10.48550/arXiv.2303.12712>.

</div>

<div id="ref-buschman_behavior_2015" class="csl-entry">

Buschman, Timothy J., and Sabine Kastner. 2015. “From Behavior to Neural
Dynamics: An Integrated Theory of Attention.” *Neuron* 88 (1): 127–44.
<https://doi.org/10.1016/j.neuron.2015.09.017>.

</div>

<div id="ref-camina_neuroanatomical_2017" class="csl-entry">

Camina, Eduardo, and Francisco Güell. 2017. “The Neuroanatomical,
Neurophysiological and Psychological Basis of Memory: Current Models and
Their Origins.” *Frontiers in Pharmacology* 8: 438.
<https://doi.org/10.3389/fphar.2017.00438>.

</div>

<div id="ref-casasanto_time_2008" class="csl-entry">

Casasanto, Daniel, and Lera Boroditsky. 2008. “Time in the Mind: Using
Space to Think about Time.” *Cognition* 106 (2): 579–93.
<https://doi.org/10.1016/j.cognition.2007.03.004>.

</div>

<div id="ref-changeux_theory_1973" class="csl-entry">

Changeux, J. P., P. Courrège, and A. Danchin. 1973. “A Theory of the
Epigenesis of Neuronal Networks by Selective Stabilization of Synapses.”
*Proceedings of the National Academy of Sciences of the United States of
America* 70 (10): 2974–78. <https://doi.org/10.1073/pnas.70.10.2974>.

</div>

<div id="ref-chavlis_drawing_2021" class="csl-entry">

Chavlis, Spyridon, and Panayiota Poirazi. 2021. “Drawing Inspiration
from Biological Dendrites to Empower Artificial Neural Networks.”
*Current Opinion in Neurobiology* 70 (October): 1–10.
<https://doi.org/10.1016/j.conb.2021.04.007>.

</div>

<div id="ref-chun_interactions_2007" class="csl-entry">

Chun, Marvin M, and Nicholas B Turk-Browne. 2007. “Interactions Between
Attention and Memory.” *Current Opinion in Neurobiology* 17 (2): 177–84.
<https://doi.org/10.1016/j.conb.2007.03.005>.

</div>

<div id="ref-cichy_deep_2019" class="csl-entry">

Cichy, Radoslaw M., and Daniel Kaiser. 2019. “Deep Neural Networks as
Scientific Models.” *Trends in Cognitive Sciences* 23 (4): 305–17.
<https://doi.org/10.1016/j.tics.2019.01.009>.

</div>

<div id="ref-collins_spreading_activation_1975" class="csl-entry">

Collins, Allan M., and Elizabeth F. Loftus. 1975. “A
Spreading-Activation Theory of Semantic Processing.” *Psychological
Review* 82 (6): 407–28. <https://doi.org/10.1037/0033-295X.82.6.407>.

</div>

<div id="ref-cowan_magical_2001" class="csl-entry">

Cowan, N. 2001. “The Magical Number 4 in Short-Term Memory: A
Reconsideration of Mental Storage Capacity.” *The Behavioral and Brain
Sciences* 24 (1): 87-114; discussion 114-185.
<https://doi.org/10.1017/s0140525x01003922>.

</div>

<div id="ref-cowan_capacity_2005" class="csl-entry">

Cowan, Nelson, Emily M. Elliott, J. Scott Saults, Candice C. Morey, Sam
Mattox, Anna Hismjatullina, and Andrew R. A. Conway. 2005. “On the
Capacity of Attention: Its Estimation and Its Role in Working Memory and
Cognitive Aptitudes.” *Cognitive Psychology* 51 (1): 42–100.
<https://doi.org/10.1016/j.cogpsych.2004.12.001>.

</div>

<div id="ref-dalmaijer_banana_2021" class="csl-entry">

Dalmaijer, Edwin S., Joram Van Rheede, Edwin V. Sperr, and Juliane
Tkotz. 2021. “Banana for Scale: Gauging Trends in Academic Interest by
Normalising Publication Rates to Common and Innocuous Keywords.” arXiv.
<https://doi.org/10.48550/arXiv.2102.06418>.

</div>

<div id="ref-de_santana_correia_attention_2022" class="csl-entry">

De Santana Correia, Alana, and Esther Luna Colombini. 2022. “Attention,
Please! A Survey of Neural Attention Models in Deep Learning.”
*Artificial Intelligence Review* 55 (8): 6037–6124.
<https://doi.org/10.1007/s10462-022-10148-x>.

</div>

<div id="ref-desislavov_trends_2023" class="csl-entry">

Desislavov, Radosvet, Fernando Martínez-Plumed, and José
Hernández-Orallo. 2023. “Trends in AI Inference Energy Consumption:
Beyond the Performance-Vs-Parameter Laws of Deep Learning.” *Sustainable
Computing: Informatics and Systems* 38 (April): 100857.
<https://doi.org/10.1016/j.suscom.2023.100857>.

</div>

<div id="ref-ding_deep_2021" class="csl-entry">

Ding, Huijun, Zixiong Gu, Peng Dai, Zhou Zhou, Lu Wang, and Xiaoxiao Wu.
2021. “Deep Connected Attention (DCA) ResNet for Robust Voice Pathology
Detection and Classification.” *Biomedical Signal Processing and
Control* 70 (September): 102973.
<https://doi.org/10.1016/j.bspc.2021.102973>.

</div>

<div id="ref-faiz_llmcarbon_2023" class="csl-entry">

Faiz, Ahmad, Sotaro Kaneda, Ruhan Wang, Rita Osi, Prateek Sharma, Fan
Chen, and Lei Jiang. 2023. “LLMCarbon: Modeling the End-to-End Carbon
Footprint of Large Language Models.”
<https://doi.org/10.48550/arXiv.2309.14393>.

</div>

<div id="ref-ferreira_misinterpretations_2001" class="csl-entry">

Ferreira, Fernanda, Kiel Christianson, and Andrew Hollingworth. 2001.
“Misinterpretations of Garden-Path Sentences: Implications for Models of
Sentence Processing and Reanalysis.” *Journal of Psycholinguistic
Research* 30 (1): 3–20. <https://doi.org/10.1023/A:1005290706460>.

</div>

<div id="ref-george_environmental_2023" class="csl-entry">

George, A.Shaji, A.S.Hovan George, and A.S.Gabrio Martin. 2023. “The
Environmental Impact of AI: A Case Study of Water Consumption by Chat
GPT,” April. <https://doi.org/10.5281/ZENODO.7855594>.

</div>

<div id="ref-gilson_how_2023" class="csl-entry">

Gilson, Aidan, Conrad W. Safranek, Thomas Huang, Vimig Socrates, Ling
Chi, Richard Andrew Taylor, and David Chartash. 2023. “How Does ChatGPT
Perform on the United States Medical Licensing Examination? The
Implications of Large Language Models for Medical Education and
Knowledge Assessment.” *JMIR Medical Education* 9 (February): e45312.
<https://doi.org/10.2196/45312>.

</div>

<div id="ref-greenwald_measuring_1998" class="csl-entry">

Greenwald, Anthony G., Debbie E. McGhee, and Jordan L. K. Schwartz.
1998. “Measuring Individual Differences in Implicit Cognition: The
Implicit Association Test.” *Journal of Personality and Social
Psychology* 74 (6): 1464–80.
<https://doi.org/10.1037/0022-3514.74.6.1464>.

</div>

<div id="ref-greenwald_understanding_2009" class="csl-entry">

Greenwald, Anthony G., T. Andrew Poehlman, Eric Luis Uhlmann, and
Mahzarin R. Banaji. 2009. “Understanding and Using the Implicit
Association Test: III. Meta-Analysis of Predictive Validity.” *Journal
of Personality and Social Psychology* 97 (1): 17–41.
<https://doi.org/10.1037/a0015575>.

</div>

<div id="ref-guo_attention_2022" class="csl-entry">

Guo, Meng-Hao, Tian-Xing Xu, Jiang-Jiang Liu, Zheng-Ning Liu, Peng-Tao
Jiang, Tai-Jiang Mu, Song-Hai Zhang, Ralph R. Martin, Ming-Ming Cheng,
and Shi-Min Hu. 2022. “Attention Mechanisms in Computer Vision: A
Survey.” *Computational Visual Media* 8 (3): 331–68.
<https://doi.org/10.1007/s41095-022-0271-y>.

</div>

<div id="ref-halassa_integrated_2010" class="csl-entry">

Halassa, Michael M., and Philip G. Haydon. 2010. “Integrated Brain
Circuits: Astrocytic Networks Modulate Neuronal Activity and Behavior.”
*Annual Review of Physiology* 72: 335–55.
<https://doi.org/10.1146/annurev-physiol-021909-135843>.

</div>

<div id="ref-hamid_chatgpt_2023" class="csl-entry">

Hamid, Oussama H. 2023. “ChatGPT and the Chinese Room Argument: An
Eloquent AI Conversationalist Lacking True Understanding and
Consciousness.” In *2023 9th International Conference on Information
Technology Trends (ITT)*, 238–41. Dubai, United Arab Emirates: IEEE.
<https://doi.org/10.1109/ITT59889.2023.10184233>.

</div>

<div id="ref-han_rational_2019" class="csl-entry">

Han, Bin, Di Feng, Vincenzo Sciancalepore, and Hans D. Schotten. 2019.
“Rational Impatience Admission Control in 5G-Sliced Networks: Shall i
Bide My Slice Opportunity?” arXiv.
<https://doi.org/10.48550/arXiv.1809.06815>.

</div>

<div id="ref-hanson_strain_2023" class="csl-entry">

Hanson, Mark A., Pablo Gómez Barreiro, Paolo Crosetto, and Dan
Brockington. 2023. “The Strain on Scientific Publishing.” arXiv.
<https://doi.org/10.48550/arXiv.2309.15884>.

</div>

<div id="ref-herculano_houzel_human_2009" class="csl-entry">

Herculano-Houzel, Suzana. 2009. “The Human Brain in Numbers: A Linearly
Scaled-up Primate Brain.” *Frontiers in Human Neuroscience* 3: 31.
<https://doi.org/10.3389/neuro.09.031.2009>.

</div>

<div id="ref-hirosawa_diagnostic_2023" class="csl-entry">

Hirosawa, Takanobu, Yukinori Harada, Masashi Yokose, Tetsu Sakamoto, Ren
Kawamura, and Taro Shimizu. 2023. “Diagnostic Accuracy of
Differential-Diagnosis Lists Generated by Generative Pretrained
Transformer 3 Chatbot for Clinical Vignettes with Common Chief
Complaints: A Pilot Study.” *International Journal of Environmental
Research and Public Health* 20 (4): 3378.
<https://doi.org/10.3390/ijerph20043378>.

</div>

<div id="ref-hopkins_artificial_2023" class="csl-entry">

Hopkins, Ashley M, Jessica M Logan, Ganessan Kichenadasse, and Michael J
Sorich. 2023. “Artificial Intelligence Chatbots Will Revolutionize How
Cancer Patients Access Information: ChatGPT Represents a
Paradigm-Shift.” *JNCI Cancer Spectrum* 7 (2): pkad010.
<https://doi.org/10.1093/jncics/pkad010>.

</div>

<div id="ref-james_stability_2018" class="csl-entry">

James, Lois. 2018. “The Stability of Implicit Racial Bias in Police
Officers.” *Police Quarterly* 21 (1): 30–52.
<https://doi.org/10.1177/1098611117732974>.

</div>

<div id="ref-ji_survey_2022" class="csl-entry">

Ji, Shaoxiong, Shirui Pan, Erik Cambria, Pekka Marttinen, and Philip S.
Yu. 2022. “A Survey on Knowledge Graphs: Representation, Acquisition,
and Applications.” *IEEE Transactions on Neural Networks and Learning
Systems* 33 (2): 494–514. <https://doi.org/10.1109/TNNLS.2021.3070843>.

</div>

<div id="ref-ji_survey_2023" class="csl-entry">

Ji, Ziwei, Nayeon Lee, Rita Frieske, Tiezheng Yu, Dan Su, Yan Xu, Etsuko
Ishii, Ye Jin Bang, Andrea Madotto, and Pascale Fung. 2023. “Survey of
Hallucination in Natural Language Generation.” *ACM Computing Surveys*
55 (12): 1–38. <https://doi.org/10.1145/3571730>.

</div>

<div id="ref-karpinski_attitude_2005" class="csl-entry">

Karpinski, Andrew, Ross B. Steinman, and James L. Hilton. 2005.
“Attitude Importance as a Moderator of the Relationship Between Implicit
and Explicit Attitude Measures.” *Personality and Social Psychology
Bulletin* 31 (7): 949–62. <https://doi.org/10.1177/0146167204273007>.

</div>

<div id="ref-kaula_problem_1995" class="csl-entry">

Kaula, Rajeev. 1995. “Problem Solving Strategies for Open Information
Systems.” *Knowledge-Based Systems* 8 (5): 235–48.
<https://doi.org/10.1016/0950-7051(95)98901-H>.

</div>

<div id="ref-kazanas_survival_2015" class="csl-entry">

Kazanas, Stephanie A., and Jeanette Altarriba. 2015. “The Survival
Advantage: Underlying Mechanisms and Extant Limitations.” *Evolutionary
Psychology* 13 (2): 147470491501300.
<https://doi.org/10.1177/147470491501300204>.

</div>

<div id="ref-khan_transformers_2022" class="csl-entry">

Khan, Salman, Muzammal Naseer, Munawar Hayat, Syed Waqas Zamir, Fahad
Shahbaz Khan, and Mubarak Shah. 2022. “Transformers in Vision: A
Survey.” *ACM Computing Surveys* 54 (10): 1–41.
<https://doi.org/10.1145/3505244>.

</div>

<div id="ref-khullar_large_2024" class="csl-entry">

Khullar, Dhruv, Xingbo Wang, and Fei Wang. 2024. “Large Language Models
in Health Care: Charting a Path Toward Accurate, Explainable, and Secure
AI.” *Journal of General Internal Medicine*, February,
s11606-024-08657-2. <https://doi.org/10.1007/s11606-024-08657-2>.

</div>

<div id="ref-kim_neuron_glia_2020" class="csl-entry">

Kim, Yoo Sung, Juwon Choi, and Bo-Eun Yoon. 2020. “Neuron-Glia
Interactions in Neurodevelopmental Disorders.” *Cells* 9 (10): 2176.
<https://doi.org/10.3390/cells9102176>.

</div>

<div id="ref-kimball_standard_1993" class="csl-entry">

Kimball, Miles S. 1993. “Standard Risk Aversion.” *Econometrica* 61 (3):
589. <https://doi.org/10.2307/2951719>.

</div>

<div id="ref-koo_benchmarking_2023" class="csl-entry">

Koo, Ryan, Minhwa Lee, Vipul Raheja, Jong Inn Park, Zae Myung Kim, and
Dongyeop Kang. 2023. “Benchmarking Cognitive Biases in Large Language
Models as Evaluators.” <https://doi.org/10.48550/arXiv.2309.17012>.

</div>

<div id="ref-kumar_semantic_2021" class="csl-entry">

Kumar, Abhilasha A., Mark Steyvers, and David A. Balota. 2021. “Semantic
Memory Search and Retrieval in a Novel Cooperative Word Game: A
Comparison of Associative and Distributional Semantic Models.”
*Cognitive Science* 45 (10): e13053.
<https://doi.org/10.1111/cogs.13053>.

</div>

<div id="ref-kuratov_search_2024" class="csl-entry">

Kuratov, Yuri, Aydar Bulatov, Petr Anokhin, Dmitry Sorokin, Artyom
Sorokin, and Mikhail Burtsev. 2024. “In Search of Needles in a 11M
Haystack: Recurrent Memory Finds What LLMs Miss.” arXiv.
<http://arxiv.org/abs/2402.10790>.

</div>

<div id="ref-kutter_distinct_2023" class="csl-entry">

Kutter, Esther F., Gert Dehnen, Valeri Borger, Rainer Surges, Florian
Mormann, and Andreas Nieder. 2023. “Distinct Neuronal Representation of
Small and Large Numbers in the Human Medial Temporal Lobe.” *Nature
Human Behaviour* 7 (11): 1998–2007.
<https://doi.org/10.1038/s41562-023-01709-3>.

</div>

<div id="ref-lai_understanding_2021" class="csl-entry">

Lai, Qiuxia, Salman Khan, Yongwei Nie, Hanqiu Sun, Jianbing Shen, and
Ling Shao. 2021. “Understanding More about Human and Machine Attention
in Deep Neural Networks.” *IEEE Transactions on Multimedia* 23: 2086–99.
<https://doi.org/10.1109/TMM.2020.3007321>.

</div>

<div id="ref-lawlor_mendelian_2008" class="csl-entry">

Lawlor, Debbie A., Roger M. Harbord, Jonathan A. C. Sterne, Nic Timpson,
and George Davey Smith. 2008. “Mendelian Randomization: Using Genes as
Instruments for Making Causal Inferences in Epidemiology.” *Statistics
in Medicine* 27 (8): 1133–63. <https://doi.org/10.1002/sim.3034>.

</div>

<div id="ref-lee_comparison_2013" class="csl-entry">

Lee, Kwang-Ho, and Dae-Young Kim. 2013. “A Comparison of Implicit and
Explicit Attitude Measures: An Application of the Implicit Association
Test (IAT) to Fast Food Restaurant Brands.” *Tourism Analysis* 18 (2):
119–31. <https://doi.org/10.3727/108354213X13645733247576>.

</div>

<div id="ref-lehmann_semantic_1992" class="csl-entry">

Lehmann, Fritz. 1992. “Semantic Networks.” *Computers & Mathematics with
Applications* 23 (2): 1–50.
<https://doi.org/10.1016/0898-1221(92)90135-5>.

</div>

<div id="ref-lillicrap_backpropagation_2020" class="csl-entry">

Lillicrap, Timothy P., Adam Santoro, Luke Marris, Colin J. Akerman, and
Geoffrey Hinton. 2020. “Backpropagation and the Brain.” *Nature Reviews.
Neuroscience* 21 (6): 335–46.
<https://doi.org/10.1038/s41583-020-0277-3>.

</div>

<div id="ref-liu_multi_head_2021" class="csl-entry">

Liu, Liyuan, Jialu Liu, and Jiawei Han. 2021. “Multi-Head or
Single-Head? An Empirical Comparison for Transformer Training.” arXiv.
<https://doi.org/10.48550/arXiv.2106.09650>.

</div>

<div id="ref-martin_modelling_2020" class="csl-entry">

Martin, Andrea E., and Giosuè Baggio. 2020. “Modelling Meaning
Composition from Formalism to Mechanism.” *Philosophical Transactions of
the Royal Society B: Biological Sciences* 375 (1791): 20190298.
<https://doi.org/10.1098/rstb.2019.0298>.

</div>

<div id="ref-mayberry_neurolinguistic_2018" class="csl-entry">

Mayberry, Rachel I., Tristan Davenport, Austin Roth, and Eric Halgren.
2018. “Neurolinguistic Processing When the Brain Matures Without
Language.” *Cortex* 99 (February): 390–403.
<https://doi.org/10.1016/j.cortex.2017.12.011>.

</div>

<div id="ref-mhatre_homogeneous_2004" class="csl-entry">

Mhatre, V., and C. Rosenberg. 2004. “Homogeneous Vs Heterogeneous
Clustered Sensor Networks: A Comparative Study.” In *2004 IEEE
International Conference on Communications (IEEE Cat. No.04CH37577)*,
3646–3651 Vol.6. Paris, France: IEEE.
<https://doi.org/10.1109/ICC.2004.1313223>.

</div>

<div id="ref-munakata_hebbian_2004" class="csl-entry">

Munakata, Yuko, and Jason Pfaffly. 2004. “Hebbian Learning and
Development.” *Developmental Science* 7 (2): 141–48.
<https://doi.org/10.1111/j.1467-7687.2004.00331.x>.

</div>

<div id="ref-nairne_adaptive_2016" class="csl-entry">

Nairne, James S., and Josefa N. S. Pandeirada. 2016. “Adaptive Memory:
The Evolutionary Significance of Survival Processing.” *Perspectives on
Psychological Science* 11 (4): 496–511.
<https://doi.org/10.1177/1745691616635613>.

</div>

<div id="ref-niu_review_2021" class="csl-entry">

Niu, Zhaoyang, Guoqiang Zhong, and Hui Yu. 2021. “A Review on the
Attention Mechanism of Deep Learning.” *Neurocomputing* 452 (September):
48–62. <https://doi.org/10.1016/j.neucom.2021.03.091>.

</div>

<div id="ref-nussenbaum_memorys_2020" class="csl-entry">

Nussenbaum, Kate, Euan Prentis, and Catherine A. Hartley. 2020.
“Memory’s Reflection of Learned Information Value Increases Across
Development.” *Journal of Experimental Psychology: General* 149 (10):
1919–34. <https://doi.org/10.1037/xge0000753>.

</div>

<div id="ref-openai_gpt_4_2023" class="csl-entry">

OpenAI, Josh Achiam, Steven Adler, Sandhini Agarwal, Lama Ahmad, Ilge
Akkaya, Florencia Leoni Aleman, et al. 2023. “GPT-4 Technical Report.”
arXiv. <https://doi.org/10.48550/arXiv.2303.08774>.

</div>

<div id="ref-pareti_all_or_none_2007" class="csl-entry">

Pareti, G. 2007. “The "All-or-None" Law in Skeletal Muscle and Nerve
Fibres.” *Archives Italiennes De Biologie* 145 (1): 39–54.
<https://doi.org/10.4449/AIB.V145I1.865>.

</div>

<div id="ref-parisi_artificial_1997" class="csl-entry">

Parisi, Domenico. 1997. “Artificial Life and Higher Level Cognition.”
*Brain and Cognition* 34 (1): 160–84.
<https://doi.org/10.1006/brcg.1997.0911>.

</div>

<div id="ref-park_generative_2023" class="csl-entry">

Park, Joon Sung, Joseph C. O’Brien, Carrie J. Cai, Meredith Ringel
Morris, Percy Liang, and Michael S. Bernstein. 2023. “Generative Agents:
Interactive Simulacra of Human Behavior.” arXiv.
<https://doi.org/10.48550/arXiv.2304.03442>.

</div>

<div id="ref-phillips_sheavinguniversal_2020" class="csl-entry">

Phillips, Steven. 2020. “Sheaving—a Universal Construction for Semantic
Compositionality.” *Philosophical Transactions of the Royal Society B:
Biological Sciences* 375 (1791): 20190303.
<https://doi.org/10.1098/rstb.2019.0303>.

</div>

<div id="ref-pichler_machine_2023" class="csl-entry">

Pichler, Maximilian, and Florian Hartig. 2023. “Machine Learning and
Deep Learning—a Review for Ecologists.” *Methods in Ecology and
Evolution* 14 (4): 994–1016. <https://doi.org/10.1111/2041-210X.14061>.

</div>

<div id="ref-polti_effect_2018" class="csl-entry">

Polti, Ignacio, Benoît Martin, and Virginie Van Wassenhove. 2018. “The
Effect of Attention and Working Memory on the Estimation of Elapsed
Time.” *Scientific Reports* 8 (1): 6690.
<https://doi.org/10.1038/s41598-018-25119-y>.

</div>

<div id="ref-rao_assessing_2023" class="csl-entry">

Rao, Arya, Michael Pang, John Kim, Meghana Kamineni, Winston Lie, Anoop
K. Prasad, Adam Landman, Keith J. Dreyer, and Marc D. Succi. 2023.
“Assessing the Utility of ChatGPT Throughout the Entire Clinical
Workflow.” *medRxiv: The Preprint Server for Health Sciences*, February,
2023.02.21.23285886. <https://doi.org/10.1101/2023.02.21.23285886>.

</div>

<div id="ref-renoult_knowing_2019" class="csl-entry">

Renoult, Louis, Muireann Irish, Morris Moscovitch, and Michael D. Rugg.
2019. “From Knowing to Remembering: The Semantic-Episodic Distinction.”
*Trends in Cognitive Sciences* 23 (12): 1041–57.
<https://doi.org/10.1016/j.tics.2019.09.008>.

</div>

<div id="ref-samsi_words_2023" class="csl-entry">

Samsi, Siddharth, Dan Zhao, Joseph McDonald, Baolin Li, Adam Michaleas,
Michael Jones, William Bergeron, Jeremy Kepner, Devesh Tiwari, and Vijay
Gadepally. 2023. “From Words to Watts: Benchmarking the Energy Costs of
Large Language Model Inference.” In *2023 IEEE High Performance Extreme
Computing Conference (HPEC)*, 1–9. Boston, MA, USA: IEEE.
<https://doi.org/10.1109/HPEC58863.2023.10363447>.

</div>

<div id="ref-savcisens_using_2023" class="csl-entry">

Savcisens, Germans, Tina Eliassi-Rad, Lars Kai Hansen, Laust Hvas
Mortensen, Lau Lilleholt, Anna Rogers, Ingo Zettler, and Sune Lehmann.
2023. “Using Sequences of Life-Events to Predict Human Lives.” *Nature
Computational Science* 4 (1): 43–56.
<https://doi.org/10.1038/s43588-023-00573-5>.

</div>

<div id="ref-schacter_future_2012" class="csl-entry">

Schacter, Daniel L., Donna Rose Addis, Demis Hassabis, Victoria C.
Martin, R. Nathan Spreng, and Karl K. Szpunar. 2012. “The Future of
Memory: Remembering, Imagining, and the Brain.” *Neuron* 76 (4): 677–94.
<https://doi.org/10.1016/j.neuron.2012.11.001>.

</div>

<div id="ref-schaeffer_are_2023" class="csl-entry">

Schaeffer, Rylan, Brando Miranda, and Sanmi Koyejo. 2023. “Are Emergent
Abilities of Large Language Models a Mirage?” arXiv.
<https://doi.org/10.48550/arXiv.2304.15004>.

</div>

<div id="ref-shaki_cognitive_2023" class="csl-entry">

Shaki, Jonathan, Sarit Kraus, and Michael Wooldridge. 2023. “Cognitive
Effects in Large Language Models.”
<https://doi.org/10.48550/ARXIV.2308.14337>.

</div>

<div id="ref-sharifian_hierarchical_1997" class="csl-entry">

Sharifian, Farzad, and Ramin Samani. 1997. “Hierarchical Spreading of
Activation.” In *Proc. Of the Conference on Language, Cognition, and
Interpretation*, 1–10. IAU Press Isfahan.

</div>

<div id="ref-siew_spreadr_2019" class="csl-entry">

Siew, Cynthia S. Q. 2019. “Spreadr: An r Package to Simulate Spreading
Activation in a Network.” *Behavior Research Methods* 51 (2): 910–29.
<https://doi.org/10.3758/s13428-018-1186-5>.

</div>

<div id="ref-simmons_anterior_2009" class="csl-entry">

Simmons, W. Kyle, and Alex Martin. 2009. “The Anterior Temporal Lobes
and the Functional Architecture of Semantic Memory.” *Journal of the
International Neuropsychological Society: JINS* 15 (5): 645–49.
<https://doi.org/10.1017/S1355617709990348>.

</div>

<div id="ref-smith_multiple_2008" class="csl-entry">

Smith, Edward E., and Murray Grossman. 2008. “Multiple Systems of
Category Learning.” *Neuroscience and Biobehavioral Reviews* 32 (2):
249–64. <https://doi.org/10.1016/j.neubiorev.2007.07.009>.

</div>

<div id="ref-squire_medial_1991" class="csl-entry">

Squire, Larry R., and Stuart Zola-Morgan. 1991. “The Medial Temporal
Lobe Memory System.” *Science* 253 (5026): 1380–86.
<https://doi.org/10.1126/science.1896849>.

</div>

<div id="ref-thaler_anomalies_1988" class="csl-entry">

Thaler, Richard H. 1988. “Anomalies: The Ultimatum Game.” *Journal of
Economic Perspectives* 2 (4): 195–206.
<https://doi.org/10.1257/jep.2.4.195>.

</div>

<div id="ref-vaswani_attention_2023" class="csl-entry">

Vaswani, Ashish, Noam Shazeer, Niki Parmar, Jakob Uszkoreit, Llion
Jones, Aidan N. Gomez, Lukasz Kaiser, and Illia Polosukhin. 2023.
“Attention Is All You Need.” arXiv.
<https://doi.org/10.48550/arXiv.1706.03762>.

</div>

<div id="ref-vig_analyzing_2019" class="csl-entry">

Vig, Jesse, and Yonatan Belinkov. 2019. “Analyzing the Structure of
Attention in a Transformer Language Model.” In *Proceedings of the 2019
ACL Workshop BlackboxNLP: Analyzing and Interpreting Neural Networks for
NLP*, 63–76. Florence, Italy: Association for Computational Linguistics.
<https://doi.org/10.18653/v1/W19-4808>.

</div>

<div id="ref-volzhenin_multilevel_2022" class="csl-entry">

Volzhenin, Konstantin, Jean-Pierre Changeux, and Guillaume Dumas. 2022.
“Multilevel Development of Cognitive Abilities in an Artificial Neural
Network.” *Proceedings of the National Academy of Sciences* 119 (39):
e2201304119. <https://doi.org/10.1073/pnas.2201304119>.

</div>

<div id="ref-webb_emergent_2023" class="csl-entry">

Webb, Taylor, Keith J. Holyoak, and Hongjing Lu. 2023. “Emergent
Analogical Reasoning in Large Language Models.” *Nature Human Behaviour*
7 (9): 1526–41. <https://doi.org/10.1038/s41562-023-01659-w>.

</div>

<div id="ref-wei_emergent_2022" class="csl-entry">

Wei, Jason, Yi Tay, Rishi Bommasani, Colin Raffel, Barret Zoph,
Sebastian Borgeaud, Dani Yogatama, et al. 2022. “Emergent Abilities of
Large Language Models.” arXiv.
<https://doi.org/10.48550/arXiv.2206.07682>.

</div>

<div id="ref-whittington_theories_2019" class="csl-entry">

Whittington, James C. R., and Rafal Bogacz. 2019. “Theories of Error
Back-Propagation in the Brain.” *Trends in Cognitive Sciences* 23 (3):
235–50. <https://doi.org/10.1016/j.tics.2018.12.005>.

</div>

<div id="ref-wiley_working_2012" class="csl-entry">

Wiley, Jennifer, and Andrew F. Jarosz. 2012. “Working Memory Capacity,
Attentional Focus, and Problem Solving.” *Current Directions in
Psychological Science* 21 (4): 258–62.
<https://doi.org/10.1177/0963721412447622>.

</div>

<div id="ref-winter_more_2023" class="csl-entry">

Winter, Bodo, Martin H. Fischer, Christoph Scheepers, and Andriy
Myachykov. 2023. “More Is Better: English Language Statistics Are Biased
Toward Addition.” *Cognitive Science* 47 (4): e13254.
<https://doi.org/10.1111/cogs.13254>.

</div>

<div id="ref-wolosker_d_amino_2008" class="csl-entry">

Wolosker, Herman, Elena Dumin, Livia Balan, and Veronika N. Foltyn.
2008. “D-Amino Acids in the Brain: D-Serine in Neurotransmission and
Neurodegeneration.” *The FEBS Journal* 275 (14): 3514–26.
<https://doi.org/10.1111/j.1742-4658.2008.06515.x>.

</div>

<div id="ref-yang_neuroinflammation_2019" class="csl-entry">

Yang, Qiao-Qiao, and Jia-Wei Zhou. 2019. “Neuroinflammation in the
Central Nervous System: Symphony of Glial Cells.” *Glia* 67 (6):
1017–35. <https://doi.org/10.1002/glia.23571>.

</div>

<div id="ref-zahedi_introduction_1991" class="csl-entry">

Zahedi, Fatemeh. 1991. “An Introduction to Neural Networks and a
Comparison with Artificial Intelligence and Expert Systems.”
*Interfaces* 21 (2): 25–38. <https://doi.org/10.1287/inte.21.2.25>.

</div>

<div id="ref-zemla_estimating_2018" class="csl-entry">

Zemla, Jeffrey C., and Joseph L. Austerweil. 2018. “Estimating Semantic
Networks of Groups and Individuals from Fluency Data.” *Computational
Brain & Behavior* 1 (1): 36–58.
<https://doi.org/10.1007/s42113-018-0003-7>.

</div>

<div id="ref-zhang_neural_2020" class="csl-entry">

Zhang, Biao, Deyi Xiong, and Jinsong Su. 2020. “Neural Machine
Translation with Deep Attention.” *IEEE Transactions on Pattern Analysis
and Machine Intelligence* 42 (1): 154–63.
<https://doi.org/10.1109/TPAMI.2018.2876404>.

</div>

<div id="ref-zhang_algorithm_2023" class="csl-entry">

Zhang, He, Liang Zhang, Ang Lin, Congcong Xu, Ziyu Li, Kaibo Liu,
Boxiang Liu, et al. 2023. “Algorithm for Optimized
<span class="nocase">mRNA</span> Design Improves Stability and
Immunogenicity.” *Nature* 621 (7978): 396–403.
<https://doi.org/10.1038/s41586-023-06127-z>.

</div>

<div id="ref-zhang_opt_2022" class="csl-entry">

Zhang, Susan, Stephen Roller, Naman Goyal, Mikel Artetxe, Moya Chen,
Shuohui Chen, Christopher Dewan, et al. 2022. “OPT: Open Pre-Trained
Transformer Language Models.” arXiv.
<https://doi.org/10.48550/arXiv.2205.01068>.

</div>

<div id="ref-zhang_unexpectedly_2024" class="csl-entry">

Zhang, Yiwen, Liwei Wu, Yangang Wang, Bin Sheng, Yih Chung Tham, Hongwei
Ji, Ying Chen, Linlin Ren, Hanyun Liu, and Lili Xu. 2024. “Unexpectedly
Low Accuracy of GPT-4 in Identifying Common Liver Diseases from CT Scan
Images.” *Digestive and Liver Disease*, February, S1590865824002111.
<https://doi.org/10.1016/j.dld.2024.01.191>.

</div>

</div>
