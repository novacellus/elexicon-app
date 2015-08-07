xquery version "3.0";

module namespace search="http://scriptores.pl/lexicon/search" ;


(: Definicje namespaces :)
declare namespace tei="http://www.tei-c.org/ns/1.0" ;
declare namespace lmilp="http://scriptores.pl/" ;

import module namespace views = "http://scriptores.pl/lexicon/views" at "views.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://scriptores.pl/lexicon/config" at "xmldb:exist:///db/apps/lexicon/modules/config.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace i18n = "http://scriptores.pl/lexicon/i18n" at "i18n.xql" ;
import module namespace helper= "http://scriptores.pl/lexicon/helper" at "helper.xql" ;


(: Mapuje elementy XML do używanych w aplikacji nazw :)
(:declare variable $elem_names := map {}:)
(: Mapuje nazwy używane w aplikacji do ścieżek w dokumencie XML :)

declare function local:paths($node as node(),$map as map(*)) as map()* {
map {"form" := "lmilp:Forma",
"definition" := "lmilp:Definicjaa" ,
"quotation" := "lmilp:Cytacja"}
};


(: 1. Podstawowe narzędzia wyszukiwania :)

(: Normalizacja zapytania :)
declare function search:normalize($string as xs:string){
    let $string.normalized := normalize-space($string)
    return if($string.normalized ne '') then ($string.normalized) else ()
};

(: Normalizacja zapytania - zaawansowane :)
declare function search:normalize_advanced($string as xs:string) {
let $string.normalized := translate( normalize-space($string) , ',.-\/?;()[]{}:"<>^%$#@!_+=', '')
return $string.normalized
};


(: Utworzenie zapytania w składni eXist :)
declare function search:query_build($how as xs:string , $partial_params as node()*) {
let $parameters := request:get-parameter-names()
let $what := request:get-parameter( "what" , () )
return 
<query>
{
(: Filtruje parametry, które nie dotyczą wyszukiwania :)
    if ($what)
    then (
    search:query_string_build($what,$how)
    )
    else()
}
</query>
};

declare function search:query_string_build($what,$how) {
let $what := search:normalize($what)
return 
switch ($how)
    case "fuzzy" return <fuzzy min-similarity="0.6">{$what}</fuzzy>
    case "normal" return
        if ( contains($what , ' ') )
        then (<phrase>{concat('"',$what,'"')}</phrase> )
        else (<term>{$what}</term>)
    default return <term>{$what}</term> 
};

(: Wyszukiwanie w wyrazach hasłowych :)
declare function search:lemma ($what as xs:string) {
let $what := search:normalize($what)
let $results := collection("/db/apps/lexicon/resources/data")//tei:entryFree[@n eq upper-case($what)]
return if ($what)
    then (
        if (count($results) = 1) then (
        (: 1 wynik:)
        $results
        (: >1 wynik:)
        )
        else ()
    )
    else (false)

};
(: Looks up entry by its @xml:id :)
declare function search:entry_by_id($id as xs:string) {
let $entry := collection("/db/apps/lexicon/resources/data/dict")//tei:entryFree[@xml:id = $id]
return $entry
};   


declare %templates:wrap function search:lemma_print ($node as node(), $model as map(*), $lang) {
let $what := concat('^(\d\.)*', search:normalize(request:get-parameter('what',())) ,'$')
(: Wchodzi w skład wyrazu hasłowego? :)

let $results_lemma := collection("/db/apps/lexicon/resources/data/dict")//tei:entryFree[matches(@n,$what,"i")]

let $results_lemma_print := 
    ( if (count($results_lemma) >= 1)
        then(
        <h4 class="alert-box success">{if (count($results_lemma) = 1) then (i18n:text($node,$model,"disambHomonyms.results.FormsHeadword",$lang)) else (i18n:text($node,$model,"disambHomonyms.results.FormsHeadwords",$lang))}</h4>,
        <ul class="small-block-grid-1">{
            for $result in $results_lemma return
                <li>{views:lemma_link($node,$model,$result/@n,"rewrite")}</li>
        }</ul>
            ) 
        else(<h4 class="alert-box alert">{i18n:text($node,$model,"disambHomonyms.results.NotFormsHeadword",$lang)}</h4>) )
        
(: Wchodzi w skład którejś z form? :)
let $results_form := collection("/db/apps/lexicon/resources/data/dict")//tei:entryFree[matches(.//tei:orth[position()>1], $what)]

let $results_form_print := 
    ( if (count($results_form) >= 1)
        then(
        <h4 class="alert-box success">{if (count($results_form) = 1) then ('jest jednym z wariantów graficznych wyrazu') else ('jest jednym z wariantów graficznych wyrazów')}</h4>,
        <ul class="small-block-grid-1">{
            for $result in $results_form return
                <li>{string($result/@n)}</li>
        }</ul>
            ) 
        else if (count($results_lemma) >= 1 ) then () else (<h4 class="alert-box alert">nie jest wariantem graficznym wyrazu</h4>)
        )
        
return ($results_lemma_print)
};



(: Wyszukiwanie na liście parsowanych lemmatów (za: Renaud) :)
declare %templates:wrap function search:suggestion ($node as node(), $model as map(*) ) {
let $query := search:normalize(request:get-parameter('what',() ) )
let $results := collection("/db/apps/lexicon/resources/data/external/")//item[./word = $query]
return if ($results) then (
<ul id="disamb_forms_list" class="small-block-grid-1 panel single_list">{
<div class="alert-box info"><h4>{i18n:text($node,$model,"disambHomonyms.results.mayBeForm",$lang)}:</h4></div>,
for $result in $results
return <li>{views:lemma_link($node,$model,$result/lemma,"rewrite")}</li>
}</ul> )
else ()
};

