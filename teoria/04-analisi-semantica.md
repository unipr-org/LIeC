```table-of-contents
```
# Analisi semantica
Per generare codice abbiamo bisogno di capire il suo significato, quindi il compilatore ha bisogno di porsi tante domande, ad esempio:
- "x" è uno scalare, un array o una funzione? "x" è dichiarata?
- Ci sono nomi che non sono stati dichiarati? Magari dichiarati e non usati? etc.
Queste domande fanno parte dell'analisi context-sensitive, cioè che hanno bisogno di un contesto per avere senso.
Come possiamo dunque rispondere a queste domande?
- Usando metodi formali
	- Grammatiche context-sensitive: consentono di definire regole in cui la produzione di un simbolo dipende dai simboli circostanti (difficili da implementare e poco efficienti).
	- Grammatiche attribuite: ai simboli vengono associati attributi (valori o informazioni aggiuntive) e regole semantiche per calcolare questi attributi (molto utili).
- Tecniche ad-hoc
	- Tabelle dei simboli: strutture dati utilizzate per tenere traccia delle informazioni sulle entità del programma, come variabili, funzioni, classi e scope.
	- Codice ad-hoc (action routines): frammenti di codice specifici (o funzioni) eseguiti durante la compilazione per risolvere problemi contestuali.

> Nel parsing (analisi sintattica) vincono le grammatiche libere dal contesto, mentre nell'analisi semantica (context-sensitive) le tecniche ad-hoc dominano loa pratica.

## Grammatiche attribuite
Le grammatiche attribuite combinano la struttura di una grammatica sintattica con regole semantiche per arricchire i simboli del linguaggio con **attributi**, che rappresentano informazioni aggiuntive come il tipo di una variabile o il valore di un’espressione, e le regole semantiche permettono di **calcolare e verificare** questi attributi.
**PROBLEMI**: 
- calcoli non locali: se un attributo in un punto del codice dipende da informazioni lontane (come l’assegnazione di una variabile definita in un altro blocco), risulta difficile gestirlo in una grammatica attribuita.
- informazioni centralizzate: per molte analisi, serve una tabella centrale delle informazioni (tabella dei simboli) per tenere traccia delle variabili, funzioni e tipi le grammatiche attribuite non sono pensate per gestire direttamente strutture centralizzate, risultando quindi poco pratiche.
Arriviamo dunque a prediligere le **Tecniche ad-hoc**, più flessibili e pratiche per problemi complessi, per ora però capiamo come funzionano queste.

Gli elementi principali sono:
- **Simboli e Attributi**: ogni simbolo della grammatica (sia terminale che non terminale) è arricchito con un insieme di attributi, quest'ultimi sono valori associati ai simboli, che possono contenere informazioni semantiche come il tipo, il valore o altre proprietà rilevanti, esistono due tipi principali di attributi:
	1. Attributi sintetizzati: calcolati dalle regole semantiche sulla base dei figli del simbolo nell'albero sintattico
	2. Attributi ereditati: derivano da informazioni che provengono dai genitori o dai fratelli del simbolo nell'albero.
- **Regole  di attribuzione**: per ogni produzione della grammatica vengono definite regole che descrivono come calcolare gli attributi. Le regole sono funzionali, cioè determinano univocamente il valore di ogni attributo basandosi sugli attributi disponibili.
- **Funzioni semantiche**: le regole di attribuzione spesso usano funzioni definite dall'utente, che calcolano gli attributi in base a valori disponibili o logica specifica.
Vediamo un esempio, la seguente grammatica descrive i numeri binari con segno:

![[binarysign_grammar.png | center | 300]]

Formiamo due AST per due input differenti (-1 e -101):

![[ast_signbinary.png | center | 550]]

Vogliamo dunque calcolare il valore decimale, dobbiamo quindi aggiungere delle regole per farlo:

![[attribute_signbinary.png| left |400]] ![[result_signbinary.png|right|220]]

Possiamo dedurre che, dall'immagine sopra, abbiamo degli attributi per ogni tipo di produzione, ad esempio banalmente per il "BIt" e "List" abbiamo due attributi necessari: posizione e valore.
Andiamo con ordine vediamo come valutare un AST con gli attributi:
 ![[AST_attribute.jpeg | center | 450]]
 **Spiegazione**
 In input abbiamo la stringa -101, che dovrà essere trasformata in decimale tramite una grammatica con attributi.
 Partiamo a sinistra dove abbiamo il segno -, questo porterà la produzione di Sign con l'attributo neg a true e lo "assegna" a number.
 Ora spostiamoci a destra, il primo List che incontriamo avrà l'attributo position uguale a 0 il secondo list attributo position uguale ad 1 e così via anche per i bit, il primo bit che incontriamo avrà position = 0 etc.
 Ora risaliamo l'albero dalle foglie quindi iniziamo dal primo bit più a sinistra che è uguale ad 1, assegnamo quindi alla sua produzione "bit" il valore 4 dato dal calcolo di 2^bit.pos, riporto ora il valore alla produzione superiore "list", nel mentre guardo anche il bit 0, che ha come valore 0 dato dalla condizione che se bit.val = 0 allora 0.
 Arriviamo ora alla produzione "List" con posizione 1, che valore avrà? Devo semplicemente riportare il valore dei due figli sommato, dunque abbiamo la list in posizione 2 con valore 4 e il bit in posizione 1 con valore 0 sommando troviamo che list in posizione 1 vale 4, questo meccanismo è applicato ricorsivamente a tutte le produzioni dell'AST trovando quindi in automatico che number avrà valore finale -5.

