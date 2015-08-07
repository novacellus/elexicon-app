xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq "/") then
    (: forward root path to index.html :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="index.html">
                <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
    </dispatch>

else if (ends-with($exist:resource, ".xql")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{$exist:resource}"/>
    </dispatch>

else if (ends-with($exist:resource, "singleView.html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{$exist:resource}">
           <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>


(:else if (ends-with($exist:resource, "advancedDisamb.html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{$exist:resource}"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
:)
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{$exist:resource}">
           <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
    



else if (matches($exist:path, "/resources/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/{substring-after($exist:path,'resources/')}"/>
    </dispatch>

else if (matches($exist:path, "^/[a-z]{2}(/)*$")) then
let $path := tokenize($exist:path, "/")    
    let $language := translate($path[2], '/', '')
    return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/index.html">
                       <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
                    </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql" absolute="yes">
                        <add-parameter name="lang" value="{$language}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/html/errors/lacking-lemma.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
                </dispatch>

else if (matches($exist:path, "/[a-z]{2}/[a-z]+(/)*") and not (matches ($exist:controller, 'resources')) ) then
    let $path := tokenize($exist:path, "/")
    (: 
    $path[1] = ""
    $path[2] = "/en"
    $path[3] = "/lemma"
    $path[4] = "/aqua"
    :)
    
    let $language := translate($path[2], '/', '')
    let $target := translate($path[3], '/', '')
   
    
    return
    switch ($target)
        case ("fontes")
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                   <forward url="{$exist:controller}/fontes.html">
                   <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
                    </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql" absolute="yes">
                        <add-parameter name="lang" value="{$language}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
                </dispatch>
        
        case ("quaere")
            return
                let $stage := translate($path[4], '/', '')
                let $lemma := translate($path[5], '/', '')
                return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/{
                    if ($stage eq 'disamb') then (
                        if ($lemma eq '') then ("advancedBrowse.html") else ("disambHomonyms.html")
                        )
                    else if ($stage eq 'solut') then ("advancedDisamb.html")
                    else ("advancedBrowse.html")}">
                       <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
                    </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql" absolute="yes">
                        <add-parameter name="lang" value="{$language}"/>
                        <add-parameter name="what" value="{$lemma}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
                </dispatch>
                
        case ("lemma")
            return
                let $lemma := translate($path[4], '/', '')
                return (
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/singleView.html">
                       <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
                    </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql" absolute="yes">
                        <add-parameter name="lang" value="{$language}"/>                 
                        <add-parameter name="what" value="{$lemma}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/html/errors/lacking-lemma.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
                </dispatch> )
        
        case ("meta")
            return
               let $page := translate($path[4], '/', '')
               return (
               <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/html/meta/{concat($page,".html")}">
                       <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
                    </forward>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql" absolute="yes">
                            <add-parameter name="lang" value="{$language}"/>                 
                            <add-parameter name="what" value="{$page}"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/html/errors/lacking-lemma.html" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch> )
         
        default return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <redirect url="{$exist:controller}/index.html">
                        <set-header name="Cache-Control" value="no-cache, no-store, max-age=0, must-revalidate"/>
                    </redirect>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </view>
                </dispatch>

(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <error-handler>
                <forward url="index.html" method="get"/>
               (:<forward url="{$exist:controller}/modules/view.xql"/>:)
          </error-handler>
    </dispatch>