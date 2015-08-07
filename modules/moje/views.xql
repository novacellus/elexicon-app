xquery version "3.0";

(: Zestaw funkcji dla widoków elementów słownika :)
module namespace views = "http://scriptores.pl/lexicon/views";
import module namespace search="http://scriptores.pl/lexicon/search" at "search.xql";
import module namespace exter="http://scriptores.pl/lexicon/exter" at "xmldb:exist:///db/apps/lexicon/modules/moje/exter.xql";
import module namespace i18n = "http://scriptores.pl/lexicon/i18n" at "xmldb:exist:///db/apps/lexicon/modules/moje/i18n.xql" ;
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://scriptores.pl/lexicon/config" at "xmldb:exist:///db/apps/lexicon/modules/config.xqm";
import module namespace helper= "http://scriptores.pl/lexicon/helper" at "helper.xql" ;
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace lmilp="http://scriptores.pl/" ;
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Definicja nazw elementów :)
declare variable $views:dict_root := collection("/db/apps/lexicon/resources/data");
declare variable $views:entryFree := tei:entryFree;
declare variable $views:orth := tei:orth;

(: Funkcje pomocnicze :)

(: Mapuje elementy XML do używanych w aplikacji nazw :)
(:declare variable $elem_names := map {}:)
(: Mapuje nazwy używane w aplikacji do ścieżek w dokumencie XML :)
declare function local:paths($node as node(),$model as map(*)) as map()* {
map {"form" := "lmilp:Forma",
"definition" := "lmilp:Definicjaa" ,
"quotation" := "lmilp:Cytacja"}
};
declare %templates:wrap function views:parameter_value($node as node(), $model as map (*),$name) {
(: Zwracam wartość parametru sesji, o nazwie $name :)
let $value := request:get-parameter($name,())
(:let $value := 'wełna':)
return $value
};
(: Link lemmatu :)
declare function views:lemma_link($node as node(), $model as map (*), $lemma as xs:string, $mode as xs:string?) {
let $lang := request:get-parameter("lang","pl")
let $mainPath := helper:rewrite-rel($node, $model, (), "linkWithLang", (), $lang, ())
return
<a class="lemma_link" href="{ if ($mode eq 'rewrite') 
then ( concat($mainPath,"lemma/", $lemma) )
else ( concat('singleView.html','?',"what=",$lemma) ) }" target="_blank">{views:lemma_clean($lemma)}</a>


(:<a class="lemma_link" href="{concat('/',$lemma)}" target="_blank">{views:lemma_clean($lemma)}</a>:)

};
(: Link "więcej wyników" :)
declare function views:more_link($node as node(),$model as map(*),$what,$where,$much as xs:integer,$start as xs:integer, $lang){
(:let $start := request:get-parameter("start",1):)
<a class="more_link button tiny" href="{escape-html-uri(concat('advancedDisamb.html','?','what=',$what,"&#38;",'where[]=',$where,"&#38;",'start=', $start))}">{concat (i18n:text($node,$model,"disambHomonyms.results.found", $lang), " ",$much," ")} {i18n:text($node,$model,"g.More",$lang)} <i class="fa fa-angle-double-right"></i></a>
};
declare function views:testowanie($node as node(), $model as map (*) ) {
let $query := concat(request:get-parameter("term",()),'*')
let $results := collection("/db/apps/lexicon/resources/data")//tei:entryFree[ft:query(.//tei:orth,'CABACIUM*')]
return <results>{$results}</results>
};

(:Pojedyncze hasło: singleView.html:)
(: Mapa całego hasła: funckja-wrapper: tworzy mapę wokół pojedynczego hasła: tymczasowo - całe hasło, docelowo - @xml:id :)
declare function local:entry($node as node(), $model as map(*)) as map (*) {
let $entry := search:lemma(request:get-parameter("what",()) )
return map {"entry" := $entry}
};

declare %templates:wrap function views:entry_single ($node as node(), $model as map(*) ) {
local:entry($node, $model)
};