### Tipologie di Attributi
- **Attributi sintetizzati**: sono calcolati a partire dagli attributi dei figli e da eventuali costanti o informazioni esterne (dal basso verso l'alto). Le caratteristiche principali sono:
	- Gli attributi sintetizzati di un nodo dipendono dai valori dei nodi figli (o terminali associati) e possono includere costanti.
	- Se una grammatica utilizza solo attributi sintetizzati, si dice **S-attributed** (compatibile con il parsing LR, bottom-up)
	- Facile da implementare durante il parsing, il parsing LR costruisce l'albero sintattico dal basso verso l'alto, calcolare gli attributi sintetizzati durante il parsing è diretto e non richiede trasformazioni particolari.
- **Attributi ereditati**: sono calcolati usando valori provenienti dal genitore del nodo nell'albero sintattico, informazioni provenienti dai fratelli e tramite costanti o informazione esterne. Le caratteristiche principali sono:
	- Gli attributi ereditati sono particolarmente utili per rappresentare il **contesto** del nodo corrente.
	- Gli attributi ereditati spesso richiedono che le informazioni siano calcolate prima che il nodo sia visitato (non è facilmente compatibile con il parsing LR).
	- Spesso, un'analisi basata su attributi ereditati può essere riscritta per evitare questi attributi, trasformandoli in sintetizzati o utilizzando strutture di supporto.
	- Nonostante le difficoltà pratiche, gli attributi ereditati sono ritenuti più "naturali" per esprimere certe relazioni semantiche, poiché modellano esplicitamente il contesto.

### Metodi per calcolare gli attributi
**Metodi dinamici basati su dipendenze**: questi metodi si basano sulle **dipendenze** tra gli attributi, rappresentate in un grafo, per determinare l'ordine di calcolo degli attributi in tempo reale.
**Procedura**: 
1. Costruzione dell'albero sintattico (AST)
2. Costruzione del grafo delle dipendenze: ogni attributo è rappresentato come un nodo del grafo, le dipendenze vengono rappresentate come archi diretti
3. Ordinamento topologico: si effettua un ordinamento topologico del grafo che garantisce che gli attributi siano calcolati nell'ordine corretto.
4. Calcolo degli attributi: vengono valutati in base all'ordine derivato dall'ordinamento topologico.
**Vantaggi**: funziona con qualsiasi grammatica attribuita.
**Svantaggi**: overhead, la costruzione e l'elaborazione del grafo delle dipendenze può essere costoso in termini di tempo e memoria.

**Metodi basati du regole (Treewalk)**: l'ordine di calcolo degli attributi è determinato **in anticipo**, durante la generazione del compilatore, analizzando le regole semantiche associate alla grammatica.
**Procedure**:
1. Analisi delle regole: durante la fase di generazione del compilatore, le regole di attribuzione sono analizzate per identificare le dipendenze tra gli attributi.
2. Si determina un **ordine fisso** per il calcolo degli attributi, basato su una strategia che garantisce che tutti gli attributi necessari per un calcolo siano disponibili al momento giusto.
3. Durante l'elaborazione dell'albero sintattico, i nodi vengono visitati in un ordine specifico (determinato in precedenza) e gli attributi vengono calcolati di conseguenza.
**Vantaggi**: L'ordine statico elimina il bisogno di costruire grafi di dipendenze a runtime, una volta determinato l'ordine, il processo è diretto.
**Svantaggi**: Non tutte le grammatiche attribuite possono essere risolte facilmente con un ordine statico. Alcune richiedono trasformazioni o modifiche.

**Metodi oblivious (Passes, Dataflow)**
Questi metodi ignorano sia le regole semantiche che l'albero sintattico, e invece scelgono un ordine predeterminato (in fase di progettazione del compilatore) per valutare gli attributi.
**Procedure**:
1. Gli sviluppatori decidono un ordine fisso di calcolo degli attributi, questo è basato su ipotesi pratiche e non richiede l'analisi delle regole semantiche.
2. Gli attributi sono calcolati in **più passaggi** sull'albero sintattico, questo approccio può essere simile a un'analisi dataflow: si propagano le informazioni attraverso i nodi fino a quando tutti gli attributi non sono calcolati.
**Vantaggi**: Non richiede analisi sofisticate di dipendenze o costruzione di grafi, può gestire attributi complessi con un numero sufficiente di passaggi.
**Svantaggi**: L'approccio può richiedere più passaggi rispetto ai metodi dinamici o basati su regole, con un aumento dei tempi di esecuzione.

>Il grafo delle dipendenze dev'essere aciclico.