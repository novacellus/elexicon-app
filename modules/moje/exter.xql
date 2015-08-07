xquery version "3.0";

module namespace exter = "http://scriptores.pl/lexicon/exter";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://scriptores.pl/lexicon/config" at "xmldb:exist:///db/apps/lexicon/modules/config.xqm";

(: External resources to be embedded in dictionary interface :)
(: 1. Linkowanie :)
(: A. Korpusy :)

declare variable $exter:lemma := translate(request:get-parameter("what",()), ',', '' );

(: Creates external resource's link based on word which is being looked up ($lemma) and resource's name ($which):)
declare function exter:link($node,$model,$which,$how) {
switch ( $which )
    (: Dictionaries (display, ie. class, depends on page url :)
    case 'georges' return <a title="" target="_blank" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }" href="{concat('http://www.zeno.org/Zeno/0/Suche?q=',$exter:lemma,'&#38;k=Georges-1913')}">Georges</a>
    case 'ducange' return <a title="" target="_blank" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }" href="{concat('http://ducange.enc.sorbonne.fr/',$exter:lemma)}">DuCange</a>
    case 'logeion' return <a title="" target="_blank" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }" href="{concat('http://logeion.uchicago.edu/index.html#',$exter:lemma)}">Logeion</a>
    case 'gaffiot' return <a title="" target="_blank" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }" href="{concat('http://www.lexilogos.com/latin/gaffiot.php?q=',$exter:lemma)}">Gaffiot</a>
    case 'ngml' return <a title="" target="_blank" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }" href="{concat('http://scriptores.pl/ngml/search?keyword=',$exter:lemma)}">NGML</a>    
    (: Corpora :)
    case 'perseus' return <a title="" target="_blank" href="{concat('http://perseus.uchicago.edu/cgi-bin/philologic/search3t?dbname=LatinAugust2012&#38;word=',$exter:lemma)}" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }">Perseus @ Philologic</a>
    case 'mgh' return <a title="" target="_blank" href="{concat('http://www.dmgh.de/de/fs1/search/query.html?fulltext=',$exter:lemma,'&#38;text=true')}" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }">MGH</a>
    case 'fontes' return <a title="" target="_blank" href="{concat('http://scriptores.pl/fontes',$exter:lemma)}" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("button small radius expand") }">Fontes</a>
    case 'ccorporum' return <a title="" target="_blank" href="{concat('http://www.mlat.uzh.ch/MLS/advsuchergebnis.php?mode=SPH_MATCH_EXTENDED2','&#38;corpus=all&#38;','suchbegriff=',$exter:lemma)}" class="{if ($how eq 'link') then ("disamb_sidebar_external_link") else("small button radius expand") }">C. Corporum</a>
    (: Internet :)
        case 'archive' return <a title="" target="_blank" href="{concat('https://openlibrary.org/search/inside?q=',$exter:lemma)}">archive.org</a>
        case 'googleb' return <a title="" target="_blank" href="{concat('https://www.google.pl/search?tbm=bks&#38;q=',$exter:lemma)}">Google Books</a>
    default return ''
};