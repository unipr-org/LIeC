```table-of-contents
```
---

# Visuale ad alto livello di astrazione
![[01-00.png]]

Un compilatore deve rispettare i seguenti requisiti:
- Riconoscimento di programmi validi/invalidi.
- Generazione di codice corretto.
- Gestione delle risorse, quale allocazione e deallocazione della memoria.
- Iterazione con il sistema operativo (e.g., linker dinamico).

## Tradizionale compilatore a due passi
![[01-01.png]]

In un compilatore a 2 passi si vede una separazione delle responsabilità. 
In un normale processo di compilazione il codice $L$ raggiunge la parte di **front end** ("esperto del linguaggio") che produce una **rappresentazione intermedia** (**IR**) che viene mandata alla parte di **back end** ("esperto dell'architettura"), la quale si occuperà di produrre il codice macchina $M$.
> Questa distinsione non è cosi marcata nei compilatori odierni.

È possibile avere più front end e/o back end: 

![[01-02.png]]

## Linguaggio IR
Il linguaggio IR (Intermediate Representation), è una rappresentazione intermedia utilizzata dal compilatore per descrivere il codice sorgente in una forma che sia più facilmente manipolabile e analizzabile durante le fasi di ottimizzazione e generazione del codice macchina. L'IR funge da ponte tra il front-end del compilatore, che analizza e interpreta il codice sorgente, e il back-end, che genera il codice macchina eseguibile.

Esistono varie tipologie di do linguaggio IR, più o meno specializzate, che possono essere:
- Strutturali: alberi, grafi, DAG (Direct Acyclic Graph).
- Lineari: 
	- 3-address code: l'assembler vede un'istruzione e 3 indirizzi (dato a, dato b, risultato) a dei registri.
	- stack-machine code: effettua una sequenza di operazioni: `push a`, `push b`, (operazione), `return {res}`. 
- Ibridi: CFG (control flow graph) per BB (basic block, blocchi o sequenze di istruzioni).

Attualmente sono utilizzate le rappresentazioni ibride che vede una una rappresentazione lineare, di blocchi o sequenze di istruzioni (non separabili tra loro), intrecciata ad una rappresentazione strutturale per effettuare i cambi di flusso mediante CFG.

Esistono diverse tipologie di linguaggi IR, ciascuna con caratteristiche e scopi specifici. Possiamo classificarle principalmente in tre categorie:
1. **Rappresentazioni Strutturali**: queste rappresentazioni organizzano le informazioni in strutture gerarchiche, come alberi, grafi o DAG (Directed Acyclic Graph).
	- **Alberi di Sintassi Astratta (AST)**: rappresentano la struttura sintattica del codice in modo gerarchico, riflettendo la grammatica del linguaggio sorgente.
	- **Grafi e DAG**: utilizzati per rappresentare le dipendenze tra le operazioni, in cui i nodi rappresentano le operazioni e gli archi le dipendenze tra di esse. I DAG sono particolarmente utili per evitare la ridondanza e per ottimizzare le espressioni comuni.
2. **Rappresentazioni Lineari**: il codice è descritto come una sequenza di istruzioni eseguite in un ordine specifico. Le più comuni sono:
	- **Three-Address Code (TAC)**: ogni istruzione in TAC coinvolge al massimo tre indirizzi o operand. Ad esempio, un’istruzione può essere del tipo `x = y + z`, dove `x`, `y`, e `z` sono variabili o indirizzi di memoria. Questa forma è semplice e ricorda molto un linguaggio assembly, rendendo facile la mappatura diretta sul codice macchina.
	- **Stack-Machine Code**: in questo modello, le operazioni sono eseguite utilizzando una pila (stack). Le istruzioni tipicamente eseguono operazioni come `push` (per aggiungere valori alla pila), eseguire un'operazione (ad esempio `add`), e `pop` (per rimuovere e ottenere il risultato). Questo approccio è semplice da implementare, ma meno efficiente rispetto a TAC in termini di accesso diretto agli operand.
