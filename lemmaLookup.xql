xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace lmilp="http://scriptores.pl/" ;
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace views="http://scriptores.pl/lexicon/views" at "xmldb:exist:///db/apps/lexicon/modules/moje/views.xql";
(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

(: Definicja nazw elementów :)
declare variable $dict_root := collection("/db/apps/lexicon/resources/data");
declare variable $entryFree := 'tei:entryFree';
declare variable $orth := 'tei:orth';

let $query := concat(request:get-parameter("term",()),'*')

(:let $results := collection("/db/apps/lexicon/resources/data")//lmilp:Haslo[ft:query(.//lmilp:Forma,<wildcard>{$query}</wildcard>)]:)
let $results := 
            let $query_mod := concat('%5E',$query)
            for $form in collection("/db/apps/lexicon/resources/data")//tei:entryFree[not(@type eq 'xref')]//tei:orth[ft:query(., $query)]
                let $forma := upper-case(translate($form/text(),'-,[] ',''))
                let $lemma := upper-case(translate($form/ancestor::tei:entryFree//tei:orth[not(matches(.,'^scr|et|s$'))][1]/text(),'-,[] ',''))
                let $entry := upper-case(translate($form/ancestor::tei:entryFree/@n,'-,[] ',''))
            return  <result>
                        <forma>{$forma}</forma>
                        <lemma>{$lemma}</lemma>
                        <entry>{$entry}</entry>
                    </result>

return <result>{
for $result in $results
order by $result/forma
return
    for $forma in $result/forma
    return <result>
        (:Pobiera formę:)
        <label>{translate ( upper-case( views:lemma_clean($forma) ) ,'][-','')}</label>
        (:Pobiera @n hasla:)
        <value>{$result/entry/text()}</value>
        </result>
    


 
 }</result>

(:for $forma in distinct-values($result//tei:orth/text()[not(matches(.,'^scr|et|s$'))])
return <result>
        (\:Pobiera formę:\)
        <label>{
        translate (
        upper-case( views:lemma_clean($forma) )
        ,'][-','')
        }</label>
        (\:Pobiera @n hasla:\)
        <value>{string($result/@n)}</value>
        (\:<pos>{substring-before($result//tei:pos[1]/text(),' ')}</pos>:\)
        </result>

 
 }</result>
:)