xquery version "3.0";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
import module namespace search="http://scriptores.pl/lexicon/search" at "modules/moje/search.xql";
import module namespace views="http://scriptores.pl/lexicon/views" at "modules/moje/views.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://scriptores.pl/lexicon/config" at "xmldb:exist:///db/apps/lexicon/modules/config.xqm";

let $results := views:fontes_container((),())
return $results