3. **Rappresentazioni Ibride**: combinano aspetti delle rappresentazioni strutturali e lineari. La forma più comune è:
	- **CFG (Control Flow Graph) per BB (Basic Block)**: in questa rappresentazione, il codice è suddiviso in "Basic Blocks" (BB), ossia sequenze di istruzioni che vengono eseguite linearmente senza interruzioni. Questi blocchi sono poi collegati tra loro tramite un CFG, che rappresenta le possibili transizioni di flusso tra i blocchi.

Attualmente, la maggior parte dei compilatori moderni utilizza rappresentazioni ibride, poiché queste permettono di sfruttare i vantaggi sia delle rappresentazioni lineari sia di quelle strutturali. La combinazione di Basic Blocks (lineare) con CFG (strutturale) consente al compilatore di eseguire sofisticate analisi e ottimizzazioni sul codice, facilitando la gestione dei salti condizionali e dei loop, e migliorando l'efficienza complessiva del codice generato.

---

# Il front end del compilatore
Il compito del front end è quello di riconoscere se i programmi (di un codice $L$) sono validi (e invalidi), segnalando errori e warning _facilmente leggibili_, per infine produrre codice IR (e strutture dati ausiliarie).

## Decomposizione del front end
![[01-03.png]]

Il front end è diviso in 3 parti:
- Lexer: si occupa di effettuare l'analisi lessicale, che si occupa di scannerizzare l'input, dividerlo in blocchi e produrre dei token. Riconosce (ferma sono quello che considera illegale, ma in caso di dubbio lascia passare) ed etichetta le parole contenute nell'input.
- Parser, che si occupa di effettuare l'analisi sintattica e produrre un IR (un astrazione dell'abstract syntax stree),. L'analisi viene effettuata in modo libera dal contesto. 
- Checker, che si occupa di fare l'analisi di semantica statica su problemi decidibili (es. esistenza di una variabile, chiamate di funzione corrette). L'analisi viene effettuata in modo dipendente dal contesto.
  
### Esempi di analisi libere dal contesto
- Il controllo di bilanciamento delle parentesi è un operazione che si può effettuare in modo libero dal contesto.
- Il controllo della validità di una variabile non è libero dal contesto.

La maggior parte degli errori presenti in un codice $L$, sono riscontrati nella fase di compilazione svolta del Checker.

---

## Lexer
Il processo di analisi lessicale (lexing) rappresenta la prima fase del front end di un compilatore, dove il codice sorgente viene suddiviso in unità significative chiamate "token". 
Un token è una coppia $<\text{part\_of\_speech,\ lexeme}>$ composta da 2 parti:
- $\text{part\_of\_speech}$, che definisce la categoria lessicale a cui appartiene la parola letta;
- $\text{lexeme}$, che corrisponde alla sequenza di caratteri che produce quella categoria.

> Esempi di token: $<STR,\ ''Hello''>$,  $<INT,\ 42>$.

### Specifica vs implementazione (Lexer)
La specifica del lexer definisce in modo formale e rigoroso quali sono i token validi del linguaggio. Questa definizione avviene utilizzando un linguaggio formale che risulti comprensibile e utilizzabile dal progettista umano. Lo strumento principale per questa specifica sono le **Espressioni Regolari (RE)**, che forniscono un modo conciso per descrivere i pattern che i token devono seguire.

Le espressioni regolari sono potenti ma presentano alcune limitazioni, ad esempio quando si tratta di esprimere intersezioni e complementi di insiemi di caratteri. Per superare queste limitazioni, possono essere estese con operatori aggiuntivi che ne aumentano la flessibilità e consentono di specificare in modo più dettagliato i token richiesti.

