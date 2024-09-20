```table-of-contents
```
---

## Visuale ad alto livello di astrazione

![[01-00.png]]

Un compilatore ha dei requisiti da rispettare:
- Riconoscimento di programmi validi/invalidi.
- Generazione di codice corretto.
- Gestione delle risorse, quale allocazione e deallocazione della memoria.
- Iterazione con il sistema operativo (es. linker dinamico).


### Tradizionale compilatore a due passi


![[01-01.png]]

In un compilatore a 2 passi si vede una separazione delle responsabilità. In un normale processo di compilazione il codice L raggiunge la parte di **front end** che produce una **rappresentazione intermedia** (**IR**) e la manda alla parte di **back end** che si occuperà di produrre il codice macchina M.


È possibile avere più front end e/o back end.

![[01-02.png]]

### Linguaggio IR

Il linguaggio IR deve essere in grado di rappresentare le informazione raccolte dal compilatore (front end). Esistono varie tipologie di do linguaggio IR, più o meno specializzate, che possono essere:
- Strutturali: alberi, grafi, DAG.
- Lineari: 3-address code, stack-machine code
- Ibridi: CFG (control flow graph) per BB (basic block, blocchi o sequenze di istruzioni)


> Per 3-address-code, si ha l'assembler che vede un istruzione e 3 indirizzi (dato a, dato b, risultato) a dei registri.


> Lo stack-machine code effettua una sequenza di operazioni: `push a`, `push b`, (operazione), `return {res}`. 


Attualmente sono utilizzate le rappresentazioni ibride che vede una una rappresentazione lineare, di blocchi o sequenze di istruzioni (non separabili tra loro), intrecciata ad una rappresentazione strutturale per effettuare i cambi di flusso mediante CFG.


> Le prime specifiche della semantica di Java erano spiegate mediante lo stack-machine code.


---

## Il front end del compilatore

Il compilatore front end è quello di riconoscere se i programmi (di un codice L) validi e invalidi, segnalando errori e warning _facilmente leggibili_, e di produrre codice IR e strutture dati ausiliarie.



### Decomposizione del front end

![[01-03.png]]

Il front end è diviso in 3 parti:
- Lexer, che si occupa di effettuare l'analisi lessicale, che si occupa di scannerizzare l'input, dividerlo in blocchi e produrre dei token. Riconosce (ferma sono quello che considera illegale, ma in caso di dubbio lascia passare) ed etichetta le parole contenute nell'input.
- Parser, che si occupa di effettuare l'analisi sintattica e produrre un IR (un astrazione dell'abstract syntax stree),. L'analisi viene effettuata in modo libera dal contesto. 
- Checker, che si occupa di fare l'analisi di semantica statica su problemi decidibili (es. esistenza di una variabile, chiamate di funzione corrette). L'analisi viene effettuata in modo dipendente dal contesto.

  
> Esempi di analisi libere dal contesto:
> Il controllo di bilanciamento delle parentesi è un operazione che si può effettuare in modo libero dal contesto.
> Il controllo della validità di una variabile non è libero dal contesto. O delle chiamate alle procedure


La maggior parte degli errori presenti in un codice L, sono riscontrati nella fase di compilazione svolta del Checker.


### Lexer

Il lexer si occupa di effettuare l'analisi lessicale lavorando su una sequenza di caratteri e producendo una sequenza di token.
Un token è una coppia ($<part\_of\_speech,\ lexeme>$)composta da 2 parti:
- part_of_speech, che definisce la categoria lessicale a cui appartiene la parola letta.
- lexeme, che corrisponde alla sequenza di caratteri che produce quella categoria.

> Esempi di token: $<STR,\ ''Hello''>$,  $<INT,\ 42>$


#### Specifica vs implementazione


La specifica definisce in modo rigoroso quali sono i token validi, utilizzando un linguaggio adeguato a svolgere questo compito e comprensibili dal _progettista_ (essere umano). Il linguaggio utilizzato sono le **RE** (espressioni regolari).

> Si presentano le difficoltà con le intersezioni e il complemento nell'utilizzo delle espressioni regolari, quindi vengono espanse con degli operatori aggiuntivi per asserire ai compiti richiesti.

