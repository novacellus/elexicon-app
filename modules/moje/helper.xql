xquery version "3.0";


module namespace helper="http://scriptores.pl/lexicon/helper";

import module namespace i18n = "http://scriptores.pl/lexicon/i18n" at "xmldb:exist:///db/apps/lexicon/modules/moje/i18n.xql" ;
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://scriptores.pl/lexicon/config" at "xmldb:exist:///db/apps/lexicon/modules/config.xqm";
import module namespace helper= "http://scriptores.pl/lexicon/helper" at "xmldb:exist:///db/apps/lexicon/modules/moje/helper.xql" ;

(: Reads parameters, sets parmeters, writes to session :)
declare %templates:wrap %templates:default("lang","pl") function helper:current_page($node as node(), $model as map(*),  $lang as xs:string) {
    let $parameters := helper:read_parameters($node,$model)
    return (
    (:  Sets language to session :)
        if ( $lang ) then (
            session:set-attribute ("lang", $lang ) 
        ) 
        else (),
    
    map { "http" := $parameters("http"), "session" := $parameters("session")
    }
    )
};

declare function helper:read_parameters ($node as node(), $model as map(*)) {

(:POST/GET attributes:)
let $http_names := request:get-parameter-names()
let $http_parameters := map:new(for $name in $http_names
return map:entry($name , request:get-parameter($name,())) )

(:Session attributes:)
let $session_names := session:get-attribute-names()
let $session_parameters := map:new (for $name in $session_names
return map:entry($name, session:get-attribute ($name)) )

return map {"http" := $http_parameters, "session" := $session_parameters}

};

(: Prints out language menu :)
declare %templates:wrap %templates:default("lang","pl") 
function helper:language_menu ( $node as node(), $model as map (*), $lang as xs:string ) {
   
   (: Map to store language data :)
    let $languages := map {
        "de" := map {"full" := 'Deutsch', "short" : = "de", "img" := ''},
        "en" := map {"full" := 'English', "short" : = "en", "img" := ''},
        "fr" := map {"full" := 'Français', "short" : = "fr", "img" := ''},
        "pl" := map {"full" := 'Polski', "short" : = "pl", "img" := ''},
        "la" := map {"full" := 'Latina', "short" : = "la", "img" := ''}
    }
    (:let $lang_active := if ( $model("current.lang") ) then (  $model("current.lang") ) else ('pl'):)
    let $link := helper:save_params($node,$model,'lang') (: Reads and copies GET parameters :)
    let $operator := if ( $link ne '' ) then ('&amp;') else '?'
        
    return
    <li class="has-dropdown menu_language not-click">
        <!--Current language-->
        <a href="{concat($link,$operator,"lang=",$lang)}">
           <span class="active_lang">{$languages($lang)("short")}</span>
        </a> 
        <ul class="dropdown">
        <!-- Not-current languages -->
            {for $language in map:keys($languages) return
            if ($language = $lang) then ()
            else (<li>
            <!-- Rewrite approach -->
            <a class="active_lang" href="{helper:rewrite-rel($node,$model,(),"language-change",$language,$lang,())}">
             {$languages($language)("short")} ({$languages($language)("full")})
            </a>
           <!-- (:Previous approach:)
            <a class="active_lang" href="{concat($link,$operator,"lang=",$language)}">
            {$languages($language)("short")} ({$languages($language)("full")}) 
            </a> -->
            </li>)
            }
            </ul>
    </li>
};

(: Saves params from current request to form a language link :)
declare %templates:wrap %templates:default("lang","pl") function helper:save_params ( $node as node(), $model as map(*) , $omit ) {


    let $param_tree :=
        for $param in request:get-parameter-names()
        return
        if ($param = $omit) then () else (
        for $value in request:get-parameter($param,())
        return
        <param value="{$value}">{$param}</param>
        )
   
let $string_seq :=
    for $param at $count in $param_tree
    return
        if ( $count = 1 ) 
        then ( concat ( '?' , $param/text() , '=' , $param/@value  ) ) 
        else ( concat ( '&amp;' , $param/text(), '=' , $param/@value , '')  )  

let $string := string-join($string_seq,'')

return $string

};

(:Various helpful functions: print etc. :)
declare function helper:session_print ( $node as node(), $model as map (*) ) {
       for $name in session:get-attribute-names()
       return (<p><span>{$name}: </span>
              <span>"{session:get-attribute($name)}"</span></p>
              )
};

declare function helper:rewrite-rel ( $node as node()*, $model as map (*)*, $url as xs:string?, $mode as xs:string?, $toWhichLang as xs:string?, $lang as xs:string?, $text as xs:string? ) {
    (: Computation depends on server proxying:)
    (: App path after proxying: HOST/ROOT/en... :)
    let $app_proxied_root := "elexicon"
    let $app_proxied_root_string := "/elexicon/"
    
    (: App name before proxying :)
    let $app_name := "lexicon"
    (: URL before server proxying :)
    let $currentURL := request:get-url()
    (: App path: URL = HOST:8080/../$app_name/$path :)
    let $currentURLPath := substring-after($currentURL, concat( $app_name, "/")) 
    (: concat(request:get-url(), '+', request:get-uri(), '+' , $config:app-root ) --> current="http://localhost:8080/exist/apps/lexicon/en/+/exist/apps/lexicon/en/+/db/apps/lexicon" :)
    (: Path without language code:)
    let $lang_strippedURLPath := substring-after($currentURLPath, concat($lang, "/"))
    
    let $attrs := <attrs>{
        for $attr in $node/@*[not(starts-with(name(.),"data"))]
        return <attr>{$attr}</attr>
                }</attrs>
    
    let $content := $node/node()
    
    return
        if ($mode eq "language-change") then (
        (: Returns only reload link :)
            concat($app_proxied_root_string, $toWhichLang, "/", $lang_strippedURLPath)
        )
        else if ($mode eq "linkWithLang") then (
            concat($app_proxied_root_string,$lang,"/")
        )
        else (
        element {name($node)} {
            (: Copy attributes :)
            for $attr at $x in $attrs/node()
                return attribute {name($attr/@*)} {$attr/@*},
            attribute href {concat($app_proxied_root_string,$lang,"/",$url)},
            if ($text) then (i18n:text($node,$model,$text,$lang) ) else (),
            $content
        }
        )
};