Un esempio classico di espressione regolare per identificare gli identificatori di un linguaggio è il seguente:
```
DIGIT = [ 0 - 9 ]
LETTER = [ a-zA-Z ] | [ _ ]
ID = LETTER ( LETTER | DIGIT ) *
```

In questo caso:
- `[ 0 - 9 ]` e `[ a-zA-Z ]` rappresentano le character class, ovvero insiemi di caratteri definiti attraverso intervalli.
- I caratteri in grassetto fanno parte del linguaggio specificato, mentre i caratteri non in grassetto sono meta-sintassi utilizzata per definire i token.

> Le espressioni regolari consentono diverse forme di abbreviazione, come iterazione positiva, complemento, e altre convenzioni che rendono più chiara la specifica del token.

L'implementazione del lexer si concentra sulla trasformazione delle specifiche dei token in un meccanismo efficiente per la loro identificazione nel codice sorgente. Questa fase è critica dal punto di vista dell'efficienza, poiché il lexer è l'unica componente del front-end che deve leggere l'intero input del programma.

La struttura più comune utilizzata per implementare un lexer è un **DFSA (Deterministic Finite State Automaton)**, un automa a stati finiti deterministico che, partendo da uno stato iniziale, si muove attraverso una serie di stati in base ai caratteri in ingresso fino a identificare un token.
Questi DFSA vengono generalmente generati in modo automatico a partire dalle espressioni regolari specificate (grazie a strumenti come lex o flex). Tuttavia, esistono eccezioni: il compilatore Clang utilizza un DFSA costruito manualmente per garantire un maggiore controllo e ottimizzazione nell'analisi lessicale.

> La fase di specifica definisce "cosa" è un token in modo formale, mentre l'implementazione si occupa del "come" riconoscere questi token in modo efficiente.

---

## Parser
Il parser è responsabile dell'analisi sintattica, ovvero della fase in cui una sequenza di token, prodotta dal lexer, viene interpretata per verificarne la struttura secondo le regole grammaticali del linguaggio sorgente. L'obiettivo è produrre una rappresentazione intermedia (IR) che catturi la struttura sintattica del programma. Questa rappresentazione può assumere la forma di un _parse tree_ (detto anche Concrete Syntax Tree, CST) o di un _Abstract Syntax Tree_ (AST).
- **Parse Tree (Concrete Syntax Tree)**: rappresenta fedelmente la grammatica del linguaggio, includendo tutti i dettagli della sintassi. Tuttavia, è raramente utilizzato direttamente nelle fasi successive del compilatore a causa della sua complessità e verbosità.
- **Abstract Syntax Tree (AST)**: è un'astrazione del parse tree che omette i dettagli irrilevanti (e.g., i simboli delle parentesi e le regole di produzione inutili). L’AST è più compatto e si concentra sulla struttura semantica del codice, rendendolo più adatto per le fasi successive di analisi e ottimizzazione.

### Specifica vs implementazione (Parser)
La specifica di un parser definisce quali sequenze di token costituiscono programmi validi secondo le regole del linguaggio. Per fare ciò, si utilizza una **Context-Free Grammar (CFG)** (i.e., grammatica libera dal contesto), che è in grado di esprimere le strutture sintattiche più comuni nei linguaggi di programmazione.

Le CFG sono composte da un insieme di regole di produzione che definiscono come i simboli non terminali possono essere sostituiti da combinazioni di terminali e altri non terminali.
Tuttavia, lavorare con le CFG presenta diverse sfide, come la gestione dell'ambiguità (dove una stessa stringa può essere generata da più di una derivazione), l’efficienza del parsing e il determinismo.

L'implementazione del parser prevede la costruzione di un meccanismo in grado di riconoscere le strutture definite dalla CFG. Questo riconoscimento avviene tramite un PDA (automa a pila non deterministico), un automa a pila non deterministico che ha la capacità di gestire un contesto grazie all'uso di una pila.