declare %templates:wrap function views:entry_simple ($node as node(),$model as map(*),$lang as xs:string)
{
(:let $lang := $model("current.lang")
:)
let $entry := $model("entry")

(: Ekscerpuje dane z hasła do mapy :)

let $entry_simple := map {
"lemma" := upper-case($entry/@n),
"forms" := $entry//tei:orth, 
"etymos" := $entry//tei:etym, 
"paradigms" := $entry//tei:iType, 
"pos" := $entry//tei:pos/@norm, 
"rodzaj" := $entry//tei:gen,
(:"senses" := if($lang ne 'pl') then ($entry//tei:def[@xml:lang="la"]) else ($entry//tei:def[@xml:lang="pl"]),:)
"senses" := $entry//tei:sense ,
"syntax" := "", "collocs" := "", "times" := "", "places" := ""
}

return (
<div class="row">
<div class="small-12 columns">
<div class="entry_simple">
<div class="entry_simple_header">
<h3 class="entry_simple_lemma">{$entry_simple('lemma')}</h3>
<fieldset>
<legend>{i18n:text($node,$model,"global.Grammar",$lang)}</legend>
<ul class="small-block-grid-2">
<!--Formy-->
    <li><span class="label">{i18n:text($node,$model,"global.Forms",$lang)}</span> {
    for $form at $posit in $entry_simple("forms")
    let $form := concat ( lower-case(search:normalize_advanced($form)) , if (count($entry_simple("forms"))>1 and $posit < count($entry_simple("forms"))) then (', ') else ('') )
    return (<span class="entry_simple_form">{$form}</span>)}</li>
    <!--Etymologia-->
    <li><span class="label">{i18n:text($node,$model,"global.Etymology",$lang)}</span>{ if ($entry_simple("etymos")) then ( for $etymo in $entry_simple("etymos") return (<span class="entry_simple_etym">{translate($etymo,'[\(\)]','') }</span>) ) else (<span class="entry_simple_etym">{i18n:text($node,$model,"etymology.classical",$lang)}</span>)}</li>
    <!--Paradygmat-->
    <li><span class="label">{i18n:text($node,$model,"global.Paradigm",$lang)}</span> {for $paradigm in $entry_simple("paradigms") return (<span class="entry_simple_iType">{$paradigm}</span>)}</li>
        <!--Część mowy-->
    {if ($entry_simple("pos")) then(<li><span class="label">{i18n:text($node,$model,"global.Pos",$lang)}</span> {for $pos in $entry_simple("pos") return (<span class="entry_simple_pos">{i18n:text($node,$model,concat("pos.",$pos),$lang )}</span>) }</li> ) else()}
        <!--Rodzaj-->
    {if ($entry_simple("rodzaj")) then(<li><span class="label">{i18n:text($node,$model,"global.Gender",$lang)}</span>
    {for $rodzaj in $entry_simple("rodzaj") 
    return (<span class="entry_simple_gen">{i18n:text($node,$model,concat("gen.",translate($rodzaj,'[\. ]','') ),$lang )}</span>)}</li>) else()}
</ul>
</fieldset>
</div>
</div>
<div class="entry_simple_senses">
<fieldset>
<legend>{i18n:text($node,$model,"global.Meanings",$lang)}</legend>
<!-- <ul class="small-block-grid-1">
{for $sense in $entry_simple("senses")
    let $level := count($sense/ancestor::tei:sense)
    
    let $def := if($lang ne 'pl') then ($sense/tei:def[@xml:lang="la"]) else ($sense/tei:def[@xml:lang="pl"])
    let $def := if ( normalize-space ($def) ne '' ) then ($def) 
                else if (normalize-space($sense/tei:label[@type = 'sens']) ne '') then ($sense/tei:label[@type = 'sens'])
                else if ( normalize-space ( string-join ( $sense/tei:emph , '' ) )ne ''  ) then ( string-join($sense/tei:emph,'') )
                else if ( $sense/tei:label[@type ="numbering"]  ) then ( $sense/tei:label[@type ="numbering"] )
                else ()
    
    let $numbering := if ($sense/@n ne '') then ($sense/@n) else ('0')
    let $numbering_ancestors := if ($sense/ancestor::tei:sense) then ( concat(string-join($sense/ancestor::tei:sense/@n,'_'),'_') ) else ()
    
    return (
    <li>
        <a class="label" href="{concat('#',concat(if($numbering_ancestors) then ($numbering_ancestors) else (),'sense_',$numbering))}">+ </a>
        <a level="{$level}" class="sense-simple" href="{concat('#',concat(if($numbering_ancestors) then ($numbering_ancestors) else (),'sense_',$numbering))}">{$def}</a>
    </li>
    )}
</ul> -->
{transform:transform($entry,doc('/db/apps/lexicon/resources/xsl/singleEntrySimple.xsl'),(<parameters><param name="lang" value="{$lang}"/></parameters>))}

</fieldset>
</div>
</div>
</div>
,
if ($entry_simple("syntax")) then (
<ul class="single_list">
<div class="alert-box info"><h3>{i18n:text($node,$model,"global.Syntax",$lang)}</h3></div>
{for $syntax in $entry_simple("syntax") return (<li>{$syntax}</li>)}
</ul>) else (),
if ($entry_simple("collocs")) then (
<ul class="single_list">
<div class="alert-box info"><h3>{i18n:text($node,$model,"global.Collocations",$lang)}</h3></div>
{for $colloc in $entry_simple("collocs") return (<li>{$colloc}</li>)}
</ul>) else (),
if ($entry_simple("times")) then (
<ul class="single_list">
<div class="alert-box info"><h3>{i18n:text($node,$model,"global.spaceTime",$lang)}</h3></div>
{for $time in $entry_simple("times") return (<li>{$time}</li>)}
</ul> ) else ()
)
};
declare %templates:wrap function views:entry_full ($node as node(),$model as map(*))
{
let $entry := $model("entry")
return
<div class="row">
                        <div class="small-12 columns">
                            <h4 class="alert-box secondary tab-header">Pełne hasło</h4>
    {transform:transform($entry,doc('/db/apps/lexicon/resources/xsl/singleEntry.xsl'),())}
    </div>
    </div>
};
declare %templates:wrap function views:entry_more ($node as node(),$model as map(*),$lang)
{
(:<div data-alert="" class="alert-box"><h3>{i18n:text($node,$model,"singleView.tab.more.header")}:</h3></div>,:)
<div class="row">
                        <div class="small-12 columns">
                            <h4 class="alert-box secondary tab-header">Więcej</h4>
<div class="entry_more_dicts">
<h4>{i18n:text($node,$model,"singleView.tab.more.header.dicts",$lang)}</h4>
<ul class="small-block-grid-2 large-block-grid-3">
<li>{exter:link((),(),'ngml',   'button')}</li>
<li>{exter:link((),(),'georges','button')}</li>
<li>{exter:link((),(),'ducange','button')}</li>
<li>{exter:link((),(),'logeion','button')}</li>
<li>{exter:link((),(),'gaffiot','button')}</li>
</ul>
</div>
<div class="entry_more_corpora">
<h4>{i18n:text($node,$model,"singleView.tab.more.header.corpora",$lang)}</h4>
<ul class="small-block-grid-2 large-block-grid-3">
<li>{exter:link((),(),'perseus','button')}</li>
<li>{exter:link((),(),'mgh','button')}</li>
<li>{exter:link((),(),'fontes','button')}</li>
<li>{exter:link((),(),'ccorporum','button')}</li>
</ul>
</div>
</div></div>
};
(: Pojedyncze hasło: sidebar :)
declare %templates:wrap function views:sidebar_lista_hasel($node, $model) {
let $what := request:get-parameter("what",())
let $ile := 10 (: Ile wyników wyświetlać? Przekazywać dynamicznie?:)
let $all := collection("/db/apps/lexicon/resources/data/dict")//tei:entryFree[not(@type eq 'xref')]
let $this := $all[@n eq upper-case($what)]
let $position := $this/position()
let $before_entry := $this/preceding-sibling::tei:entryFree[not(@type eq 'xref')][position() = (last() - $ile) to last() ]
let $this_entry := $this
let $after_entry := $this/following-sibling::tei:entryFree[not(@type eq 'xref')][position () = 1 to $ile]
return (
<ul class="sidebar_list">{
        for $entry-before in ($before_entry)
        return (<li>{views:lemma_link($node,$model,$entry-before/@n,"rewrite")}</li>),
        
        <div class="lemma_link active-lemma-link">
            <strong>{views:lemma_clean (string-join($this_entry/@n,'') ) }</strong>
        </div>,
        
        for $entry-after in ($after_entry)
        return (<li>{views:lemma_link($node,$model,$entry-after/@n,"rewrite")}</li>)
}</ul>)
};
(:Oczyszczanie lemma na potrzeby funkcji views:sidebar_lista_hasel:)
declare function views:lemma_clean($string as xs:string) {
let $string := translate(normalize-space($string),',', '')
let $string := if (matches($string, ' ')) then (substring-before($string,' ')) else ($string)
return $string
};

(:Wyszukiwanie zaawansowane: advancedDisamb.html:)
(: Wyniki wyszukiwania zaawansowanego: wyszukiwanie :)
declare %templates:wrap function views:advancedDisamb ($node as node(),$model as map(*),$what as xs:string*,$where as xs:string*) {
(: Allows leading wildcards :)    
    let $options := <options>
    <leading-wildcard>yes</leading-wildcard>
</options>
(: Szukane słowo :)
    let $what := request:get-parameter("what",())
    let $partial := request:get-parameter("how[]",())
    let $partial_params := for $param in $partial
        return <partial>{$param}</partial>
    let $what_alt := search:query_build("normal",$partial_params)
    let $where := request:get-parameter("where[]",())
    
    (: Gdzie szuka: definicje, lemmaty, cytaty :)
    let $wheres :=
        for $where1 in tokenize($where," ")
        return switch($where1)
            case "lemma" return 'tei:orth' 
            case "definition" return 'tei:def'
            case "quotation" return 'tei:quote'
            default return ()
            
    let $search_options := "<options><leading-wildcard>yes</leading-wildcard></options>"
            
    (: Tworzy predykat "doklejany" do ścieżki wszystkich haseł:)
    let $wheres_string := if ($what ne '') 
        then (if (count($wheres) > 0) then (concat ('[','ft:query(.//(', string-join( $wheres,'|'), ')',",'",$what_alt,"'",",",$search_options,"",')]' ) )
            else(concat ('[','ft:query(.//(', string-join( $wheres,'|'), ')',",'",$what_alt,"'",')]' )) ) 
        else ('')
    
    let $wheres_map := map:new(
        for $where1 at $count in $where
        return map:entry(  $count, $where1)
        )
    
    let $main_string := concat('collection("/db/apps/lexicon/resources/data/dict")//tei:entryFree',$wheres_string )
    (: Wyświetla listę haseł wyszukanych na podstawie lemmatu, cytatów i definicji:)
    let $filter_string := local:filter_string($node,$model)("filter_string")
    let $filter_criteria := local:filter_string($node,$model)("filter_criteria")
    let $page_ref := request:get-header("Referer")
    (:Checks if request has been made from the orginal search page or disambHomonyms.html :)
    let $if_advancedBrowse := xs:boolean(matches($page_ref,'advancedBrowse|disambHomonyms'))
    
    let $results_main_ids := ''
    (:let $results_main := util:eval(concat($main_string,$filter_string))
    let $results_main_ids := <ids>{for $result in $results_main return <id>{string($result/@xml:id)}</id>}</ids>:)
(:    let $results_main_from_ids :=
        for $id in $results_main_ids/id
        return search:entry_by_id($id):)
    (: Łączy dwie części kwerendy (hasła + predykaty pozycyjne) i zwraca mapę z wynikami wyszukiwania oraz zapytaniami:)
    return
    if (not($what) and not($wheres_string) and not($filter_string) and not($if_advancedBrowse)) then
    (
        map {
            "results_main" := session:get-attribute("RESULTS.results_main"),
            "results_main_ids" := session:get-attribute("RESULTS.results_main_ids"),
            "main_string" := session:get-attribute("RESULTS.main_string"),
            "query.what" := session:get-attribute("QUERY.what"),
            "query.where" := session:get-attribute("QUERY.where"),
            "filter_string" := session:get-attribute("RESULTS.filter_string"),
            "filter_criteria" := session:get-attribute("RESULTS.filter_criteria")
            
            } )
    else (
        let $store := (
            session:remove-attribute("RESULTS.results_main"),
            session:remove-attribute("RESULTS.results_main_ids"),
            session:remove-attribute("RESULTS.main_string"),
            session:remove-attribute("RESULTS.filter_string"),
            session:remove-attribute("RESULTS.filter_criteria"),
            session:remove-attribute("QUERY.what"),              
            session:remove-attribute("QUERY.where"),

            session:set-attribute("RESULTS.results_main", util:eval(concat($main_string,$filter_string)) ),
            session:set-attribute("RESULTS.results_main_ids", $results_main_ids ),
            session:set-attribute("RESULTS.main_string", $main_string),
            session:set-attribute("RESULTS.filter_string", $filter_string),
            session:set-attribute("RESULTS.filter_criteria",$filter_criteria),
            session:set-attribute("QUERY.what",$what),
            session:set-attribute("QUERY.where",$wheres_map)            
            )
        return (
            map {
            "results_main" :=  util:eval(concat($main_string,$filter_string)),
            "results_main_ids" := $results_main_ids,
            "main_string" := $main_string,
            "filter_criteria" := $filter_criteria,
            "filter_string" := $filter_string,            
            "query.what" := $what,
            "query.where" := $wheres_map
            }
            )
            )
};
(:Filtruje wyniki wg kryteriów zaawansowanych:)
declare function local:filter_string($node as node(), $model as map(*)) {
let $parameters := helper:read_parameters($node,$model)
(: For each search criterion returns human-readable label :)
let $filter_criteria := map:new (

for $parameter in map:keys($parameters("http"))
    let $value := map:get($parameters("http"),$parameter)
    return    
        switch($parameter)
        case "gram_gen" return 
            if ($value ne '')
            then (
            switch ($value)
                case 'm' return map:entry($parameter,'masculinum')
                case 'f' return map:entry($parameter,'femininum')
                case 'n' return map:entry($parameter,'neutrum')
                default return ()
                ) else ()
        case "gram_pos" return if ($value ne '') then ( 
                switch ($value)
                case 'n' return map:entry($parameter,'nomen')
                case 'v' return map:entry($parameter,'verbum')
                case 'adi' return map:entry($parameter,'adiectivum')
                case 'adv' return map:entry($parameter,'adverbium')
                case 'num' return map:entry($parameter,'numerale')
                case 'praep' return map:entry($parameter,'praepositio')
                case 'coni' return map:entry($parameter,'coniunctio')
                default return () ) else ()
        case "gram_itype" return if ($value ne '') then ( map:entry($parameter, concat('declinatio/coniugatio: ',$value) ) ) else ()
        case "def_dom" return if ($value ne '') then ( 
                switch ($value)
                case 'astr' return map:entry($parameter,'astronomia')
                case 'math' return map:entry($parameter,'mathematica')
                case 'geom' return map:entry($parameter,'geometria')
                case 'phil' return map:entry($parameter,'philosophia')
                case 'theol' return map:entry($parameter,'theologia')
                case 'mus' return map:entry($parameter,'musica')
                case 'gram' return map:entry($parameter,'grammatica')
                case 'rhet' return map:entry($parameter,'rhetorica')
                case 'nat' return map:entry($parameter,'natura')
                case 'med' return map:entry($parameter,'medicina')
                case 'bot' return map:entry($parameter,'botanica')
                case 'iur' return map:entry($parameter,'ius')
                case 'eccl' return map:entry($parameter,'ecclesia')
                case 'milit' return map:entry($parameter,'militaria')
                default return () ) else ()
        case "gram_etym_lang" return
        if ($value ne '')
        then (
        switch ($value)
                case 'la' return map:entry($parameter,'lingua Latina')
                case 'grc' return map:entry($parameter,'lingua Graeca')
                case 'pl-x-med' return map:entry($parameter,'lingua Polona antiqua')
                case 'hu-x-med' return map:entry($parameter,'lingua Hungarica antiqua')
                case 'it-x-med' return map:entry($parameter,'lingua Italica antiqua')
                case 'fr-x-med' return map:entry($parameter,'lingua Gallica antiqua')
                case 'other' return map:entry($parameter,'alia lingua')
                default return ()
                 ) else () 
        case "gram_etym_word" return
        if ($value ne '') then (  map:entry($parameter,concat('e voce:',$value) ) ) else ()
        case "gram_etym_glossa" return if ($value ne '') then ( map:entry($parameter,concat('voce Polona definitum: ',$value) ) ) else () 
        
        default return ()
        
        )
        
(: Prepares $filter_string to be joined with main search :)
let $filter_string := 
for $parameter in map:keys($parameters("http"))
    let $value := map:get($parameters("http"),$parameter)    
    return switch($parameter)
        case "gram_gen" return 
            switch ($value)
                case 'm' return '[ft:query(.//tei:gen,"m")]'
                case 'f' return '[ft:query(.//tei:gen,"f")]'
                case 'n' return '[ft:query(.//tei:gen,"n")]'
                default return ()
        case "gram_pos" return
                switch ($value)
                case 'n' return '[.//tei:pos/@norm eq "subst"]'
                case 'v' return '[.//tei:pos/@norm eq "v"]'
                case 'adi' return '[.//tei:pos/@norm eq "adi"]'
                case 'adv' return '[.//tei:pos/@norm eq "adv"]'
                case 'num' return '[matches(.//tei:pos , "num")]'
                case 'praep' return '[matches(.//tei:pos , "praep")]'
                case 'coni' return '[matches(.//tei:pos , "coni")]'
                default return ()
        case "gram_itype" return if ($value) then ( concat('[some $paradigm in (.//tei:iType/@norm) satisfies (matches($paradigm,"',$value,'"))]') ) else ()
        case "def_dom" return
                switch ($value)
                case 'astr' return '[.//tei:usg[@type="dom"]/@norm eq "astr"]'
                case 'math' return '[.//tei:usg[@type="dom"]/@norm eq "math"]'
                case 'geom' return '[.//tei:usg[@type="dom"]/@norm eq "geom"]'
                case 'phil' return '[.//tei:usg[@type="dom"]/@norm eq "phil"]'
                case 'theol' return '[.//tei:usg[@type="dom"]/@norm eq "theol"]'
                case 'mus' return '[.//tei:usg[@type="dom"]/@norm eq "mus"]'
                case 'gram' return '[.//tei:usg[@type="dom"]/@norm eq "gram"]'
                case 'rhet' return '[.//tei:usg[@type="dom"]/@norm eq "thet"]'
                case 'nat' return '[.//tei:usg[@type="dom"]/@norm eq "nat"]'
                case 'med' return '[.//tei:usg[@type="dom"]/@norm eq "med"]'
                case 'bot' return '[.//tei:usg[@type="dom"]/@norm eq "bot"]'
                case 'iur' return '[.//tei:usg[@type="dom"]/@norm eq "iur"]'
                case 'eccl' return '[.//tei:usg[@type="dom"]/@norm eq "eccl"]'
                case 'milit' return '[.//tei:usg[@type="dom"]/@norm eq "milit"]'
                default return ()
        case "gram_etym_lang" return
        switch ($value)
                case 'la' return '[.//tei:etym[./tei:mentioned/@xml:lang eq "la"]|.//tei:etym[./tei:mentioned/@xml:lang eq "la-x-cla"]]'
                case 'grc' return '[.//tei:etym[./tei:mentioned/@xml:lang eq "grc"]]'
                case 'pl-x-med' return '[.//tei:etym[./tei:mentioned/@xml:lang eq "pl-x-med"]]'
                case 'hu-x-med' return '[.//tei:etym[./tei:mentioned/@xml:lang eq "hu-x-med"]]'
                case 'it-x-med' return '[.//tei:etym[./tei:mentioned/@xml:lang eq "it-x-med"]]'
                case 'fr-x-med' return '[.//tei:etym[./tei:mentioned/@xml:lang eq "fr-x-med"]]'
                case 'other' return '[.//tei:etym[./tei:mentioned/@xml:lang eq "other"]]'
                default return ()
        case "gram_etym_word" return if ($value) then ( concat('[ft:query(.//tei:etym,"',$value,'")]') ) else ()
        case "gram_etym_glossa" return if ($value) then (concat('[ft:query(.//tei:gloss,"',$value,'")]') ) else ()
        default return ()
return map {"filter_string" := string-join($filter_string), "filter_criteria" := $filter_criteria}
};
(: Wyszukiwanie zaawansowane: kryteria wyszukiwania - fraza :)

(: Wyszukiwanie zaawansowane: kryteria wyszukiwania - filtry :)
declare
%templates:wrap
function views:search_criteria_print ( $node as node(),$model as map(*) ) {
let $filter_criteria := $model("filter_criteria")
return
if (count($filter_criteria) > 0 ) then (
<div class="disamb-criteria">
                    <fieldset>
                        <legend>Kryteria wyszukiwania</legend>
                        <div class="row">
                            
               {         
for $key in map:keys($filter_criteria)
return
<div class="small-6 columns disamb-criteria-item">
<span class="label">{$key}</span>   {map:get($filter_criteria,$key)}
</div>
}</div>
                    </fieldset>
                </div>)
                else ()
};

(: Wyszukiwanie zaawansowane: kryteria wyszukiwania - wyrażenie :)
declare
%templates:wrap
function views:search_phrase_print ( $node as node(),$model as map(*) ) {
let $what := $model("query.what")
let $wheres_map := $model("query.where")
           
            
return 
    if ( $what )
    then (
    "Poszukiwany ciąg ",
        <span class="label secondary">
            <strong>{$model("query.what")}</strong>
        </span>,
     " w " ,
                    for $where in map:keys($wheres_map)
                        return
                        <span class="label">{map:get($wheres_map,$where)}</span>
                    ) else ( )
     };

(:Lista wyników: drukowanie:)
declare 
%templates:wrap
%templates:default("start",1)
function views:results_print($node as node(), $model as map(*) , $start as xs:string*, $lang) {
    let $start := xs:integer($start)
    let $what := $model("query.what")
    let $filter_string := $model("filter_string")
    (:let $where := request:get-parameter("where[]",()):)  
    (:Miejsce użytkownika na liście wyników:)
    let $how_much := 10 (: Ile rezultatów pokazywać? :)
    let $results := $model("results_main")
    let $counter := count($results)
    let $how_much_displayed := count (subsequence ( $results, $start, $how_much ) ) (:Ile wyników może rzeczywiście wyświetlić:)
    return (
        (: No criteria defined :)
        if ( not($what) and not($filter_string) )
        then ( 
        <div class="row small-8 columns alert-box warning" id="disamb_message_nocriteria">You have specified no criteria for your query.<br/> Please specify search criteria on the <a href="advancedBrowse.html">Advanced Browse page</a>
        </div>
        )
        else (
        if ( $counter>0 ) 
        then (
        <div class="alert-box success" id="disamb_message">
                {concat(' ' , i18n:text($node,$model,"advancedDisamb.results.header.after",$lang) ) }
        </div>,
        
        <ul class="small-block-grid-1"> {
            for $entry in subsequence ( $results, $start, $how_much )
            let $lemma := string-join($entry/@n)
            let $excerpt := if ($entry//tei:def[1]) then ( substring( string-join ($entry//tei:def[1], ', '), 0, 75 ) ) else ()
            let $expanded := util:expand($entry)
            return (
            <li>
                    <div class="advDisamb_entry panel">{views:lemma_link($node,$model,$lemma,"rewrite")}
                        <span class="advDisamb_entry_excerpt_text">{$excerpt}</span>
                        <!-- <div class="advDisamb_entry_hit"><small>{kwic:summarize($entry, <config width="40"/>)}</small></div>-->
                        <ul class="advDisamb_entry_hit_list single_list">
                        {for $hit in $expanded//exist:match
                            let $hit_length := kwic:string-length($hit)
                            return 
                            <li class="advDisamb_entry_hit">
                                <span class="previous">{kwic:truncate-previous($expanded, $hit, '',  50 , $hit_length , ())}</span>
                                <span class="hit" style="color:red;">{$hit}</span>
                                <span class="following">{kwic:truncate-following($expanded, $hit, '',  50 , $hit_length , ())}</span>
                                
                            </li>
                        }
                        </ul>
                    </div>
                </li>) }
       </ul>,
       
       <ul class="button-group centered-468px">{
       (: Przycisk "mniej" :)
       (if ( subsequence ( $results, 0, $start ) )
        then (<li><a class="more_button button no-margin" href="{escape-html-uri(concat('advancedDisamb.html','?','start=', $start - $how_much))}"><i class="fa fa-angle-double-left"/>{concat(' ', i18n:text($node,$model,"global.Previous",$lang)) }</a></li>)
        else()
        ),
        (: Licznik wyników :)
        (<li><a class="more_button button no-margin">{$start} - {$start + $how_much_displayed - 1} / {$counter}</a></li>),
       (: Przycisk "więcej" :)
        (if ( count ( $results ) >= $start + $how_much ) 
        then (<li>
            <a class="more_button button no-margin" 
            href="{escape-html-uri(concat('advancedDisamb.html','?','start=', $start+$how_much))}">
            { concat ( i18n:text($node,$model,"global.Next",$lang) , ' ' ) } 
            <i class="fa fa-angle-double-right"></i>
            </a>
            </li>)
        else(
        )
        )
        }</ul>,
        <hr/>,
                (:<ul class="button-group">
                    <li>
                        Wyników na stronie: 
                    </li>
                    <li>
                        <a class="more_button button tiny deploy no-margin" href="#">10</a>
                    </li>
                    <li>
                        <a class="more_button button tiny deploy no-margin" href="#">25</a>
                    </li>
                    <li>
                        <a class="more_button button tiny deploy no-margin" href="#">50</a>
                    </li>
                    <li>
                        <a class="more_button button tiny deploy no-margin" href="#">100</a>
                    </li>
                </ul>,:)
        <p class="hide">{$model("variables")}</p>
        
        )
        else (
       (:$model:)
       response:redirect-to(xs:anyURI (concat("disambHomonyms.html?what=",encode-for-uri(request:get-parameter("what",())) ) ))
        )
        
        (:Brak rezultatów, przekierowanie:)
) )
};

(:System fasetów: ekstrakcja:)
declare function local:facets_extraction ($node as node(),$model as map (*)) {
let $tree := $model("results_main")
(: Paradygmat :)
let $paradygmat := map:new (
    let $paradygmat_values := distinct-values($tree//tei:iType/@norm)
    for $each_value in $paradygmat_values return map:entry($each_value,count($tree//tei:iType[@norm = $each_value])))
(: Część mowy :)
let $pos := map:new (
    let $pos_values := distinct-values($tree//tei:pos/@norm)
    for $each_value in $pos_values return map:entry($each_value,count($tree//tei:pos[@norm = $each_value])) )
(: Rodzaj :)
let $rodzaj := map:new (
    let $rodzaj_values := distinct-values($tree//tei:gen)
    for $each_value in $rodzaj_values return map:entry($each_value,count($tree//tei:gen[. = $each_value])) )

let $facets-all := map {"paradigm" := $paradygmat, "pos" := $pos, "gender" := $rodzaj}
let $FACETS := session:set-attribute("RESULTS.facets",$facets-all) 
return ($facets-all)
};

(:System fasetów: drukowanie:)
declare %templates:wrap function views:facets_print($node as node(), $model as map(*),$start, $lang as xs:string?) {
(: Określa, czy strona zostaje przywołana jako wynik wyszukiwania czy tylko na skutek przeładowania fasetów (action="refine"):)
    let $action := request:get-parameter("action",())
    let $page_ref := request:get-header("Referer")
    (:Checks if request has been made from the orginal search page or disambHomonyms.html :)
    let $if_advancedBrowse := xs:boolean(matches($page_ref,'advancedBrowse|disambHomonyms'))
    let $results := if ($action eq 'refine')  then(session:get-attribute("RESULTS:results")) 
        else (
        if ( not($model("filter_string")) and not($model("query.what")) )
        then ()
        else ( $model("results_main") )
        )
    let $facets:= if( $results  ) then (local:facets_extraction($node,$model)) else  (session:get-attribute("RESULTS.facets"))
    let $how_much_facets := 3 (: Ile fasetów wyświetlać? :)
    
return (
if ($action eq 'refine')  then() else()
,
if ( count($results) > 0)
then (
    <div class="row">
        <div class="small-12 columns" id="disamb_sidebar_title">
            <div class="panel"><h5>{i18n:text($node,$model,"advancedDisamb.sidebar.header",$lang)}</h5></div>
        </div>
    </div>,
   
  
    for $key in map:keys($facets)
        let $this_facet_map := map:get($facets,$key) (: Mapa pojedynczego fasetu :)
    
        return if (count($this_facet_map)>0) (: Sprawdź czy mapa zawiera informację o fasetach :)
    
        then (
    
    <div class="row">
        <div class="small-12 columns advDisamb_sidebar_criterion">
            <div class="panel">
            <h6 class="alert-box secondary">
            {i18n:text($node,$model,concat('global.',$key),$lang)}
            </h6>
        <ul class="sidebar_list">{
            let $keys_ordered := 
                for $key1 in map:keys($this_facet_map)
                order by number(map:get($this_facet_map,$key1)) descending
                return $key1
            
            for $key1 at $position in $keys_ordered
            where $position <= $how_much_facets
            return
            
            <li>
                <!--<input name="where[]" value="lemma" checked="checked" type="checkbox">-->
                <label class="advDisamb_sidebar_criterion_label">
                    <a href="#">{$key1}</a>
                <span> [{map:get($this_facet_map,$key1)}]</span>
                </label>
           </li>}
        </ul>
        <!--<h4 class="hidden js-remove-hidden_f"><small><a href="#" class="expand-next-sidebar_f">Więcej kryteriów [4]</a></small></h4>
                        <ul class="sidebar_list sidebar-hidden_f">
                            <li>
                                <input name="where[]" value="lemma" checked="checked" type="checkbox"><label><a href="#">celownik</a> [2247]</label>
                            </li>
                            <li>
                                <input name="where[]" value="lemma" checked="checked" type="checkbox"><label><a href="#">biernik</a> [220]</label>
                            </li>
                            <li>
                                <input name="where[]" value="lemma" checked="checked" type="checkbox"><label><a href="#">narzędnik</a> [220]</label>
                            </li>
                            <li>
                                <input name="where[]" value="lemma" checked="checked" type="checkbox"><label><a href="#">miejscownik</a> [220]</label>
                            </li>
                        </ul> -->
                        <!-- Ewentualny przycisk zatwierdzania filtru i przeładowania strony -->
          <!--              <a href="#" class="button tiny panel-filter-button">Filtruj</a> -->
        </div>
        </div>
    </div>
    )
    else ()
    )
    
    else () 
    
    )
};

declare function views:fontes_search () {
let $filter_siglum := if ( normalize-space( request:get-parameter("filter_siglum",()) ) ne '' ) then ( normalize-space( request:get-parameter("filter_siglum",()) ) ) else ( '' )
let $filter_auctor := if ( normalize-space( request:get-parameter("filter_auctor",()) ) ne '' ) then ( normalize-space( request:get-parameter("filter_auctor",()) ) ) else ( '' )
let $filter_titulus := if ( normalize-space( request:get-parameter("filter_titulus",()) ) ne '' ) then ( normalize-space( request:get-parameter("filter_titulus",()) ) ) else ( '' )
let $filter_genus := if ( normalize-space( request:get-parameter("filter_genus",()) ) ne '' ) then ( normalize-space( request:get-parameter("filter_genus",()) ) ) else ( '' )

let $results := 
    if (  $filter_siglum ne '' or $filter_auctor ne '' or $filter_titulus ne '' or $filter_genus ne '' )
    then ( 
    doc("/db/apps/lexicon/resources/data/helper/fontes.xml")//tei:bibl[matches(tei:title[@type='abbr'] , $filter_siglum , "i" )][matches (tei:author , $filter_auctor, "i" )][ matches(tei:title[not(@type='abbr')] , $filter_titulus, "i" ) ][ matches (tei:note[@type="text_type"] , $filter_genus , "i") ]
    )
    (: No criteria specified :)
    else ()
    return map {"results.fontes" := $results}
    };

declare function views:fontes_print ($result) {
let $siglum := $result/tei:title[@type = 'abbr']/text()
let $auctor := $result/tei:author/text()
let $titulus := $result/tei:title[not(@type = 'abbr')]/text()
let $tempus_from := $result/tei:date/@from
let $tempus_to := $result/tei:date/@to
let $tempus := concat (if ($tempus_from ne '') then ($tempus_from) else (), if ($tempus_from ne '' and $tempus_to ne '') then (' - ') else (), if ($tempus_to ne '') then ($tempus_to) else () )
let $genus := $result/tei:note[@type = 'text_type']/text()
let $editor := $result/tei:editor/text()
let $biblio := $result/tei:note[@type = 'biblio']/text()
let $excerpsit := $result/tei:note[@type = 'excerpsit'  ]/text()
let $www := $result/tei:ref[@type = 'url'][not(matches(normalize-space(.),'BRAK|-'))]/text()

let $results := <div class="fontes_result">
								<div class="large-2 columns">
									<a href="#">
										<h3>{$siglum}</h3>
									</a>
								</div>
								<div class="large-10 columns">
									<div class="row">
										<div class=" large-9 columns">
											<h4>{$auctor}</h4>
											<h5><em>{$titulus}</em></h5>
											<p>
											{if ($tempus) then (<span class="label">Tempus: {$tempus}</span>) else ()}
											{if ($genus) then (<span class="label">Genus: {$genus}</span>) else ()}											
											</p>
										</div>
										
										{if ($www) then (
										<div class=" large-3 columns">
											<a href="{$www}" class="button expand medium" target="_blank"><span>WWW</span> </a>
										</div>
										) else ()}
										
										<div class="row">
											<div class=" large-9 columns">
												<ul class="large-block-grid-2">
													<li>
														<ul>
														{if ($editor) then (<li><strong>Edidit:</strong> {$editor}</li>) else () }
														{if ($biblio) then (<li><strong>Bibliographica:</strong> {$biblio}</li>) else () }
													   </ul>
													</li>
													{if ($excerpsit) then (<li>
														<ul>
															<li><strong>Excerpsit: </strong> {$excerpsit}</li>
														</ul>
													</li>) else () }
													
												</ul>
											</div>
										</div>
									</div>
								</div>
								<hr/>
								</div>
return $results
};

declare %templates:wrap function views:fontes_container ($node as node()*, $model as map(*)* ) {
let $results := views:fontes_search()

return
    <div class="row">
    {
    if (count($results("results.fontes")) > 0) then (
    for $result in $results("results.fontes")
    return views:fontes_print( $result )
    ) else (
    )
    }
    </div>
};

declare function views:tooltip ($node as node()*, $model as map (*), $text as xs:string, $lang as xs:string, $id as xs:string? ) {
let $hint_text := i18n:text( $node, $model, $text, $lang)
return 
    <span class="has-tip" title="{$hint_text}" id="{$id}">
        <i class="fa fa-info-circle" />
    </span>
};

declare function views:tooltip_custom ($node as node()*, $model as map (*), $type as xs:string, $lang as xs:string ) {
    switch ($type)
        case ("advanced_search_info_panel") return (
                                       <div class="row" id="advanced_search_info_panel">
                                        <div class="small-6 columns">
                                            <small>By default full matching is performed. If you wish to look up for partial matches, you need to use wildcards:</small>
                                            <ul>
                                                <li>
                                                    <small>* (asterisk) - replaces any number of characters</small>
                                                </li>
                                                <li>
                                                    <small>? (question mark) - replaces one character</small>
                                                </li>
                                            </ul>
                                        </div>
                                        <div class="small-6 columns">
                                            <span class="label">Examples</span>
                                            <ul>
                                                <li>
                                                    <small>
                                                        <strong>*GER</strong> will yield ARMIGER, AGER etc.; <strong>GER*</strong> will yield both GERO and GERUNDIUM etc.</small>
                                                </li>
                                                <li>
                                                    <small>
                                                        <strong>?GER</strong> will yield AGER, but not ARMIGER; <strong>GER?</strong> will yield GERO, but not GERUNDIUM</small>
                                                </li>
                                                <li>
                                                    <small>
                                                        <strong>?GER*</strong> will yield AGER, AGERACIO, but not ARMIGER</small>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
        )
        default return ()
};