(: Wyszukiwanie w cytatach :)
declare function search:quotation ($node as node(),$model as map(*)) as map(*) {
let $query := search:query_build("normal",())
let $results := collection("/db/apps/lexicon/resources/data")//tei:entryFree[ft:query(.//tei:quote,$query)]
return map {"results_quotation" := $results}
};

declare %templates:wrap function search:quotation_print($node as node(), $model as map(*), $lang) as node()* {
let $results := search:quotation($node,$model)
(: Ile wyników wyświetlać? :)
let $limit := 3
(: Ile wyników znaleziono? :)
let $ile := count($results("results_quotation"))
return if ($results("results_quotation")) then (
<h4  class="alert-box success">{i18n:text($node,$model,"disambHomonyms.results.isQuoted",$lang)}</h4>,
<ul class="single_list small-block-grid-1">
{
    for $result in $results("results_quotation")
    (: Filtruje ilość wyników :)    
    where $results("results_quotation")/$result/position() <= $limit
    return 
    let $lemma := xs:string($result[self::tei:entryFree]/@n)
    let $expanded := util:expand($result,"expand-xincludes=no")
    let $match := $expanded//exist:match
    let $context := 50
    let $previous_string :=  string-join( $expanded//exist:match/preceding::text(), ' ' ) 
    let $following_string :=  string-join( $expanded//exist:match/following::text(), ' ' ) 
    let $previous := concat ('... ',substring($previous_string, string-length($previous_string)-$context) )
    let $following := concat (substring($following_string,0,$context),'...' )
    return <li>{views:lemma_link($node,$model,$lemma,"rewrite"), <span class="previous">{$previous}</span>,<span class="hi">{$match}</span>,<span class="following">{$following}</span> }</li>
    }    
    </ul>,
    if ($ile > 3) then (views:more_link($node,$model,request:get-parameter("what",()),"quotation",$ile,1,$lang)) else ()
 )
 else (
 <h4 class="alert-box alert">{i18n:text($node,$model,"disambHomonyms.results.isNotQuoted",$lang)}</h4>
 )
};

(: Wyszukiwanie w definicjach :)
declare function search:definition($node as node(), $model as map(*)) as map(*) {
let $query := search:query_build("normal",())
let $results := collection("/db/apps/lexicon/resources/data")//tei:entryFree[ft:query(.//tei:def,$query)]
return map {"results_definition" := $results}
};


declare %templates:wrap function search:definition_print($node as node(), $model as map(*), $lang) as node()* {
let $results := search:definition($node,$model)
(: Ile wyników wyświetlać? :)
let $limit := 3
(: Ile wyników znaleziono? :)
let $ile := count($results("results_definition"))
return if ($results("results_definition")) then (
<h4 class="alert-box success">{i18n:text($node,$model,"disambHomonyms.results.isInDef",$lang)}</h4>,
<ul class="single_list small-block-grid-1 white-elements">
{
    for $result in $results("results_definition")
    (: Filtruje ilość wyników :)    
    where $results("results_definition")/$result/position() <= $limit
    return 
    let $lemma := xs:string($result[self::tei:entryFree]/@n)
    let $expanded := util:expand($result,"expand-xincludes=no")
    let $match := $expanded//exist:match
    let $context := 50
    let $previous_string :=  string-join( $expanded//exist:match/preceding::text(), ' ' ) 
    let $following_string :=  string-join( $expanded//exist:match/following::text(), ' ' ) 
    let $previous := concat ('... ',substring($previous_string, string-length($previous_string)-$context) )
    let $following := concat (substring($following_string,0,$context),'...' )
    return <li>{views:lemma_link($node,$model,$lemma,"rewrite"), <span class="previous">{$previous}</span>,<span class="hi">{$match}</span>,<span class="following">{$following}</span> }</li>
    
    }
    </ul>,
    if ($ile > 3) then (views:more_link($node,$model,request:get-parameter("what",()),"definition",$ile,1,$lang)) else ()
    
    )
else (<h4  class="alert-box alert">{i18n:text($node,$model,"disambHomonyms.results.isnotInDef",$lang)}</h4>)
};

declare function search:lemma_fuzzy ($node as node(), $model as map(*)) {
let $query := search:query_build("fuzzy",())
let $results := collection("/db/apps/lexicon/resources/data")//tei:entryFree[ft:query(.//tei:orth,$query)]
(:let $results := collection("/db/apps/lexicon/resources/data")//lmilp:Haslo[ft:query(lmilp:Forma,concat("'",$what,"~0.5'"))]:)
return map {"results_lemma_fuzzy" := $results}
};

declare %templates:wrap function search:lemma_fuzzy_print($node as node(), $model as map(*), $lang) as node()* {
let $results := search:lemma_fuzzy($node,$model)
return if ($results("results_lemma_fuzzy")) then (
<h4 class="alert-box success">{i18n:text($node,$model,"disambHomonyms.results.fuzzy",$lang)}</h4>,
<ul id="disamb_forms_list" class="single_list small-block-grid-1">{
for $haslo in $results("results_lemma_fuzzy")[self::tei:entryFree]
   let $form := $haslo/@n
    return <li>{views:lemma_link($node,$model,$form,"rewrite")}</li>
    }
    </ul>
   (:return <rezultaty>{$results("results_lemma_fuzzy")}</rezultaty>:)
)
else ()
};


declare function search:advancedSearch ($node as node(), $model as map(*)) {
let $session := session:get-attribute-names()
return $session
};