Il PDA può essere implementato direttamente (in modo implicito) utilizzando tecniche come la ricorsione e il backtracking. Questo approccio permette di definire parser ricorsivi discendenti che seguono direttamente la struttura della grammatica specificata.
In alternativa, è possibile utilizzare tool di generazione automatica di parser (e.g., Yacc, Bison o ANTLR) che producono un parser partendo dalla grammatica specificata. 

Possiamo scrivere una grammatica libera da contesto come $G = \langle S, N, T, P \rangle$:
- $N$: simboli non terminali (categorie sintattiche).
- $T$: simboli terminali (categorie lessicali, i.e., token prodotti dal lexer).
- $S \in N$: simbolo iniziale.
- $P \subseteq N \times (N \cup T)^*$: produzioni della grammatica.

### Esempio di CFG
Supponiamo di avere la seguente grammatica per espressioni additive:
$$
\begin{array}{l}
S = Expr \\
N = \{ Expr,\ Op,\ Term \} \\
T = \{ id,\ num,\ +,\ - \} \\
P = \begin{cases} 
	S \to Expr, \\ Expr \to Term \mid Expr \; Op \; Term, \\ Op \to + \mid -, \\ Term \to id \mid num 
	\end{cases} 
\end{array}
$$
Con le seguenti abbreviazioni:
- $N$, $T$ e $S$ impliciti
- Numerazione produzioni:
```
1      S -> Expr
2   Expr -> Term
3         | Expr Op Term
4     Op -> +
5         | -
6   Term -> id
7         | num
```

L'esempio di derivazione di `x + 2 - y` (top down) sarà:

![[01-07.png]]

L'esempio di parsing di `x + 2 - y` (bottom up) sarà:

![[01-08.png]]

Ma questo parse tree può essere trasformato nel seguente abstract syntax tree (AST):

![[01-09.png]]

---

## Checker
Il checker è responsabile della Context-Sensitive Analysis (CSA), un'analisi semantica statica che trasforma un AST "grezzo" in un AST arricchito con informazioni contestuali. Queste informazioni includono dettagli come i tipi di dato, le conversioni implicite e la risoluzione del sovraccarico (overloading).

In molti casi, il checker e il parser sono fortemente integrati. In queste implementazioni, l'AST "grezzo" non viene generato come passaggio intermedio; invece, si costruisce direttamente un AST arricchito a partire dal parse tree. Questo approccio consente di migliorare l'efficienza e la coerenza, riducendo la complessità complessiva del processo di analisi.

### Specifica vs implementazione (Checker)
La specifica del checker ha il compito di definire in modo rigoroso i programmi validi, ma questa definizione rigorosa può risultare complessa e non sempre standardizzata. La difficoltà di formalizzare la semantica di un linguaggio di programmazione porta spesso a utilizzare una combinazione di linguaggio naturale (come standard di linguaggio, manuali e documentazione del compilatore) e semantiche formali, come sistemi di regole. Tuttavia, questo approccio può ancora generare ambiguità e rendere la comprensione delle specifiche problematica.

Nell’implementazione, la correttezza del checker è un aspetto cruciale. In passato, si utilizzavano grammatiche arricchite con attributi calcolati per gestire l'analisi semantica. Oggi, però, si preferiscono tecniche di Syntax Directed Translation (SDT). Gli SDT consistono in programmi specializzati per visitare l'albero di sintassi, e ciò spesso comporta la generazione di numerosi visitor.

### Esempio di AST
Supponiamo di avere il seguente programma in C chiamato `a.c`:
```c
int main(int argc, char* argv[]) { 
	return argc == 1; 
}
```

Il dump dell'AST prodotto da clang sarà:

![[01-10.png]]

Mentre l'AST generato utilizzando la compilazione C++ sarà: 

![[01-11.png]]

---

# Il back end del compilatore
Il compito del back end è quello di tradurre la IR in linguaggio (macchina) $M$. 
Vengono scelte le istruzioni per implementare le operazioni. Inoltre viene deciso quali valori mantenere nei registri.
Deve rispettare le interfacce di sistema (e.g., le eccezioni che arrivano).

