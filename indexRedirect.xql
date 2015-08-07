xquery version "3.0";
import module namespace search="http://scriptores.pl/lexicon/search" at "xmldb:exist:///db/apps/lexicon/modules/moje/search.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://scriptores.pl/lexicon/config" at "xmldb:exist:///db/apps/lexicon/modules/config.xqm";
import module namespace helper= "http://scriptores.pl/lexicon/helper" at "xmldb:exist:///db/apps/lexicon/modules/moje/helper.xql" ;

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

(: Pobiera zapytanie ze strony głównej i sprawdza, czy hasło istnieje w słowniku:)


(: Pobranie i normalizacja zapytania :)
let $what := search:normalize_advanced( request:get-parameter("what",()) )
let $uri := concat( encode-for-uri($what),'')
(:let $currentPath := then (response:redirect-to(xs:anyURI (concat(helper:rewrite-rel((),(), concat("lemma/",$what), "linkWithLang", (),(),()),$uri) )) ):)


(: Sprawdza czy lemmat znajduje się w słowniku :)
let $iflemma := if ($what ne '') then ( search:lemma($what) ) else ()
let $currentUrl := helper:rewrite-rel((), (), (), 'linkWithLang', (),(),());

(: Przekierowanie ze strony głównej: 1. strona hasła; 2. strona dezambigwacji. :)
   return (session:set-attribute('QUERY.what',$what) ,
   if ($iflemma)
   then (
        if(count($iflemma) = 1)
        (: Strona pojedynczego hasła :)     
        then (response:redirect-to(xs:anyURI (  "lemma/aqua" ) ) )
        (:then (response:redirect-to(xs:anyURI (concat("../lemma/",$uri) )) ):)
        (: Strona wyboru z kilku haseł" :)
        else (response:redirect-to(xs:anyURI (concat("disambHomonyms.html?what=",$uri) ) ) )
        
   )
   else if ($what ne '')
    (: Fraza istnieje, brak lemmatu :)
    then ( response:redirect-to (xs:anyURI ( concat("disambHomonyms.html?what=",$uri ) ) ) ) 
    (: Fraza nie istnieje :)
    else (response:redirect-to(xs:anyURI ( "/") ) ) 
    )