L'implementazione presenta un fattore critico dettato dall'efficienza, perché è l'unica parte di front end che deve leggersi tutto l'input. Per effettuare il riconoscimento viene utilizzo un DFSA (automa a stati finiti deterministico), che viene generato (quasi sempre in automatico) attraverso dei tool a partire dalle specifiche.


> Clang ha un DFSA non generato in automatico per avere il massimo controllo.


Esempio di RE per identificatori:

Nella specifica si ha:
- DIGIT = \[ **0** - **9** ]
- LETTER = \[ **a**-**zA**-**Z** ] | \[ **\_** ]
- ID = LETTER( LETTER | DIGIT ) *

> \[ **0** - **9** ], \[ **a**-**zA**-**Z** ]| sono delle **character class**


NOTE:
- I caratteri del linguaggio L sono in grassetto.
- I caratteri non in grassetto sono meta-sintassi.
- Lo \[ **0** - **9** ] abbrevia **0** | **1** | $\dots$ | **9**.
- La meta-sintassi ammette varie forme di abbreviazione (iterazione positiva, complemento, $\ldots$).
- Alcune cose sono implicite, ad esempio nei range l'ordine dei caratteri


> L'uso delle espressioni regolari è pervasivo (comandi shell con wildcard, ricerche di strighe in file di testo con grep o in db, query&replace editor testuali, uso di wildcard in file di configurazione di servizi es. firewall, librerie di supporto per regex).

### Parser

Il parser si occupa di effettuare l'analisi sintattica, prendendo in input una sequenza di token e producendo una rappresentazione IR della struttura sintattica. L'output deve essere adeguato a per le fasi successive, mediante l'utilizzo di un parse tree (concrete syntax tree, usato raramente), o di un AST (abstract syntax tree) che è un astrazione del parse tree.

#### Specifica vs implementazione


La specifica implica l'utilizzo di un linguaggio adeguato e comprensibile dal _progettista_ (essere umano). Il linguaggio scelto è CFG (context free grammar). È possibile che si possano riscontra dei problemi non banali, come il determinismo, l'efficienza e l'ambiguità.

L'implementazione vede l'utilizzo di un riconoscitore rappresentato dal PDA (automa a pila non deterministico), che viene codificato direttamente (spesso implicitamente, usando la ricorsione ed il backtracking) o generato automaticamente partendo dalla grammatica. I generatori presentano tipologie differenti, e queste sono determinate per delle sottoclassi di grammatiche.

> A volte sono applicati _sporchi trucchi_


> Per le CFG vedi slide $[18,\ 22]$ delle slide `01-Struttura-compilatore`


### Checker


Il checker si occupa di effettuare CSA (context-sensistive analysis), analisi semantica statica, prendendo un AST "grezzo" e producendo un "AST" arricchito di informazioni dipendenti dal contesto (tipi di dato, conversioni implicite, risoluzione overloading, $\ldots$).

> Spesso checker e parser sono fortemente integrati, l’AST “grezzo” non viene generato, si costruisce direttamente l’AST arricchito a partire dal parse tree.


#### Specifica vs implementazione


La specifica si occupa di definire in modo rigoroso quali sono i programmi validi. Purtroppo un modo rigoroso non standardizzatto perché la complessità cresce molto facilmente, quindi si procede con la scrittura mediante l'utilizzo del linguaggio naturale (es. standard del linguaggio, manualistico, documaentazione compilatore) e l'applicazioni di semantiche formali (sistemi di regole). Nonostante questo si incorre comunque nelle difficoltà relative alla comprensione.


L'implementazione vede la correttezza come fattore critico. Precedentemente si utilizzavano delle grammatiche arricchite da _attributi_ calcolati, ad oggi sono stati sostituiti dagli SDT (syntax directed translation).

> Gli SDT sono programmi specifici per visitare l'albero (generazione di molti visitor)



> Per gli esempi vedi slide $[25,\ 28]$ delle slide `01-Struttura-compilatore`


---

## Il back end del compilatore

![[01-07.png]]