![[01-12.png]]

Il back end si divide in tre sottosezioni:
1. Vengono selezionate le istruzioni.
2. Vengono allocati i registri.
3. Vengono schedulate le istruzioni.

Sono problemi inerentemente complicati (NPC), e quindi ci si basa sull'applicazione di tecniche euristiche.

![[01-13.png]]

## Instruction selection
Ha il compito di produrre un codice veloce (tempo) e compatto (spazio). Deve sfruttare caratteristiche della “macchina” per M. Spesso visto come problema di pattern matching. Ricerca di ottimi locali (approssimazione).

## Register allocation
Gestione di un insieme finito di risorse (registri CPU). Splilling dei registri: istruzioni di LOAD e STORE (vanno evitate). Colorazione di grafi.

## Instruction scheduling
Gestione dipendenze a livello hardware: evitare le attese. Ottimizzare l’uso delle unità funzionali della CPU. Può modificare il tempo di vita dei valori nei registri (quindi influenzare la loro allocazione)

### Esempio di scheduling
Operazioni da seguire:
```
a <- b * c + d
e <- f + a
```

Dobbiamo tenere traccia dei cicli di clock per ogni istruzione: supponiamo che per load e store impieghiamo 2 cicli e con le altre operazioni solo 1.

Il codice pseudo-macchina sarà:
```
load @b -> r1
load @c -> r2
mult r1, r2 -> r3
load @d -> r4
add r3, r4 -> r5
store r5 -> @a
load @f -> r6
add r5, r6 -> r7
store r7 -> @e
```

Ma per esempio l'istruzione 3 non può essere eseguita il ciclo dopo di clock della istruzione 2 perchè la 2 ci impiega 2 cicli. Dobbiamo aggiungere un "nop" (operazione vuota, attendi). Questo porta ad una perdita di tempo e spreco di spazio. Possiamo ottimizzare queste sequenze di nop andando a diminuire i registri utilizzati.

---

# Front end e back end (riassumendo)
Quindi riassumendo, la separazione responsabilità e competenze sarà:
- Front end: linguaggi sorgente, generatori automatici, problema “risolto”.
- Back end: macchine target, approcci ad hoc, problema “in evoluzione” (nuove CPU, GPU, ...).

---

# Middle end
Analizza e trasforma il codice IR. 
Obiettivo: migliorare il codice
- metriche classiche: tempo di esecuzione, spazio memoria
- metriche recenti: consumo energia, risorse hardware, ...
Deve preservare la semantica del programma.

![[01-14.png]]

Suddivisione in passi (possibilmente ripetuti, quisti loop vanno in esecuzione un numero finito di volte)
Ogni passo mantiene la semantica del programma
Un singolo passo implementa una analisi o trasformazione IR:
- passo di analisi: faccio analisi per dedurre nuove informazioni per eventuali nuove modifiche (e.g., identificazione di valori costanti, identificazione di codice o valori inutili, analisi di aliasing)
- passo di trasformazione: effettua la trasformazione (e.g., propagazione di valori costanti, rimozione di codice inutile (tipo strutturare un software per più architetture e rimuovo le architetture non supportate), inlining di chiamate a funzioni, loop unrolling)
Un passo può dipendere e/o invalidare altri passi
Sequenza dei passi dipende dal compilatore (e opzioni)

> Non passiamo i tipi piccoli per riferimento nelle funzioni perchè cosi evitiamo l'aliasing e il compilatore è molto più veloce.

![[01-15.png]]

Altri benefici della strutturazione del compilatore
- front end riutilizzabili per implementare interpreti
- compilazione JIT (Just In Time): passi middle end scelti a run-time
- semplificazione sviluppo di analisi ad hoc (clang-tidy)
- integrazione con IDE (editori, debugger, ...)